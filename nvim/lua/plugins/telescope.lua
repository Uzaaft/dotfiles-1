return {
  {
    "nvim-telescope/telescope.nvim",
    version = "^0.1",
    -- or                              , branch = '2.1.1',
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
    },
    config = function()
      local builtin = require "telescope.builtin"
      -- Find files
      vim.keymap.set("n", "<leader>ff", function()
        builtin.find_files {
          hidden = true,
          find_command = {
            "/usr/bin/fd",
            "-H",
            "--type",
            "f",
            "-I",
            "-E",
            ".git",
            "-E",
            ".idea",
            "-E",
            "target",
            "-E",
            "node_modules",
          },
        }
      end, { noremap = true, silent = true, desc = "Find files using fd" })
      -- Grep current file
      vim.keymap.set("n", "<leader>gr", function()
        builtin.live_grep {
          additional_args = { "--smart-case" },
        }
      end, { desc = "Live grep whole project" })
      -- Find in current
      vim.keymap.set("n", "<leader>fc", builtin.current_buffer_fuzzy_find, { desc = "Find in current buffer" })
      -- Find buffers
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      -- Search in help
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find in help" })

      vim.keymap.set("n", "<leader>fS", builtin.lsp_document_symbols, { desc = "Search in document symbols" })

      local actions = require "telescope.actions"
      require("telescope").setup {
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown {
              -- even more opts
            },
          },
        },
        defaults = {
          mappings = {
            i = {
              ["<C-u>"] = false,
              ["<esc>"] = actions.close,
              ["<A-c>"] = actions.delete_buffer,
            },
            n = {
              ["<esc>"] = actions.close,
              ["<A-c>"] = actions.delete_buffer,
            },
          },
        },
      }

      require("telescope").load_extension "ui-select"
    end,
  },
}
