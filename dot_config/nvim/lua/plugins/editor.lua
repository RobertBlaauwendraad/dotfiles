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
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- Routes vim.ui.select() through a telescope picker instead of the built-in
      -- cmdline list (which needs a "Press ENTER" for lists taller than cmdheight).
      "nvim-telescope/telescope-ui-select.nvim",
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>",  desc = "Grep in files" },
      { "<leader>fr", "<cmd>Telescope oldfiles<CR>",   desc = "Recent files" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>",    desc = "Buffers" },
      { "<leader>fc", "<cmd>Telescope commands<CR>",   desc = "Commands" },
    },
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = { require("telescope.themes").get_dropdown() },
        },
      })
      -- pcall so a not-yet-installed extension can't take down telescope setup.
      pcall(require("telescope").load_extension, "ui-select")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    config = function()
      -- main branch: install parsers explicitly (async, no-op if present).
      -- Compiled with the tree-sitter CLI, see Brewfile: tree-sitter-cli.
      require("nvim-treesitter").install({
        "bash", "css", "diff", "gitcommit", "go", "html", "javascript",
        "json", "jsonc", "lua", "luadoc", "markdown", "markdown_inline",
        "python", "query", "rust", "toml", "tsx", "typescript", "vim",
        "vimdoc", "yaml",
      })

      -- main branch doesn't wire highlighting/indent for us; do it per buffer
      -- when a parser is available for the filetype.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          if pcall(vim.treesitter.start) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
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
      -- Review another worktree's changes without leaving this cockpit: pick a
      -- worktree, diffview opens against it via -C (nvim's cwd stays on this repo).
      { "<leader>gw", function() require("worktree").review_diff() end, desc = "Diff: review a worktree" },
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
