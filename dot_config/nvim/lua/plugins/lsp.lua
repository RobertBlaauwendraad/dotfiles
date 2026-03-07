return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "ts_ls", "pyright", "lua_ls", "jsonls", "cssls", "html",
        },
        automatic_installation = true,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason-lspconfig.nvim" },
    config = function()
      local servers = { "ts_ls", "pyright", "lua_ls", "jsonls", "cssls", "html" }
      for _, server in ipairs(servers) do
        vim.lsp.config[server] = {}
        vim.lsp.enable(server)
      end

      vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition,     { desc = "Go to definition" })
      vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation,  { desc = "Go to implementation" })
      vim.keymap.set("n", "<leader>gu", vim.lsp.buf.references,      { desc = "Show usages" })
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,          { desc = "Rename element" })
      vim.keymap.set("n", "<leader>am", vim.lsp.buf.code_action,     { desc = "Code actions" })
      vim.keymap.set("n", "<leader>en", vim.diagnostic.goto_next,    { desc = "Next error" })
      vim.keymap.set("n", "<leader>ep", vim.diagnostic.goto_prev,    { desc = "Prev error" })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-j>"]     = cmp.mapping.select_next_item(),
          ["<C-k>"]     = cmp.mapping.select_prev_item(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
}
