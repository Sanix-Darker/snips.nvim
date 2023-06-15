# snips.nvim

As a fan of sharing block of code snippets, i came accross an interesting project [snips](https://snips.sh), no authentification needed at all, it allow you to save some code online and share it whenever you want and with no limit.

So i was like... why not making a small plugin for it !
In the past i was using Gist.vim but the fact that it need authentification and i needed to generate a token save on my computer... i was not really happy about that...

The simple idea behind this plugin is to :
- get selected lines from the current buffer
- save it in a temporary file
- execute this command `cat /tmp.file | ssh snips.sh` and return the output in the command prompt


## HOW TO INSTALL

Using Packer :
```lua
use 'Sanix-Darker/snips.nvim'
```

or Vim-plug

```
Plub 'Sanix-Darker/snips.nvim'
```

Then in your `init.lua` file :

```lua
require('snips.nvim').setup()
```

## HOW TO USE

