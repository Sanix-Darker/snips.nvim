local Snips = require('..lua.snips')
local vim = {}
vim.api = {}

-- Mocking the 'vim' global variable
_G.vim = vim

-- Test for the 'get_selected_lines' function
describe('get_selected_lines', function()
    it('should return a table of selected lines', function()
        -- Mock the required Vim API functions
        vim.api.nvim_buf_get_mark = function(_, _)
            return {1, 3} -- Mocking the start and end lines
        end
        vim.api.nvim_buf_get_lines = function(_, start, _, _)
            return {"line 1", "line 2", "line 3"} -- Mocking buffer lines
        end

        local expected = {"line 1"}
        local result = Snips.get_selected_lines()
        assert.are.same(expected, result)
    end)
end)

-- Test for the 'get_file_extension' function
describe('get_file_extension', function()
    it('should return the file extension of the current buffer', function()
        -- Mock the required Vim API functions
        vim.api.nvim_get_current_buf = function()
            return 1 -- Mocking the current buffer
        end
        vim.api.nvim_buf_get_name = function(_)
            return "path/to/file.lua" -- Mocking the file name
        end

        local expected = "lua"
        local result = Snips.get_file_extension()
        assert.are.equal(expected, result)
    end)
end)


-- Test for the 'escape_esc' function
describe('escape_esc', function()
    it('should set the key mapping for terminal escape', function()
        -- Mock the required Vim API functions
        vim.api.nvim_set_keymap = function(_, _, _, opts)
            assert.are.equal("v:lua.term_esc.smart_esc(b:terminal_job_pid)", _)
            assert.are.equal("<Esc>", _G.term_esc.key)
        end

        Snips.escape_esc()
    end)
end)

-- Test for the 'command_factory' function
describe('command_factory', function()
    it('should return the formatted command based on options', function()
        Snips.opts = { snips_host = "snips.sh", cat_cmd = "cat", ssh_cmd = "ssh", post_behavior = "echo" }

        local expected_cmd = "cat /tmp/tempfile123.lua | ssh snips.sh -- --ext lua"
        local result = Snips:command_factory("/tmp/tempfile123.lua", "lua")
        assert.are.equal(expected_cmd, result)
    end)

    it('should return the formatted command without extension argument if extension is nil', function()
        Snips.opts = { snips_host = "snips.sh", cat_cmd = "cat", ssh_cmd = "ssh", post_behavior = "echo" }

        local expected_cmd = "cat /tmp/tempfile123 | ssh snips.sh "
        local result = Snips:command_factory("/tmp/tempfile123", nil)
        assert.are.equal(expected_cmd, result)
    end)
end)
