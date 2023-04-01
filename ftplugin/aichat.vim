let s:plugin_root = expand('<sfile>:p:h:h')
let setup_cfg_path = s:plugin_root . "/setup.cfg"
let cfg_data = aichat#ReadConfigFile(setup_cfg_path)
let cache_path = aichat#ParseConfigData(cfg_data, 'openai', 'cache_path')

" Save the buffer to cache
function! SaveBufferToCache()
  if &buftype != 'nofile' | return | endif

  let l:buffer_content = join(getline(1, "$"), "\n")
  let l:cache_directory = expand('$HOME/.vim/tools/gpt/cache/')
  let l:filename = 'cache_' . aichat#GetTimestamp() . '.aichat'
  let l:target_path = l:cache_directory . l:filename

  if !isdirectory(l:cache_directory)
    call mkdir(l:cache_directory, 'p')
  endif

  call writefile(split(l:buffer_content, "\n"), l:target_path)
endfunction

if !empty(cache_path)
  augroup aichat_autocmds
    autocmd!
    autocmd BufWinLeave <buffer> call SaveBufferToCache()
  augroup END
endif

