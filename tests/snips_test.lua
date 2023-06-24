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
    Snips.opts = { snips_host = "snips.sh", cat_cmd = "cat", ssh_cmd = "ssh", post_behavior = "echo" }

    it('should return the formatted command based on options', function()
        local expected_cmd = "cat /tmp/tempfile123.lua | ssh snips.sh -- --ext lua "
        local result = Snips:command_factory("/tmp/tempfile123.lua", "lua")
        assert.are.equal(expected_cmd, result)
    end)

    it('should return the formatted command without extension argument if extension is nil', function()
        local expected_cmd = "cat /tmp/tempfile123 | ssh snips.sh  "
        local result = Snips:command_factory("/tmp/tempfile123", nil)
        assert.are.equal(expected_cmd, result)
    end)
    it('should return the formatted command without extension argument if extension is nil with private flag', function()
        local expected_cmd = "cat /tmp/tempfile123 | ssh snips.sh -- --private "
        local result = Snips:command_factory("/tmp/tempfile123", nil, true)
        assert.are.equal(expected_cmd, result)
    end)

    it('should return the formatted command based on options with private flag', function()
        local expected_cmd = "cat /tmp/tempfile123.lua | ssh snips.sh -- --ext lua --private "
        local result = Snips:command_factory("/tmp/tempfile123.lua", "lua", true)
        assert.are.equal(expected_cmd, result)
    end)
end)


-- Test for the 'command_factory' function
describe('args_builder', function()
    it('should build args concatenation as expected', function()
        -- Test case 1: No arguments provided
        local result1 = Snips.args_builder()
        assert.are.equal(result1, " ")

        -- Test case 2: Only private argument provided
        local result2 = Snips.args_builder(true)
        assert.are.equal(result2, "-- --private ")

        -- Test case 3: Only extension argument provided
        local result3 = Snips.args_builder(nil, "lua")
        assert.are.equal(result3, "-- --ext lua ")

        -- Test case 4: Both private and extension arguments provided
        local result4 = Snips.args_builder(true, "py")
        assert.are.equal(result4, "-- --ext py --private ")

        -- Test case 5: Neither private nor extension arguments provided
        local result5 = Snips.args_builder(nil, nil)
        assert.are.equal(result5, " ")

        -- Test case 6: Only extension argument provided with nil private argument
        local result6 = Snips.args_builder(nil, "txt")
        assert.are.equal(result6, "-- --ext txt ")
    end)
end)
