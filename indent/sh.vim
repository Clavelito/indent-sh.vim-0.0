vim9script noclear

# Vim indent file
# Language:         Shell Script
# Author:           Clavelito <maromomo@hotmail.com>
# Last Change:      Tue, 01 Mar 2022 10:24:04 +0900
# Version:          0.0
# License:          http://www.apache.org/licenses/LICENSE-2.0
#
# Description:      This is not a gg=G filter.
#                   This is a very simplified version.


if exists('b:did_indent')
  finish
endif
b:did_indent = 1

setlocal indentexpr=g:GetShInd()
setlocal indentkeys+=0=elif,0=fi,0=esac,0=done
setlocal indentkeys-=:,0#
b:undo_indent = 'setlocal indentexpr< indentkeys<'

if exists('*g:GetShInd')
  finish
endif
const cpo_save = &cpo
set cpo&vim

def g:GetShInd(): number
  var lnum = prevnonblank(v:lnum - 1)
  var line = getline(lnum)
  while lnum > 0 && Comment(line)
    lnum = prevnonblank(lnum - 1)
    line = getline(lnum)
  endwhile
  const cline = getline(v:lnum)
  if lnum == 0 || cline =~ '^#'
    return 0
  endif
  var pnum = prevnonblank(lnum - 1)
  var pline = getline(pnum)
  while pnum > 0 && Comment(pline)
    pnum = prevnonblank(pnum - 1)
    pline = getline(pnum)
  endwhile
  var ind = indent(lnum)
  if (Continue(pline) || Bar(pline)) && !Continue(line) && !Bar(line)
    while pnum > 0 && (Comment(pline) || Continue(pline) || Bar(pline))
      if !Comment(pline)
        ind = indent(pnum)
      endif
      if Esac(pline)
        break
      endif
      pnum = prevnonblank(pnum - 1)
      pline = getline(pnum)
    endwhile
  endif
  if (CaseStart(pline) || CaseEnd(pline)) && !Esac(line) && !Backslash(line)
      || !Backslash(pline) && Backslash(line)
      && !CaseStart(pline) && (!CaseEnd(pline) || CaseEnd(pline) && Esac(line))
    ind += shiftwidth()
  elseif ExprCont(pline) && !Continue(line)
    ind = indent(pnum)
  endif
  if CaseStart(line)
      || ExprCont(line)
      || line =~# '[]});]\s*\%(do\|then\)\%(\s\|$\)'
      || line =~# '^\s*\%(do\|then\|else\)\%(\s\|$\)'
      || line =~# '\<\%(for\|select\)\s\+\h\w*\s\+do\%(\s\|$\)'
      || line =~# '^\s*\%(if\|elif\|while\|until\)\s' && Continue(line)
      || line =~ '^[^#]*[$\\]\@1<!{\s*\%(#[^}]*\)\=$'
      || line =~ '^[^#]*\\\@1<!((\=\s*\%(#[^)]*\)\=$'
    ind += shiftwidth()
  endif
  if line =~# '[;&})]\s*\%(done\|fi\)\>'
    ind -= shiftwidth()
  endif
  if CaseEnd(line)
    ind -= shiftwidth()
  endif
  if Esac(cline)
    ind -= CaseEnd(line) ? shiftwidth() : shiftwidth() * 2
  elseif cline =~# '^\s*\%(done\|fi\)\>'
      || cline =~# '^\s*\%(elif\|else\)\%(\s\|$\)'
      || cline =~ '^\s*[})]'
    ind -= shiftwidth()
  endif
  return ind
enddef

def Continue(line: string): bool
  return AndOr(line) || Backslash(line)
enddef

def AndOr(line: string): bool
  return line =~ '\%(&&\|||\)\s*\%(#.*\|\\\)\=$'
enddef

def Backslash(line: string): bool
  return line =~ '\\\@1<!\%(\\\\\)*\\$'
enddef

def Bar(line: string): bool
  return line =~ '\%([;|]\@1<!\&\\\@1<!\%(\\\\\)*\)|&\=\s*\%(#.*\|\\\)\=$'
enddef

def ExprCont(line: string): bool
  return line =~# '^\s*\%(if\|elif\|while\|until\)\%(\s*\\\=\|\s\+#.*\)$'
enddef

def CaseStart(line: string): bool
  return line =~# '\<case\s.*\sin\%(\s*\|\s\+#.*\)$'
enddef

def CaseEnd(line: string): bool
  return line =~ ';[;&|]\s*\%(#.*\)\=$'
enddef

def Esac(line: string): bool
  return line =~# '^\s*esac\>'
enddef

def Comment(line: string): bool
  return line =~ '^\s*#'
enddef

&cpo = cpo_save
