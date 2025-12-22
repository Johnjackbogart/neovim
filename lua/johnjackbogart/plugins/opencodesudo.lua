return {
	"sudo-tee/opencode.nvim",
	name = "opencode-sudo",
	enabled = true,
	config = function()
		require("opencode").setup({})

		local opencode_insert_group = vim.api.nvim_create_augroup("opencode_insert", { clear = true })

		vim.api.nvim_create_autocmd("FileType", {
			group = opencode_insert_group,
			pattern = { "opencode", "opencode_input", "opencode_prompt" },
			callback = function(args)
				vim.schedule(function()
					if not vim.api.nvim_buf_is_valid(args.buf) then
						return
					end
					if vim.api.nvim_get_current_buf() ~= args.buf then
						return
					end
					vim.cmd("startinsert")
				end)
			end,
		})
	end,
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				anti_conceal = { enabled = false },
				file_types = { "markdown", "opencode_output" },
			},
			ft = { "markdown", "Avante", "copilot-chat", "opencode_output" },
		},
		-- Optional, for file mentions and commands completion, pick only one
		"saghen/blink.cmp",
		-- 'hrsh7th/nvim-cmp',

		-- Optional, for file mentions picker, pick only one
		"folke/snacks.nvim",
		-- 'nvim-telescope/telescope.nvim',
		-- 'ibhagwan/fzf-lua',
		-- 'nvim_mini/mini.nvim',
	},
}
