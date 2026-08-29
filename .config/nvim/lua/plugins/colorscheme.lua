return {
  { "harshrajsachan/omni.nvim", priority = 1000, lazy = false },
  { "catppuccin/nvim", name = "catppuccin", lazy = true },
  { "folke/tokyonight.nvim", lazy = true },
  { "rebelot/kanagawa.nvim", lazy = true },
  { "EdenEast/nightfox.nvim", lazy = true },
  { "rose-pine/neovim", name = "rose-pine", lazy = true },
  { "nanotech/jellybeans.vim", lazy = true },
  { "datsfilipe/vesper.nvim", lazy = true },
  { "spf13/vim-colors", lazy = true }, -- has ir_black, molokai, peaksea, wombat256mod (4 schemes)
  { "vext01/theunixzoo-vim-colorscheme", lazy = true }, -- :colorscheme theunixzoo

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "jellybeans",
    },
  },
}
