if !has('nvim-0.5.0')
  echohl Error
  echom 'This plugin only works with Neovim >= v0.5.0'
  echohl clear
  finish
endif

" The Create a new Snips
command! -range SnipsCreate <line1>,<line2>lua require'snips'.execute_snips_command()
" The Create a private Snips
command! -range SnipsCreatePrivate <line1>,<line2>lua require'snips'.execute_snips_command({ private = true })

" Create a new Snips from register
command! SnipsCreateFromRegister lua require'snips'.execute_snips_command({ from_register = true })
" Create a new Snips from register
command! SnipsCreatePrivateFromRegister lua require'snips'.execute_snips_command({ from_register = true, private = true })

" To open the snips UI to list for available saved/uploaded snips
command! SnipsList lua require'snips'.list_snips()
