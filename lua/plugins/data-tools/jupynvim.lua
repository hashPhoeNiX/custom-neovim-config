return {
  "sheng-tse/jupynvim",
  -- Only loaded on demand by notebook-picker.lua; never auto-starts.
  lazy = true,
  -- Build the Rust backend binary. Requires cargo on PATH.
  build = function()
    local core = vim.fn.stdpath("data") .. "/lazy/jupynvim/core"
    local out = vim.fn.system({
      "cargo", "build", "--release",
      "--manifest-path", core .. "/Cargo.toml",
    })
    if vim.v.shell_error ~= 0 then
      vim.notify("jupynvim: cargo build failed:\n" .. out, vim.log.levels.ERROR)
    end
  end,
  config = function()
    require("jupynvim").setup({
      log_level = "info",
      image_renderer = "placeholder", -- Kitty unicode placeholders (works with Ghostty/WezTerm)
    })
  end,
}
