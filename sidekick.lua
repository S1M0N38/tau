return {
  "folke/sidekick.nvim",
  dev = true,
  opts = {
    cli = {
      win = {
        keys = {
          shift_cr = {
            "<S-CR>",
            function(self)
              if self:is_running() then
                vim.api.nvim_chan_send(self.job, "\x1b[13;2u")
              end
            end,
            mode = "t",
            desc = "CSI-u Shift+Enter",
          },
          alt_cr = {
            "<A-CR>",
            function(self)
              if self:is_running() then
                vim.api.nvim_chan_send(self.job, "\x1b[13;3u")
              end
            end,
            mode = "t",
            desc = "CSI-u Alt+Enter",
          },
          stopinsert_esc = {
            "<esc>",
            function(self)
              self.esc_timer = self.esc_timer or vim.uv.new_timer()
              if self.esc_timer:is_active() then
                self.esc_timer:stop()
                vim.cmd.stopinsert()
              else
                self.esc_timer:start(200, 0, function() end)
                return "<esc>"
              end
            end,
            mode = "t",
            expr = true,
            desc = "enter normal mode",
          },
        },
      },
      mux = {
        backend = "tmux",
        enabled = true,
        -- Session naming: "tau-pi-1", "tau-pi-2", "tau-claude-1", etc.
        -- {parent} = current tmux session name (the project)
        -- {tool} = AI tool name
        -- {n} = auto-incremented instance number
        name = "{parent}-{tool}-{n}",
        -- create = "split",
        -- split = {
        --   vertical = true, -- side by side with LazyVim
        --   size = 0.5,
        -- },
      },
    },
  },
  keys = {
    {
      "<leader>ac",
      function()
        require("sidekick.cli").spawn({ name = "pi" })
      end,
    },
    {
      "<leader>as",
      function()
        require("sidekick.cli").sessions()
      end,
      desc = "Switch tmux session",
    },
  },
}
