-- Completion engine: blink.cmp (faster than nvim-cmp, native LSP integration)
return {
  {
    "saghen/blink.cmp",
    version = "*",
    opts = {
      keymap     = { preset = "default" },
      appearance = { nerd_font_variant = "mono" },
      sources    = { default = { "lsp", "path", "snippets", "buffer" } },
      signature  = { enabled = true },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
      },
    },
  },
}
