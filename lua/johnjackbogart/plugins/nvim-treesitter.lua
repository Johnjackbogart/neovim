return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"windwp/nvim-ts-autotag",
		},
		config = function()
			require("nvim-treesitter").setup({})

			-- ensure these language parsers are installed
			require("nvim-treesitter").install({
				"json",
				"javascript",
				"typescript",
				"tsx",
				"yaml",
				"html",
				"css",
				"prisma",
				"markdown",
				"markdown_inline",
				"svelte",
				"graphql",
				"bash",
				"lua",
				"luadoc",
				"vim",
				"dockerfile",
				"gitignore",
				"query",
			})

			-- enable syntax highlighting, folds, and indentation for any
			-- filetype with an installed parser
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					if not pcall(vim.treesitter.start) then
						return
					end
					vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
					vim.wo[0][0].foldmethod = "expr"
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})

			-- enable autotagging (w/ nvim-ts-autotag plugin)
			require("nvim-ts-autotag").setup()

			-- enable nvim-ts-context-commentstring plugin for commenting tsx and jsx
			require("ts_context_commentstring").setup({})
		end,
	},
}
