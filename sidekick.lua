return {
  "folke/sidekick.nvim",
  dev = true,
  opts = {
    cli = {
      win = {
        keys = {
          ctrl_p = {
            "<C-p>",
            function(self)
              if self:is_running() then
                vim.api.nvim_chan_send(self.job, "\x1b[112;5u")
              end
            end,
            mode = "t",
            desc = "CSI-u <C-p>",
          },
          shift_cr = {
            "<S-CR>",
            function(self)
              if self:is_running() then
                vim.api.nvim_chan_send(self.job, "\x1b[13;2u")
              end
            end,
            mode = "t",
            desc = "CSI-u <S-CR>",
          },
          alt_cr = {
            "<A-CR>",
            function(self)
              if self:is_running() then
                vim.api.nvim_chan_send(self.job, "\x1b[13;3u")
              end
            end,
            mode = "t",
            desc = "CSI-u <M-CR>",
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
        -- create = "split",
        -- split = {
        --   vertical = true, -- side by side with LazyVim
        --   size = 0.5,
        -- },
      },
    },
  },
  keys = {
    -- spawn / attach
    {
      "<leader>ac",
      function()
        require("sidekick.cli").select({ name = "pi" })
      end,
      desc = "Spawn pi",
    },
    {
      "<leader>aC",
      function()
        require("sidekick.cli").select()
      end,
      desc = "Select tool",
    },
    -- sessions
    {
      "<leader>as",
      function()
        require("sidekick.cli").sessions()
      end,
      desc = "Sessions",
    },
    -- terminal toggle / focus
    {
      "<leader>at",
      function()
        require("sidekick.cli").toggle()
      end,
      desc = "Toggle terminal",
    },
    -- send
    {
      "<leader>ap",
      function()
        require("sidekick.cli").prompt()
      end,
      desc = "Send prompt",
    },
    -- hide / close
    {
      "<leader>ah",
      function()
        require("sidekick.cli").hide()
      end,
      desc = "Hide terminal",
    },
    {
      "<leader>aq",
      function()
        require("sidekick.cli").close()
      end,
      desc = "Close session",
    },
  },
}
