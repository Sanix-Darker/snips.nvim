# snips.nvim

https://github.com/Sanix-Darker/snips.nvim/assets/22576758/673501a4-6a7d-4f9a-bdbb-eb2c78ed3455

---

![Peek 2023-06-20 11-14](https://github.com/Sanix-Darker/snips.nvim/assets/22576758/d8efd731-902e-45e5-8f5b-685a1b30230a)
As a fan of sharing snippet blocks of code, I came across an interesting project [snips](https://snips.sh) from [robherley](https://github.com/robherley), none authentication is required to generate a small snippet of code, whenever you want and without limit.

So I thought... why not make a small/dumb plugin for that on my neovim !
In the past I used [Gist.vim](https://github.com/mattn/vim-gist) but the fact that it required authentication and I had to generate a token that was going to be saved on "clear" on my computer... I didn't really like that.

## REQUIREMENTS

- VIM (>=8 recommended)
- NVIM (>=0.5 recommended)

## FEATURES

- Save/upload code snipets from your code editor.
- List/Edit your saved blocks of code.

## HOW DOES IT WORK

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
- Select a bunch of lines from your current buffer and use a snips.nvim command.

## COMMANDS

- `SnipsList` To open the list of all uploaded/saved snips you have created so far.
- `SnipsCreate` and you have generated/saved a snippet of your code, you're left with the link to share.
- `SnipsCreatePrivate` to create private snips
    Note: on private mode, with a generated link like : https://snips.sh/f/the-id
    You can access your private snips code with:
        $ ssh f:the-id@snips.sh
- `SnipsCreateFromRegister` to create a snippet from register.
- `SnipsCreatePrivateFromRegister` to create a snippet from register and save/upload on private.

## SETUP OPTIONS

Those are default values, you can change as your will !

```lua
local opts = {
  snips_host = "snips.sh", -- in case you deployed your own custom instance
  post_behavior = "echo",  -- enum: ["echo", "yank", "echo_and_yank"]
  to_register = "+", -- yank to
  from_register = "+", -- copy from
  cat_cmd = "cat", -- can be `bat` or `less`
  ssh_cmd = "ssh", -- choose your custom ssh client
}
require("snips.nvim").setup(opts)
```

## NOTE

If you have some ideas on how to upgrade this plugin i would be happy to read your issues, suggestions, Pull Requests.
But for now i will keep it simple since it does what i want it to do for now.

## AUTHOR

[sanix-darker](https://github.com/sanix-darker)

## CONTRIBUTORS

[Pagliacii](https://github.com/Pagliacii)
