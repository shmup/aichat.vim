let g:vim_ai_complete_default = {
      \  "options": {
      \    "model": "text-davinci-003",
      \    "max_tokens": 1000,
      \    "temperature": 0.1,
      \    "request_timeout": 20,
      \  },
      \}
let g:vim_ai_edit_default = {
      \  "options": {
      \    "model": "text-davinci-003",
      \    "max_tokens": 1000,
      \    "temperature": 0.1,
      \    "request_timeout": 20,
      \  },
      \}
let g:vim_ai_chat_default = {
      \  "options": {
      \    "model": "gpt-4",
      \    "max_tokens": 1000,
      \    "temperature": 1,
      \    "request_timeout": 20,
      \  },
      \}
if !exists('g:vim_ai_complete')
  let g:vim_ai_complete = {"options":{}}
endif
if !exists('g:vim_ai_edit')
  let g:vim_ai_edit = {"options":{}}
endif
if !exists('g:vim_ai_chat')
  let g:vim_ai_chat = {"options":{}}
endif

let s:plugin_root = expand('<sfile>:p:h:h')
let s:complete_py = s:plugin_root . "/py/complete.py"
let s:chat_py = s:plugin_root . "/py/chat.py"

function! ScratchWindow()
  vnew
  setlocal buftype=nofile bufhidden=hide noswapfile ft=aichat
endfunction

function! MakePrompt(selected_lines, lines, instruction)
  let lines = trim(join(a:lines, "\n"))
  let instruction = trim(a:instruction)
  let delimiter = instruction != "" && a:selected_lines ? ":\n" : ""
  let selection = a:selected_lines || instruction == "" ? lines : ""
  let prompt = join([instruction, delimiter, selection], "")
  return prompt
endfunction

function! AIRun(selected_lines, ...) range
  let lines = getline(a:firstline, a:lastline)
  let prompt = MakePrompt(a:selected_lines, lines, a:0 ? a:1 : "")
  let options_default = g:vim_ai_complete_default['options']
  let options = g:vim_ai_complete['options']
  let cursor_on_empty_line = trim(join(lines, "\n")) == ""
  set paste
  if cursor_on_empty_line
    execute "normal! " . a:lastline . "GA"
  else
    execute "normal! " . a:lastline . "Go"
  endif
  execute "py3file " . s:complete_py
  execute "normal! " . a:lastline . "G"
  set nopaste
endfunction

function! AIEditRun(selected_lines, ...) range
  let prompt = MakePrompt(a:selected_lines, getline(a:firstline, a:lastline), a:0 ? a:1 : "")
  let options_default = g:vim_ai_edit_default['options']
  let options = g:vim_ai_edit['options']
  set paste
  execute "normal! " . a:firstline . "GV" . a:lastline . "Gc"
  execute "py3file " . s:complete_py
  set nopaste
endfunction

function! AIChatRun(selected_lines, ...) range
  let lines = getline(a:firstline, a:lastline)
  set paste
  let is_outside_of_chat_window = search('^>>> user$', 'nw') == 0
  if is_outside_of_chat_window
    call ScratchWindow()
    let prompt = ""
    if a:0 || a:selected_lines
      let prompt = MakePrompt(a:selected_lines, lines, a:0 ? a:1 : "")
    endif
    execute "normal i>>> system\nYou are a world class expert.\n>>> user\n" . prompt
  endif

  let options_default = g:vim_ai_chat_default['options']
  let options = g:vim_ai_chat['options']
  execute "py3file " . s:chat_py
  set nopaste
endfunction

" Function that saves a SCRATCH buffer to a specified path
function! SaveAIChatFunction(filename)
  let ext = ".aichat"

  let target_directory = expand("$HOME/.vim/tools/gpt/")
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

command! -nargs=1 -complete=file_in_path SaveAIChat call SaveAIChatFunction(<f-args>)
command! -range -nargs=? AI <line1>,<line2>call AIRun(<range>, <f-args>)
command! -range -nargs=? AIEdit <line1>,<line2>call AIEditRun(<range>, <f-args>)
command! -range -nargs=? AIChat <line1>,<line2>call AIChatRun(<range>, <f-args>)
