---@class Snips
local M = {}
-- to escape ESC, this will contains key and the process name(the ssh client)
_G.term_esc = {}

---Return a list of lines selected in the current buffer(visual mode)
---@return {}
function M.get_selected_lines()
    local start_line = vim.api.nvim_buf_get_mark(0, "<")[1]
    local end_line = vim.api.nvim_buf_get_mark(0, ">")[1]

    local lines = {}
    for line = start_line, end_line do
        table.insert(lines, vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1])
    end

    return lines
end

---Return the file extension of the current buffer
---@return string
function M.get_file_extension()
    local current_buffer = vim.api.nvim_get_current_buf()
    local file_name = vim.api.nvim_buf_get_name(current_buffer)
    local file_extension = file_name:match("%.([^%.]+)$")
    return file_extension
end

---Split screen and past the content inside the new buffer
function M.split_and_insert(content)
    -- split and go inside the new splitted window
    vim.cmd("split")
    vim.cmd("wincmd j")

    -- Create a new empty buffer and set the content
    vim.api.nvim_command("enew")
    -- Make the new buffer as a temp buffer
    local bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
    vim.api.nvim_buf_set_option(bufnr, "bufhidden", "delete")
    vim.api.nvim_buf_set_option(bufnr, "swapfile", false)
    vim.api.nvim_buf_set_option(bufnr, "buflisted", false)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<C-w>q", { noremap = true, silent = true })
    -- Split the content into lines
    local lines = vim.split(vim.trim(content), "\n")
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
    vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
    vim.cmd("resize -10")
end

---Extract the url from snips.sh output
function M:yank_shared_url(cleaned_output, silent)
    local id = cleaned_output:match("id:%s*(%S+)")
    if id then
        local url = string.format("https://snips.sh/f/%s", id)
        vim.fn.setreg(self.opts.yank_register, url)
        if not silent then
          vim.print("SNIPS URL: " .. url .. " (Copied to your clipboard.)")
        end
    elseif not silent then
        vim.print(cleaned_output)
    end
end

---Execute the ssh command line to send the file on snips
function M.execute_snips_command()
    local selected_lines = {}
    for _, line in ipairs(M.get_selected_lines()) do
        table.insert(selected_lines, line)
    end

    if selected_lines == nil or #selected_lines == 0 then
        vim.print("SNIPS::ERROR:: No lines selected.")
        return
    end

    local content = table.concat(selected_lines, "\n")

    local ext = M.get_file_extension()
    local temp_file = os.tmpname()
    if ext ~= nil then
        temp_file = temp_file .. "." .. ext
    end

    local file = io.open(temp_file, "w")

    -- because i miss the simplicity of golang
    if file == nil then
        vim.print("SNIPS::ERROR:: Failed to create temporary file.")
        return
    end
    local success, error_message =
    pcall(
    function()
        file:write(content)
        file:close()
    end
    )
    if not success then
        vim.print("SNIPS::ERROR:: While writing to or closing the temporary file:", error_message)
        return
    end

    local command = M:command_factory(temp_file, ext)
    local output = io.popen(command):read("*a")
    -- To remove terminal colors
    local cleaned_output = output:gsub("\27%[[%d;]+m", "")

    if M.opts.post_behavior == "yank" then
        M:yank_shared_url(cleaned_output)
    elseif M.opts.post_behavior == "echo_and_yank" then
        M:yank_shared_url(cleaned_output, true)
        M.split_and_insert(cleaned_output)
    else
        -- Create a new empty buffer and paste the output of the code there
        M.split_and_insert(cleaned_output)
    end

    -- we erase the tmp file
    os.remove(temp_file)
end

---To capture ESC on snips UI, we need those three methods
local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

_G.term_esc.smart_esc = function(term_pid)
    local function find_process(pid)
        local p = vim.api.nvim_get_proc(pid)
        if _G.term_esc.except[p.name] then
            return true
        end
        for _, v in ipairs(vim.api.nvim_get_proc_children(pid)) do
            if find_process(v) then
                return true
            end
        end
        return false
    end

    if find_process(term_pid) then
        return t(_G.term_esc.key)
    else
        return t "<C-\\><C-n>"
    end
end

local set = function(table)
    local ret = {}
    for _, v in ipairs(table) do
        ret[v] = true
    end
    return ret
end

---to call the terminal escape on Esc
function M.escape_esc()
    _G.term_esc.key = "<Esc>"
    _G.term_esc.except = set({"ssh"})

    vim.api.nvim_set_keymap(
        "t",
        _G.term_esc.key,
        "v:lua.term_esc.smart_esc(b:terminal_job_pid)",
        {noremap = true, expr = true}
    )
end

---To open the snips terminal UI for all availabe snips
function M.list_snips(ssh_command)
    ssh_command = ssh_command or "ssh"

    vim.cmd("split")
    vim.cmd("wincmd j")

    vim.api.nvim_command("enew")

    local command = string.format("%s snips.sh", ssh_command)
    vim.fn.termopen(command)

    vim.cmd("startinsert")

    -- escape ESC
    M.escape_esc()
end

function M:command_factory(file_path, extension)
    local extension_args = ""

    -- We force an extension if we detect that there is one
    if extension ~= nil then
        extension_args = "-- --ext " .. extension
    end

    return string.format(
        "%s %s | %s %s %s",
        self.opts.cat_cmd,
        file_path,
        self.opts.ssh_cmd,
        self.opts.snips_host,
        extension_args
    )
end

-- Setup user settings.
function M.setup(opts)
    -- nothing defined yet
    local default_opts = {
        snips_host = "snips.sh",
        post_behavior = "echo", -- or "yank"
        yank_register = "+",
        cat_cmd = "cat",
        ssh_cmd = "ssh"
    }
    M.opts = vim.tbl_extend("keep", opts, default_opts)
end

-- yup, we return the module at the end
return M
