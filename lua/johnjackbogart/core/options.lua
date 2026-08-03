local opt = vim.opt

opt.timeout = true
opt.timeoutlen = 750

-- with this set, guifg, guibg, gui set colors
opt.termguicolors = true

-- line numbers
opt.relativenumber = true
opt.number = true

-- tabs & indent
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- line wrapping
opt.wrap = false

-- search
opt.ignorecase = true
opt.smartcase = true

-- cursor
opt.cursorline = true
opt.guicursor = "a:blinkon200"

-- appearance
opt.background = "dark"
opt.signcolumn = "yes"

-- backspace
opt.backspace = "indent,eol,start"

-- clipboard
opt.clipboard:append("unnamedplus")

-- split windows
opt.splitright = true
opt.splitbelow = true

-- undo
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.undofile = true

-- search
opt.incsearch = true

-- misc
opt.scrolloff = 10
opt.iskeyword:append("-")
opt.updatetime = 50
