-- Vanilla Config
-- require('impatient')
require('jimi.settings')
require('jimi.autocmd')
vim.g.mapleader = " "
vim.g.maplocalleader = " "
require('jimi.plugins')
require('jimi.keybinds')

---Pretty print lua table
function _G.dump(...)
    local objects = vim.tbl_map(vim.inspect, { ... })
    print(unpack(objects))
end
