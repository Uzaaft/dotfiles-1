return {
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        keys = {
            {
                "<leader>a",
                function()
                    require("harpoon"):list():append()
                end,
                desc = "Mark file with harpoon",
            },
            {
                "<C-e>",
                function()
                    require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
                end,
                desc = "Toogle harpoon UI",
            },
            {
                "<C-j>",
                function()
                    require("harpoon"):list():select(1)
                end,
                desc = "Select 1 harpoon",
            },
            {
                "<C-k>",
                function()
                    require("harpoon"):list():select(2)
                end,
                desc = "Select 2 harpoon",
            },
            {
                "<C-l>",
                function()
                    require("harpoon"):list():select(3)
                end,
                desc = "Select 3 harpoon",
            },
            {
                "<C-ñ>",
                function()
                    require("harpoon"):list():select(4)
                end,
                desc = "Select 4 harpoon",
            },
        },
        config = function()
            local harpoon = require("harpoon")

            harpoon:setup()
        end,
    },
}
