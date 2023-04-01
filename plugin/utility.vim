let s:plugin_root = expand('<sfile>:p:h:h')

function! ScratchWindow()
  vnew
  setlocal buftype=nofile bufhidden=hide noswapfile ft=aichat
endfunction

function! ReadConfigFile(cfg_path) abort
  if filereadable(a:cfg_path)
    let config_data = readfile(a:cfg_path)
    return config_data
  else
    echo "Error: Config file not found."
    return []
  endif
endfunction

function! ParseConfigData(config_data, section, key) abort
  let in_section = 0
  for line in a:config_data
    if in_section
      if line =~# '^' . a:key . '\s*=\s*'
        return matchstr(line, '=.*$')[1:]
      endif
    elseif line =~# '^\[' . a:section . ']$'
      let in_section = 1
    endif
  endfor
  echo "Error: Key not found in the given section."
  return ''
endfunction

function! SaveAIChatFunction(filename)
  let ext = ".aichat"
  let setup_cfg_path = s:plugin_root . "/setup.cfg"
  let cfg_data = ReadConfigFile(setup_cfg_path)
  let script_path = ParseConfigData(cfg_data, 'openai', 'script_path')
  let target_directory = expand(script_path)
  let target_directory .= (target_directory[-1:] !=# '/' ? '/' : '')

  if !isdirectory(target_directory)
    call mkdir(target_directory, "p")
  endif

  let target_path = target_directory . a:filename
  if expand("%:e") !=# ext
    let target_path .= ext
  endif

  " often it's a nofile &buftype so we always use this technique
  let buffer_content = join(getline(1, "$"), "\n")

  call writefile(split(buffer_content, "\n"), target_path)
  echo "File saved to: " . target_path
  execute 'edit ' . target_path
endfunction
