return {
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-path',
        }
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        config = function()
            require("mason-tool-installer").setup({
                ensure_installed = {
                    "gopls",
                    "html-lsp",
                    "json-lsp",
                    "lua_ls",
                    "prettier",
                    "graphql-language-service-cli",
                    "yaml-language-server",
                },
                auto_update = true,
            })
        end,
    },
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        dependencies = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' }, -- Required
            {
                -- Optional
                'williamboman/mason.nvim',
                build = ":MasonUpdate"
            },
            { 'williamboman/mason-lspconfig.nvim' }, -- Optional

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },     -- Required
            { 'hrsh7th/cmp-nvim-lsp' }, -- Required
            { 'L3MON4D3/LuaSnip' },     -- Required
            { 'hrsh7th/cmp-nvim-lsp-signature-help' },
            { "ray-x/lsp_signature.nvim" },
            { "onsails/lspkind.nvim" },
            -- Telescope
            { 'nvim-telescope/telescope.nvim' }
        },
        config = function()
            vim.diagnostic.config({
                virtual_text = true,
            })

            local lsp = require("lsp-zero").preset({})


            -- Fix Undefined global 'vim'
            -- Note that things are overriden in the inlay-hints part setup

            local cmp = require("cmp")
            local cmp_select = { behavior = cmp.SelectBehavior.Replace }
            local cmp_mappings = lsp.defaults.cmp_mappings({
                ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
                ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
                ["<CR>"] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            })

            --- Luasnip Mapping ---
            local luasnip = require("luasnip")
            cmp_mappings["<Tab>"] = cmp.mapping(function(fallback)
                if luasnip.expand_or_locally_jumpable() then
                    luasnip.expand_or_jump()
                else
                    fallback()
                end
            end, { "i", "s" })
            cmp_mappings["<S-Tab>"] = cmp.mapping(function(fallback)
                if luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end, { "i", "s" })

            --- CMP Setup ---
            cmp.setup({
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end
                },
                sources = {
                    {
                        name = "luasnip",
                        option = { use_show_condition = false, show_autosnippets = true }
                    },
                    { name = "nvim_lsp" },
                    { name = "buffer" },
                    { name = "crates" },
                    { name = "path" },
                },
                mapping = cmp_mappings,
                preselect = 'none',
                completion = {
                    completeopt = 'menu,menuone,noinsert',
                },
                -- Disable completion in comments
                enabled = function()
                    -- Check if the current buffer's filetype is "TelescopePrompt"
                    local telescope_prompt = vim.bo.filetype == "TelescopePrompt"

                    -- Check if the cursor is inside a comment (treesitter or syntax).
                    local inside_comment = require("cmp.config.context").in_treesitter_capture("comment") == true
                        or require("cmp.config.context").in_syntax_group("Comment")

                    return not (telescope_prompt or inside_comment)
                end,
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                performance = {
                    trigger_debounce_time = 300,
                    throttle = 60,
                    fetching_timeout = 200,
                },
                formatting = {
                    format = require("lspkind").cmp_format({
                        mode = "symbol_text",
                        maxwidth = 50,         -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
                        ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
                        menu = ({
                            buffer = "[Buffer]",
                            nvim_lsp = "[LSP]",
                            luasnip = "[Snip]",

                        })
                    })
                }
            })

            -- some lsp settings
            lsp.set_preferences({
                suggest_lsp_servers = true,
                sign_icons = {
                    error = " ",
                    warn = " ",
                    hint = " ",
                    info = " "
                },
            })

            --Telescope for some shortcuts
            local telescope = require("telescope.builtin")

            lsp.on_attach(function(client, bufnr)
                local opts = { buffer = bufnr, remap = false }

                vim.keymap.set("n", "gd", telescope.lsp_definitions, opts)
                vim.keymap.set("n", "gD", function() vim.lsp.buf.declaration() end, opts)
                vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
                -- vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
                vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
                vim.keymap.set("n", "ge", function() vim.diagnostic.goto_next() end, opts)
                vim.keymap.set("n", "gpe", function() vim.diagnostic.goto_prev() end, opts)
                vim.keymap.set("n", "<leader>le", telescope.diagnostics, opts)
                -- Good old JetBrains
                vim.keymap.set("n", "<A-CR>", function() vim.lsp.buf.code_action() end, opts)
                vim.keymap.set("v", "<A-CR>", function() vim.lsp.buf.code_action() end, opts)

                vim.keymap.set("n", "<leader>vr", function() vim.lsp.buf.references() end, opts)
                vim.keymap.set("n", "<leader>R", function() vim.lsp.buf.rename() end, opts)
                vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
                vim.keymap.set("n", "gr", telescope.lsp_references, opts)
                vim.keymap.set("n", "gi", telescope.lsp_implementations, opts)
            end)

            -- Signature helper
            local signHelper = require("lsp_signature").setup({
                floating_window = false,
            })

            -- Setup LSPs

            local lspconfig = require('lspconfig')

            require('mason').setup({})
            require('mason-lspconfig').setup({
                ensure_installed = { 'gopls', 'lua_ls', 'yamlls', 'jsonls' },
                handlers = {
                    lsp.default_setup,
                    -- Lua setup
                    lua_ls = function()
                        lspconfig.lua_ls.setup({
                            settings = {
                                Lua = {
                                    diagnostics = {
                                        globals = { "vim" },
                                    },
                                },
                            },
                        })
                    end,
                    -- YAML setup
                    yamlls = function()
                        lspconfig.yamlls.setup({
                            settings = {
                                yaml = {
                                    keyOrdering = false
                                }
                            },
                        })
                    end,
                    -- GraphQL setup
                    graphql = function()
                        local util = require 'lspconfig.util'
                        lspconfig.graphql.setup({
                            root_dir = util.root_pattern('.git', '.graphqlrc*', '.graphql.config.*', 'graphql.config.*',
                                '/config/gqlgen.yaml')
                        })
                    end
                }
            })

            -- Format on save
            lsp.format_on_save({
                format_opts = {
                    async = false,
                    timeout_ms = 10000,
                },
                servers = {
                    ["lua_ls"] = { "lua" },
                    ["gopls"] = { "go" },
                    ["rust-analyzer"] = { "rust" },
                    ["jsonls"] = { "json" },
                }
            })

            -- Setup LSP ZERO
            lsp.setup()
        end
    }
}
