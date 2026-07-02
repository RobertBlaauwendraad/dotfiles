local servers = { "ts_ls", "eslint", "pyright", "gopls", "lua_ls", "jsonls", "cssls", "html" }

-- With no config, prettier silently reformats to its own defaults, clobbering
-- projects that follow another style (e.g. firsty-be is eslint-only, 4-space,
-- no prettier). So conform only runs prettier when the project opts in with a
-- prettier config file. (Misses the rarer package.json "prettier" key and
-- .editorconfig-only setups — acceptable; add them here if a project needs it.)
local prettier_config = {
  ".prettierrc", ".prettierrc.json", ".prettierrc.yml", ".prettierrc.yaml",
  ".prettierrc.json5", ".prettierrc.js", ".prettierrc.cjs", ".prettierrc.mjs",
  ".prettierrc.ts", ".prettierrc.toml", "prettier.config.js", "prettier.config.cjs",
  "prettier.config.mjs", "prettier.config.ts",
}
local function has_prettier_config(_, ctx)
  return #vim.fs.find(prettier_config, { path = ctx.dirname, upward = true }) > 0
end

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
    -- mason only auto-installs LSP servers; this ensures the standalone CLI
    -- formatters conform shells out to are present too (prettierd = a daemon
    -- wrapping prettier, much faster on repeated format-on-save).
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-tool-installer").setup({ ensure_installed = { "prettierd" } })
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        desc = "Format buffer",
      },
    },
    opts = {
      -- prettierd is a resident daemon wrapping prettier (fast repeated saves);
      -- prettier is the fallback. Both are gated on has_prettier_config below,
      -- so files in non-prettier projects are left untouched on save.
      formatters = {
        prettier  = { condition = has_prettier_config },
        prettierd = { condition = has_prettier_config },
      },
      formatters_by_ft = {
        javascript      = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescript      = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        json            = { "prettierd", "prettier", stop_after_first = true },
        jsonc           = { "prettierd", "prettier", stop_after_first = true },
        css             = { "prettierd", "prettier", stop_after_first = true },
        html            = { "prettierd", "prettier", stop_after_first = true },
        yaml            = { "prettierd", "prettier", stop_after_first = true },
        markdown        = { "prettierd", "prettier", stop_after_first = true },
      },
      -- Format on :w. No lsp_format fallback here on purpose — only the
      -- prettier filetypes above auto-format; other filetypes stay manual
      -- (via <leader>cf, which does fall back to the LSP formatter).
      format_on_save = { timeout_ms = 2000 },
    },
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
          -- <leader>cf (format) is owned by conform.nvim, which prefers prettier
          -- and falls back to the LSP formatter for other filetypes.
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
