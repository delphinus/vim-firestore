if exists('b:current_syntax')
  finish
endif

let s:vim_firestore_warnings = get(g:, 'vim_firestore_warnings', 1)

if s:vim_firestore_warnings
  " Theses error regexp are derived from syntax/json.vim
  syn cluster firestoreSyntaxError contains=firestoreUnknownStatement,firestoreTripleQuotesError
  syn match firestoreUnknownStatement /\<[[:alpha:]][[:alnum:]]*\>/
  syn match firestoreTripleQuotesError /\%("""\|'''\)/
endif

" Global {{{
syntax match firestoreRulesVersion /\%^\_s*rules_version/ nextgroup=firestoreOpRulesVersion skipwhite
hi def link firestoreRulesVersion Statement

syn keyword firestoreOpRulesVersion = nextgroup=firestoreRulesVersionString skipwhite
syn match firestoreRulesVersionString /\(['"]\)\d\+\1/ nextgroup=firestoreMatchSemicolon skipwhite

syntax match firestoreService /^\_s*service/ nextgroup=firestoreCloudFirestore skipwhite skipnl
hi def link firestoreService Statement

syntax match firestoreCloudFirestore +cloud\.firestore+ nextgroup=firestoreDeclaration skipwhite skipnl
hi def link firestoreCloudFirestore Keyword

syn region firestoreDeclaration matchgroup=firestoreBraces start=/{/ end=/}\_s*\%$/ contains=firestoreFunction,firestoreMatch,firestoreComment,@firestoreSyntaxError
" }}}

" Function {{{
syn keyword firestoreFunction function nextgroup=firestoreFunctionName skipwhite containedin=firestoreDeclaration
hi def link firestoreFunction Keyword

syn match firestoreFunctionName /\K\k*/ nextgroup=firestoreFunctionCallSignature contained
hi def link firestoreFunctionName Function

syn region firestoreFunctionCallSignature matchgroup=firestoreParens start=/(/ end=/)/ contains=firestoreFunctionComma,firestoreComment nextgroup=firestoreFunctionBlock skipwhite skipnl containedin=firestoreFunction
hi def link firestoreFunctionCallSignature PreProc

syn match firestoreFunctionComma /,/ containedin=firestoreFunctionCallSignature

syn region firestoreFunctionBlock matchgroup=firestoreParens start=/{/ end=/}/ contains=firestoreStatement,@firestoreSyntaxError containedin=firestoreFunction keepend

syn keyword firestoreStatement return nextgroup=@firestoreExpression skipwhite skipnl containedin=firestoreFunctionBody
hi def link firestoreStatement Statement
" }}}

" Match {{{
syn keyword firestoreMatch match nextgroup=@firestoreMatchPath skipwhite skipnl containedin=firestoreDeclaration
hi def link firestoreMatch Keyword

syn cluster firestoreMatchPath contains=firestoreMatchPathConstant,firestoreMatchPathInterpolation,firestoreMatchPathDocumentAll

syn match firestoreMatchPathConstant +/[-_0-9a-zA-Z]\+\>+ nextgroup=@firestoreMatchPath,firestoreMatchBlock skipwhite skipnl containedin=firestoreMatch
hi def link firestoreMatchPathConstant String

syn match firestoreMatchPathInterpolation "/{[-_0-9a-zA-Z]\+}"he=s+1 nextgroup=@firestoreMatchPath,firestoreMatchBlock skipwhite skipnl contains=firestoreMatchPathVariable containedin=firestoreMatch
hi def link firestoreMatchPathInterpolation String

syn match firestoreMatchPathVariable /{[-_0-9a-zA-Z]\+}/ containedin=firestoreMatchPathInterpolation keepend
hi def link firestoreMatchPathVariable Label

syn match firestoreMatchPathDocumentAll "/{\(document\|sub\)=\*\*}" nextgroup=@firestoreMatchPath,firestoreMatchBlock skipwhite skipnl contains=firestoreMatchPathDocumentAllInternal containedin=firestoreMatch
hi def link firestoreMatchPathDocumentAll String

syn match firestoreMatchPathDocumentAllInternal /{\(document\|sub\)=\*\*}/ containedin=firestoreMatchPathDocumentAll keepend
hi def link firestoreMatchPathDocumentAllInternal Label

syn cluster firestoreMatchBlockStatement contains=firestoreFunction,firestoreAllow,firestoreComment,firestoreMatchSemicolon

syn region firestoreMatchBlock matchgroup=firestoreParens start=/{/ end=/}/ contains=firestoreMatch,firestoreFunction,firestoreComment,@firestoreMatchBlockStatement,@firestoreSyntaxError contained

syn match firestoreMatchSemicolon /;/ nextgroup=@firestoreMatchBlockStatement skipwhite skipnl contained

syn keyword firestoreAllow allow nextgroup=firestoreAccessControl skipwhite skipnl
hi def link firestoreAllow Statement

syn keyword firestoreAccessControl get list read create update delete write nextgroup=firestoreAllowDelimiter skipwhite skipnl contained
hi def link firestoreAccessControl PreProc

syn match firestoreAllowDelimiter /,/ nextgroup=firestoreAccessControl skipwhite skipnl contained
syn match firestoreAllowDelimiter /:/ nextgroup=firestoreIf skipwhite skipnl contained

syn keyword firestoreIf if nextgroup=@firestoreExpression skipwhite skipnl contained
hi def link firestoreIf Statement
" }}}

" Expression {{{
syn cluster firestoreExpression contains=@firestoreValue,firestoreParentheses,firestoreOpUnary

syn cluster firestoreNextStatement contains=firestoreMethod,firestoreProperty,@firestoreOp,@firestoreMatchBlockStatement

syn region firestoreParentheses matchgroup=firestoreParens start=/(/ end=/)/ nextgroup=@firestoreNextStatement,firestoreSlice skipwhite skipnl contains=@firestoreExpression

" Value {{{
syn cluster firestoreValue contains=firestoreVariable,firestoreFunctionCall,@firestoreNumber,@firestorePath,firestoreString,firestoreList,firestoreMap,firestoreValueKeywords

syn match firestoreVariable /\K\k*\>\((\)\@!/ nextgroup=@firestoreNextStatement,firestoreSlice skipwhite skipnl contained
hi def link firestoreVariable Identifier

syn region firestoreFunctionCall matchgroup=firestoreFunctionCallNormal start=/\K\k*(/ end=/)/ nextgroup=@firestoreNextStatement,firestoreSlice skipwhite skipnl contains=@firestoreExpression contained
hi def link firestoreFunctionCallNormal Normal
syn region firestoreFunctionCall matchgroup=firestoreFunctionCallDefined start=/\(bool\|exists\|float\|get\|getAfter\|int\|string\)(/ end=/)/ nextgroup=@firestoreNextStatement,firestoreSlice skipwhite skipnl contains=@firestoreExpression contained
hi def link firestoreFunctionCallDefined Identifier

syn region firestoreSlice matchgroup=firestoreBrackets start=/\[/ end=/\]/ nextgroup=@firestoreNextStatement skipwhite skipnl contains=@firestoreExpression,firestoreOpUnary contained

" number
syn cluster firestoreNumber contains=firestoreNumberInteger,firestoreNumberFloat

" integer
syn match firestoreNumberInteger /\v-?\d+/ nextgroup=@firestoreOp,@firestoreMatchBlockStatement skipwhite skipnl containedin=firestoreValue
hi def link firestoreNumberInteger Number
" float
syn match firestoreNumberFloat /\v-?\d+\.\d*/ nextgroup=@firestoreOp,@firestoreMatchBlockStatement skipwhite skipnl containedin=firestoreNumber
syn match firestoreNumberFloat /\v-?\.\d+/ nextgroup=@firestoreOp,@firestoreMatchBlockStatement skipwhite skipnl containedin=firestoreNumber
hi def link firestoreNumberInteger Number

" string
syn region firestoreString start=/\z(['"]\)/ skip=/\\\z1/ end=/\z1/ nextgroup=firestoreMethod,@firestoreOp skipwhite skipnl contains=firestoreEscapedCharacter containedin=firestoreValue
hi def link firestoreString String

syn match firestoreEscapedCharacter /\\./ containedin=firestoreString
hi def link firestoreEscapedCharacter SpecialChar

" list
syn region firestoreList matchgroup=firestoreBrackets start=/\[/ end=/\]/ nextgroup=firestoreMethod contains=@firestoreExpression containedin=firestoreValue
syn region firestoreList matchgroup=firestoreBrackets start=/\[/ end=/\]/ nextgroup=@firestoreNextStatement skipwhite skipnl contains=@firestoreExpression containedin=firestoreValue

" map
syn region firestoreMap matchgroup=firestoreBraces start=/{/ end=/}/ nextgroup=@firestoreNextStatement skipwhite skipnl contains=@firestoreExpression,firestoreOpUnary containedin=firestoreValue

" path
syn cluster firestorePath contains=firestorePathConstant,firestorePathDefault,firestorePathInterpolation

syn match firestorePathConstant "/[-_0-9a-zA-Z]\+\>" nextgroup=@firestorePath,@firestorePathOp skipwhite skipnl contained
hi def link firestorePathConstant String

syn match firestorePathDefault "/(default)" nextgroup=@firestorePath,@firestorePathOp skipwhite skipnl contains=firestorePathDefaultParens,firestorePathDefaultKeywords contained

syn match firestorePathDefaultParens "/(\|)" containedin=firestorePathDefault
hi def link firestorePathDefaultParens String

syn keyword firestorePathDefaultKeywords default containedin=firestorePathDefault
hi def link firestorePathDefaultKeywords Identifier

syn region firestorePathInterpolation matchgroup=firestorePathInterpolationDelimiter start="/\$(" end=")" nextgroup=@firestorePath,@firestorePathOp skipwhite skipnl contains=@firestoreExpression contained
hi def link firestorePathInterpolationDelimiter Label

" special values
syn keyword firestoreValueKeywords NaN true false null nextgroup=@firestoreOp,@firestoreMatchBlockStatement skipwhite skipnl containedin=firestoreValue
syn match firestoreValueKeywords /∞/ nextgroup=@firestoreOp,@firestoreMatchBlockStatement skipwhite skipnl containedin=firestoreValue
hi def link firestoreValueKeywords Keyword

" }}}

syn match firestoreProperty /\.\K\k*\>\((\)\@!/ nextgroup=@firestoreNextStatement,firestoreSlice skipwhite skipnl contained

" Method {{{
syn region firestoreMethod start=/\.\K\k*(/ end=/)/ nextgroup=@firestoreNextStatement,firestoreSlice skipwhite skipnl contains=firestoreMethodName,firestoreMethodCall contained keepend

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
syn cluster firestoreOp contains=firestoreOpKeywords,firestoreOpArithmetics,firestoreOpSlash,firestoreOpRulesVersion

syn keyword firestoreOpKeywords is nextgroup=firestoreType skipwhite skipnl containedin=@firestoreOp
syn keyword firestoreOpKeywords in nextgroup=@firestoreExpression skipwhite skipnl containedin=@firestoreOp
hi def link firestoreOpKeywords Operator

syn match firestoreOpArithmetics ,[-+*%:]\|!!\|&&\|||\|[!=]==\?\|>=\|<=\|<<[<=]\?\|>>[>=]?\|[=!><|&], nextgroup=@firestoreExpression skipwhite skipnl containedin=@firestoreOp
hi def link firestoreOpArithmetics Operator

syn match firestoreOpSlash +/+ nextgroup=@firestoreExpression skipwhite skipnl contained
hi def link firestoreOpSlash Operator

syn match firestoreOpUnary /!/ nextgroup=@firestoreExpression,firestoreParentheses skipwhite skipnl contained

" this is used for @firestorePath
syn cluster firestorePathOp contains=firestoreOpKeywords,firestoreOpArithmetics
" }}}

syn keyword firestoreType bool duration float integer latlng list map number path string timestamp nextgroup=@firestoreOp,firestoreComment skipwhite skipnl contained
hi def link firestoreType Type
" }}}

" Comment {{{
syn match firestoreComment +//.*+ nextgroup=@firestoreValue,firestoreMatch,firestoreParentheses,firestoreOpUnary,@firestoreMatchBlockStatement,@firestoreOp skipwhite skipnl contains=@Spell,firestoreTodo
hi def link firestoreComment Comment

syn keyword firestoreTodo TODO FIXME XXX BUG containedin=firestoreComment
hi def link firestoreTodo Todo
" }}}

hi def link firestoreParens Normal
hi def link firestoreBraces Function
hi def link firestoreBrackets Function

if s:vim_firestore_warnings
  hi def link firestoreUnknownStatement Error
  hi def link firestoreTripleQuotesError Error
endif

let b:current_syntax = 'firestore'

" vim:se fdm=marker:
