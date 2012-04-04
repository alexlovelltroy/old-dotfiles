call pathogen#infect()
" Vimrc is a strange file.  It can be tough to understand.  "
" When vimrc is edited, reload it
autocmd! bufwritepost vimrc source ~/.vimrc

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
" """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" " Set 7 lines to the curors - when moving vertical..
set so=7

set wildmenu "Turn on WiLd menu

set ruler "Always show current position

"set cmdheight=2 "The commandbar height

set hid "Change buffer - without saving

" Set backspace config
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

set ignorecase "Ignore case when searching
set smartcase

set hlsearch "Highlight search things

set incsearch "Make search act like search in modern browsers
set nolazyredraw "Don't redraw while executing macros 

set magic "Set magic on, for regular expressions

set showmatch "Show matching bracets when text indicator is over them
set mat=2 "How many tenths of a second to blink

" No sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set expandtab
set shiftwidth=4
set tabstop=4
set smarttab
set lbr
set tw=79
set ai "Auto indent
set si "Smart indet
set wrap "Wrap lines

" Turn on syntax highlighting "
syntax on
" Turn on automatic filetype detection "
filetype on
filetype plugin on
filetype indent on
" Set the colorscheme to something that doesn't suck.  Thanks Rico!"
colorscheme elflord
if has('gui_running')
    set background=light
else
    set background=dark
endif
colorscheme solarized
" Set to auto read when a file is changed from the outside
set autoread

" Make the mouse work even through ssh and screen "
"set ttymouse=xterm2
"set mouse=a
" Turn on incremental searching and turn off highlighting"
set incsearch
set nohls
" Remember lots of old lines
set history=1000
" No sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500
" set up syntax highlighting for my e-mail
au BufRead,BufNewFile .followup,.article,.letter,/tmp/pico*,nn.*,snd.*,/tmp/mutt*,/private*mutt* :set ft=mail 
au BufRead,BufNewFile .followup,.article,.letter,/tmp/pico*,nn.*,snd.*,/tmp/mutt*,/private*mutt* :VimroomToggle
" Add line numbers to all files"
set ic number
" Turn backup off.  It's faster and everything should be in VCS
set nobackup
set nowb
set noswapfile
"Allow backspace over start of insert and indent and EOL
set backspace=indent,start,eol
" Set the titlestring
set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}
"set titlestring=%{hostname()}\ %t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}
" Show me leading and trailing spaces and tabs"
set list listchars=tab:>-,trail:.,extends:>
" Move text, but keep selection
vnoremap > ><CR>gv
vnoremap < <<CR>gv

" Tab configuration
map <leader>tn :tabnew<cr>
map <leader>te :tabedit 
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove 

" File opening shortcuts: http://vimcasts.org/episodes/the-edit-command/
map <leader>ew :e <C-R>=expand("%:p:h") . "/" <CR>
map <leader>es :sp <C-R>=expand("%:p:h") . "/" <CR>
map <leader>ev :vsp <C-R>=expand("%:p:h") . "/" <CR>
map <leader>et :tabe <C-R>=expand("%:p:h") . "/" <CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Python
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Delete trailing white space, useful for Python ;)
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc
autocmd BufWrite *.py :call DeleteTrailingWS()

" Automatically set the foldmethod on python files"
au FileType python set foldmethod=indent
" Say goodbye to all tabs everywhere and setup automatic indentations"
au FileType python set tabstop=4 shiftwidth=4 smarttab expandtab softtabstop=4 autoindent
au FileType python match ErrorMsg '\%>80v.\+'
au FileType erlang set tabstop=4 shiftwidth=4 smarttab expandtab softtabstop=4 autoindent
" Automatically setup folding on javascript"
function! JavaScriptFold()
    setl foldmethod=syntax
    setl foldlevelstart=1
    syn region foldBraces start=/{/ end=/}/ transparent fold keepend extend

    function! FoldText()
        return substitute(getline(v:foldstart), '{.*', '{...}', '') 
    endfunction
    setl foldtext=FoldText()
endfunction
au FileType javascript call JavaScriptFold()
au FileType javascript setl fen 

" Nice statusbar
set laststatus=2
set statusline=
set statusline+=\{%{hostname()}\}\           " hostname.
set statusline+=%2*%-3.3n%0*\                " buffer number
set statusline+=%f\ 
if v:version > 702
  set statusline+=%{g:minscm_getStatus()}\     " SCM info
endif
set statusline+=%h%1*%m%r%w%0*               " flags
set statusline+=\[%{strlen(&ft)?&ft:'none'}, " filetype
set statusline+=%{&encoding},                " encoding
set statusline+=%{&fileformat}]              " file format
set statusline+=%=                           " right align
set statusline+=%2*0x%-8B\                   " current char
set statusline+=%-14.(%l,%c%V%)\ %<%P        " offset

" Some useful functions

"Kill trailing whitespace
function! s:StripTrailingWhitespaces()
  " Preparation: save last search, and cursor position.
  let _s=@/
  let l = line(".")
  let c = col(".")
  " Do the business:
  %s/\s\+$//e
  " Clean up: restore previous search history, and cursor position
  let @/=_s
  call cursor(l, c)
endfunction


" Shell redirect to vsplit panel awesomeness"
function! s:RunShellCommand(cmdline)
  let isfirst = 1
  let words = []
  for word in split(a:cmdline)
    if isfirst
      let isfirst = 0  " don't change first word (shell command)
    else
      if word[0] =~ '\v[%#<]'
        let word = expand(word)
      endif
      let word = shellescape(word, 1)
    endif
    call add(words, word)
  endfor
  let expanded_cmdline = join(words)
  botright vnew
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  call setline(1, 'You entered:  ' . a:cmdline)
  call setline(2, 'Expanded to:  ' . expanded_cmdline)
  call append(line('$'), substitute(getline(2), '.', '=', 'g'))
  silent execute '$read !'. expanded_cmdline
  1
endfunction

" Some really useful aliases that go with that shell function
command! -complete=shellcmd -nargs=+ Shell call s:RunShellCommand(<q-args>)
command! -complete=file -nargs=* Hg  call s:RunShellCommand('hg '.<q-args>)
command! -complete=file -nargs=* Nose  call s:RunShellCommand('nosetests '.<q-args>)

" Python PEP8 checking - requires pep8.py somewhere in the $PATH
" Control-P to run a PEP8 check on the current file...
nnoremap <silent> <C-p> :cexpr system("~/bin/pep8.py --repeat ".expand("%:p"))<CR>
" Then Control-J and Control-K to move between the 'errors'
nnoremap <silent> <C-j> :cnext<CR>
nnoremap <silent> <C-k> :cprevious<CR>

"if has("multi_byte")
"    if &termencoding == ""
"        let &termencoding = &encoding
"    endif
"    set encoding=utf-8
"    setglobal fileencoding=utf-8 bomb
"    set fileencodings=ucs-bom,utf-8,latin1
"endif
function! NERDTreeQuit()
  redir => buffersoutput
  silent buffers
  redir END
"                     1BufNo  2Mods.     3File           4LineNo
  let pattern = '^\s*\(\d\+\)\(.....\) "\(.*\)"\s\+line \(\d\+\)$'
  let windowfound = 0

  for bline in split(buffersoutput, "\n")
    let m = matchlist(bline, pattern)

    if (len(m) > 0)
      if (m[2] =~ '..a..')
        let windowfound = 1
      endif
    endif
  endfor

  if (!windowfound)
    quitall
  endif
endfunction
autocmd WinEnter * call NERDTreeQuit()
autocmd vimenter * if !argc() | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
let g:miniBufExplMapWindowNavVim = 1
