-- rustaceanvim owns the rust-analyzer LSP.
-- Do NOT setup `rust_analyzer` in lsp.lua — would create a duplicate instance.
return {
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    lazy    = false, -- plugin is already lazy by ft
    ft      = { "rust" },
  },
}
