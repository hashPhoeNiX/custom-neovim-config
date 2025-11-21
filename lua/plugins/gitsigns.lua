return {
  "lewis6991/gitsigns.nvim",
  config = function()
    local auto_hunk_preview_enabled = false
    local auto_hunk_preview_window_enabled = false
    local hunk_preview_timer = nil
    local hunk_preview_window_timer = nil

    require("gitsigns").setup({
      -- numhl = true,
      -- linehl = false,
      -- word_diff = false,
      -- attach_to_untracked = true,
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 100,
        ignore_whitespace = false,
      },
      -- update_debounce = 100,
      on_attach = function(bufnr)
        local gitsigns = require('gitsigns')

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal({ ']c', bang = true })
          else
            gitsigns.nav_hunk('next')
          end
        end, { desc = "Next hunk" })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal({ '[c', bang = true })
          else
            gitsigns.nav_hunk('prev')
          end
        end, { desc = "Previous hunk" })

        -- Actions
        -- map('n', '<leader>hs', gitsigns.stage_hunk)
        -- map('n', '<leader>hr', gitsigns.reset_hunk)

        -- map('v', '<leader>hs', function()
        --   gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        -- end)

        -- map('v', '<leader>hr', function()
        --   gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        -- end)

        -- map('n', '<leader>hS', gitsigns.stage_buffer)
        -- map('n', '<leader>hR', gitsigns.reset_buffer)
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = "Preview hunk" })
        map('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = "Preview hunk inline" })

        map('n', '<leader>hb', function()
          gitsigns.blame_line({ full = true })
        end, { desc = "Blame line (full)" })

        map('n', '<leader>hd', gitsigns.diffthis, { desc = "Diff this" })

        map('n', '<leader>hD', function()
          gitsigns.diffthis('~')
        end, { desc = "Diff this (previous)" })

        -- map('n', '<leader>hQ', function() gitsigns.setqflist('all') end)
        -- map('n', '<leader>hq', gitsigns.setqflist)

        -- Toggles
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = "Toggle blame line" })
        -- map('n', '<leader>tw', gitsigns.toggle_word_diff)

        -- Text object
        map({ 'o', 'x' }, 'ih', gitsigns.select_hunk, { desc = "Select hunk" })

        -- Auto hunk preview on cursor move (inline)
        map('n', '<leader>ha', function()
          auto_hunk_preview_enabled = not auto_hunk_preview_enabled

          if auto_hunk_preview_enabled then
            -- Setup autocmd for auto-preview
            vim.api.nvim_create_autocmd('CursorMoved', {
              group = vim.api.nvim_create_augroup('GitSignsAutoPreview' .. bufnr, { clear = true }),
              buffer = bufnr,
              callback = function()
                -- Debounce to avoid previewing on every move
                if hunk_preview_timer then
                  hunk_preview_timer:stop()
                end

                hunk_preview_timer = vim.defer_fn(function()
                  -- Only preview if we're on a hunk
                  local hunk = gitsigns.get_hunks()[1]
                  if hunk then
                    gitsigns.preview_hunk_inline()
                  end
                end, 300) -- 300ms debounce
              end,
            })
            vim.notify("[gitsigns] Auto hunk preview (inline) enabled", vim.log.levels.INFO)
          else
            -- Disable autocmd
            vim.api.nvim_del_augroup_by_name('GitSignsAutoPreview' .. bufnr)
            if hunk_preview_timer then
              hunk_preview_timer:stop()
              hunk_preview_timer = nil
            end
            vim.notify("[gitsigns] Auto hunk preview (inline) disabled", vim.log.levels.INFO)
          end
        end, { desc = "Toggle auto hunk preview (inline)" })

        -- Auto hunk preview on cursor move (window)
        map('n', '<leader>hA', function()
          auto_hunk_preview_window_enabled = not auto_hunk_preview_window_enabled

          if auto_hunk_preview_window_enabled then
            -- Setup autocmd for auto-preview in floating window
            vim.api.nvim_create_autocmd('CursorMoved', {
              group = vim.api.nvim_create_augroup('GitSignsAutoPreviewWindow' .. bufnr, { clear = true }),
              buffer = bufnr,
              callback = function()
                -- Debounce to avoid previewing on every move
                if hunk_preview_window_timer then
                  hunk_preview_window_timer:stop()
                end

                hunk_preview_window_timer = vim.defer_fn(function()
                  -- Only preview if we're on a hunk
                  local hunk = gitsigns.get_hunks()[1]
                  if hunk then
                    gitsigns.preview_hunk()
                  end
                end, 300) -- 300ms debounce
              end,
            })
            vim.notify("[gitsigns] Auto hunk preview (window) enabled", vim.log.levels.INFO)
          else
            -- Disable autocmd
            vim.api.nvim_del_augroup_by_name('GitSignsAutoPreviewWindow' .. bufnr)
            if hunk_preview_window_timer then
              hunk_preview_window_timer:stop()
              hunk_preview_window_timer = nil
            end
            vim.notify("[gitsigns] Auto hunk preview (window) disabled", vim.log.levels.INFO)
          end
        end, { desc = "Toggle auto hunk preview (window)" })
      end,
    })
  end,
}
