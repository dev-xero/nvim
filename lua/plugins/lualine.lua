return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
        local icons = LazyVim.config.icons

        local colors = {
            bg = "#011627",
            fg = "#d6deeb",
            gray = "#5f7e97",
            blue = "#82aaff",
            darkblue = "#011221",
            green = "#22da6e",
            cyan = "#21c7a8",
            yellow = "#ecc48d",
            orange = "#ffae57",
            red = "#ef5350",
            magenta = "#c792ea",
            violet = "#c792ea",
        }

        -- Diff source
        local function diff_source()
            local gitsigns = vim.b.gitsigns_status_dict
            if gitsigns then
                return {
                    added = gitsigns.added,
                    modified = gitsigns.changed,
                    removed = gitsigns.removed,
                }
            end
        end

        -- LSP info: server count and status
        local function lsp_info()
            local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
            if #buf_clients == 0 then
                return "󰅚 No LSP"
            end

            local clients = {}
            local formatters = {}

            for _, client in pairs(buf_clients) do
                if client.name == "null-ls" or client.name == "jose-elias-alvarez/null-ls.nvim" then
                    table.insert(formatters, "Formatters")
                elseif client.name ~= "copilot" then
                    table.insert(clients, client.name)
                end
            end

            local result = {}
            if #clients > 0 then
                table.insert(result, "󰒋 " .. table.concat(clients, "·"))
            end
            if #formatters > 0 then
                table.insert(result, "󰉼 " .. table.concat(formatters, "·"))
            end

            return table.concat(result, " ")
        end

        -- Git status
        local function git_blame()
            local blame = vim.fn.system("git log --oneline -1 2>/dev/null")
            if vim.v.shell_error == 0 then
                return blame:gsub("\n", ""):sub(1, 50)
            end
            return ""
        end

        -- Buffer info
        local function buffer_info()
            local buf_count = #vim.fn.getbufinfo({ buflisted = 1 })
            return "󰓩 " .. buf_count
        end

        -- Search count
        local function search_count()
            if vim.v.hlsearch == 0 then
                return ""
            end
            local result = vim.fn.searchcount()
            if result.maxcount and result.maxcount > 0 then
                return string.format("󰍉 %d/%d", result.current, result.total)
            end
            return ""
        end

        -- Macro recording status
        local function macro_recording()
            local recording_register = vim.fn.reg_recording()
            if recording_register == "" then
                return ""
            else
                return "Recording @" .. recording_register
            end
        end

        -- Python virtual environment
        local function python_env()
            if vim.bo.filetype == "python" then
                local venv = os.getenv("VIRTUAL_ENV")
                if venv then
                    local venv_name = vim.fn.fnamemodify(venv, ":t")
                    return "󰐍 " .. venv_name
                end
            end
            return ""
        end

        -- File size
        local function file_size()
            local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
            if size < 0 then
                return ""
            end
            local suffixes = { "B", "KB", "MB", "GB" }
            local i = 1
            while size > 1024 and i < #suffixes do
                size = size / 1024
                i = i + 1
            end
            return string.format("%.1f%s", size, suffixes[i])
        end

        -- Mode icons
        local mode_map = {
            n = "󰋜 NORMAL",
            i = "󰏫 INSERT",
            v = "󰈈 VISUAL",
            V = "󰈈 V-LINE",
            [""] = "󰈈 V-BLOCK",
            c = "󰘳 COMMAND",
            s = "󰘶 SELECT",
            S = "󰘶 S-LINE",
            [""] = "󰘶 S-BLOCK",
            R = "󰛔 REPLACE",
            r = "󰛔 REPLACE",
            ["!"] = "󰘳 SHELL",
            t = "󰙀 TERMINAL",
        }

        local function mode_with_icon()
            local mode = vim.api.nvim_get_mode().mode
            return mode_map[mode] or mode
        end

        return {
            options = {
                theme = "auto",
                globalstatus = vim.o.laststatus == 3,
                disabled_filetypes = {
                    statusline = { "dashboard", "alpha", "starter", "TelescopePrompt" },
                    winbar = {
                        "help",
                        "startify",
                        "dashboard",
                        "packer",
                        "neogitstatus",
                        "NvimTree",
                        "Trouble",
                        "alpha",
                        "lir",
                        "Outline",
                        "spectre_panel",
                        "toggleterm",
                    },
                },
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                refresh = {
                    statusline = 1000,
                    tabline = 1000,
                    winbar = 1000,
                },
            },
            sections = {
                lualine_a = {
                    {
                        mode_with_icon,
                        separator = { left = "", right = "" },
                        color = function()
                            local mode_colors = {
                                n = { bg = colors.blue, fg = colors.bg, gui = "bold" },
                                i = { bg = colors.green, fg = colors.bg, gui = "bold" },
                                v = { bg = colors.violet, fg = colors.bg, gui = "bold" },
                                V = { bg = colors.violet, fg = colors.bg, gui = "bold" },
                                [""] = { bg = colors.violet, fg = colors.bg, gui = "bold" },
                                c = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
                                R = { bg = colors.red, fg = colors.bg, gui = "bold" },
                                r = { bg = colors.red, fg = colors.bg, gui = "bold" },
                                t = { bg = colors.orange, fg = colors.bg, gui = "bold" },
                            }
                            return mode_colors[vim.api.nvim_get_mode().mode]
                                or { bg = colors.gray, fg = colors.bg, gui = "bold" }
                        end,
                        padding = { left = 1, right = 1 },
                    },
                },
                lualine_b = {
                    {
                        "branch",
                        icon = { "", color = { fg = colors.orange } },
                        color = { fg = colors.fg, gui = "bold" },
                    },
                    {
                        "diff",
                        source = diff_source,
                        symbols = {
                            added = " ",
                            modified = " ",
                            removed = " ",
                        },
                        diff_color = {
                            added = { fg = colors.green },
                            modified = { fg = colors.yellow },
                            removed = { fg = colors.red },
                        },
                        colored = true,
                    },
                },
                lualine_c = {
                    {
                        "filename",
                        path = 1,
                        symbols = {
                            modified = " 󰷥",
                            readonly = " 󰌾",
                            unnamed = "󰟢 [No Name]",
                            newfile = "󰎔 [New]",
                        },
                        color = { fg = colors.cyan, gui = "bold" },
                    },
                    {
                        file_size,
                        color = { fg = colors.gray },
                    },
                    {
                        macro_recording,
                        color = { fg = colors.red, gui = "bold" },
                    },
                    {
                        search_count,
                        color = { fg = colors.yellow },
                    },
                },
                lualine_x = {
                    {
                        python_env,
                        color = { fg = colors.green },
                    },
                    {
                        "diagnostics",
                        sources = { "nvim_diagnostic" },
                        symbols = {
                            error = icons.diagnostics.Error .. " ",
                            warn = icons.diagnostics.Warn .. " ",
                            info = icons.diagnostics.Info .. " ",
                            hint = icons.diagnostics.Hint .. " ",
                        },
                        diagnostics_color = {
                            error = { fg = colors.red },
                            warn = { fg = colors.yellow },
                            info = { fg = colors.blue },
                            hint = { fg = colors.cyan },
                        },
                        colored = true,
                        update_in_insert = false,
                    },
                    {
                        lsp_info,
                        color = { fg = colors.violet },
                    },
                    {
                        "encoding",
                        fmt = string.upper,
                        color = { fg = colors.gray },
                    },
                    {
                        "fileformat",
                        symbols = {
                            unix = "󰌽 LF",
                            dos = "󰌾 CRLF",
                            mac = "󰌿 CR",
                        },
                        color = { fg = colors.gray },
                    },
                    {
                        "filetype",
                        colored = true,
                        icon = { align = "right" },
                        color = { fg = colors.blue },
                    },
                },
                lualine_y = {
                    {
                        buffer_info,
                        color = { fg = colors.magenta },
                    },
                    {
                        "progress",
                        fmt = function(str)
                            if str == "Top" then
                                return "󰝣 Top"
                            elseif str == "Bot" then
                                return "󰝡 Bot"
                            else
                                return "󰩃 " .. str
                            end
                        end,
                        color = { fg = colors.fg },
                    },
                },
                lualine_z = {
                    {
                        "location",
                        fmt = function(str)
                            return "󰉸 " .. str
                        end,
                        separator = { left = "", right = "" },
                        color = { bg = colors.blue, fg = colors.bg, gui = "bold" },
                        padding = { left = 1, right = 1 },
                    },
                },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {
                    {
                        "filename",
                        path = 1,
                        symbols = {
                            modified = " 󰷥",
                            readonly = " 󰌾",
                            unnamed = "󰟢 [No Name]",
                        },
                        color = { fg = colors.gray },
                    },
                },
                lualine_x = {
                    {
                        "location",
                        color = { fg = colors.gray },
                    },
                },
                lualine_y = {},
                lualine_z = {},
            },
            extensions = { "neo-tree", "lazy", "trouble", "mason", "toggleterm", "quickfix" },
        }
    end,
}
