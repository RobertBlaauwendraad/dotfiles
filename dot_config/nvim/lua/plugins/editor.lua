return {
  {
    -- Ctrl-hjkl moves between nvim splits and, at the edge, crosses into the
    -- adjacent zellij pane — one navigation scheme for editor + multiplexer.
    "swaits/zellij-nav.nvim",
    lazy = true,
    event = "VeryLazy",
    keys = {
      { "<C-h>", "<cmd>ZellijNavigateLeft<CR>",  desc = "Focus split/pane left" },
      { "<C-j>", "<cmd>ZellijNavigateDown<CR>",  desc = "Focus split/pane down" },
      { "<C-k>", "<cmd>ZellijNavigateUp<CR>",    desc = "Focus split/pane up" },
      { "<C-l>", "<cmd>ZellijNavigateRight<CR>", desc = "Focus split/pane right" },
    },
    opts = {},
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>",  desc = "Grep in files" },
      { "<leader>fr", "<cmd>Telescope oldfiles<CR>",   desc = "Recent files" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>",    desc = "Buffers" },
      { "<leader>fc", "<cmd>Telescope commands<CR>",   desc = "Commands" },
    },
    config = function()
      require("telescope").setup()
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.config").setup({
        ensure_installed = "all",
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        current_line_blame = true,
        current_line_blame_opts = {
          delay = 500,
        },
      })

      vim.keymap.set("n", "<leader>gb", ":Gitsigns blame_line<CR>", { desc = "Blame line" })
      vim.keymap.set("n", "<leader>gB", ":Gitsigns blame<CR>",      { desc = "Blame file" })
    end,
  },
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<CR>",          desc = "Diff: review changes" },
      { "<leader>gm", "<cmd>DiffviewOpen origin/main<CR>", desc = "Diff: vs origin/main" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "Diff: file history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<CR>",   desc = "Diff: repo history" },
      { "<leader>gq", "<cmd>DiffviewClose<CR>",         desc = "Diff: close" },
    },
    config = function()
      require("diffview").setup()
    end,
  },
  {
    "echasnovski/mini.pairs",
    config = function()
      require("mini.pairs").setup()
    end,
  },
  {
    "echasnovski/mini.comment",
    keys = {
      { "gc", mode = { "n", "x" }, desc = "Comment" },
      { "gcc", desc = "Comment line" },
    },
    config = function()
      require("mini.comment").setup()
    end,
  },
}
