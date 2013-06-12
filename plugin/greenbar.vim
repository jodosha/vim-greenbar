" greenbar.vim - Visual feedback for your TDD cycle.
" Maintainer:    Luca Guidi <http://lucaguidi.com>
" Version:       0.1

if exists('g:loaded_greenbar') || &cp
  finish
endif
let g:loaded_greenbar = 1

if !exists('g:greenbar_file')
  let g:greenbar_file = '.greenbar'
endif

" Private functions {{{1
function! s:is_green()
  return readfile(g:greenbar_file, '', 1)[0][0] == 0
endfunction

function! s:is_within_tmux()
  return len($TMUX) > 0
endfunction

function! greenbar#set_statusline()
  let green = s:is_green()
  if green
    hi statusline guibg=Green ctermfg=64 guifg=White ctermbg=254
  else
    hi statusline guibg=Red ctermfg=160 guifg=White ctermbg=254
  endif
  return green
endfunction
" }}}1

" Public functions {{{1
function! SendTestToGreenbar(file)
  call RunGreenbarTest(a:file)
endfunction

function! SendFocusedTestToGreenbar(file, line)
  call RunGreenbarFocusedTest(a:file, a:line)
endfunction
" }}}1

" Mappings {{{1
nnoremap <silent> <Plug>SendTestToGreenbar :<C-U>w \| call SendTestToGreenbar(expand('%'))<CR>
nnoremap <silent> <Plug>SendFocusedTestToGreenbar :<C-U>w \| call SendFocusedTestToGreenbar(expand('%'), line('.'))<CR>

if !exists("g:no_greenbar_mappings")
  nmap <leader>t <Plug>SendTestToGreenbar
  nmap <leader>T <Plug>SendFocusedTestToGreenbar
endif

if !exists("g:tmux_session")
  let g:tmux_session = s:is_within_tmux()
endif

if g:tmux_session == 0
  autocmd ShellCmdPost * call greenbar#set_statusline()
endif

" override function from dispatch-vim
function! dispatch#complete(id)
  if !greenbar#set_statusline()
    exec ":Copen"
  endif
endfunction
" }}}1
