return {
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = "nvim-tree/nvim-web-devicons",
        opts = {
            options = {
                numbers = function(opts)
                    return string.format("%s", opts.raise(opts.ordinal))
                end,
            },
        },
    },
}
