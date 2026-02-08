{ pkgs, ... }:

let
	c = import ../../modules/colors.nix;
in
{
	programs.nixvim = {
		enable = true;

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
			clipboard = "unnamedplus";  # Use system clipboard
		};

		globals = {
			mapleader = " ";
			maplocalleader = " ";
		};

		# Rose Pine Moon theme
		colorschemes.rose-pine = {
			enable = true;
			settings = {
				variant = "moon";
				dark_variant = "moon";
				styles = {
					bold = true;
					italic = true;
					transparency = false;
				};
				highlight_groups = {
					Normal = { bg = c.base; fg = c.text; };
					NormalFloat = { bg = c.surface; fg = c.text; };
					Cursor = { bg = c.highlightHigh; fg = c.text; };
					CursorLine = { bg = c.highlightLow; };
					CursorLineNr = { fg = c.rose; bold = true; };
					StatusLine = { bg = c.surface; fg = c.text; };
					StatusLineNC = { bg = c.base; fg = c.muted; };
					VertSplit = { fg = c.overlay; };
					DiagnosticError = { fg = c.love; };
					DiagnosticWarn = { fg = c.gold; };
					DiagnosticInfo = { fg = c.foam; };
					DiagnosticHint = { fg = c.iris; };
				};
			};
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
				nixd = { enable = true; };
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
				html = { enable = true; };
				cssls = { enable = true; };
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
				gopls = { enable = true; };
				clangd = { enable = true; };
				jdtls = { enable = true; };
				phpactor = { enable = true; };
			};
		};

		plugins.conform-nvim = {
			enable = true;
			settings = {
				formatters_by_ft = {
					javascript = [ "prettierd" "prettier" { stop_after_first = true; } ];
					javascriptreact = [ "prettierd" "prettier" { stop_after_first = true; } ];
					typescript = [ "prettierd" "prettier" { stop_after_first = true; } ];
					typescriptreact = [ "prettierd" "prettier" { stop_after_first = true; } ];
					css = [ "prettierd" "prettier" { stop_after_first = true; } ];
					html = [ "prettierd" "prettier" { stop_after_first = true; } ];
					json = [ "prettierd" "prettier" { stop_after_first = true; } ];
					yaml = [ "prettierd" "prettier" { stop_after_first = true; } ];
					markdown = [ "prettierd" "prettier" { stop_after_first = true; } ];
					blade = [ "blade-formatter" ];
					php = [ { __unkeyed = "phpactor"; lsp_format = "fallback"; } ];
					nix = [ { __unkeyed = "nixd"; lsp_format = "fallback"; } ];
					rust = [ { __unkeyed = "rust_analyzer"; lsp_format = "fallback"; } ];
					go = [ { __unkeyed = "gopls"; lsp_format = "fallback"; } ];
					c = [ { __unkeyed = "clangd"; lsp_format = "fallback"; } ];
					cpp = [ { __unkeyed = "clangd"; lsp_format = "fallback"; } ];
					java = [ { __unkeyed = "jdtls"; lsp_format = "fallback"; } ];
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

		extraConfigLua = ''
			-- none-ls is still required as "null-ls" (API compatibility)
			local null_ls = require("null-ls")

			-- Setup none-ls without sources for now
			-- eslint_d requires none-ls-extras which isn't in nixpkgs yet
			null_ls.setup({
				sources = {},
			})
		'';

		# Treesitter (Syntax Highlighting)
		plugins.treesitter = {
			enable = true;
			settings = {
				highlight.enable = true;
				indent.enable = true;
			};
			grammarPackages = let
				g = pkgs.vimPlugins.nvim-treesitter.builtGrammars;
			in [
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
				"<leader>ff" = { action = "find_files"; options.desc = "Find files"; };
				"<leader>fg" = { action = "live_grep"; options.desc = "Live grep"; };
				"<leader>fb" = { action = "buffers"; options.desc = "Find buffers"; };
				"<leader>fh" = { action = "help_tags"; options.desc = "Help tags"; };
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
			};
		};

		plugins.lazygit.enable = true;

		# Statusline
		plugins.lualine = {
			enable = true;
			settings = {
				options = {
					theme = "rose-pine";
					globalstatus = true;
				};
				sections = {
					lualine_a = [ "mode" ];
					lualine_b = [ "branch" "diff" "diagnostics" ];
					lualine_c = [ "filename" ];
					lualine_x = [ "encoding" "fileformat" "filetype" ];
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
			{ mode = "n"; key = "<leader>e"; action = "<cmd>Neotree toggle<cr>"; options.desc = "Toggle file explorer"; }

			# LazyGit
			{ mode = "n"; key = "<leader>gg"; action = "<cmd>LazyGit<cr>"; options.desc = "Open LazyGit"; }

			# Window navigation
			{ mode = "n"; key = "<C-h>"; action = "<C-w>h"; options.desc = "Move to left window"; }
			{ mode = "n"; key = "<C-j>"; action = "<C-w>j"; options.desc = "Move to bottom window"; }
			{ mode = "n"; key = "<C-k>"; action = "<C-w>k"; options.desc = "Move to top window"; }
			{ mode = "n"; key = "<C-l>"; action = "<C-w>l"; options.desc = "Move to right window"; }

			# Buffer navigation
			{ mode = "n"; key = "<S-h>"; action = "<cmd>bprevious<cr>"; options.desc = "Previous buffer"; }
			{ mode = "n"; key = "<S-l>"; action = "<cmd>bnext<cr>"; options.desc = "Next buffer"; }
			{ mode = "n"; key = "<leader>bd"; action = "<cmd>bdelete<cr>"; options.desc = "Delete buffer"; }

			# Visual mode improvements
			{ mode = "v"; key = "<"; action = "<gv"; options.desc = "Indent left"; }
			{ mode = "v"; key = ">"; action = ">gv"; options.desc = "Indent right"; }
			{ mode = "v"; key = "J"; action = ":m '>+1<CR>gv=gv"; options.desc = "Move line down"; }
			{ mode = "v"; key = "K"; action = ":m '<-2<CR>gv=gv"; options.desc = "Move line up"; }

			# Utilities
			{ mode = "n"; key = "<leader>w"; action = "<cmd>w<cr>"; options.desc = "Save file"; }
			{ mode = "n"; key = "<leader>q"; action = "<cmd>q<cr>"; options.desc = "Quit"; }
			{ mode = "n"; key = "<Esc>"; action = "<cmd>noh<cr>"; options.desc = "Clear search highlighting"; }

			# Debug keybindings
			{ mode = "n"; key = "<leader>db"; action = "<cmd>DapToggleBreakpoint<cr>"; options.desc = "Toggle breakpoint"; }
			{ mode = "n"; key = "<leader>dc"; action = "<cmd>DapContinue<cr>"; options.desc = "Debug continue"; }
			{ mode = "n"; key = "<leader>dt"; action = "<cmd>DapTerminate<cr>"; options.desc = "Debug terminate"; }
			{ mode = "n"; key = "<leader>du"; action = "<cmd>lua require('dapui').toggle()<cr>"; options.desc = "Toggle debug UI"; }

			# Format with conform.nvim
			{ mode = "n"; key = "<leader>f"; action = "<cmd>lua require('conform').format({ async = true, lsp_fallback = true })<cr>"; options.desc = "Format buffer"; }
		];
	};
}
