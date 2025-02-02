let s:plugin_root = expand('<sfile>:p:h:h')
let s:config_data = aichat#ReadConfigFile(s:plugin_root . '/setup.cfg')
let s:cache_path = aichat#ParseConfigData(s:config_data, 'openai', 'cache_path')

" Save the buffer to cache
function! aichat#SaveBufferToCache()
  if &buftype != 'nofile' | return | endif

  let l:buffer_content = trim(join(getline(1, "$"), "\n"))
  let l:cache_directory = trim(expand(s:cache_path))
  let l:filename = 'cache_' . aichat#GetTimestamp() . '.aichat'
  let l:target_path = l:cache_directory . '/' . l:filename

  if !isdirectory(l:cache_directory)
    call mkdir(l:cache_directory, 'p')
  endif

  call writefile(split(l:buffer_content, "\n"), l:target_path)
endfunction

if !empty(s:cache_path)
  augroup aichat_autocmds
    autocmd!
    autocmd BufWinLeave <buffer> call aichat#SaveBufferToCache()
  augroup END
endif

