-- VSCode "Python Interactive Window"-style REPL: send lines/selections/
-- "# %%"-delimited blocks to a live ipython REPL in a split, with state
-- persisting across sends. Separate from Molten/Jupynvim (Jupyter-kernel-
-- backed, used for actual .ipynb notebooks with rich outputs) — this is a
-- plain REPL sender for iterative work in regular .py files.
return {
  "Vigemus/iron.nvim",
  config = function()
    local iron = require("iron.core")
    local view = require("iron.view")
    local common = require("iron.fts.common")

    iron.setup({
      config = {
        scratch_repl = true,
        repl_definition = {
          python = {
            command = { "ipython", "--no-autoindent" },
            format = common.bracketed_paste_python,
            block_dividers = { "# %%", "#%%" },
          },
        },
        repl_open_cmd = view.split.rightbelow("%40"),
        ignore_blank_lines = true,
      },
      keymaps = {
        toggle_repl = "<leader>ii",
        restart_repl = "<leader>iR",
        send_line = "<leader>il",
        send_paragraph = "<leader>ip",
        send_until_cursor = "<leader>iu",
        send_code_block = "<leader>ib",
        send_code_block_and_move = "<leader>in",
        send_file = "<leader>if",
        visual_send = "<leader>iv",
        send_motion = "<leader>iv",
        cr = "<leader>i<cr>",
        interrupt = "<leader>ix",
        exit = "<leader>iq",
        clear = "<leader>ic",
      },
      ignore_blank_lines = true,
    })

    local which_key = require("which-key")
    which_key.add({
      { "<leader>i", group = "Iron REPL" },
    })
  end,
}
