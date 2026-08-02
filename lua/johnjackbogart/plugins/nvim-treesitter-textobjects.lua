return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	lazy = true,
	config = function()
		require("nvim-treesitter-textobjects").setup({
			select = {
				lookahead = true,
			},
			move = {
				set_jumps = true,
			},
		})

		local select_textobject = require("nvim-treesitter-textobjects.select").select_textobject
		local swap = require("nvim-treesitter-textobjects.swap")
		local move = require("nvim-treesitter-textobjects.move")

		local select_keymaps = {
			["a="] = "@assignment.outer",
			["i="] = "@assignment.inner",
			["l="] = "@assignment.lhs",
			["r="] = "@assignment.rhs",

			["a:"] = "@property.outer",
			["i:"] = "@property.inner",
			["l:"] = "@property.lhs",
			["r:"] = "@property.rhs",

			["aa"] = "@parameter.outer",
			["ia"] = "@parameter.inner",

			["ai"] = "@conditional.outer",
			["ii"] = "@conditional.inner",

			["al"] = "@loop.outer",
			["il"] = "@loop.inner",

			["af"] = "@call.outer",
			["if"] = "@call.inner",

			["am"] = "@function.outer",
			["im"] = "@function.inner",

			["ac"] = "@class.outer",
			["ic"] = "@class.inner",
		}
		for lhs, query in pairs(select_keymaps) do
			vim.keymap.set({ "x", "o" }, lhs, function()
				select_textobject(query, "textobjects")
			end, { desc = "Select " .. query })
		end

		vim.keymap.set("n", "<leader>na", function()
			swap.swap_next("@parameter.inner")
		end, { desc = "Swap parameter/argument with next" })
		vim.keymap.set("n", "<leader>n:", function()
			swap.swap_next("@property.outer")
		end, { desc = "Swap object property with next" })
		vim.keymap.set("n", "<leader>nm", function()
			swap.swap_next("@function.outer")
		end, { desc = "Swap function with next" })

		vim.keymap.set("n", "<leader>pa", function()
			swap.swap_previous("@parameter.inner")
		end, { desc = "Swap parameter/argument with previous" })
		vim.keymap.set("n", "<leader>p:", function()
			swap.swap_previous("@property.outer")
		end, { desc = "Swap object property with previous" })
		vim.keymap.set("n", "<leader>pm", function()
			swap.swap_previous("@function.outer")
		end, { desc = "Swap function with previous" })

		local move_next_start = {
			["]f"] = "@call.outer",
			["]m"] = "@function.outer",
			["]c"] = "@class.outer",
			["]i"] = "@conditional.outer",
			["]l"] = "@loop.outer",
		}
		for lhs, query in pairs(move_next_start) do
			vim.keymap.set({ "n", "x", "o" }, lhs, function()
				move.goto_next_start(query, "textobjects")
			end, { desc = "Next " .. query .. " start" })
		end
		vim.keymap.set({ "n", "x", "o" }, "]s", function()
			move.goto_next_start("@local.scope", "locals")
		end, { desc = "Next scope" })
		vim.keymap.set({ "n", "x", "o" }, "]z", function()
			move.goto_next_start("@fold", "folds")
		end, { desc = "Next fold" })

		local move_next_end = {
			["]F"] = "@call.outer",
			["]M"] = "@function.outer",
			["]C"] = "@class.outer",
			["]I"] = "@conditional.outer",
			["]L"] = "@loop.outer",
		}
		for lhs, query in pairs(move_next_end) do
			vim.keymap.set({ "n", "x", "o" }, lhs, function()
				move.goto_next_end(query, "textobjects")
			end, { desc = "Next " .. query .. " end" })
		end

		local move_prev_start = {
			["[f"] = "@call.outer",
			["[m"] = "@function.outer",
			["[c"] = "@class.outer",
			["[i"] = "@conditional.outer",
			["[l"] = "@loop.outer",
		}
		for lhs, query in pairs(move_prev_start) do
			vim.keymap.set({ "n", "x", "o" }, lhs, function()
				move.goto_previous_start(query, "textobjects")
			end, { desc = "Prev " .. query .. " start" })
		end

		local move_prev_end = {
			["[F"] = "@call.outer",
			["[M"] = "@function.outer",
			["[C"] = "@class.outer",
			["[I"] = "@conditional.outer",
			["[L"] = "@loop.outer",
		}
		for lhs, query in pairs(move_prev_end) do
			vim.keymap.set({ "n", "x", "o" }, lhs, function()
				move.goto_previous_end(query, "textobjects")
			end, { desc = "Prev " .. query .. " end" })
		end

		local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")

		-- vim way: ; goes to the direction you were moving.
		vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
		vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

		-- Optionally, make builtin f, F, t, T also repeatable with ; and ,
		vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
		vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
		vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
		vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
	end,
}
