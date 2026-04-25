return {
	"sudo-tee/opencode.nvim",
	name = "opencode-sudo",
	enabled = true,
	config = function()
		require("opencode").setup({
			preferred_completion = "nvim-cmp",
		})

		local ok_cmp, cmp = pcall(require, "cmp")
		if ok_cmp then
			cmp.setup.filetype("opencode", {
				sources = {
					{ name = "opencode_mentions" },
				},
			})
		end

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
		--[[		vim.api.nvim_create_autocmd("VimEnter", {
			group = opencode_insert_group,
			once = true,
			callback = function()
				vim.schedule(function()
					local ok, api = pcall(require, "opencode.api")
					if not ok then
						return
					end
					if api.open_input then
						api.open_input()
					elseif api.toggle then
						api.toggle()
					end
				end) --*
			end,
		}) ]]
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
