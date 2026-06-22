{ pkgs, inputs, ... }:

let
  debugExtPath = "${pkgs.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server";
  testExtPath = "${pkgs.vscode-extensions.vscjava.vscode-java-test}/share/vscode/extensions/vscjava.vscode-java-test/server";
in
{
  programs.nixvim = {
    enable = true;
    nixpkgs.source = inputs.nixpkgs;

    extraPackages = [
      pkgs.gcc
      pkgs.jdk25
      pkgs.jdt-language-server
      pkgs.vscode-extensions.vscjava.vscode-java-debug
      pkgs.vscode-extensions.vscjava.vscode-java-test
    ];

    extraPlugins = with pkgs.vimPlugins; [
      mini-nvim
      lua-async
      nvim-java-core
      nvim-java-test
      nvim-java-dap
      nvim-java-refactor
      nvim-java
      vim-tmux-navigator
    ];

    # Basic settings
    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      smartindent = true;
      wrap = false;
      swapfile = false;
      backup = false;
      undofile = true;
      hlsearch = false;
      incsearch = true;
      termguicolors = true;
      scrolloff = 8;
      signcolumn = "yes";
      updatetime = 50;
      colorcolumn = "100";
      cursorline = true;
      mouse = "a";
      clipboard = "unnamedplus"; # Use system clipboard
    };

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    # LSP Configuration
    plugins.lsp = {
      enable = true;
      keymaps = {
        silent = true;
        diagnostic = {
          "[d" = "goto_prev";
          "]d" = "goto_next";
        };
        lspBuf = {
          "gd" = "definition";
          "gD" = "declaration";
          "K" = "hover";
          "gi" = "implementation";
          "gr" = "references";
          "<leader>rn" = "rename";
          "<leader>ca" = "code_action";
        };
      };
      servers = {
        nixd = {
          enable = true;
        };
        ts_ls = {
          enable = true;
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "all";
                includeInlayParameterNameHintsWhenArgumentMatchesName = true;
                includeInlayFunctionParameterTypeHints = true;
                includeInlayVariableTypeHints = true;
                includeInlayPropertyDeclarationTypeHints = true;
                includeInlayFunctionLikeReturnTypeHints = true;
                includeInlayEnumMemberValueHints = true;
              };
            };
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all";
                includeInlayParameterNameHintsWhenArgumentMatchesName = true;
                includeInlayFunctionParameterTypeHints = true;
                includeInlayVariableTypeHints = true;
                includeInlayPropertyDeclarationTypeHints = true;
                includeInlayFunctionLikeReturnTypeHints = true;
                includeInlayEnumMemberValueHints = true;
              };
            };
          };
        };
        html = {
          enable = true;
        };
        cssls = {
          enable = true;
        };
        tailwindcss = {
          enable = true;
          filetypes = [
            "html"
            "css"
            "javascript"
            "javascriptreact"
            "typescript"
            "typescriptreact"
            "php"
            "blade"
          ];
        };
        emmet_ls = {
          enable = true;
          filetypes = [
            "html"
            "css"
            "javascript"
            "javascriptreact"
            "typescript"
            "typescriptreact"
            "php"
            "blade"
          ];
        };
        rust_analyzer = {
          enable = true;
          installCargo = false;
          installRustc = false;
        };
        gopls = {
          enable = true;
        };
        clangd = {
          enable = true;
        };
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
        phpactor = {
          enable = true;
        };
      };
    };

    plugins.conform-nvim = {
      enable = true;
      settings = {
        formatters_by_ft = {
          javascript.__raw = ''{ "prettierd", "prettier", stop_after_first = true }'';
          javascriptreact.__raw = ''{ "prettierd", "prettier", stop_after_first = true }'';
          typescript.__raw = ''{ "prettierd", "prettier", stop_after_first = true }'';
          typescriptreact.__raw = ''{ "prettierd", "prettier", stop_after_first = true }'';
          css.__raw = ''{ "prettierd", "prettier", stop_after_first = true }'';
          html.__raw = ''{ "prettierd", "prettier", stop_after_first = true }'';
          json.__raw = ''{ "prettierd", "prettier", stop_after_first = true }'';
          yaml.__raw = ''{ "prettierd", "prettier", stop_after_first = true }'';
          markdown.__raw = ''{ "prettierd", "prettier", stop_after_first = true }'';
          blade = [ "blade-formatter" ];
          php.__raw = ''{ lsp_format = "prefer" }'';
          nix.__raw = ''{ lsp_format = "prefer" }'';
          rust.__raw = ''{ lsp_format = "prefer" }'';
          go.__raw = ''{ lsp_format = "prefer" }'';
          c.__raw = ''{ lsp_format = "prefer" }'';
          cpp.__raw = ''{ lsp_format = "prefer" }'';
          java.__raw = ''{ lsp_format = "prefer" }'';
        };
        format_on_save = {
          timeout_ms = 500;
          lsp_format = "fallback";
        };
        formatters = {
          prettierd = {
            command = "prettierd";
          };
          prettier = {
            command = "prettier";
          };
          blade-formatter = {
            command = "blade-formatter";
            args = [ "--stdin" ];
          };
        };
      };
    };

    plugins.none-ls = {
      enable = true;
    };

    # Add none-ls-extras for eslint support
    # Note: none-ls-extras might not be in nixpkgs yet
    # The plugin would be: nvimtools/none-ls-extras.nvim
    # For now, just use the basic none-ls without extras

    extraConfigLuaPre = ''
      -- Skip nvim-java package downloads (packages are provided by Nix)
      local Manager = require('pkgm.manager')
      Manager.install = function(self, name, version)
        return ""
      end

      -- Skip nvim-java's jdtls LSP setup (handled by nixvim's plugins.lsp.servers.jdtls)
      local lsp_setup = require('java.startup.lsp_setup')
      lsp_setup.setup = function(_) end

      require('java').setup({
        jdk = {
          auto_install = false,
        },
        java_test = {
          enable = true,
        },
        java_debug_adapter = {
          enable = true,
        },
      })
    '';

    extraConfigLua = ''
      			local _theme_file = vim.fn.expand("~/.config/themes/current/nvim-theme.lua")
      			if vim.fn.filereadable(_theme_file) == 1 then dofile(_theme_file) end

      			-- none-ls is still required as "null-ls" (API compatibility)
      			local null_ls = require("null-ls")

      			-- Setup none-ls without sources for now
      			-- eslint_d requires none-ls-extras which isn't in nixpkgs yet
      			null_ls.setup({
      				sources = {},
      			})

      			-- Blade filetype detection (Laravel templates)
      			vim.filetype.add({
      				pattern = {
      					[".*%.blade%.php"] = "blade",
      					["todo%.txt"] = "todotxt",
      				},
      			})
      		'';

    # Treesitter (Syntax Highlighting)
    plugins.treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
      grammarPackages =
        let
          g = pkgs.vimPlugins.nvim-treesitter.builtGrammars;
        in
        [
          g.nix
          g.javascript
          g.typescript
          g.tsx
          g.html
          g.css
          g.rust
          g.go
          g.c
          g.cpp
          g.java
          g.php
          g.blade
          g.json
          g.yaml
          g.toml
          g.markdown
          g.bash
          g.lua
          g.vim
          g.todotxt
        ];
    };

    # Autocompletion
    plugins.cmp = {
      enable = true;
      settings = {
        snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
        mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-d>" = "cmp.mapping.scroll_docs(-4)";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<C-e>" = "cmp.mapping.close()";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
        };
        sources = [
          { name = "nvim_lsp"; }
          { name = "luasnip"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
        window = {
          completion.border = "rounded";
          documentation.border = "rounded";
        };
      };
    };

    plugins.luasnip.enable = true;
    plugins.cmp-nvim-lsp.enable = true;
    plugins.cmp-path.enable = true;
    plugins.cmp-buffer.enable = true;

    # File Explorer
    plugins.neo-tree = {
      enable = true;
      settings = {
        close_if_last_window = true;
        window.width = 30;
        filesystem = {
          follow_current_file.enabled = true;
          use_libuv_file_watcher = true;
        };
      };
    };

    # Fuzzy Finder
    plugins.telescope = {
      enable = true;
      keymaps = {
        "<leader>ff" = {
          action = "find_files";
          options.desc = "Find files";
        };
        "<leader>fg" = {
          action = "live_grep";
          options.desc = "Live grep";
        };
        "<leader>fb" = {
          action = "buffers";
          options.desc = "Find buffers";
        };
        "<leader>fh" = {
          action = "help_tags";
          options.desc = "Help tags";
        };
      };
      extensions.fzf-native.enable = true;
    };

    # Git Integration
    plugins.gitsigns = {
      enable = true;
      settings = {
        signs = {
          add.text = "│";
          change.text = "│";
          delete.text = "_";
          topdelete.text = "‾";
          changedelete.text = "~";
          untracked.text = "┆";
        };
        current_line_blame = true;
        watch_gitdir = {
          interval = 200;
          follow_files = true;
        };
        attach_to_untracked = true;
      };
    };

    plugins.lazygit.enable = true;

    # Statusline
    plugins.lualine = {
      enable = true;
      settings = {
        options = {
          theme = "auto";
          globalstatus = true;
        };
        sections = {
          lualine_a = [ "mode" ];
          lualine_b = [
            "branch"
            "diff"
            "diagnostics"
          ];
          lualine_c = [ "filename" ];
          lualine_x = [
            "encoding"
            "fileformat"
            "filetype"
          ];
          lualine_y = [ "progress" ];
          lualine_z = [ "location" ];
        };
      };
    };

    # Debugging
    plugins.dap.enable = true;
    plugins.dap-ui.enable = true;
    plugins.dap-virtual-text.enable = true;

    # Quality of Life Plugins
    plugins.web-devicons.enable = true;
    plugins.nvim-autopairs.enable = true;
    plugins.comment.enable = true;
    plugins.vim-surround.enable = true;
    plugins.which-key = {
      enable = true;
      settings.delay = 500;
    };
    plugins.indent-blankline = {
      enable = true;
      settings.scope.enabled = true;
    };
    plugins.bufferline = {
      enable = true;
      settings.options = {
        mode = "buffers";
        separator_style = "slant";
        always_show_bufferline = true;
      };
    };

    # Keybindings
    keymaps = [
      # File explorer
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree toggle<cr>";
        options.desc = "Toggle file explorer";
      }

      # LazyGit
      {
        mode = "n";
        key = "<leader>gg";
        action = "<cmd>LazyGit<cr>";
        options.desc = "Open LazyGit";
      }

      # Buffer navigation
      {
        mode = "n";
        key = "<S-h>";
        action = "<cmd>bprevious<cr>";
        options.desc = "Previous buffer";
      }
      {
        mode = "n";
        key = "<S-l>";
        action = "<cmd>bnext<cr>";
        options.desc = "Next buffer";
      }
      {
        mode = "n";
        key = "<leader>bd";
        action = "<cmd>bdelete<cr>";
        options.desc = "Delete buffer";
      }

      # Visual mode improvements
      {
        mode = "v";
        key = "<";
        action = "<gv";
        options.desc = "Indent left";
      }
      {
        mode = "v";
        key = ">";
        action = ">gv";
        options.desc = "Indent right";
      }
      {
        mode = "v";
        key = "J";
        action = ":m '>+1<CR>gv=gv";
        options.desc = "Move line down";
      }
      {
        mode = "v";
        key = "K";
        action = ":m '<-2<CR>gv=gv";
        options.desc = "Move line up";
      }

      # Utilities
      {
        mode = "n";
        key = "<leader>w";
        action = "<cmd>w<cr>";
        options.desc = "Save file";
      }
      {
        mode = "n";
        key = "<leader>q";
        action = "<cmd>q<cr>";
        options.desc = "Quit";
      }
      {
        mode = "n";
        key = "<Esc>";
        action = "<cmd>noh<cr>";
        options.desc = "Clear search highlighting";
      }

      # Debug keybindings
      {
        mode = "n";
        key = "<leader>db";
        action = "<cmd>DapToggleBreakpoint<cr>";
        options.desc = "Toggle breakpoint";
      }
      {
        mode = "n";
        key = "<leader>dc";
        action = "<cmd>DapContinue<cr>";
        options.desc = "Debug continue";
      }
      {
        mode = "n";
        key = "<leader>dt";
        action = "<cmd>DapTerminate<cr>";
        options.desc = "Debug terminate";
      }
      {
        mode = "n";
        key = "<leader>du";
        action = "<cmd>lua require('dapui').toggle()<cr>";
        options.desc = "Toggle debug UI";
      }

      # Format with conform.nvim
      {
        mode = "n";
        key = "<leader>f";
        action = "<cmd>lua require('conform').format({ async = true, lsp_fallback = true })<cr>";
        options.desc = "Format buffer";
      }

      # Java (nvim-java)
      {
        mode = "n";
        key = "<leader>jr";
        action = "<cmd>JavaRunnerRunMain<cr>";
        options.desc = "Java: Run main";
      }
      {
        mode = "n";
        key = "<leader>jt";
        action = "<cmd>JavaTestRunCurrentClass<cr>";
        options.desc = "Java: Run test class";
      }
      {
        mode = "n";
        key = "<leader>jT";
        action = "<cmd>JavaTestRunCurrentMethod<cr>";
        options.desc = "Java: Run test method";
      }
      {
        mode = "n";
        key = "<leader>jd";
        action = "<cmd>JavaTestDebugCurrentClass<cr>";
        options.desc = "Java: Debug test class";
      }
      {
        mode = "n";
        key = "<leader>jD";
        action = "<cmd>JavaTestDebugCurrentMethod<cr>";
        options.desc = "Java: Debug test method";
      }
    ];
  };
}
