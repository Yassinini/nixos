return {
	{
		"harshrajsachan/omni.nvim",
		priority = 1000,
		lazy = false,
		config = function()
			vim.o.background = "dark"
			vim.cmd.colorscheme("blackout")
		end,
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "blackout",
		},
	},
}
