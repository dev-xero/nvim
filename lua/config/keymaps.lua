local map = LazyVim.safe_keymap_set

map("n", "<A-h>", function()
    Snacks.terminal(nil, { cwd = LazyVim.root() })
end, { desc = "Toggle Floating Terminal" })
