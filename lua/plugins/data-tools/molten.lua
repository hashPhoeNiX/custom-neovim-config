-- Provide a command to create a blank new Python notebook
-- note: the metadata is needed for Jupytext to understand how to parse the notebook.
-- if you use another language than Python, you should change it in the template.
local default_notebook = [[
  {
    "cells": [
     {
      "cell_type": "code",
      "execution_count": null,
      "metadata": {},
      "outputs": [],
      "source": [
        ""
      ]
     }
    ],
    "metadata": {
     "kernelspec": {
      "display_name": "Python 3",
      "language": "python",
      "name": "python3"
     },
     "language_info": {
      "codemirror_mode": {
        "name": "ipython"
      },
      "file_extension": ".py",
      "mimetype": "text/x-python",
      "name": "python",
      "nbconvert_exporter": "python",
      "pygments_lexer": "ipython3"
     }
    },
    "nbformat": 4,
    "nbformat_minor": 5
  }
]]

local function new_notebook(filename)
  local path = filename .. ".ipynb"
  local file = io.open(path, "w")
  if file then
    file:write(default_notebook)
    file:close()
    vim.cmd("edit " .. path)
  else
    print("Error: Could not open new notebook file for writing.")
  end
end

-- automatically import output chunks from a jupyter notebook
-- tries to find a kernel that matches the kernel in the jupyter notebook
-- falls back to a kernel that matches the name of the active venv (if any)
local imb = function(e) -- init molten buffer
  vim.schedule(function()
    local kernels = vim.fn.MoltenAvailableKernels()
    local try_kernel_name = function()
      local metadata = vim.json.decode(io.open(e.file, "r"):read("a"))["metadata"]
      return metadata.kernelspec.name
    end
    local ok, kernel_name = pcall(try_kernel_name)
    if not ok or not vim.tbl_contains(kernels, kernel_name) then
      kernel_name = nil
      local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
      if venv ~= nil then
        kernel_name = string.match(venv, "/.+/(.+)")
      end
    end
    if kernel_name ~= nil and vim.tbl_contains(kernels, kernel_name) then
      vim.cmd(("MoltenInit %s"):format(kernel_name))
    end
    vim.cmd("MoltenImportOutput")
  end)
end

return {
  --{ --commented out: can't find plugin in nixpkgs
  --	"bluz71/vim-moonfly-colors",
  --	lazy = false,
  --	priority = 1000,
  --	config = function()
  --		vim.cmd.syntax("enable")
  --		vim.cmd.colorscheme("moonfly")

  --		vim.api.nvim_set_hl(0, "MoltenOutputBorder", { link = "Normal" })
  --		vim.api.nvim_set_hl(0, "MoltenOutputBorderFail", { link = "MoonflyCrimson" })
  --		vim.api.nvim_set_hl(0, "MoltenOutputBorderSuccess", { link = "MoonflyBlue" })
  --	end,
  --},
  {
    "benlubas/molten-nvim",
    version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
    lazy = false,
    dependencies = { "3rd/image.nvim" },
    build = ":UpdateRemotePlugins",
    init = function()
      --vim.g.python3_host_prog =
      --	vim.fn.expand("/etc/profiles/per-user/oluwapelumiadeosun/bin/myHomeModuleNvim-python3")
      -- vim.g.molten_auto_open_output = true
      vim.g.molten_image_provider = "image.nvim"
      -- vim.g.molten_output_win_max_height = 12
      -- vim.g.molten_output_win_hide_on_leave = false
      vim.g.molten_output_virt_lines = true
      -- vim.g.molten_output_show_more = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_wrap_output = false
      -- vim.g.molten_virt_text_max_lines = 1

      local which_key = require("which-key")

      which_key.add({
        { "<leader>m", group = " Molten group" },
      })

      -- KEYMAPS
      -- New Cell
      vim.keymap.set("n", "<leader>mnc", function()
        local line = vim.fn.getline('.')
        if vim.fn.search("^```$", "nW") > 0 then -- If we can find a closing ```
          vim.fn.search("^```$")                 -- Go to it
        end
        vim.cmd("normal! o")                     -- New line
        vim.fn.append(vim.fn.line('.'), { "", "```python", "", "```" })
        vim.fn.cursor(vim.fn.line('.') + 3, 1)
        vim.cmd("startinsert")
      end, { desc = "Molten New code cell" })

      -- vim.keymap.set("n", "<leader>nc", "o<CR>```python<CR><CR>```<Esc>ki",
      --   { desc = "New code cell" }
      -- )

      vim.keymap.set("n", "<leader>mi", ":MoltenInit<CR>", {
        silent = true,
        desc = "Molten Init Kernel",
      })

      vim.keymap.set("n", "<leader>mdi", ":MoltenDeinit<CR>", {
        silent = true,
        desc = "Molten Deinit Kernel",
      })

      vim.keymap.set("n", "<leader>ml", ":MoltenEvaluateLine<CR>", {
        silent = true,
        desc = "Molten Evaluate Line",
      })
      -- vim.keymap.set("n", "<leader>ml", ":MoltenReevaluateCell<CR>", {
      --   silent = true,
      --   desc = "Molten Evaluate Line",
      -- })

      vim.keymap.set(
        "v",
        "<leader>mv",
        ":<C-u>MoltenEvaluateVisual<CR>gv<ESC>",
        { silent = true, desc = "Molten Evaluate Visual" }
      )
      vim.keymap.set("n", "<leader>mh", ":MoltenHideOutput<CR>", {
        silent = true,
        desc = "Molten Hide Output",
      })
      vim.keymap.set("n", "<leader>ms", ":MoltenShowOutput<CR>", {
        silent = true,
        desc = "Molten Show Output",
      })

      vim.keymap.set(
        "n",
        "<leader>mo",
        ":noautocmd MoltenEnterOutput<CR>",
        { silent = true, desc = "Molten Enter Output" }
      )
      vim.keymap.set(
        "n",
        "<localleader>e",
        ":MoltenEvaluateOperator<CR>",
        { desc = "evaluate operator", silent = true }
      )
      vim.keymap.set(
        "n",
        "<localleader>os",
        ":noautocmd MoltenEnterOutput<CR>",
        { desc = "open output window", silent = true }
      )
      vim.keymap.set(
        "n",
        "<localleader>mr",
        ":MoltenReevaluateCell<CR>",
        { desc = "re-eval cell", silent = true }
      )
      vim.keymap.set(
        "v",
        "<localleader>r",
        ":<C-u>MoltenEvaluateVisual<CR>gv",
        { desc = "execute visual selection", silent = true }
      )
      vim.keymap.set("n", "<localleader>md", ":MoltenDelete<CR>", { desc = "delete Molten cell", silent = true })
      -- if you work with html outputs:
      vim.keymap.set(
        "n",
        "<localleader>mx",
        ":MoltenOpenInBrowser<CR>",
        { desc = "open output in browser", silent = true }
      )

      -- Extra config
      vim.api.nvim_create_user_command("NewNotebook", function(opts)
        new_notebook(opts.args)
      end, {
        nargs = 1,
        complete = "file",
      })

      -- automatically import output chunks from a jupyter notebook
      vim.api.nvim_create_autocmd("BufAdd", {
        pattern = { "*.ipynb" },
        callback = imb,
      })

      -- we have to do this as well so that we catch files opened like nvim ./hi.ipynb
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = { "*.ipynb" },
        callback = function(e)
          if vim.api.nvim_get_vvar("vim_did_enter") ~= 1 then
            imb(e)
          end
        end,
      })

      -- automatically export output chunks to a jupyter notebook on write
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = { "*.ipynb" },
        callback = function()
          if require("molten.status").initialized() == "Molten" then
            vim.cmd("MoltenExportOutput!")
          end
        end,
      })

      -- change the configuration when editing a python file
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*.py",
        callback = function(e)
          if string.match(e.file, ".otter.") then
            return
          end
          if require("molten.status").initialized() == "Molten" then -- this is kinda a hack...
            vim.fn.MoltenUpdateOption("virt_lines_off_by_1", false)
            vim.fn.MoltenUpdateOption("virt_text_output", false)
          else
            vim.g.molten_virt_lines_off_by_1 = false
            vim.g.molten_virt_text_output = false
          end
        end,
      })

      -- Undo those config changes when we go back to a markdown or quarto file
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = { "*.qmd", "*.md", "*.ipynb" },
        callback = function(e)
          if string.match(e.file, ".otter.") then
            return
          end
          if require("molten.status").initialized() == "Molten" then
            vim.fn.MoltenUpdateOption("virt_lines_off_by_1", true)
            vim.fn.MoltenUpdateOption("virt_text_output", true)
          else
            vim.g.molten_virt_lines_off_by_1 = true
            vim.g.molten_virt_text_output = true
          end
        end,
      })

      --vim.keymap.set("n", "<localleader>ip", function()
      --	local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
      --	if venv ~= nil then
      --		-- in the form of /home/benlubas/.virtualenvs/VENV_NAME
      --		venv = string.match(venv, "/.+/(.+)")
      --		vim.cmd(("MoltenInit %s"):format(venv))
      --	else
      --		vim.cmd("MoltenInit python3")
      --	end
      --end, { desc = "Initialize Molten for python3", silent = true })
    end,
  },
}
