" Catppuccin Mocha airline theme
" Colors: https://catppuccin.com/palette/

let s:base     = '#1e1e2e'
let s:mantle   = '#181825'
let s:crust    = '#11111b'
let s:surface0 = '#313244'
let s:surface1 = '#45475a'
let s:text     = '#cdd6f4'
let s:subtext  = '#bac2de'
let s:blue     = '#89b4fa'
let s:mauve    = '#cba6f7'
let s:green    = '#a6e3a1'
let s:peach    = '#fab387'
let s:red      = '#f38ba8'
let s:yellow   = '#f9e2af'

let s:N1 = [ s:crust,    s:blue,     232, 75  ]
let s:N2 = [ s:text,     s:surface1, 252, 240 ]
let s:N3 = [ s:subtext,  s:surface0, 248, 236 ]
let s:I1 = [ s:crust,    s:green,    232, 114 ]
let s:V1 = [ s:crust,    s:mauve,    232, 141 ]
let s:R1 = [ s:crust,    s:red,      232, 211 ]
let s:IA = [ s:surface1, s:mantle,   240, 234 ]

let g:airline#themes#catppuccin_mocha#palette = {}
let g:airline#themes#catppuccin_mocha#palette.accents = {
      \ 'red':    [ s:red,    '', 211, '', '' ],
      \ 'yellow': [ s:yellow, '', 222, '', '' ],
      \ 'green':  [ s:green,  '', 114, '', '' ],
      \ }
let g:airline#themes#catppuccin_mocha#palette.normal   = airline#themes#generate_color_map(s:N1, s:N2, s:N3)
let g:airline#themes#catppuccin_mocha#palette.insert   = airline#themes#generate_color_map(s:I1, s:N2, s:N3)
let g:airline#themes#catppuccin_mocha#palette.visual   = airline#themes#generate_color_map(s:V1, s:N2, s:N3)
let g:airline#themes#catppuccin_mocha#palette.replace  = airline#themes#generate_color_map(s:R1, s:N2, s:N3)
let g:airline#themes#catppuccin_mocha#palette.inactive = airline#themes#generate_color_map(s:IA, s:IA, s:IA)
