return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
		-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
	},
	config = function()
		local manager = require("neo-tree.sources.manager")

		-- each tab gets its own neo-tree state, so remember the tab we were on
		-- before switching away, to inherit its tree's root in a brand new tab
		local last_active_tab
		vim.api.nvim_create_autocmd("TabLeave", {
			callback = function()
				last_active_tab = vim.api.nvim_get_current_tabpage()
			end,
		})

		-- finds the root path of another tab's already-navigated filesystem tree,
		-- preferring the tab we just came from
		local function root_from_other_tab(current_tabid)
			local preferred, fallback
			for _, other in ipairs(manager._get_all_states()) do
				if other.name == "filesystem" and other.tabid ~= current_tabid and other.path then
					if other.tabid == last_active_tab then
						preferred = other.path
					end
					fallback = fallback or other.path
				end
			end
			return preferred or fallback
		end

		require("neo-tree").setup({
			close_if_last_window = true,
			window = {
				position = "left",
				width = 36,
			},
			event_handlers = {
				{
					-- opens file on new tab
					event = "file_opened",
					handler = function(file_path)
						local tabid = vim.api.nvim_get_current_tabpage()
						local state = manager.get_state("filesystem", tabid)

						if state.path then
							-- this tab's tree is already set up, just make sure it's visible
							manager.show("filesystem")
							return
						end

						-- brand new tab: inherit another tab's root if one exists,
						-- otherwise root at the new file's own directory
						local root = root_from_other_tab(tabid) or vim.fn.fnamemodify(file_path, ":p:h")

						-- path_to_reveal expands just the folders leading to file_path
						manager.navigate(state, root, file_path)
					end,
				},
			},
		})

		-- opens on startup
		manager.show("filesystem")
		-- open greeter with file tree as well
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")
		alpha.setup(dashboard.opts)
	end,
	-- i have an alias set to 'sudo nvim --cmd let notree = 1
	-- this way I can start without tree open, like sometimes with tmux
	cond = function()
		if vim.fn.exists("notree") > 0 then
			return false
		else
			return true
		end
	end,
}
