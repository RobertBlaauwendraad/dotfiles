local servers = { "ts_ls", "pyright", "lua_ls", "jsonls", "cssls", "html" }

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
      require("mason-lspconfig").setup({ ensure_installed = servers })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- Let every server advertise nvim-cmp's completion capabilities
      vim.lsp.config["*"] = {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      }
      for _, server in ipairs(servers) do
        vim.lsp.enable(server)
      end

      -- Show diagnostics inline (virtual_text defaults to off on nvim 0.11+)
      vim.diagnostic.config({
        virtual_text = true,
        severity_sort = true,
        float = { border = "rounded" },
      })

      -- Rely on nvim 0.11+ built-in LSP maps: grr (references), gri
      -- (implementation), grt (type definition), gra (code action), grn
      -- (rename), gO (document symbols), K (hover), and [d / ]d / <C-w>d for
      -- diagnostics. We add only what nvim leaves out.
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local function m(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
          end
          m("gd", vim.lsp.buf.definition, "Go to definition")   -- nvim has no LSP gd
          m("<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format buffer")
        end,
      })
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
