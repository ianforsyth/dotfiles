local status_ok, alpha = pcall(require, "alpha")
if not status_ok then
  return
end

local if_nil = vim.F.if_nil

local default_terminal = {
    type = "terminal",
    command = nil,
    width = 69,
    height = 8,
    opts = {
        redraw = true,
        window_config = {},
    },
}

local default_header = {
    type = "text",
    val = {
        [[                               __                ]],
        [[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
        [[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
        [[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
        [[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
        [[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
    },
    opts = {
        position = "center",
        hl = "Type",
        -- wrap = "overflow";
    },
}

local footer = {
    type = "text",
    val = "",
    opts = {
        position = "center",
        hl = "Number",
    },
}

local leader = "SPC"

--- @param sc string
--- @param txt string
--- @param keybind string? optional
--- @param keybind_opts table? optional
local function button(sc, txt, keybind, keybind_opts)
    local sc_ = sc:gsub("%s", ""):gsub(leader, "<leader>")

    local opts = {
        position = "center",
        shortcut = sc,
        cursor = 5,
        width = 50,
        align_shortcut = "right",
        hl_shortcut = "Keyword",
    }
    if keybind then
        keybind_opts = if_nil(keybind_opts, { noremap = true, silent = true, nowait = true })
        opts.keymap = { "n", sc_, keybind, keybind_opts }
    end

    local function on_press()
        local key = vim.api.nvim_replace_termcodes(keybind or sc_ .. "<Ignore>", true, false, true)
        vim.api.nvim_feedkeys(key, "t", false)
    end

    return {
        type = "button",
        val = txt,
        on_press = on_press,
        opts = opts,
    }
end

local strava_projects = {
    type = "group",
    val = {
      { type = "text", val = "Strava Projects", opts = { hl = "SpecialComment", position = "center" } },
      -- { type = "padding", val = 1 },
      button("a", "🏃 Active",   ":cd ~/workspace/strava/active<CR>:NvimTreeOpen<CR>"),
      button("b", "📣 Bullhorn",   ":cd ~/workspace/strava/bullhorn<CR>:NvimTreeOpen<CR>"),
      button("cow", "🔔 Cowbell",   ":cd ~/workspace/strava/cowbell/<CR>:NvimTreeOpen<CR>"),
      button("con", "⚙️  Config",   ":cd ~/workspace/strava/configuration//<CR>:NvimTreeOpen<CR>"),
      button("d", "🌀 Dass",   ":cd ~/workspace/strava/dass/<CR>:NvimTreeOpen<CR>"),
    },
    opts = {
        spacing = 1,
    },
}

local personal_projects = {
    type = "group",
    val = {
      { type = "text", val = "Personal Projects", opts = { hl = "SpecialComment", position = "center" } },
      -- { type = "padding", val = 1 },
      button("n", "💻 NeoVim Config",   ":cd ~/.config/nvim/<CR>:NvimTreeOpen<CR>"),
      button("i", "👱 Website",   ":cd ~/workspace/ianforsyth.github.io/<CR>:NvimTreeOpen<CR>"),
    },
    opts = {
        spacing = 1,
    },
}

local buttons = {
    type = "group",
    val = {
      { type = "text", val = "Actions", opts = { hl = "SpecialComment", position = "center" } },
      -- { type = "padding", val = 1 },
      button("e", "  New file", "<cmd>ene <CR>"),
      button("SPC f f", "  Find file"),
      button("SPC f h", "  Recently opened files"),
      button("SPC f r", "  Frecency/MRU"),
      button("SPC f g", "  Find word"),
      button("SPC f m", "  Jump to bookmarks"),
      button("SPC s l", "  Open last session"),
    },
    opts = {
        spacing = 1,
    },
}

local section = {
    terminal = default_terminal,
    header = default_header,
    personal_projects = personal_projects,
    strava_projects = strava_projects,
    buttons = buttons,
    footer = footer,
}

local config = {
    layout = {
        { type = "padding", val = 2 },
        section.header,
        { type = "padding", val = 2 },
        section.personal_projects,
        section.strava_projects,
        section.buttons,
        section.footer,
    },
    opts = {
        margin = 5,
    },
}

alpha.setup(config)

