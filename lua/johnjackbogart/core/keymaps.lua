-- other keymaps are also set in:
-- nvim-cmp
-- nvim-treesitter-textobjects
-- lsp/lspconfig
-- harpoon
vim.g.mapleader = " "

local keymap = vim.keymap

-- general
-- why can't i remap escape to caps lock
keymap.set("i", "jk", "<ESC>")
keymap.set("n", "<leader>nh", ":nohl<CR>")
keymap.set("n", "x", '"_x')
keymap.set("n", "<leader>+", "<C-a>")
keymap.set("n", "<leader>-", "<C-x>")

-- window split
keymap.set("n", "<leader>sv", "<C-w>v") -- split vertical
keymap.set("n", "<leader>sh", "<C-w>s") -- split horizontal
keymap.set("n", "<leader>se", "<C-w>=") -- make split windows equal width
keymap.set("n", "<leader>sx", ":close<CR>") -- split vertical
keymap.set("n", "<leader>wm", "<cmd>MainEditor<CR>") -- focus main editor window

-- tabs
keymap.set("n", "<leader>to", ":tabnew<CR>") -- new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close current tab
keymap.set("n", "<leader>tn", ":tabn<CR>") -- next tab
keymap.set("n", "<leader>tp", ":tabp<CR>") -- previous tab

-- plugins

-- Open Code
local function is_opencode_buffer(buf)
	local filetype = vim.bo[buf].filetype
	return filetype == "opencode"
		or filetype == "opencode_input"
		or filetype == "opencode_prompt"
		or filetype == "opencode_output"
end

local function is_opencode_input_buffer(buf)
	local filetype = vim.bo[buf].filetype
	if filetype == "opencode_input" or filetype == "opencode_prompt" then
		return true
	end
	if filetype ~= "opencode" then
		return false
	end
	if vim.bo[buf].buftype == "prompt" then
		return true
	end
	local name = vim.api.nvim_buf_get_name(buf)
	if name:match("input") or name:match("prompt") then
		return true
	end
	return vim.bo[buf].modifiable and not vim.bo[buf].readonly
end

local function is_main_editor_buffer(buf)
	if is_opencode_buffer(buf) then
		return false
	end
	return vim.bo[buf].buftype == ""
end

local function find_opencode_window()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if is_opencode_buffer(buf) then
			return win
		end
	end
end

local function find_opencode_input_window()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if is_opencode_input_buffer(buf) then
			return win
		end
	end
end

local function find_non_opencode_window()
	local last_win = vim.g.opencode_last_win
	if last_win and vim.api.nvim_win_is_valid(last_win) then
		local buf = vim.api.nvim_win_get_buf(last_win)
		if not is_opencode_buffer(buf) then
			return last_win
		end
	end

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if not is_opencode_buffer(buf) then
			return win
		end
	end
end

local function find_main_editor_window()
	local last_win = vim.g.main_editor_win
	if last_win and vim.api.nvim_win_is_valid(last_win) then
		local buf = vim.api.nvim_win_get_buf(last_win)
		if is_main_editor_buffer(buf) then
			return last_win
		end
	end

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if is_main_editor_buffer(buf) then
			return win
		end
	end
end

local function focus_opencode_window(win)
	vim.api.nvim_set_current_win(win)
	vim.schedule(function()
		if not vim.api.nvim_win_is_valid(win) then
			return
		end
		local buf = vim.api.nvim_win_get_buf(win)
		if is_opencode_input_buffer(buf) then
			vim.cmd("startinsert")
		end
	end)
end

local function toggle_opencode_focus()
	local current_win = vim.api.nvim_get_current_win()
	local current_buf = vim.api.nvim_get_current_buf()

	if is_opencode_buffer(current_buf) then
		local target_win = find_non_opencode_window()
		if target_win then
			vim.api.nvim_set_current_win(target_win)
		end
		return
	end

	vim.g.opencode_last_win = current_win

	local opencode_win = find_opencode_input_window() or find_opencode_window()
	if opencode_win then
		focus_opencode_window(opencode_win)
		return
	end

	local ok, api = pcall(require, "opencode.api")
	if not ok then
		return
	end
	if api.open_input then
		api.open_input()
	elseif api.toggle then
		api.toggle()
	end
	vim.schedule(function()
		local win = find_opencode_input_window() or find_opencode_window()
		if win then
			focus_opencode_window(win)
		end
	end)
end

local function focus_main_editor_window()
	local target_win = find_main_editor_window()
	if target_win then
		vim.api.nvim_set_current_win(target_win)
	end
end

vim.api.nvim_create_autocmd("WinEnter", {
	callback = function()
		local buf = vim.api.nvim_get_current_buf()
		if not is_opencode_buffer(buf) then
			vim.g.opencode_last_win = vim.api.nvim_get_current_win()
		end
		if is_main_editor_buffer(buf) then
			vim.g.main_editor_win = vim.api.nvim_get_current_win()
		end
	end,
})

vim.api.nvim_create_user_command("MainEditor", focus_main_editor_window, { desc = "Focus main editor window" })

keymap.set({ "n", "x" }, "<leader>aaa", function()
	require("opencode").ask("@this: ", { submit = true })
end, { desc = "Ask opencode" })

keymap.set({ "n", "x" }, "<leader>aai", function()
	require("opencode").select()
end, { desc = "Execute opencode action…" })
keymap.set({ "n", "t" }, "<leader>aat", function()
	local ok, api = pcall(require, "opencode.api")
	if ok and api.toggle then
		api.toggle()
	end
end, { desc = "Toggle opencode" })
keymap.set({ "n", "t" }, "<leader>aaw", toggle_opencode_focus, { desc = "Toggle opencode focus" })

-- Neo Tree
keymap.set("n", "<leader>ee", "<cmd>Neotree<CR>") -- open tree
keymap.set("n", "<leader>ef", "<cmd>Neotree focus<CR>") -- focus on NeoTree
keymap.set("n", "<leader>et", "<cmd>Neotree reveal<CR>") -- toggle file explorer on current file
keymap.set("n", "<leader>ec", "<cmd>Neotree toggle<CR>") -- collapse file explorer
keymap.set("n", "<leader>er", "<cmd>Neotree<CR>") -- refresh file explorer, Neo Tree does this automatically
keymap.set("n", "<leader>ew", "<cmd>Neotree focus<CR>") -- focus NeoTree

-- Lazy
keymap.set("n", "<leader>L", "<cmd>Lazy<CR>") -- open Lazy

-- Telescope
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>")
keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>")
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<CR>")
keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>")
keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<CR>")

-- Mason / LSP
keymap.set("n", "<leader>M", "<cmd>Mason<CR>")

-- Alpha / Greeter
keymap.set("n", "<leader>aa", "<cmd>Alpha<CR>")

-- UndoTree
keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<CR>")

-- Vim Fugitive
keymap.set("n", "<leader>gs", "<cmd>Git<CR>")

-- Primeagen told me to do this
keymap.set("v", "K", ":m '<-2<CR>gv=gv")
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("n", "J", "mzJ`z")
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")
keymap.set("x", "<leader>p", '"_dP')
keymap.set("n", "<leader>y", '"+y')
keymap.set("v", "<leader>y", '"+y')
keymap.set("n", "<leader>Y", '"+Y')
