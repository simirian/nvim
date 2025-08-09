" simirian's Neovim
" fex module file type syntax

if exists("b:current_syntax")
  finish
endif

" conceals file ids in fex buffers
syn match fexid /^\/[0-9a-f]*/ conceal

let b:current_syntax = "fex"
