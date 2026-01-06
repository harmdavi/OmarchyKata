return {
  {
    "lervag/vimtex",
    lazy = false, -- IMPORTANT: do not lazy-load VimTeX
    init = function()
      vim.g.vimtex_compiler_method = "latexmk"

      -- Choose ONE viewer depending on your OS
      vim.g.vimtex_view_method = "zathura" -- Linux
      -- vim.g.vimtex_view_method = "skim" -- macOS
      -- vim.g.vimtex_view_method = "general" -- Windows
    end,
  },
}
