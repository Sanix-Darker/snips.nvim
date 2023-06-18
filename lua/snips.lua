---@class Snips
local M = {}

---Return a list of lines selected in the current buffer(visual mode)
---@return {}
function M.get_selected_lines()
    local start_line = vim.api.nvim_buf_get_mark(0, "<")[1]
    local end_line = vim.api.nvim_buf_get_mark(0, ">")[1]

    local lines = {}
    for line = start_line, end_line do
        table.insert(
            lines,
            vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
        )
    end

    return lines
end

---Return the file extension of the current buffer
---@return string
function M.get_file_extension()
    -- because we need/want hightlighting
    -- unfortunatelly, snips.sh infer the type itself on their server...
    -- so even if you specify the type extension here... it will guess
    -- something else... however... am keeping this function
    local current_buffer = vim.api.nvim_get_current_buf()
    local file_name = vim.api.nvim_buf_get_name(current_buffer)
    local file_extension = file_name:match("%.([^%.]+)$")
    return file_extension
end


---Split screen and past the content inside the new buffer
function M.split_and_insert(content)
    -- split and go inside the new splitted window
    vim.cmd('split')
    vim.cmd('wincmd j')

    -- Create a new empty buffer and set the content
    vim.api.nvim_command('enew')
    -- Split the content into lines
    local lines = vim.split(content, '\n')
    vim.api.nvim_buf_set_lines(0, 0, -1, true, lines)
    vim.cmd('resize -10')
end


---Extract the url from snips.sh output
function M.yank_shared_url(cleaned_output)
  -- Extract the URL from the output (kind of salty... idc as soon as it works)
  -- commenting this because at the end, am not quite sure we need to extract
  -- the url, the user would also want to see the whole command output, idk?
  local url = cleaned_output:match("URL 🔗%s+(%S+)")
  if url then
    print("SNIPS URL: " .. url)
  else
    print(cleaned_output)
  end
end


---Execute the ssh command line to send the file on snips
function M.execute_snips_command()
    local selected_lines = {}
    for _, line in ipairs(M.get_selected_lines()) do
      table.insert(selected_lines, line)
    end

    if selected_lines == nil or #selected_lines == 0 then
        print("SNIPS::ERROR:: No lines selected.")
        return
    end

    local content = table.concat(selected_lines, "\n")

    local temp_file = os.tmpname() .. "." .. M.get_file_extension()
    local file = io.open(temp_file, "w")

    -- because i miss the simplicity of golang
    if file == nil then
        print("SNIPS::ERROR:: Failed to create temporary file.")
        return
    end
    local success, error_message = pcall(function()
        file:write(content)
        file:close()
    end)
    if not success then
        print("SNIPS::ERROR:: While writing to or closing the temporary file:", error_message)
        return
    end

    -- yes... you should have at leas "cat " on your system... easy
    local ssh_command = string.format("cat %s | ssh snips.sh", temp_file)
    local output = io.popen(ssh_command):read("*a")
    -- to remove fancy colorisations
    local cleaned_output = output:gsub("\27%[[%d;]+m", "")

    if M.opts.post_behavior == "echo" then
      -- Create a new empty buffer and paste the output of the code there
      M.split_and_insert(cleaned_output)
    else
      M.yank_shared_url(cleaned_output)
    end

    -- we erase the tmp file
    os.remove(temp_file)
end

-- Setup user settings.
function M.setup(opts)
    -- nothing defined yet
    local default_opts = {
      post_behavior = "echo",  -- or "yank"
    }
    vim.tbl_extend("force", default_opts, opts)
    M.opts = opts
end

-- yup, we return the module at the end
return M
