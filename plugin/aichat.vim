let g:system_seed = 'You are a clean and concise world-class software engineer, ready to help with programming-related, bash, and vim questions.'

let g:vim_ai_complete_default_options = {
      \  "model": "text-davinci-003",
      \  "max_tokens": 1000,
      \  "temperature": 0.1,
      \  "request_timeout": 20,
      \}
let g:vim_ai_edit_default_options = {
      \  "model": "text-davinci-003",
      \  "max_tokens": 1000,
      \  "temperature": 0.1,
      \  "request_timeout": 20,
      \}
let g:vim_ai_chat_default_options = {
      \  "model": "gpt-3.5-turbo",
      \  "max_tokens": 1000,
      \  "temperature": 1,
      \  "request_timeout": 20,
      \}
if !exists('g:vim_ai_complete_options')
  let g:vim_ai_complete_options = {}
endif
if !exists('g:vim_ai_edit_options')
  let g:vim_ai_edit_options = {}
endif
if !exists('g:vim_ai_chat_options')
  let g:vim_ai_chat_options = {}
endif

let s:plugin_root = expand('<sfile>:p:h:h')
let s:complete_py = s:plugin_root . "/py/complete.py"
let s:chat_py = s:plugin_root . "/py/chat.py"

function! aichat#MakePrompt(selected_lines, lines, instruction)
  let lines = trim(join(a:lines, "\n"))
  let instruction = trim(a:instruction)
  let delimiter = instruction != "" && a:selected_lines ? ":\n" : ""
  let selection = a:selected_lines || instruction == "" ? lines : ""
  let prompt = join([instruction, delimiter, selection], "")
  return prompt
endfunction

function! AIRun(selected_lines, ...) range
  let lines = getline(a:firstline, a:lastline)
  let prompt = aichat#MakePrompt(a:selected_lines, lines, a:0 ? a:1 : "")
  let options_default = g:vim_ai_complete_default_options
  let options = g:vim_ai_complete_options
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
  let prompt = aichat#MakePrompt(a:selected_lines, getline(a:firstline, a:lastline), a:0 ? a:1 : "")
  let options_default = g:vim_ai_edit_default_options
  let options = g:vim_ai_edit_options
  set paste
  execute "normal! " . a:firstline . "GV" . a:lastline . "Gc"
  execute "py3file " . s:complete_py
  set nopaste
endfunction

function! AIChatRun(viewType, selected_lines, ...) range
  let lines = getline(a:firstline, a:lastline)
  set paste
  let is_outside_of_chat_window = search('^>>> user$', 'nw') == 0
  if is_outside_of_chat_window
    call aichat#ScratchWindow(a:viewType)
    let prompt = ""
    if a:0 || a:selected_lines
      let prompt = aichat#MakePrompt(a:selected_lines, lines, a:1 ? a:2 : "")
    endif
    execute "normal i>>> system\n" . g:system_seed . "\n>>> user\n" . prompt
  endif

  let options_default = g:vim_ai_chat_default_options
  let options = g:vim_ai_chat_options
  execute "py3file " . s:chat_py
  set nopaste
endfunction

command! -nargs=1 -complete=file_in_path SaveAIChat call aichat#SaveAIChat(<f-args>)
command! -range -nargs=? AI <line1>,<line2>call AIRun(<range>, <f-args>)
command! -range -nargs=? AIEdit <line1>,<line2>call AIEditRun(<range>, <f-args>)
command! -range -nargs=? AIChat <line1>,<line2>call AIChatRun('enew', <range>, <f-args>)
command! -range -nargs=? AIVnewChat <line1>,<line2>call AIChatRun('vnew', <range>, <f-args>)
