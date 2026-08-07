---@type lazy.LazySpec
return {
  'stevearc/overseer.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local ov = require 'overseer'

    ov.setup {
      task_list = {
        direction = 'bottom',
        min_height = 8,
        max_height = { 20, 0.2 },
      },
      form = { border = 'rounded' },
    }

    local function ctx()
      local file = vim.fn.expand '%:p'
      local base = vim.fn.fnamemodify(file, ':t')
      local out = '/tmp/ov-' .. vim.fn.fnamemodify(base, ':r') .. '.bin'
      return { file = file, base = base, out = out }
    end

    local function a_ctx(a)
      local c = ctx()
      c.tool = a.tool
      return c
    end

    local function first_exec(names)
      for _, n in ipairs(names) do
        if vim.fn.executable(n) == 1 then return n end
      end
    end

    local function compile_task(a, c, open_qf)
      return {
        name = 'compile ' .. c.base,
        cmd = a.build(c),
        strategy = { 'jobstart', use_terminal = false },
        components = {
          { 'on_output_quickfix', open = open_qf },
          'default',
        },
      }
    end

    local function run_task(a, c)
      return {
        name = 'run ' .. a.ft[1],
        cmd = a.run(c),
        components = { 'default' },
      }
    end

    local actions = {
      c = {
        ft = { 'c' },
        tools = { 'gcc', 'clang' },
        build = function(c) return { c.tool, c.file, '-o', c.out } end,
        run = function(c) return { c.out } end,
      },
      cpp = {
        ft = { 'cpp', 'cxx', 'cc', 'hpp' },
        tools = { 'g++', 'clang++' },
        build = function(c) return { c.tool, '-std=c++17', '-Wall', c.file, '-o', c.out } end,
        run = function(c) return { c.out } end,
      },
      rust = {
        ft = { 'rust' },
        tools = { 'cargo' },
        build = function() return { 'cargo', 'build' } end,
        run = function() return { 'cargo', 'run' } end,
      },
      zig = {
        ft = { 'zig' },
        tools = { 'zig' },
        build = function(c) return { 'zig', 'build-exe', c.file, '-femit-bin=' .. c.out } end,
        run = function(c) return { c.out } end,
      },
      python = {
        ft = { 'python' },
        tools = { 'python3' },
        run = function(c) return { 'python3', c.file } end,
      },
      go = {
        ft = { 'go' },
        tools = { 'go' },
        run = function(c) return { 'go', 'run', c.file } end,
      },
      ruby = {
        ft = { 'ruby' },
        tools = { 'ruby' },
        run = function(c) return { 'ruby', c.file } end,
      },
      javascript = {
        ft = { 'javascript' },
        tools = { 'bun', 'node' },
        run = function(c)
          if c.tool == 'bun' then return { 'bun', 'run', c.file } end
          return { 'node', c.file }
        end,
      },
      typescript = {
        ft = { 'typescript' },
        tools = { 'bun', 'tsx', 'ts-node', 'node' },
        run = function(c)
          if c.tool == 'bun' then return { 'bun', 'run', c.file } end
          if c.tool == 'tsx' then return { 'tsx', c.file } end
          if c.tool == 'ts-node' then return { 'node', '--loader=ts-node/esm', c.file } end
          return { 'node', c.file }
        end,
      },
      lua = {
        ft = { 'lua' },
        tools = { 'lua' },
        run = function(c) return { 'lua', c.file } end,
      },
      sh = {
        ft = { 'sh', 'bash' },
        tools = { 'sh' },
        run = function(c) return { 'sh', c.file } end,
      },
    }

    for _, a in pairs(actions) do
      local tool = first_exec(a.tools or {})

      if tool then
        a.tool = tool

        if a.build then
          ov.register_template {
            name = 'compile ' .. a.ft[1],
            tags = { ov.TAG.BUILD },
            condition = { filetype = a.ft },
            builder = function() return compile_task(a, a_ctx(a), true) end,
          }
        end

        if a.run then
          ov.register_template {
            name = 'run ' .. a.ft[1],
            tags = { ov.TAG.RUN },
            condition = { filetype = a.ft },
            builder = function() return run_task(a, a_ctx(a)) end,
          }
        end

        if a.build and a.run then
          ov.register_template {
            name = 'compile & run ' .. a.ft[1],
            tags = { ov.TAG.BUILD, ov.TAG.RUN },
            condition = { filetype = a.ft },
            builder = function()
              local c = a_ctx(a)
              return {
                name = 'compile & run ' .. a.ft[1],
                strategy = {
                  'orchestrator',
                  tasks = { compile_task(a, c, false), run_task(a, c) },
                },
              }
            end,
          }
        end
      end
    end

    vim.api.nvim_create_user_command('Run', function()
      ov.run_task { tags = { ov.TAG.RUN } }
    end, { desc = 'Run the default action for the current language' })

    vim.api.nvim_create_user_command('Build', function()
      ov.run_task { tags = { ov.TAG.BUILD } }
    end, { desc = 'Compile the current file (errors to quickfix)' })

    vim.api.nvim_create_user_command('BuildRun', function()
      ov.run_task { tags = { ov.TAG.BUILD, ov.TAG.RUN } }
    end, { desc = 'Compile, then run only if the compile succeeds' })

    vim.keymap.set('n', '<leader>rr', function()
      ov.run_task({}, function(task)
        if task then ov.run_action(task, 'open hsplit') end
      end)
    end, { desc = 'Run action and open output pane' })

    vim.keymap.set('n', '<leader>rl', function()
      local ts = ov.list_tasks { status = { 'SUCCESS', 'FAILURE', 'CANCELED' } }
      if vim.tbl_isempty(ts) then
        vim.notify('No finished task to rerun', vim.log.levels.INFO)
        return
      end
      local latest = ts[1]
      for _, t in ipairs(ts) do
        if (t.time_start or 0) > (latest.time_start or 0) then latest = t end
      end
      ov.run_action(latest, 'restart')
    end, { desc = 'Re-run the most recent task' })

    vim.keymap.set('n', '<leader>ro', function() ov.toggle { direction = 'bottom' } end, { desc = 'Open task list' })

    vim.keymap.set('n', '<leader>rs', function()
      local ts = ov.list_tasks { status = { 'RUNNING', 'PENDING' } }
      for _, t in ipairs(ts) do t:stop() end
      if vim.tbl_isempty(ts) then vim.notify('Nothing running', vim.log.levels.INFO) end
    end, { desc = 'Stop running task(s)' })

    vim.keymap.set('n', '<leader>rc', '<cmd>cclose<CR>', { desc = 'Close the compile quickfix' })
  end,
}