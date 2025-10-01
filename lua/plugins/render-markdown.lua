return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
  -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
  -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    enabled = true,
    render_modes = true, -- Default: { 'n', 'c', 't' } -- normal, command, terminal
    completions = {
      blink = {
        enabled = true
      },
    }
  },
  config = function(_, opts)
    local rm = require("render-markdown")
    rm.setup(opts)

    -- Helper to detect notebook / molten buffer
    local function is_notebook_buf(bufnr)
      local ft = vim.bo[bufnr].filetype or ""
      -- adjust if your notebook ft is json or jsonc
      if ft == "ipynb" or ft == "json" or ft == "jsonc" then
        return true
      end
      local ok, status = pcall(require, "molten.status")
      if ok and status.initialized() == "Molten" then
        return true
      end
      return false
    end

    -- Autocmd: disable or enable on BufEnter
    vim.api.nvim_create_autocmd("BufEnter", {
      callback = function(ev)
        local bufnr = ev.buf
        if is_notebook_buf(bufnr) then
          if rm.disable_buffer then
            rm.disable_buffer(bufnr)
          else
            vim.b[bufnr].render_markdown_disable = true
          end
        else
          if rm.enable_buffer then
            rm.enable_buffer(bufnr)
          end
        end
      end,
    })

    -- -- (Optional) Wrap the internal “should_render” logic if available
    -- if rm.manager and rm.manager.should_render then
    --   local orig = rm.manager.should_render
    --   rm.manager.should_render = function(bufnr, ...)
    --     if is_notebook_buf(bufnr) then
    --       return false
    --     end
    --     return orig(bufnr, ...)
    --   end
  end
}
