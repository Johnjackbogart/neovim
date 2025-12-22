-- This connects to lsps, which allow for things like inline errors
--
-- from Claude:
--  The inline LSP errors (virtual text at the end of lines) are actually built-in to Neovim itself - not a plugin.
--
--  Neovim has a native vim.diagnostic module that displays diagnostics as virtual text by default. Your nvim-lspconfig plugin connects to language servers, and Neovim's built-in diagnostic system handles the display.
--
--  You can configure it in your config with vim.diagnostic.config(). For example:
--
--  vim.diagnostic.config({
--    virtual_text = true,       -- toggle inline text on/off
--    signs = true,              -- gutter signs
--    underline = true,          -- underline errors
--    update_in_insert = false,  -- don't update while typing
--  })
--
--  Your lspsaga plugin provides the fancy floating windows for diagnostics (like <leader>D and <leader>d keymaps you have), but the persistent inline virtual text is pure Neovim.
--
--  If you want to disable or customize the inline errors, just add a vim.diagnostic.config() call somewhere in your config (like in core/options.lua).

return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
	},
	config = function()
		-- import cmp-nvim-lsp plugin
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local keymap = vim.keymap -- for conciseness

		local opts = { noremap = true, silent = true }
		local function setup_typescript_commands(bufnr)
			local function execute_command(command, arguments)
				vim.lsp.buf.execute_command({ command = command, arguments = arguments })
			end

			local function apply_source_action(action)
				vim.lsp.buf.code_action({
					context = {
						only = { action },
						diagnostics = vim.diagnostic.get(bufnr),
					},
					apply = true,
				})
			end

			local function add_missing_imports()
				apply_source_action("source.addMissingImports.ts")
			end

			local function fix_all()
				apply_source_action("source.fixAll.ts")
			end

			local function organize_imports()
				apply_source_action("source.organizeImports.ts")
			end

			local function remove_unused()
				apply_source_action("source.removeUnused.ts")
			end

			local function rename_file()
				local source = vim.api.nvim_buf_get_name(bufnr)
				vim.ui.input({ prompt = "New name: ", default = source }, function(target)
					if not target or target == "" or target == source then
						return
					end

					execute_command("_typescript.applyRenameFile", {
						{
							sourceUri = vim.uri_from_fname(source),
							targetUri = vim.uri_from_fname(target),
						},
					})

					local rename_result = vim.fn.rename(source, target)
					if rename_result ~= 0 then
						vim.notify("Rename failed.", vim.log.levels.ERROR)
						return
					end

					vim.api.nvim_buf_set_name(bufnr, target)
					vim.api.nvim_buf_call(bufnr, function()
						vim.cmd("silent! write")
					end)
				end)
			end

			vim.api.nvim_buf_create_user_command(
				bufnr,
				"TypescriptAddMissingImports",
				add_missing_imports,
				{ desc = "Add missing imports" }
			)
			vim.api.nvim_buf_create_user_command(
				bufnr,
				"TypescriptFixAll",
				fix_all,
				{ desc = "Fix all" }
			)
			vim.api.nvim_buf_create_user_command(
				bufnr,
				"TypescriptRenameFile",
				rename_file,
				{ desc = "Rename file and update imports" }
			)
			vim.api.nvim_buf_create_user_command(
				bufnr,
				"TypescriptOrganizeImports",
				organize_imports,
				{ desc = "Organize imports" }
			)
			vim.api.nvim_buf_create_user_command(
				bufnr,
				"TypescriptRemoveUnused",
				remove_unused,
				{ desc = "Remove unused imports" }
			)
		end
		local function setup(server, config)
			if vim.lsp.config then
				if type(vim.lsp.config) == "function" then
					vim.lsp.config(server, config)
				else
					vim.lsp.config[server] = vim.tbl_deep_extend("force", vim.lsp.config[server] or {}, config)
				end
				if vim.lsp.enable then
					vim.lsp.enable(server)
				end
			else
				require("lspconfig")[server].setup(config)
			end
		end
		local on_attach = function(client, bufnr)
			-- i did this because highlighting is not correct for types in opencodedyke.lua
			--if client.name == "lua_ls" then
			--client.server_capabilities.semanticTokensProvider = nil
			--end
			if client.server_capabilities.semanticTokensProvider then
				vim.lsp.semantic_tokens.start(bufnr, client.id)
			end

			opts.buffer = bufnr

			-- set these here so you can access buffer for opts
			keymap.set("n", "gf", "<cmd>Lspsaga finder<CR>", opts) -- show definition, references
			keymap.set("n", "gD", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts) -- got to definition
			keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", opts) -- see definition and make edits in window
			keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts) -- go to implementation
			keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts) -- see available code actions
			keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts) -- smart rename
			keymap.set("n", "<leader>D", "<cmd>Lspsaga show_line_diagnostics<CR>", opts) -- show  diagnostics for line
			keymap.set("n", "<leader>d", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts) -- show diagnostics for cursor
			keymap.set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts) -- jump to previous diagnostic in buffer
			keymap.set("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts) -- jump to next diagnostic in buffer
			keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts) -- show documentation for what is under cursor

			opts.desc = "Restart LSP"
			keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary

			if client.name == "ts_ls" then
				setup_typescript_commands(bufnr)

				opts.desc = "Rename file and update file imports"
				keymap.set("n", "<leader>rf", ":TypescriptRenameFile<CR>", opts) -- rename file and update imports

				opts.desc = "Rename file and update file imports"
				keymap.set("n", "<leader>oi", ":TypescriptOrganizeImports<CR>", opts) -- organize imports (not in youtube nvim video)

				opts.desc = "Remove unused imports"
				keymap.set("n", "<leader>ru", ":TypescriptRemoveUnused<CR>", opts) -- remove unused variables (not in youtube nvim video)
			end
		end

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Change the Diagnostic symbols in the sign column (gutter)
		-- (not in youtube nvim video)
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- configure html server
		setup("html", {
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- configure typescript server with plugin
		setup("ts_ls", {
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- configure css server
		setup("cssls", {
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- configure tailwindcss server
		setup("tailwindcss", {
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- configure svelte server
		setup("svelte", {
			capabilities = capabilities,
			on_attach = function(client)
				on_attach(client)

				vim.api.nvim_create_autocmd("BufWritePost", {
					pattern = { "*.js", "*.ts" },
					callback = function(ctx)
						if client.name == "svelte" then
							client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
						end
					end,
				})
			end,
		})

		-- configure prisma orm server
		setup("prismals", {
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- configure graphql language server
		setup("graphql", {
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
		})

		-- configure emmet language server
		setup("emmet_ls", {
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
		})

		-- configure python server
		setup("pyright", {
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- configure lua server (with special settings)
		setup("lua_ls", {
			capabilities = capabilities,
			on_attach = on_attach,
			settings = { -- custom settings for lua
				Lua = {
					semantic = { enable = true },
					-- make the language server recognize "vim" global
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						-- make language server aware of runtime files
						library = {
							[vim.fn.expand("$VIMRUNTIME/lua")] = true,
							[vim.fn.stdpath("config") .. "/lua"] = true,
							[vim.fn.stdpath("data") .. "/lazy"] = true,
							-- running into issues when adding types to certain lua files
							-- https://hugosum.com/blog/adding-types-to-your-neovim-configuration
							--					[vim.fn.stdpath("$HOME/.config/nvim/lazy") .. "/lua"] = true,
						},
					},
				},
			},
		})
	end,
}
