" Vim indent file
" Language: Vue.js
" Maintainer: Eduardo San Martin Morote
" Author: Adriaan Zonnenberg

if exists('b:did_indent')
  finish
endif
let b:did_indent = 1

" The order is important here, tags without attributes go last.
" HTML is left out, it will be used when there is no match.
if !exists('g:vue_indent_languages')
  let g:vue_indent_languages = [
        \   { 'name': 'pug', 'pairs': ['<template lang="pug"', '</template>'] },
        \   { 'name': 'stylus', 'pairs': ['<style lang="stylus"', '</style>'] },
        \   { 'name': 'css', 'pairs': ['<style', '</style>'] },
        \   { 'name': 'coffee', 'pairs': ['<script lang="coffee"', '</script>'] },
        \   { 'name': 'javascript', 'pairs': ['<script', '</script>'] },
        \ ]
endif

" Load and return the indentexpr for language, resetting indentexpr to its
" prior value before returning.
function! s:get_indentexpr(language)
  let saved_indentexpr = &indentexpr
  let &l:indentexpr = ''
  if strlen(globpath(&rtp, 'indent/'. a:language .'.vim'))
    unlet! b:did_indent
    execute 'runtime! indent/' . a:language . '.vim'
    let b:did_indent = 1
  endif
  let lang_indentexpr = &indentexpr
  let &l:indentexpr = saved_indentexpr
  return lang_indentexpr
endfunction

let s:html_indent = s:get_indentexpr('html')

setlocal indentexpr=GetVueIndent()

if exists('*GetVueIndent')
  finish
endif

function! GetVueIndent()
  for language in g:vue_indent_languages
    let opening_tag_line = searchpair(language.pairs[0], '', language.pairs[1], 'bWr')

    if opening_tag_line
      if !has_key(language, 'indentexpr')
        let language.indentexpr = s:get_indentexpr(language.name)
      endif
      if !empty(language.indentexpr)
        execute 'let indent = ' . get(language, 'indentexpr', -1)
      endif
      break
    endif
  endfor

  if exists('l:indent')
    if (opening_tag_line == prevnonblank(v:lnum - 1) || opening_tag_line == v:lnum)
          \ || getline(v:lnum) =~ '\v^\s*\</(script|style|template)'
      return 0
    endif
  else
    " Couldn't find language, fall back to html
    execute 'let indent = ' . s:html_indent
  endif

  return indent
endfunction
