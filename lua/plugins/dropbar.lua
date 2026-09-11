return {
  "Bekaboo/dropbar.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- jupynvim's notebook buffers use filetype = <kernel language> (e.g.
    -- "python"), which satisfies dropbar's default treesitter-parser check
    -- and turns winbar on there too. jupynvim does its own custom top-of-
    -- buffer rendering (virt_lines_above cell borders, kept in view via a
    -- hardcoded winrestview topfill on open) that assumes it owns the full
    -- window height; dropbar's winbar stealing a row breaks that math and
    -- clips the first cell's code out of view. jupynvim sets
    -- vim.b[buf].jupynvim_filetype on every buffer it manages, so use that
    -- as a reliable exclusion marker.
    local default_enable = require("dropbar.configs").opts.bar.enable
    require("dropbar").setup({
      bar = {
        enable = function(buf, win, info)
          if vim.b[buf].jupynvim_filetype then
            return false
          end
          return default_enable(buf, win, info)
        end,
      },
    })

    local dropbar_api = require("dropbar.api")
    vim.keymap.set("n", "<leader>;", dropbar_api.pick, { desc = "Pick symbol in winbar" })
    vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of context" })
    vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
  end,
}
