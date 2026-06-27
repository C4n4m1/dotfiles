-- ~/.config/nvim/lua/plugins/colorscheme.lua
return {
  {
    "dgox16/oldworld.nvim", -- Replace with the theme's GitHub repo
    lazy = false, -- Load the plugin immediately (not lazily)
    priority = 1000, -- Ensure it loads first
    config = function()
      -- Apply the theme
      vim.cmd.colorscheme("oldworld") -- Replace with the theme's name
    end,
  },
}
