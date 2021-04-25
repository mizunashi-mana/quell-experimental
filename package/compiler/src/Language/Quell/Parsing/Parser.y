{
module Language.Quell.Parsing.Parser where

import Language.Quell.Prelude

import qualified Prelude
import qualified Language.Quell.Type.Ast                        as Ast
import qualified Language.Quell.Type.Token                      as Token
import qualified Language.Quell.Parsing.Parser.Layout           as Layout
import qualified Language.Quell.Data.Bag                        as Bag
import qualified Language.Quell.Parsing.Spanned                 as Spanned
import qualified Language.Quell.Parsing.Runner                  as Runner
import           Language.Quell.Parsing.Parser.AstParsed
}

%expect 0

%token
    '#case'         { S Token.KwCase }
    '#data'         { S Token.KwData }
    '#do'           { S Token.KwDo }
    '#in'           { S Token.KwIn }
    '#let'          { S Token.KwLet }
    '#letrec'       { S Token.KwLetrec }
    '#newtype'      { S Token.KwNewtype }
    '#of'           { S Token.KwOf }
    '#type'         { S Token.KwType }
    '#when'         { S Token.KwWhen }
    '#where'        { S Token.KwWhere }
    '#yield'        { S Token.KwYield }

    '->'        { S Token.SymArrow }
    '@'         { S Token.SymAt }
    ':'         { S Token.SymColon }
    '=>'        { S Token.SymDArrow }
    '='         { S Token.SymEqual }
    '\\/'       { S Token.SymForall }
    '\\'        { S Token.SymLambda }
    '<-'        { S Token.SymLeftArrow }
    '|'         { S Token.SymOr }
    '_'         { S Token.SymUnderscore }

    '`'         { S Token.SpBackquote }
    '#@'        { S Token.SpBlock }
    '['         { S Token.SpBrackOpen }
    ']'         { S Token.SpBrackClose }
    ','         { S Token.SpComma }
    '{'         { S Token.SpBraceOpen }
    '}'         { S Token.SpBraceClose }
    '{{'        { S Token.SpDBraceOpen }
    '}}'        { S Token.SpDBraceClose }
    '('         { S Token.SpParenOpen }
    ')'         { S Token.SpParenClose }
    ';'         { S Token.SpSemi }
    VOBRACE     { S Token.SpVBraceOpen }
    VCBRACE     { S Token.SpVBraceClose }
    VSEMI       { S Token.SpVSemi }

    CONID       { S (Token.IdConId _) }
    CONSYM      { S (Token.IdConSym _) }
    VARID       { S (Token.IdVarId _) }
    VARSYM      { S (Token.IdVarSym _) }

    BYTECHAR    { S (Token.LitByteChar _) }
    BYTESTRING  { S (Token.LitByteString _) }
    CHAR        { S (Token.LitChar _) }
    STRING      { S (Token.LitString _) }
    INTEGER     { S (Token.LitInteger _) }
    RATIONAL    { S (Token.LitRational _) }

    INTERP_STRING_WITHOUT_INTERP    { S (Token.LitInterpStringWithoutInterp _) }
    INTERP_STRING_START             { S (Token.LitInterpStringStart _) }
    INTERP_STRING_CONTINUE          { S (Token.LitInterpStringContinue _) }
    INTERP_STRING_END               { S (Token.LitInterpStringEnd _) }

%monad { Runner.T }{ >>= }{ return }
%lexer { lexer }{ S Token.EndOfSource }
%tokentype { Spanned.T Token.T }

%name parseProgram          program
%name parseType             type
%name parseExpr             expr
%name parsePat              pat
%name parseLiteral          literal
%%

program :: { Ast.Program C }
    : decl_body
    {
        Ast.Program
            {
                decls = otoList $1
            }
    }

decl_body :: { Bag.T (Ast.Decl C) }
    : lopen decl_items lclose   { $2 }

decl_items :: { Bag.T (Ast.Decl C) }
    : decl_items_semis decl_item    { $1 <> pure $2 }
    | decl_items_semis              { $1 }

decl_items_semis :: { Bag.T (Ast.Decl C) }
    : decl_items_semis decl_item lsemis     { $1 <> pure $2 }
    | {- empty -}                           { mempty }

decl_item :: { Ast.Decl C }
    : sig_item              { $1 }
    | type_decl             { undefined }
    | data_decl             { undefined }
    | val_decl              { undefined }


typesig_decl :: { Ast.Decl C }
    : '#type' declcon ':' type
    { spAnn ($1, $2, $3, $4) do Ast.DeclTypeSig (unS $2) $4 }

valsig_decl :: { Ast.Decl C }
    : var ':' type -- declvar ':' type
    { spAnn ($1, $2, $3) do Ast.DeclValSig (unS $1) $3 }

consig_decl :: { Ast.Decl C }
    : declcon ':' type
    { spAnn ($1, $2, $3) do Ast.DeclConSig (unS $1) $3 }


type_decl :: { () }
    : '#type' decltype '=' type type_decl_where    { () }

type_decl_where :: { () }
    : '#where' type_decl_where_body  { () }
    | {- empty -}                   { () }

type_decl_where_body :: { () }
    : lopen type_decl_where_items lclose    { () }

type_decl_where_items :: { () }
    : type_decl_where_items_semis type_decl_where_item  { () }
    | type_decl_where_items_semis                       { () }

type_decl_where_items_semis :: { () }
    : type_decl_where_items_semis type_decl_where_item lsemis   { () }
    | {- empty -}                                               { () }

type_decl_where_item :: { () }
    : typesig_decl      { () }
    | type_decl         { () }


data_decl :: { () }
    : '#data' declcon ':' type data_decl_where                   { () }
    | '#data' declcon data_decl_where                            { () }
    | '#data' decltype '=' alg_data_type type_decl_where         { () }
    | '#newtype' decltype '=' type type_decl_where               { () }

data_decl_where :: { () }
    : '#where' data_decl_body    { () }
    | {- empty -}               { () }

data_decl_body :: { () }
    : lopen data_decl_items lclose  { () }

data_decl_items :: { () }
    : data_decl_items_semis data_decl_item  { () }
    | data_decl_items_semis                 { () }

data_decl_items_semis :: { () }
    : data_decl_items_semis data_decl_item lsemis   { () }
    | {- empty -}                                   { () }

data_decl_item :: { () }
    : consig_decl       { () }

alg_data_type :: { () }
    : '(' alg_data_type_items ')'   { () }
    | alg_data_type_items           { () }

alg_data_type_items :: { () }
    : alg_data_type_items_vbar impltype '|'     { () }
    | alg_data_type_items_vbar impltype         { () }

alg_data_type_items_vbar :: { () }
    : alg_data_type_items_vbar impltype '|'     { () }
    | '|'                                       { () }
    | {- empty -} %shift                        { () }


val_decl :: { () }
    : declvarexpr '=' expr val_decl_where     { () }

val_bind :: { () }
    : pat '=' expr val_decl_where       { () }

val_decl_where :: { () }
    : '#where' val_decl_where_body   { () }
    | {- empty -}                   { () }

val_decl_where_body :: { () }
    : lopen val_decl_where_items lclose { () }

val_decl_where_items :: { () }
    : val_decl_where_items_semis val_decl_where_item    { () }
    | val_decl_where_items_semis                        { () }

val_decl_where_items_semis :: { () }
    : val_decl_where_items_semis val_decl_where_item lsemis { () }
    | {- empty -}                                           { () }

val_decl_where_item :: { () }
    : let_bind_item     { () }


decltype :: { Ast.DeclType C }
    : declcon bind_vars
    {
        let vs = otoList $2
        in spAnn ($1 :< vs) do Ast.DeclAppType (unS $1) vs
    }
    | simpl_bind_var_decl declconop simpl_bind_var_decl
    { spAnn ($1, $2, $3) do Ast.DeclInfixType $1 (unS $2) $3 }

impltype :: { Ast.ImplType C }
    : con type_apps_list
    {
        let ts = otoList $2
        in spAnn ($1 :< ts) do Ast.ImplAppType (unS $1) ts
    }
    | type_qualified conop type_qualified
    { spAnn ($1, $2, $3) do Ast.ImplInfixType $1 (unS $2) $3 }

declvarexpr :: { () }
    : declvar bind_vars                         { () }
    | simple_bind_var declop simple_bind_var    { () }

simpl_bind_var_decl :: { Ast.BindVar C }
    : simple_bind_var
    { spAnn $1 case unS $1 of (n, mt) -> Ast.BindVar n mt }


type :: { Ast.TypeExpr C }
    : '\\/' bind_vars '=>' type
    {
        case otoList $2 of
            [] ->
                spAnn ($1, $3, $4) do Ast.TypeForall [] $4
            bvs0@(bv:bvs) ->
                spAnn ($1, bv :| bvs, $3, $4) do Ast.TypeForall bvs0 $4
    }
    | type_unit '->' type
    {
        case spAnn $2 do Ast.TypeVar Ast.primNameArrow of
            t2 -> spAnn ($1, $2, $3) do Ast.TypeInfix $1 t2 $3
    }
    | type_unit %shift              { $1 }

type_unit :: { Ast.TypeExpr C }
    : type_infix %shift         { $1 }

type_infix :: { Ast.TypeExpr C }
    : type_infix type_op type_apps  { spAnn ($1, $2, $3) do Ast.TypeInfix $1 $2 $3 }
    | type_apps %shift              { $1 }

type_op :: { Ast.TypeExpr C }
    : consym                        { spAnn $1 do Ast.TypeCon do unS $1 }
    | var_sym_ext                   { spAnn $1 do Ast.TypeVar do unS $1 }
    | '`' type_qualified_op '`'     { spAnn ($1, $2, $3) do Ast.TypeAnn $2 }

type_qualified_op :: { Ast.TypeExpr C }
    : con_sym_ext   { spAnn $1 do Ast.TypeCon do unS $1 }
    | var_sym_ext   { spAnn $1 do Ast.TypeVar do unS $1 }
    | type_block    { $1 }

type_apps :: { Ast.TypeExpr C }
    : type_qualified type_apps_list %shift
    {
        case otoList $2 of
            [] ->
                $1
            xs0@(x:xs) ->
                spAnn ($1, x :| xs) do Ast.TypeApp $1 xs0
    }

type_apps_list :: { Bag.T (Ast.AppType C) }
    : type_apps_list type_app   { snoc $1 $2 }
    | type_qualified            { mempty }

type_app :: { Ast.AppType C }
    : '@' type_qualified    { spAnn ($1, $2) do Ast.UnivAppType $2 }
    | type_qualified        { spAnn $1 do Ast.AppType $1 }

type_qualified :: { Ast.TypeExpr C }
    : type_block            { $1 }

type_block :: { Ast.TypeExpr C }
    : type_atomic           { $1 }

type_atomic :: { Ast.TypeExpr C }
    : '(' type ':' type ')'
    { spAnn ($1, $2, $3, $4, $5) do Ast.TypeSig $2 $4 }
    | '(' type ')'                      { spAnn ($1, $2, $3) do Ast.TypeAnn $2 }
    | con                               { spAnn $1 do Ast.TypeCon do unS $1 }
    | var                               { spAnn $1 do Ast.TypeVar do unS $1 }
    | literal                           { spAnn $1 do Ast.TypeLit $1 }
    | '(' type_tuple_items ')'
    { spAnn ($1, $2, $3) do Ast.TypeTuple do otoList do unS $2 }
    | '[' type_array_items ']'
    {
        case $2 of { (ms2, ts) ->
            spAnn ($1 :< ms2, $3) do Ast.TypeArray do otoList ts
        }
    }
    | '{' type_simplrecord_items '}'
    {
        case $2 of { (ms2, ts) ->
            spAnn ($1 :< ms2, $3) do Ast.TypeRecord do otoList ts
        }
    }

type_tuple_items :: { S (Bag.T (Ast.TypeExpr C)) }
    : type_tuple_items_commas type ','  { spn ($1, $2, $3) do snoc (unS $1) $2 }
    | type_tuple_items_commas type      { spn ($1, $2) do snoc (unS $1) $2 }

type_tuple_items_commas :: { S (Bag.T (Ast.TypeExpr C)) }
    : type_tuple_items_commas type ','  { spn ($1, $2, $3) do snoc (unS $1) $2 }
    | type ','                          { spn ($1, $2) do pure $1 }

type_array_items :: { MaySpBag (Ast.TypeExpr C) }
    : type_array_items_commas type      { maySpBagAppend $1 $2 $2 }
    | type_array_items_commas           { $1 }

type_array_items_commas :: { MaySpBag (Ast.TypeExpr C) }
    : type_array_items_commas type ','  { maySpBagAppend $1 ($2, $3) $2 }
    | {- empty -}                       { maySpBagEmpty }

type_simplrecord_items :: { MaySpBag (Ast.Name, Ast.TypeExpr C) }
    : type_simplrecord_items_commas type_simplrecord_item
    { maySpBagAppend $1 $2 do unS $2 }
    | type_simplrecord_items_commas
    { $1 }

type_simplrecord_items_commas :: { MaySpBag (Ast.Name, Ast.TypeExpr C) }
    : type_simplrecord_items_commas type_simplrecord_item ','
    { maySpBagAppend $1 ($2, $3) do unS $2 }
    | {- empty -}
    { maySpBagEmpty }

type_simplrecord_item :: { S (Ast.Name, Ast.TypeExpr C) }
    : var ':' type      { spn ($1, $2, $3) (unS $1, $3) }


sig_item :: { Ast.Decl C }
    : typesig_decl      { $1 }
    | valsig_decl       { $1 }


expr :: { Ast.Expr C }
    : expr_unit ':' type        { spAnn ($1, $2, $3) do Ast.ExprSig $1 $3 }
    | expr_unit %shift          { $1 }

expr_unit :: { Ast.Expr C }
    : expr_infix %shift         { $1 }

expr_infix :: { Ast.Expr C }
    : expr_infix expr_op expr_apps  { spAnn ($1, $2, $3) do Ast.ExprInfix $1 $2 $3 }
    | expr_apps                     { $1 }

expr_op :: { Ast.Expr C }
    : consym                        { spAnn $1 do Ast.ExprCon do unS $1 }
    | var_sym_ext                   { spAnn $1 do Ast.ExprVar do unS $1 }
    | '`' expr_qualified_op '`'     { spAnn ($1, $2, $3) do Ast.ExprAnn $2 }

expr_qualified_op :: { Ast.Expr C }
    : con_sym_ext       { spAnn $1 do Ast.ExprCon do unS $1 }
    | var_sym_ext       { spAnn $1 do Ast.ExprVar do unS $1 }
    | expr_block        { $1 }

expr_apps :: { Ast.Expr C }
    : expr_apps_list %shift
    {
        case $1 of { (e, b) -> case otoList b of
            [] ->
                e
            xs0@(x:xs) ->
                spAnn (e, x :| xs) do Ast.ExprApp e xs0
        }
    }

expr_apps_list :: { (Ast.Expr C, Bag.T (Ast.AppExpr C)) }
    : expr_apps_list expr_app   { case $1 of (e, xs) -> (e, snoc xs $2) }
    | expr_qualified            { ($1, mempty) }

expr_app :: { Ast.AppExpr C }
    : '@' type_qualified        { spAnn ($1, $2) do Ast.UnivAppExpr $2 }
    | expr_qualified            { spAnn $1 do Ast.AppExpr $1 }

expr_qualified :: { Ast.Expr C }
    : expr_block                { $1 }

expr_block :: { Ast.Expr C }
    : '\\' '#case' case_alt_body            { undefined }
    | '\\' lambda_body                      { undefined } -- conflict with expr
    | '#let' let_body                       { undefined } -- conflict with expr
    | '#letrec' let_body                    { undefined } -- conflict with expr
    | '#case' case_body                     { undefined }
    | '#do' do_body                         { undefined }
    | '#@' layout_block_body                { spAnn ($1, $2) do Ast.ExprAnn do unS $2 }
    | expr_atomic                           { $1 }

expr_atomic :: { Ast.Expr C }
    : '(' expr ')'                  { spAnn ($1, $2, $3) do Ast.ExprAnn $2 }
    | con                           { spAnn $1 do Ast.ExprCon do unS $1 }
    | var                           { spAnn $1 do Ast.ExprVar do unS $1 }
    | expr_literal                  { $1 }

expr_literal :: { Ast.Expr C }
    : literal                           { spAnn $1 do Ast.ExprLit $1 }
    | expr_interp_string                { $1 }
    | '(' expr_tuple_items ')'
    { spAnn ($1, $2, $3) do Ast.ExprTuple do otoList do unS $2 }
    | '[' expr_array_items ']'
    {
        case $2 of { (ms2, es) ->
            spAnn ($1 :< ms2, $3) do Ast.ExprArray do otoList es
        }
    }
    | '{' expr_simplrecord_items '}'
    {
        case $2 of { (ms2, es) ->
            spAnn ($1 :< ms2, $3) do Ast.ExprRecord do otoList es
        }
    }

expr_interp_string :: { Ast.Expr C }
    : interp_string_without_interp
    { spAnn $1 do Ast.ExprInterpString [$1] }
    | interp_string_start interp_string_expr expr_interp_string_conts interp_string_end
    {
        case otoList do cons $2 do snoc $3 $4 of
            xs -> spAnn ($1 :| xs) do Ast.ExprInterpString do $1:xs
    }

expr_interp_string_conts :: { Bag.T (Ast.InterpStringPart C) }
    : expr_interp_string_conts interp_string_cont interp_string_expr
    { snoc (snoc $1 $2) $3 }
    | {- empty -}   { mempty }

interp_string_without_interp :: { Ast.InterpStringPart C }
    : INTERP_STRING_WITHOUT_INTERP
    {
        case unS $1 of
            Token.LitInterpStringWithoutInterp txt ->
                spAnn $1 do Ast.InterpStringLit txt
            _ ->
                error "unreachable"
    }

interp_string_start :: { Ast.InterpStringPart C }
    : INTERP_STRING_START
    {
        case unS $1 of
            Token.LitInterpStringStart txt ->
                spAnn $1 do Ast.InterpStringLit txt
            _ ->
                error "unreachable"
    }

interp_string_cont :: { Ast.InterpStringPart C }
    : INTERP_STRING_CONTINUE
    {
        case unS $1 of
            Token.LitInterpStringContinue txt ->
                spAnn $1 do Ast.InterpStringLit txt
            _ ->
                error "unreachable"
    }

interp_string_end :: { Ast.InterpStringPart C }
    : INTERP_STRING_END
    {
        case unS $1 of
            Token.LitInterpStringEnd txt ->
                spAnn $1 do Ast.InterpStringLit txt
            _ ->
                error "unreachable"
    }

interp_string_expr :: { Ast.InterpStringPart C }
    : expr      { spAnn $1 do Ast.InterpStringExpr $1 }

expr_tuple_items :: { S (Bag.T (Ast.Expr C)) }
    : expr_tuple_items_commas expr ','   { spn ($1, $2, $3) do snoc (unS $1) $2 }
    | expr_tuple_items_commas expr       { spn ($1, $2) do snoc (unS $1) $2 }

expr_tuple_items_commas :: { S (Bag.T (Ast.Expr C)) }
    : expr_tuple_items_commas expr ','  { spn ($1, $2, $3) do snoc (unS $1) $2 }
    | expr ','                          { spn ($1, $2) do pure $1 }

expr_array_items :: { MaySpBag (Ast.Expr C) }
    : expr_array_items_commas expr      { maySpBagAppend $1 $2 $2 }
    | expr_array_items_commas           { $1 }

expr_array_items_commas :: { MaySpBag (Ast.Expr C) }
    : expr_array_items_commas expr ','  { maySpBagAppend $1 ($2, $3) $2 }
    | {- empty -}                       { maySpBagEmpty }

expr_simplrecord_items :: { MaySpBag (Ast.Name, Ast.Expr C) }
    : expr_simplrecord_items_semis expr_simplrecord_item
    { maySpBagAppend $1 $2 do unS $2 }
    | expr_simplrecord_items_semis
    { $1 }

expr_simplrecord_items_semis :: { MaySpBag (Ast.Name, Ast.Expr C) }
    : expr_simplrecord_items_semis expr_simplrecord_item ','
    { maySpBagAppend $1 ($2, $3) do unS $2 }
    | {- empty -}
    { maySpBagEmpty }

expr_simplrecord_item :: { S (Ast.Name, Ast.Expr C) }
    : var '=' expr      { spn ($1, $2, $3) do (unS $1, $3) }


pat :: { Ast.Pat C }
    : pat_unit ':' type     { spAnn ($1, $2, $3) do Ast.PatSig $1 $3 }
    | pat_unit              { $1 }

pat_unit :: { Ast.Pat C }
    : pat_unit_list
    {
        let ps = otoList do unS $1
        in spAnn $1 do Ast.PatOr ps
    }

pat_unit_list :: { S (Bag.T (Ast.Pat C)) }
    : pat_unit_list '|' pat_infix %shift
    { spn ($1, $2, $3) do snoc (unS $1) $3 }
    | pat_infix %shift
    { spn $1 do pure $1 }

pat_infix :: { Ast.Pat C }
    : pat_infix conop_qualified pat_univ_apps
    { spAnn ($1, $2, $3) do Ast.PatInfix $1 (unS $2) $3 }
    | pat_apps
    { $1 }

pat_univ_apps :: { Ast.Pat C }
    : pat_apps pat_univ_apps_args
    {
        case $2 of { (ms2, ts) ->
            spAnn ($1 :< ms2) do Ast.PatUnivApp $1 do otoList ts
        }
    }

pat_univ_apps_args :: { MaySpBag (Ast.TypeExpr C) }
    : pat_univ_apps_args '@' type_qualified
    { maySpBagAppend $1 ($2, $3) $3 }
    | {- empty -}
    { maySpBagEmpty }

pat_apps :: { Ast.Pat C }
    : con_qualified pat_apps_args %shift
    {
        case $2 of { (ms2, ps) ->
            spAnn ($1 :< ms2) do Ast.PatApp (unS $1) do otoList ps
        }
    }

pat_apps_args :: { MaySpBag (Ast.AppPat C) }
    : pat_apps_args pat_app             { maySpBagAppend $1 $2 $2 }
    | {- empty -}                       { maySpBagEmpty }

pat_app :: { Ast.AppPat C }
    : '@' type_qualified        { spAnn ($1, $2) do Ast.UnivAppPat $2 }
    | pat_qualified             { spAnn $1 do Ast.AppPat $1 }

pat_qualified :: { Ast.Pat C }
    : pat_atomic     { $1 }

pat_atomic :: { Ast.Pat C }
    : '(' pat ')'           { spAnn ($1, $2, $3) do Ast.PatAnn $2 }
    | con                   { spAnn $1 do Ast.PatCon do unS $1 }
    | var %shift            { spAnn $1 do Ast.PatVar do unS $1 }
    | pat_literal           { $1 }

pat_literal :: { Ast.Pat C }
    : literal                           { spAnn $1 do Ast.PatLit $1 }
    | '(' pat_tuple_items ')'           { undefined }
    | '[' pat_array_items ']'           { undefined }
    | '{' pat_simplrecord_items '}'     { undefined }

pat_tuple_items :: { () }
    : pat_tuple_items_commas pat ','    { () }
    | pat_tuple_items_commas pat        { () }

pat_tuple_items_commas :: { () }
    : pat_tuple_items_commas pat ','    { () }
    | pat ','                           { () }

pat_array_items :: { () }
    : pat_array_items_commas pat    { () }
    | pat_array_items_commas        { () }

pat_array_items_commas :: { () }
    : pat_array_items_commas pat ','    { () }
    | {- empty -}                       { () }

pat_simplrecord_items :: { () }
    : pat_simplrecord_items_semis pat_simplrecord_item      { () }
    | pat_simplrecord_items_semis                           { () }

pat_simplrecord_items_semis :: { () }
    : pat_simplrecord_items_semis pat_simplrecord_item ','      { () }
    | {- empty -}                                               { () }

pat_simplrecord_item :: { () }
    : var '=' pat       { () }


lambda_body :: { () }
    : lambda_pat_args guarded_alt   { () }

lambda_pat_args :: { () }
    : lambda_pat_args pat_atomic    { () }
    | {- empty -}                   { () }


let_body :: { () }
    : let_binds '#in' expr           { () }

let_binds :: { () }
    : lopen let_bind_items lclose   { () }

let_bind_items :: { () }
    : let_bind_items_semis let_bind_item    { () }
    | let_bind_items_semis                  { () }

let_bind_items_semis :: { () }
    : let_bind_items_semis let_bind_item lsemis     { () }
    | {- empty -}                                   { () }

let_bind_item :: { () }
    : sig_item                  { () }
    | type_decl                 { () }
    | data_decl                 { () }
    | val_bind                  { () } -- conflict with valsig_decl


case_body :: { () }
    : case_exprs '#of' case_alt_body     { () }

case_exprs :: { () }
    : case_exprs_commas expr    { () }
    | case_exprs_commas         { () }

case_exprs_commas :: { () }
    : case_exprs_commas expr ','    { () }
    | {- empty -}                   { () }

case_alt_body :: { () }
    : lopen case_alt_items lclose       { () }

case_alt_items :: { () }
    : case_alt_items_semis case_alt_item    { () }
    | case_alt_items_semis                  { () }

case_alt_items_semis :: { () }
    : case_alt_items_semis case_alt_item lsemis     { () }
    | {- empty -}                                   { () }

case_alt_item :: { () }
    : case_pats guarded_alt     { () }

case_pats :: { () }
    : case_pats_commas pat_unit     { () }
    | case_pats_commas              { () }

case_pats_commas :: { () }
    : case_pats_commas pat ','      { () }
    | {- empty -}                   { () }

guarded_alt :: { () }
    : '->' expr                     { () }
    | '#when' guarded_alt_body      { () }

guarded_alt_body :: { () }
    : lopen guarded_alt_items lclose    { () }

guarded_alt_items :: { () }
    : guarded_alt_items_semis guarded_alt_item  { () }
    | guarded_alt_items_semis                   { () }

guarded_alt_items_semis :: { () }
    : guarded_alt_items_semis guarded_alt_item lsemis   { () }
    | {- empty -}                                       { () }

guarded_alt_item :: { () }
    : guard_qual '->' expr      { () }

guard_qual :: { () }
    : expr_unit         { () }


do_body :: { () }
    : lopen do_stmt_items lclose        { () }

do_stmt_items :: { S ([Ast.DoStmt C], Ast.Expr C) }
    : do_stmt_items_semis do_yield_item lsemis
    {
        case $1 of { (ms1, ss) ->
            spn (ms1 :> $2 :< $3) do (otoList ss, unS $2)
        }
    }
    | do_stmt_items_semis do_yield_item
    {
        case $1 of { (ms1, ss) ->
            spn (ms1 :> $2) do (otoList ss, unS $2)
        }
    }

do_stmt_items_semis :: { MaySpBag (Ast.DoStmt C) }
    : do_stmt_items_semis do_stmt_item lsemis
    { maySpBagAppend $1 ($2 :< $3) $2 }
    | {- empty -}
    { maySpBagEmpty }

do_stmt_item :: { Ast.DoStmt C }
    : pat '<-' expr             { undefined }
    | pat '=' expr              { undefined }
    | '#letrec' let_binds       { undefined }

do_yield_item :: { S (Ast.Expr C) }
    : '#yield' expr     { spn ($1, $2) $2 }


layout_block_body :: { S (Ast.Expr C) }
    : lopen layout_block_item lclose
    { spn ($1 :> $2 :< $3) do unS $2 }

layout_block_item :: { S (Ast.Expr C) }
    : expr lsemis   { spn ($1 :< $2) $1 }
    | expr          { spn $1 $1 }


bind_var :: { Ast.BindVar C }
    : '@' simple_bind_var
    { spAnn ($1, $2) case unS $2 of (name, mayTy) -> Ast.UnivBindVar name mayTy }
    | simple_bind_var
    { spAnn $1 case unS $1 of (name, mayTy) -> Ast.BindVar name mayTy }

simple_bind_var :: { S (Ast.Name, Maybe (Ast.TypeExpr C)) }
    : var_id_ext
    { spn $1 (unS $1, Nothing) }
    | '(' var_id_ext ':' type ')'
    { spn ($1, $2, $3, $4, $5)  (unS $2, Just $4) }

con_qualified :: { S Ast.Name }
    : con       { $1 }

conop_qualified :: { S Ast.Name }
    : conop     { $1 }

con :: { S Ast.Name }
    : con_id_ext            { $1 }
    | '(' con_sym_ext ')'   { spn ($1, $2, $3) do unS $2 }

conop :: { S Ast.Name }
    : con_sym_ext           { $1 }
    | '`' con_sym_ext '`'   { spn ($1, $2, $3) do unS $2 }
    | '`' con_id_ext '`'    { spn ($1, $2, $3) do unS $2 }

var :: { S Ast.Name }
    : var_id_ext            { $1 }
    | '(' var_sym_ext ')'   { spn ($1, $2, $3) do unS $2 }

op :: { S Ast.Name }
    : var_sym_ext               { $1 }
    | '`' var_sym_ext '`'       { spn ($1, $2, $3) do unS $2 }
    | '`' var_id_ext '`'        { spn ($1, $2, $3) do unS $2 }

con_id_ext :: { S Ast.Name }
    : conid             { $1 }
    | '(' ')'           { spn $1 Ast.primNameUnit }

con_sym_ext :: { S Ast.Name }
    : consym            { $1 }
    | '->'              { spn $1 Ast.primNameArrow }

var_id_ext :: { S Ast.Name }
    : varid     { $1 }
    | '_'       { spn $1 Ast.primNameWildcard }

var_sym_ext :: { S Ast.Name }
    : varsym    { $1 }


declcon :: { S Ast.Name }
    : con
    { if
        | isExtName do unS $1 -> undefined
        | otherwise -> $1
    }

declconop :: { S Ast.Name }
    : conop
    { if
        | isExtName do unS $1 -> undefined
        | otherwise -> $1
    }

declvar :: { S Ast.Name }
    : var
    { if
        | isExtName do unS $1 -> undefined
        | otherwise -> $1
    }

declop :: { S Ast.Name }
    : op
    { if
        | isExtName do unS $1 -> undefined
        | otherwise -> $1
    }


lopen :: { Maybe Span }
    : lopen VSEMI   { $1 }
    | '{'           { Just do sp $1 }
    | '{{'          { Just do sp $1 }
    | VOBRACE       { Nothing }

lclose :: { Maybe Span }
    : '}'           { Just do sp $1 }
    | '}}'          { Just do sp $1 }
    | VCBRACE       { Nothing }
    | error         { Nothing }

lsemis :: { Maybe Span }
    : lsemis semi   { $1 <:> $2 }
    | semi          { $1 }

semi :: { Maybe Span }
    : ';'           { Just do sp $1 }
    | VSEMI         { Nothing }


literal :: { Ast.Lit C }
    : BYTECHAR
    {
        spAnn $1 case unS $1 of
            Token.LitByteChar w -> Ast.LitByteChar w
            _                   -> error "unreachable"
    }
    | BYTESTRING
    {
        spAnn $1 case unS $1 of
            Token.LitByteString s   -> Ast.LitByteString s
            _                       -> error "unreachable"
    }
    | CHAR
    {
        spAnn $1 case unS $1 of
            Token.LitChar c -> Ast.LitChar c
            _               -> error "unreachable"
    }
    | STRING
    {
        spAnn $1 case unS $1 of
            Token.LitString s   -> Ast.LitString s
            _                   -> error "unreachable"
    }
    | INTEGER
    {
        spAnn $1 case unS $1 of
            Token.LitInteger i  -> Ast.LitInteger i
            _                   -> error "unreachable"
    }
    | RATIONAL
    {
        spAnn $1 case unS $1 of
            Token.LitRational r -> Ast.LitRational r
            _                   -> error "unreachable"
    }

bind_vars :: { Bag.T (Ast.BindVar C) }
    : bind_vars bind_var    { snoc $1 $2 }
    | {- empty -}           { mempty }


conid :: { S Ast.Name }
    : CONID
    {
        $1 <&> \case
            Token.IdConId n     -> n
            _                   -> error "unreachable"
    }

consym :: { S Ast.Name }
    : CONSYM
    {
        $1 <&> \case
            Token.IdConSym n    -> n
            _                   -> error "unreachable"
    }

varid :: { S Ast.Name }
    : VARID
    {
        $1 <&> \case
            Token.IdVarId n     -> n
            _                   -> error "unreachable"
    }

varsym :: { S Ast.Name }
    : VARSYM
    {
        $1 <&> \case
            Token.IdVarSym n    -> n
            _                   -> error "unreachable"
    }
{
type Span = Spanned.Span
type S = Spanned.T

pattern S :: a -> S a
pattern S x <- Spanned.Spanned
    {
        getSpan = _,
        unSpanned = x
    }

unS :: S a -> a
unS sx = Spanned.unSpanned sx

type MaySpBag a = (Maybe Span, Bag.T a)

maySpBagAppend :: SpannedBuilder s => MaySpBag a -> s -> a -> MaySpBag a
maySpBagAppend (ms1, m) s2 x = (Just do sp (ms1 :> s2), snoc m x)

maySpBagEmpty :: MaySpBag a
maySpBagEmpty = (Nothing, mempty)


type C = AstParsed


(<:>) :: Maybe Span -> Maybe Span -> Maybe Span
Nothing  <:> Nothing  = Nothing
msp1     <:> Nothing  = msp1
Nothing  <:> msp2     = msp2
Just sp1 <:> Just sp2 = Just do sp1 <> sp2

mkName :: StringLit -> Ast.Name
mkName s = Ast.mkName do text s

isExtName :: Ast.Name -> Bool
isExtName n = any (== n)
    [
        Ast.primNameUnit,
        Ast.primNameArrow,
        Ast.primNameWildcard
    ]


lexer = undefined

happyError = undefined
}
