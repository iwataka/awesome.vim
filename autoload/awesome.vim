let s:save_cpo = &cpoptions
set cpoptions&vim

if !exists('g:awesome_dict_cache')
  let g:awesome_dict_cache = expand('~/.cache/awesome.vim')
endif
if !exists('g:awesome_dict_extra')
  let g:awesome_dict_extra = {
        \ 'The art of command line': 'jlevy/the-art-of-command-line',
        \ 'HEAD': 'joshbuchea/HEAD',
        \ 'Engineering blogs': 'kilimchoi/engineering-blogs',
        \ 'Beautiful Docs': 'PharkMillups/beautiful-docs',
        \ 'Useful Java Links': 'Vedenin/useful-java-links'
        \ }
endif
if !exists('g:awesome_default_identifier')
  let g:awesome_default_identifier = 'sindresorhus/awesome'
endif

fu! awesome#execute(key)
  let dest = get(s:awesome_dict(), a:key, g:awesome_default_identifier)
  call s:github_open(dest)
endfu

fu! awesome#update()
  let readme = s:github_readme(g:awesome_default_identifier)
  let lines = s:github_decode(readme)
  let result = {}
  let pat =  '\v\[([^\]]+)\]\(https://github.com/([^\)]+/awesome-[^\)]+)\)'
  for line in lines
    let seg = matchstr(line, pat)
    if !empty(seg)
      let key = substitute(seg, pat, '\1', '')
      let val = substitute(seg, pat, '\2', '')
      let result[key] = val
    endif
  endfor
  call writefile(split(string(result), '\n'), s:cache_file())
  unlet! s:awesome_dict
endfu

fu! awesome#complete(A, L, P)
  return filter(keys(s:awesome_dict()), "v:val =~ '^'.a:A && !empty(v:val)")
endfu

fu! s:awesome_dict()
  let cache = s:cache_file()
  if !isdirectory(g:awesome_dict_cache)
    call mkdir(g:awesome_dict_cache, 'p')
  endif
  if !filereadable(cache)
    call awesome#update()
  endif
  if !exists('s:awesome_dict')
    let s:awesome_dict = eval(join(readfile(cache)))
    call extend(s:awesome_dict, g:awesome_dict_extra)
  endif
  return s:awesome_dict
endfu

fu! s:cache_file()
  return substitute(g:awesome_dict_cache, '\v/+$', '', '').'cache.txt'
endfu

fu! s:github_fname(identifier)
  return 'github://'.a:identifier
endfu

fu! s:github_open(identifier)
  let fname = s:github_fname(a:identifier)
  if bufexists(fname)
    exe 'edit '.fname
  elseif a:identifier =~ '\v[^/]+/[^/]+'
    call s:github_open_readme(a:identifier)
  endif
endfu

fu! s:github_open_readme(identifier)
  let readme = s:github_readme(a:identifier)
  noswapfile enew
  setlocal buftype=nofile
  silent exe 'file '.s:github_fname(a:identifier)
  call s:set_filetype(readme.name)

  " See http://vim.wikia.com/wiki/Newlines_and_nulls_in_Vim_script
  setlocal modifiable
  setlocal noreadonly
  if line('$') != 0
    call append(0, s:github_decode(readme))
    normal! gg
  endif

  setlocal nomodifiable
  setlocal readonly
  if exists('#AwesomeNew')
    doautocmd AwesomeNew
  endif
endfu

fu! s:set_filetype(fname)
  let ext = fnamemodify(a:fname, ':e')
  if ext =~ '\vmd|markdown'
    setlocal ft=markdown
  elseif ext =~ '\vadoc|asciidoc'
    setlocal ft=asciidoc
  elseif ext =~ '\vrst'
    setlocal ft=rst
  endif
endfu

fu! s:github_readme(identifier)
  let url = 'https://api.github.com/repos/'.a:identifier.'/readme'
  let reply = webapi#http#get(url)
  return webapi#json#decode(reply.content)
endfu

fu! s:github_decode(readme)
  let content = substitute(a:readme.content, '\n', '', 'g')
  if a:readme.encoding == 'base64'
    let content = webapi#base64#b64decode(content)
  endif
  return split(content, '\n')
endfu

let &cpo = s:save_cpo
unlet s:save_cpo
