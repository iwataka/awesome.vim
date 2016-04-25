let s:save_cpo = &cpoptions
set cpoptions&vim

if !exists('g:awesome_dict_cache')
  let g:awesome_dict_cache = expand('~/.cache/awesome.vim/cache')
endif
if !exists('g:awesome_dict_extra')
  let g:awesome_dict_extra = {
        \ 'The art of command line': 'jlevy/the-art-of-command-line',
        \ 'HEAD': 'joshbuchea/HEAD',
        \ 'Engineering blogs': 'kilimchoi/engineering-blogs',
        \ 'Beautiful Docs': 'PharkMillups/beautiful-docs'
        \ }
endif

let s:awesome_default_owner = 'sindresorhus'
let s:awesome_default_repo = 'awesome'

fu! awesome#execute(key)
  let dest = get(s:awesome_dict(), a:key, s:awesome_default_owner.'/'.s:awesome_default_repo)
  call github#readme#open(dest)
endfu

fu! awesome#update()
  let readme = github#readme#get(s:awesome_default_owner, s:awesome_default_repo)
  let lines = github#readme#decode(readme)
  let result = {}
  let pat =  '\v\[([^\]]+)\]\(https://github.com/([^\)]+/awesome-[^\)]+)\)'
  for line in lines
    let seg = matchstr(line, pat)
    let key = substitute(seg, pat, '\1', '')
    let val = substitute(seg, pat, '\2', '')
    let result[key] = val
  endfor
  call writefile(split(string(result), '\n'), g:awesome_dict_cache)
  unlet s:awesome_dict
endfu

fu! awesome#complete(A, L, P)
  return filter(keys(s:awesome_dict()), "v:val =~ '^'.a:A && !empty(v:val)")
endfu

fu! s:awesome_dict()
  if !isdirectory(fnamemodify(g:awesome_dict_cache, ':h'))
    call mkdir(fnamemodify(g:awesome_dict_cache, ':h'), 'p')
  endif
  if !filereadable(g:awesome_dict_cache)
    call s:update_awesome()
  endif
  if !exists('s:awesome_dict')
    let s:awesome_dict = eval(join(readfile(g:awesome_dict_cache)))
    call extend(s:awesome_dict, g:awesome_dict_extra)
  endif
  return s:awesome_dict
endfu

let &cpo = s:save_cpo
unlet s:save_cpo
