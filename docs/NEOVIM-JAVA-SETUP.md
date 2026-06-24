# Neovim + Java Setup (nixvim + nvim-java)

This document explains how Neovim is configured via nixvim with integrated Java development support using nvim-java, and calls out the non-obvious parts that are easy to break.

## Overview

Neovim is configured entirely through nixvim (a flake input), which generates a Neovim configuration from Nix expressions. The Java tooling is a hybrid: nixvim manages the jdtls LSP server, while nvim-java provides higher-level commands (run main, run/debug tests, refactor). Making these two cooperate requires monkey-patching at Lua init time.

Configuration lives in `users/flur/programs/nvim.nix`.

## How nixvim integrates with the flake

nixvim is imported as a flake input and used as a home-manager module (`programs.nixvim`). It generates `init.lua` and installs all declared plugins and LSP servers into the Nix store. The key line:

```nix
nixpkgs.source = inputs.nixpkgs;
```

This pins nixvim's internal nixpkgs to the same nixpkgs the rest of the system uses, avoiding version mismatches.

## Java-specific setup

### Packages provided by Nix

All Java tooling is supplied via `extraPackages` (on `$PATH` at runtime) and `extraPlugins` (Vim plugins loaded at startup):

- `jdk25` -- the JDK itself
- `jdt-language-server` -- Eclipse JDT Language Server binary
- `vscode-extensions.vscjava.vscode-java-debug` -- DAP adapter JARs
- `vscode-extensions.vscjava.vscode-java-test` -- test runner JARs
- `nvim-java`, `nvim-java-core`, `nvim-java-test`, `nvim-java-dap`, `nvim-java-refactor` -- the nvim-java plugin family
- `lua-async` -- async runtime dependency of nvim-java

### jdtls LSP configuration

jdtls is declared as a nixvim LSP server (`plugins.lsp.servers.jdtls`). The critical part is `init_options.bundles`, which injects the debug and test extension JARs:

```nix
jdtls = {
  enable = true;
  extraOptions = {
    init_options = {
      bundles.__raw = ''
        vim.tbl_flatten({
          vim.split(vim.fn.glob("${debugExtPath}/*.jar"), "\n", { trimempty = true }),
          vim.split(vim.fn.glob("${testExtPath}/*.jar"), "\n", { trimempty = true }),
        })
      '';
    };
  };
};
```

`debugExtPath` and `testExtPath` are Nix store paths resolved at build time. The `__raw` escape tells nixvim to emit this as literal Lua rather than serializing it as a Nix value.

**What the bundles enable:** Without these JARs, jdtls is a plain language server (completions, diagnostics, go-to-definition). The debug bundle adds DAP support (breakpoints, step-through, variable inspection). The test bundle adds test discovery and execution. Both are required for the `JavaTestRun*` and `JavaTestDebug*` commands to work.

## The monkey-patching (extraConfigLuaPre)

nvim-java expects to manage its own jdtls installation and LSP attachment. Since Nix already handles both, two of nvim-java's subsystems must be disabled at Lua level before `require('java').setup()` runs:

```lua
-- 1. Disable package manager downloads
local Manager = require('pkgm.manager')
Manager.install = function(self, name, version)
  return ""
end

-- 2. Disable nvim-java's own LSP setup
local lsp_setup = require('java.startup.lsp_setup')
lsp_setup.setup = function(_) end
```

### Why patch 1 is needed (pkgm.manager)

nvim-java bundles a package manager (`pkgm`) that downloads jdtls, debug adapters, and test runners from the internet at first launch. On NixOS this would fail (no `curl`/`wget` in the sandbox, read-only store paths). The patch replaces `Manager.install` with a no-op so nvim-java thinks everything is already installed. The actual binaries come from `extraPackages`.

### Why patch 2 is needed (lsp_setup)

Without this patch, nvim-java would call `vim.lsp.start()` for jdtls with its own configuration, creating a second jdtls instance that races with the one nixvim already starts via `plugins.lsp.servers.jdtls`. Symptoms of a missing patch: duplicate diagnostics, double completions, high memory usage from two JVMs. The patch makes `lsp_setup.setup` a no-op so nixvim is the sole owner of the jdtls lifecycle.

### After patching, setup runs normally

```lua
require('java').setup({
  jdk = { auto_install = false },
  java_test = { enable = true },
  java_debug_adapter = { enable = true },
})
```

This registers nvim-java's commands (`:JavaRunnerRunMain`, `:JavaTestRunCurrentClass`, etc.) and hooks them into the jdtls instance that nixvim manages.

## How nixvim and nvim-java coordinate

The division of responsibility:

| Concern | Owner |
|---|---|
| jdtls binary on PATH | Nix (`extraPackages`) |
| jdtls LSP lifecycle (start, attach, config) | nixvim (`plugins.lsp.servers.jdtls`) |
| Debug/test JAR bundles | Nix store paths injected via `init_options.bundles` |
| DAP adapter registration | nvim-java (`java_debug_adapter.enable`) |
| Test discovery and execution commands | nvim-java (`java_test.enable`) |
| Refactoring commands | nvim-java (`nvim-java-refactor` plugin) |

The `extraConfigLuaPre` block runs before nixvim configures LSP, so the patch order is: disable nvim-java's installer -> disable nvim-java's LSP setup -> run nvim-java's `setup()` (registers commands only) -> nixvim starts jdtls with the bundled JARs.

## Known fragility points

### nvim-java internal API changes

The patches target `pkgm.manager` and `java.startup.lsp_setup` by module path. If nvim-java renames these modules or changes the function signatures, the patches will silently break. **Symptom:** nvim-java tries to download packages (patch 1 broken) or a duplicate jdtls spawns (patch 2 broken). **Fix:** check nvim-java's source for the current module paths and update the `require()` calls.

### JAR glob paths

The debug and test extension JARs are globbed from Nix store paths:

```nix
debugExtPath = "${pkgs.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server";
```

If the upstream VSCode extension changes its directory layout, the glob will match zero JARs. **Symptom:** `:JavaTestRunCurrentClass` fails with "no debug adapter" or similar. **Fix:** `ls` the store path to find where the JARs moved.

### jdtls / JDK version mismatch

`jdt-language-server` from nixpkgs may not support the JDK version in `extraPackages` (currently `jdk25`). If jdtls doesn't support the JDK, it may fail to start or produce incorrect diagnostics. **Symptom:** jdtls crashes on attach or reports syntax errors on valid code. **Fix:** check jdtls release notes for JDK compatibility and align versions.

### Plugin load order

`extraConfigLuaPre` runs before plugin initialization. If nixvim changes when `extraConfigLuaPre` executes relative to plugin loading, the patches may run too late. This hasn't happened but is worth knowing about.

## Other notable configuration choices

### nixd LSP with flake-aware options

The nixd server is configured to resolve NixOS and home-manager options from the local flake:

```nix
options = {
  nixos.expr = "(builtins.getFlake (toString ${flakeDir})).nixosConfigurations.flurPC.options";
  home-manager.expr = "...";
};
```

This gives completions and hover docs for NixOS module options. `flakeDir` points to `~/nixos-system`.

### Runtime theme loading

Neovim loads its colorscheme at runtime from the theme switcher output:

```lua
local _theme_file = vim.fn.expand("~/.config/themes/current/nvim-theme.lua")
if vim.fn.filereadable(_theme_file) == 1 then dofile(_theme_file) end
```

This runs in `extraConfigLua` (after plugins load). If the theme file is missing, Neovim falls back to its default colorscheme silently.

### Blade filetype detection

Laravel Blade templates are detected by filename pattern (`*.blade.php -> "blade"`) using `filetype.pattern`, with a dedicated treesitter grammar and blade-formatter integration.

### Formatting strategy

`conform-nvim` handles formatting with a two-tier approach:
- Web languages: prettierd with prettier fallback (`stop_after_first = true`)
- Everything else (Nix, Rust, Go, C, Java): defers to the LSP formatter (`lsp_format = "prefer"`)
- Format-on-save with 500ms timeout and LSP fallback

### DAP keybindings

Debug Adapter Protocol is exposed through `<leader>d` prefix:
- `<leader>db` -- toggle breakpoint
- `<leader>dc` -- continue
- `<leader>dt` -- terminate
- `<leader>du` -- toggle DAP UI

### Java-specific keybindings

All under `<leader>j`:
- `<leader>jr` -- run main class
- `<leader>jt` -- run test class
- `<leader>jT` -- run test method
- `<leader>jd` -- debug test class
- `<leader>jD` -- debug test method
