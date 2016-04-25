if &compatible || (exists('g:loaded_awesome') && g:loaded_awesome)
  finish
endif
let g:loaded_awesome = 1

com! -nargs=? -complete=customlist,awesome#complete Awesome
      \ call awesome#execute(<q-args>)
com! -nargs=0 AwesomeUpdate call awesome#update()

