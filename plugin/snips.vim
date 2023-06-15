if !has('nvim-0.5.0')
  echohl Error
  echom 'This plugin only works with Neovim >= v0.5.0'
  echohl clear
  finish
endif

" The Create a Snips
command! -range SnipsCreate <line1>,<line2>lua require'snips'.execute_snips_command()
