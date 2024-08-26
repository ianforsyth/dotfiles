local ls = require("luasnip")

-- Function to get the correct comment string based on the file type
local function get_comment_string()
  local filetype = vim.bo.filetype
  local comment_strings = {
    lua = "--",
    python = "#",
    ruby = "#",
    javascript = "//",
    typescript = "//",
    java = "//",
    c = "//",
    cpp = "//",
    scala = "//",
    vim = "\"",
    sh = "#",
    bash = "#",
    html = "<!--",
    xml = "<!--",
    -- Add more filetypes and their respective comment strings here
  }

  -- Return the appropriate comment string or default to "//"
  return comment_strings[filetype] or "//"
end

-- Function to get the current date in the desired format
local function current_date()
  local month = os.date("%m"):gsub("^0", "")
  local day = os.date("%d"):gsub("^0", "")
  local year = os.date("%y")
  return month .. "/" .. day .. "/" .. year
end

-- Function to create the full comment snippet
local function comment_snippet()
  return get_comment_string() .. " IF (" .. current_date() .. "): "
end

-- Define snippets for all file types
ls.add_snippets("all", {
  ls.snippet("cc", { ls.function_node(comment_snippet) }),
})

return ls

