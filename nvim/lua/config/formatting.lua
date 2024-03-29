-- IF (3/28/24): Need this for my monorepo project. In this particular
-- case the parent project is called "base", app and api are a vite app
-- and rails app respectively. Some build tools like eslint and prettier
-- don't work well because they can't get to node_modules from the parent

function ChangeWorkingDirectory()
  -- Check if the current buffer is associated with a file or if it's a special buffer
    -- Skip changing the directory for special buffers like terminals
    if vim.fn.bufname() == '' or vim.bo.buftype ~= '' then
        return
    end

    -- Get the full path of the current file
    local file_path = vim.fn.expand('%:p')

    -- Check if 'app' is in the path
    if string.find(file_path, '/app/') then
        -- Change the working directory to the 'app' directory
        local app_root = string.match(file_path, '^(.*base/app/)')
        vim.api.nvim_command('lcd ' .. app_root)
    -- Check if 'api' is in the path
    elseif string.find(file_path, '/api/') then
        -- Change the working directory to the 'api' directory
        local api_root = string.match(file_path, '^(.*base/api/)')
        vim.api.nvim_command('lcd ' .. api_root)
    end
end

-- Set an autocommand to run the function every time a buffer is entered
vim.api.nvim_create_autocmd("BufEnter", {callback = ChangeWorkingDirectory})
