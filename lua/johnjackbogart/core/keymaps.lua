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

-- tabs
keymap.set("n", "<leader>to", ":tabnew<CR>") -- new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close current tab
keymap.set("n", "<leader>tn", ":tabn<CR>") -- next tab
keymap.set("n", "<leader>tp", ":tabp<CR>") -- previous tab

-- plugins

-- Open Code
keymap.set({ "n", "x" }, "<leader>aaa", function()
	require("opencode").ask("@this: ", { submit = true })
end, { desc = "Ask opencode" })

keymap.set({ "n", "x" }, "<leader>aai", function()
	require("opencode").select()
end, { desc = "Execute opencode action…" })
keymap.set({ "n", "t" }, "<leader>aat", function()
	require("opencode").toggle()
end, { desc = "Toggle opencode" })

-- Neo Tree
keymap.set("n", "<leader>ee", "<cmd>Neotree<CR>") -- open tree
keymap.set("n", "<leader>ef", "<cmd>Neotree focus<CR>") -- focus on NeoTree
keymap.set("n", "<leader>et", "<cmd>Neotree reveal<CR>") -- toggle file explorer on current file
keymap.set("n", "<leader>ec", "<cmd>Neotree toggle<CR>") -- collapse file explorer
keymap.set("n", "<leader>er", "<cmd>Neotree<CR>") -- refresh file explorer, Neo Tree does this automatically
keymap.set("n", "<leader>ew", "<C-w><C-w>") -- toggle back to file, will just cycle through windows

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
