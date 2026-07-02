local servers = { "ts_ls", "pyright", "gopls", "lua_ls", "jsonls", "cssls", "html" }

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

      -- nvim's built-in LSP navigation maps (grr/gri/grt/gO) dump into the
      -- quickfix/loclist. Route them through Telescope instead: fuzzy list +
      -- live preview, and it auto-jumps when there's only one result. We keep
      -- nvim's gra (code action), grn (rename), K (hover), and [d / ]d.
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local tb = require("telescope.builtin")
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          local function m(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
          end
          m("gd",  tb.lsp_definitions,       "Go to definition")   -- nvim has no LSP gd
          m("grr", tb.lsp_references,        "References")
          m("gO",  tb.lsp_document_symbols,  "Document symbols")
          m("<leader>fs", tb.lsp_dynamic_workspace_symbols, "Workspace symbols")
          m("<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format buffer")
          -- gri/grt only where the server implements them (lua_ls/pyright/jsonls
          -- etc. don't); otherwise nvim's default maps warn on every press.
          if client and client:supports_method("textDocument/implementation") then
            m("gri", tb.lsp_implementations, "Implementations")
          end
          if client and client:supports_method("textDocument/typeDefinition") then
            m("grt", tb.lsp_type_definitions, "Type definition")
          end
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
