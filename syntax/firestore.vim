if exists('b:current_syntax')
  finish
endif

" Global {{{
syntax match firestoreService /\%^\_s*service/ nextgroup=firestoreCloudFirestore skipwhite skipnl
hi def link firestoreService Statement

syntax match firestoreCloudFirestore +cloud\.firestore+ nextgroup=firestoreDeclaration skipwhite skipnl
hi def link firestoreCloudFirestore Keyword

syn region firestoreDeclaration matchgroup=firestoreBraces start=/{/ end=/}\_s*\%$/ contains=firestoreFunction,firestoreMatch,firestoreComment
" }}}

" Function {{{
syn keyword firestoreFunction function nextgroup=firestoreFunctionName skipwhite containedin=firestoreDeclaration
hi def link firestoreFunction Keyword

syn match firestoreFunctionName /\K\k*/ nextgroup=firestoreFunctionCall contained
hi def link firestoreFunctionName Function

syn region firestoreFunctionCall matchgroup=firestoreParens start=/(/ end=/)/ contains=firestoreFunctionComma,firestoreComment nextgroup=firestoreFunctionBlock skipwhite skipnl containedin=firestoreFunction
hi def link firestoreFunctionCall PreProc

syn match firestoreFunctionComma /,/ containedin=firestoreFunctionCall

syn region firestoreFunctionBlock matchgroup=firestoreParens start=/{/ end=/}/ contains=@firestoreFunctionBody containedin=firestoreFunction keepend

syn cluster firestoreFunctionBody contains=firestoreStatement

syn keyword firestoreStatement return nextgroup=@firestoreExpression skipwhite skipnl containedin=firestoreFunctionBody
hi def link firestoreStatement Statement
" }}}

" Match {{{
syn keyword firestoreMatch match nextgroup=firestoreMatchPath skipwhite skipnl containedin=firestoreDeclaration
hi def link firestoreMatch Function

syn match firestoreMatchPath +/[-0-9a-zA-Z]\+\>+ nextgroup=firestoreMatchPath,firestoreMatchPathInterpolation,firestoreMatchBlock skipwhite skipnl containedin=firestoreMatch
hi def link firestoreMatchPath String

syn match firestoreMatchPathInterpolation "/{[-0-9a-zA-Z]\+}"he=s+1 nextgroup=firestoreMatchPath,firestoreMatchPathInterpolation,firestoreMatchBlock skipwhite skipnl contains=firestoreMatchPathVariable containedin=firestoreMatch
hi def link firestoreMatchPathInterpolation String

syn match firestoreMatchPathVariable /{[-0-9a-zA-Z]\+}/ containedin=firestoreMatchPathInterpolation keepend
hi def link firestoreMatchPathVariable Label

syn region firestoreMatchBlock matchgroup=firestoreParens start=/{/ end=/}/ contains=@firestoreMatchBody containedin=firestoreMatch
" }}}

" Expression {{{
syn cluster firestoreExpression contains=@firestoreValue,firestoreParentheses

syn region firestoreParentheses matchgroup=firestoreParens start=/(/ end=/)/ nextgroup=@firestoreOp skipwhite skipnl contains=@firestoreExpression

" Value {{{
syn cluster firestoreValue contains=firestoreVariable,firestoreNumber,firestoreString,firestoreList,firestoreType

syn match firestoreVariable /\K\k*\>\((\)\@!/ nextgroup=firestoreMethod,firestoreProperty,@firestoreOp skipwhite skipnl contained
hi def link firestoreVariable Identifier

" integer
syn match firestoreNumber /\v-?\d+/ nextgroup=@firestoreOp skipwhite skipnl containedin=firestoreValue
" float
syn match firestoreNumber /\v-?\d+\.\d*/ nextgroup=@firestoreOp skipwhite skipnl containedin=firestoreNumber
syn match firestoreNumber /\v-?\.\d+/ nextgroup=@firestoreOp skipwhite skipnl containedin=firestoreNumber
hi def link firestoreNumber Number

syn region firestoreString start=/\z(['"]\)/ skip=/\\\z1/ end=/\z1/ nextgroup=firestoreMethod,@firestoreOp skipwhite skipnl contains=firestoreEscapedCharacter containedin=firestoreValue
hi def link firestoreString String

syn match firestoreEscapedCharacter /\\./ containedin=firestoreString
hi def link firestoreEscapedCharacter SpecialChar

syn region firestoreList matchgroup=firestoreBrackets start=/\[/ end=/\]/ nextgroup=firestoreMethod contains=@firestoreExpression containedin=firestoreValue
syn region firestoreList matchgroup=firestoreBrackets start=/\[/ end=/\]/ nextgroup=@firestoreOp skipwhite skipnl contains=@firestoreExpression containedin=firestoreValue
" }}}

syn match firestoreProperty /\.\K\k*\>\((\)\@!/ nextgroup=firestoreMethod,firestoreProperty,@firestoreOp skipwhite skipnl contained

" Method {{{
syn region firestoreMethod start=/\.\K\k*(/ end=/)/ nextgroup=firestoreMethod contains=firestoreMethodName,firestoreMethodCall containedin=firestoreFunctionBlock keepend
syn region firestoreMethod start=/\.\K\k*(/ end=/)/ nextgroup=@firestoreOp skipwhite skipnl contains=firestoreMethodName,firestoreMethodCall containedin=firestoreFunctionBlock keepend

" duration
syn keyword firestoreMethodName nanos seconds containedin=firestoreMethod
" latlng
syn keyword firestoreMethodName latitude longitude containedin=firestoreMethod
" list
syn keyword firestoreMethodName hasAll hasAny hasOnly join size containedin=firestoreMethod
" map
syn keyword firestoreMethodName keys values containedin=firestoreMethod
" path
syn keyword firestoreMethodName bind containedin=firestoreMethod
" request
syn keyword firestoreMethodName auth method path query resource containedin=firestoreMethod
" resource
syn keyword firestoreMethodName name data id containedin=firestoreMethod
hi def link firestoreMethodName Keyword

syn region firestoreMethodCall matchgroup=firestoreParens start=/(/ end=/)/ contains=firestoreMethod,@firestoreExpression
" }}}

" Op {{{
syn cluster firestoreOp contains=firestoreOpKeywords,firestoreOpArithmetics
hi def link firestoreOp Operator

syn keyword firestoreOpKeywords is nextgroup=firestoreType skipwhite skipnl containedin=@firestoreOp
syn keyword firestoreOpKeywords in nextgroup=@firestoreExpression skipwhite skipnl containedin=@firestoreOp

syn match firestoreOpArithmetics ,[-+*/%]\|!!\|&&\|||\|[!=]==\?\|>=\|<=\|<<[<=]\?\|>>[>=]?\|[=!><|&], nextgroup=@firestoreExpression skipwhite skipnl containedin=@firestoreOp
hi def link firestoreOpArithmetics Operator
" }}}

syn keyword firestoreType bool duration float integer latlng list map number path string timestamp nextgroup=@firestoreOp skipwhite skipnl contained
hi def link firestoreType Type
" }}}

" Comment {{{
syn match firestoreComment +//.*+ contains=@Spell,firestoreTodo
hi def link firestoreComment Comment

syn keyword firestoreTodo TODO FIXME XXX BUG containedin=firestoreComment
hi def link firestoreTodo Todo
" }}}

hi def link firestoreParens Normal
hi def link firestoreBraces Function
hi def link firestoreBrackets Function

let b:current_syntax = 'firestore'

" vim:se fdm=marker:
