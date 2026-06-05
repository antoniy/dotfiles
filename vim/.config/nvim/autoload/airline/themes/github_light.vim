" GitHub Light High Contrast airline theme (day counterpart of catppuccin_mocha.vim)
" Palette: https://primer.style/ (light_high_contrast)

let s:base     = '#ffffff'
let s:mantle   = '#eaeef2'
let s:crust    = '#ffffff'
let s:surface0 = '#e7ecf0'
let s:surface1 = '#afb8c1'
let s:text     = '#0e1116'
let s:subtext  = '#4b535d'
let s:blue     = '#0349b4'
let s:mauve    = '#512598'
let s:green    = '#055d20'
let s:peach    = '#702c00'
let s:red      = '#a0111f'
let s:yellow   = '#4e2c00'

let s:N1 = [ s:crust,    s:blue,     231, 25  ]
let s:N2 = [ s:text,     s:surface1, 233, 250 ]
let s:N3 = [ s:subtext,  s:surface0, 240, 254 ]
let s:I1 = [ s:crust,    s:green,    231, 22  ]
let s:V1 = [ s:crust,    s:mauve,    231, 54  ]
let s:R1 = [ s:crust,    s:red,      231, 124 ]
let s:IA = [ s:surface1, s:mantle,   250, 254 ]

let g:airline#themes#github_light#palette = {}
let g:airline#themes#github_light#palette.accents = {
      \ 'red':    [ s:red,    '', 124, '', '' ],
      \ 'yellow': [ s:yellow, '', 58,  '', '' ],
      \ 'green':  [ s:green,  '', 22,  '', '' ],
      \ }
let g:airline#themes#github_light#palette.normal   = airline#themes#generate_color_map(s:N1, s:N2, s:N3)
let g:airline#themes#github_light#palette.insert   = airline#themes#generate_color_map(s:I1, s:N2, s:N3)
let g:airline#themes#github_light#palette.visual   = airline#themes#generate_color_map(s:V1, s:N2, s:N3)
let g:airline#themes#github_light#palette.replace  = airline#themes#generate_color_map(s:R1, s:N2, s:N3)
let g:airline#themes#github_light#palette.inactive = airline#themes#generate_color_map(s:IA, s:IA, s:IA)
