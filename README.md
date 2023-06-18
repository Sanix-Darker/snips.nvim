# snips.nvim

https://github.com/Sanix-Darker/snips.nvim/assets/22576758/673501a4-6a7d-4f9a-bdbb-eb2c78ed3455

As a fan of sharing snippet blocks of code, I came across an interesting project [snips](https://snips.sh) from [robherley](https://github.com/robherley), none authentication is required to generate a small snippet of code, whenever you want and without limit.

So I thought... why not make a small/dumb plugin for that on my neovim !
In the past I used [Gist.vim](https://github.com/mattn/vim-gist) but the fact that it required authentication and I had to generate a token that was going to be saved on "clear" on my computer... I didn't really like that.

The simple idea behind this plugin is to:
- get selected rows from current buffer
- save it in a temporary file
- run this command `cat /your-generated-tmp.file | ssh snips.sh` and return output in a new splitted buffer.

## HOW TO INSTALL

- Using Packer :
    ```lua
    use 'Sanix-Darker/snips.nvim'
    ```

- Using Vim-plug :
    ```
    Plug 'Sanix-Darker/snips.nvim'
    ```

    Then in your `init.lua` file you can just run :

    ```lua
    require('snips.nvim').setup()
    -- this will just make sure the plugin is available
    -- maybe planing on adding more customisations ? idk...
    ```

- Using Lazy.nvim :

    ```lua
    require('snips').setup()
    ```
    or

    ```lua
    return {
      {
        "Sanix-Darker/snips.nvim",
        config = true,
        cmd = { "SnipsCreate" },  -- optional, make the plugin loads at cmd executed
      },
    }
    ```

## HOW TO USE

- *IMPORTANT NOTE*: You need to etablish a first connection with snips.sh server
    by running this example command on the terminal : `echo "Hello world" | ssh snips.sh`
    Then you can open your nvim.
- Select a bunch of lines from your current buffer.
- Hit `SnipsCreate` and you have generated/saved a snippet of your code, you're left with the link to share.

## DEFAULT OPTIONS

```lua
local opts = {
  post_behavior = "echo",  -- or "yank"
}
require("snips.nvim").setup(opts)
```

## NOTE

If you have some ideas on how to upgrade this plugin i would be happy to read your issues, suggestions, Pull Requests.
But for now i will keep it simple since it does what i want it to do for now.

## AUTHOR

[sanix-darker](https://github.com/sanix-darker)
