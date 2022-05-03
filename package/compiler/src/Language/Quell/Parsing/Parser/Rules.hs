{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE TemplateHaskell     #-}

module Language.Quell.Parsing.Parser.Rules where

import           Language.Quell.Prelude

import qualified Data.List                               as List
import qualified Language.Haskell.TH                     as TH
import           Language.Parser.Ptera.TH                (eps, pattern (:*),
                                                          pattern HNil,
                                                          ruleExpr, varA,
                                                          (<::>), (<:>), (<^>))
import qualified Language.Parser.Ptera.TH                as Ptera
import qualified Language.Quell.Data.Bag                 as Bag
import qualified Language.Quell.Parsing.Parser.AstParsed as AstParsed
import qualified Language.Quell.Parsing.Parser.Layout    as Layout
import qualified Language.Quell.Parsing.Spanned          as Spanned
import qualified Language.Quell.Type.Ast                 as Ast
import qualified Language.Quell.Type.Token               as Token


type Token = Layout.TokenWithL

pattern LexToken :: Token.LexToken -> Layout.TokenWithL
pattern LexToken t <- Layout.Token (Spanned.Spanned { unSpanned = t })

$(Ptera.genGrammarToken (TH.mkName "Tokens") [t|Token|]
    [ ("EOS",           [p|LexToken Token.EndOfSource|])

    , ("#as",           [p|LexToken Token.KwAs|])
    , ("#case",         [p|LexToken Token.KwCase|])
    , ("#data",         [p|LexToken Token.KwData|])
    , ("#default",      [p|LexToken Token.KwDefault|])
    , ("#derive",       [p|LexToken Token.KwDerive|])
    , ("#do",           [p|LexToken Token.KwDo|])
    , ("#export",       [p|LexToken Token.KwExport|])
    , ("#family",       [p|LexToken Token.KwFamily|])
    , ("#foreign",      [p|LexToken Token.KwForeign|])
    , ("#impl",         [p|LexToken Token.KwImpl|])
    , ("#in",           [p|LexToken Token.KwIn|])
    , ("#infix",        [p|LexToken Token.KwInfix|])
    , ("#let",          [p|LexToken Token.KwLet|])
    , ("#letrec",       [p|LexToken Token.KwLetrec|])
    , ("#match",        [p|LexToken Token.KwMatch|])
    , ("#module",       [p|LexToken Token.KwModule|])
    , ("#newtype",      [p|LexToken Token.KwNewtype|])
    , ("#pattern",      [p|LexToken Token.KwPattern|])
    , ("#rec",          [p|LexToken Token.KwRec|])
    , ("#record",       [p|LexToken Token.KwRecord|])
    , ("#role",         [p|LexToken Token.KwRole|])
    , ("#self",         [p|LexToken Token.KwSelf|])
    , ("#sig",          [p|LexToken Token.KwSignature|])
    , ("#static",       [p|LexToken Token.KwStatic|])
    , ("#trait",        [p|LexToken Token.KwTrait|])
    , ("#type",         [p|LexToken Token.KwType|])
    , ("#use",          [p|LexToken Token.KwUse|])
    , ("#with",         [p|LexToken Token.KwWith|])
    , ("#when",         [p|LexToken Token.KwWhen|])
    , ("#where",        [p|LexToken Token.KwWhere|])
    , ("#yield",        [p|LexToken Token.KwYield|])

    , ("#Default",      [p|LexToken Token.LKwDefault|])
    , ("#Self",         [p|LexToken Token.LKwSelf|])

    , ("->",            [p|LexToken Token.SymArrow|])
    , ("@",             [p|LexToken Token.SymAt|])
    , ("!",             [p|LexToken Token.SymBang|])
    , (":",             [p|LexToken Token.SymColon|])
    , ("=>",            [p|LexToken Token.SymDArrow|])
    , ("<=",            [p|LexToken Token.SymDLeftArrow|])
    , ("=",             [p|LexToken Token.SymEqual|])
    , ("^",             [p|LexToken Token.SymForall|])
    , ("\\",            [p|LexToken Token.SymLambda|])
    , ("<-",            [p|LexToken Token.SymLeftArrow|])
    , ("|",             [p|LexToken Token.SymOr|])
    , ("~",             [p|LexToken Token.SymTilde|])
    , ("_",             [p|LexToken Token.SymUnderscore|])
    , ("?",             [p|LexToken Token.SymUnknown|])

    , ("`",             [p|LexToken Token.SpBackquote|])
    , ("##",            [p|LexToken Token.SpBlock|])
    , ("[",             [p|LexToken Token.SpBrackOpen|])
    , ("]",             [p|LexToken Token.SpBrackClose|])
    , (",",             [p|LexToken Token.SpComma|])
    , ("{",             [p|LexToken Token.SpBraceOpen|])
    , ("}",             [p|LexToken Token.SpBraceClose|])
    , ("{{",            [p|LexToken Token.SpDBraceOpen|])
    , ("}}",            [p|LexToken Token.SpDBraceClose|])
    , (".",             [p|LexToken Token.SpDot|])
    , ("..",            [p|LexToken Token.SpDots|])
    , ("(",             [p|LexToken Token.SpParenOpen|])
    , (")",             [p|LexToken Token.SpParenClose|])
    , (";",             [p|LexToken Token.SpSemi|])
    , ("#>",            [p|LexToken Token.SpThen|])
    , ("#@",            [p|LexToken Token.SpTypeBlock|])

    , ("con_id",        [p|LexToken Token.IdConId{}|])
    , ("con_sym",       [p|LexToken Token.IdConSym{}|])
    , ("var_id",        [p|LexToken Token.IdVarId{}|])
    , ("var_sym",       [p|LexToken Token.IdVarSym{}|])

    , ("bytechar",      [p|LexToken Token.LitByteChar{}|])
    , ("bytestring",    [p|LexToken Token.LitByteString{}|])
    , ("integer",       [p|LexToken Token.LitInteger{}|])
    , ("rational",      [p|LexToken Token.LitRational{}|])
    , ("char",          [p|LexToken Token.LitChar{}|])
    , ("string",        [p|LexToken Token.LitString{}|])

    , ("interp_string_without_interp",
                        [p|LexToken Token.LitInterpStringWithoutInterp{}|])
    , ("interp_string_start",
                        [p|LexToken Token.LitInterpStringStart{}|])
    , ("interp_string_cont",
                        [p|LexToken Token.LitInterpStringContinue{}|])
    , ("interp_string_end",
                        [p|LexToken Token.LitInterpStringEnd{}|])

    , ("{n}",           [p|Layout.ExpectNewImplicitLayout{}|])
    , ("<n>",           [p|Layout.Newline{}|])
    ])

data GrammarContext = GrammarContext
    { layoutStack :: [LayoutItem]
    }
    deriving (Eq, Show)

data LayoutItem
    = NoLayout
    | ImplicitLayout Layout.Position
    | ExplicitScopedLayout Layout.Position
    deriving (Eq, Show)

$(Ptera.genRules
    do TH.mkName "RuleDefs"
    do Ptera.GenRulesTypes
        { Ptera.genRulesCtxTy = [t|GrammarContext|]
        , Ptera.genRulesTokensTy = [t|Tokens|]
        , Ptera.genRulesTokenTy = [t|Token|]
        }
    [ (TH.mkName "rdProgramEos", "program EOS", [t|Ast.Program AstParsed.T|])
    , (TH.mkName "rdProgram", "program", [t|Ast.Program AstParsed.T|])

    , (TH.mkName "rdDeclBody", "decl_body", [t|([Ast.Decl AstParsed.T], Maybe Spanned.Span)|])
    , (TH.mkName "rdDeclItems", "decl_items", [t|([Ast.Decl AstParsed.T], Maybe Spanned.Span)|])
    , (TH.mkName "rdDeclItems0", "(decl_item lsemis)* decl_item?",
        [t|([Ast.Decl AstParsed.T], Maybe Spanned.Span)|])
    , (TH.mkName "rdDeclItem", "decl_item", [t|Ast.Decl AstParsed.T|])

    , (TH.mkName "rdTypeDecl", "type_decl", [t|Ast.Decl AstParsed.T|])

    , (TH.mkName "rdDataDecl", "data_decl", [t|Ast.Decl AstParsed.T|])

    , (TH.mkName "rdValDecl", "val_decl", [t|Ast.Decl AstParsed.T|])

    , (TH.mkName "rdSigItem", "sig_item", [t|Ast.Decl AstParsed.T|])

    , (TH.mkName "rdBindVar", "bind_var", [t|Ast.BindVar AstParsed.T|])
    , (TH.mkName "rdBindVars0", "bind_var*", [t|(Bag.T (Ast.BindVar AstParsed.T), Maybe Spanned.Span)|])
    , (TH.mkName "rdConQualified", "con_qualified", [t|(Ast.Name, Spanned.Span)|])

    , (TH.mkName "rdDeclCon", "declcon", [t|(Ast.Name, Spanned.Span)|])
    , (TH.mkName "rdDeclVar", "declvar", [t|(Ast.Name, Spanned.Span)|])

    , (TH.mkName "rdLsemis", "lsemis", [t|Maybe Spanned.Span|])
    , (TH.mkName "rdMayLsemis", "lsemis?", [t|Maybe Spanned.Span|])
    , (TH.mkName "rdLsemi", "lsemi", [t|Maybe Spanned.Span|])

    , (TH.mkName "rdTokOpenParen", "tok_open_paren_without_skip", [t|Spanned.Span|])
    , (TH.mkName "rdTokOpenBrack", "tok_open_brack_without_skip", [t|Spanned.Span|])
    , (TH.mkName "rdTokOpenBrace", "tok_open_brace_without_skip", [t|Spanned.Span|])
    , (TH.mkName "rdTokOpenDBrace", "tok_open_dbrace_without_skip", [t|Spanned.Span|])
    , (TH.mkName "rdTokCloseParen", "tok_close_paren_without_skip", [t|Spanned.Span|])
    , (TH.mkName "rdTokCloseBrack", "tok_close_brack_without_skip", [t|Spanned.Span|])
    , (TH.mkName "rdTokCloseBrace", "tok_close_brace_without_skip", [t|Spanned.Span|])
    , (TH.mkName "rdTokCloseDBrace", "tok_close_dbrace_without_skip", [t|Spanned.Span|])
    , (TH.mkName "rdTokInterpStringStart", "tok_interp_string_start_without_skip", [t|Ast.InterpStringPart AstParsed.T|])
    , (TH.mkName "rdTokInterpStringCont", "tok_interp_string_cont_without_skip", [t|Ast.InterpStringPart AstParsed.T|])
    , (TH.mkName "rdTokInterpStringEnd", "tok_interp_string_end_without_skip", [t|Ast.InterpStringPart AstParsed.T|])

    , (TH.mkName "rdSkip", "skip", [t|()|])
    ])

$(Ptera.genParsePoints
    do TH.mkName "ParsePoints"
    do TH.mkName "RuleDefs"
    [ "program EOS"
    ])

type RuleExpr = Ptera.RuleExprM GrammarContext RuleDefs Tokens Token
type Alt = Ptera.AltM GrammarContext RuleDefs Tokens Token
type TypedExpr = Ptera.TypedExpr RuleDefs Tokens Token
type SemAct = Ptera.SemActM GrammarContext
type ActionTask = Ptera.ActionTask GrammarContext


grammar :: Ptera.GrammarM GrammarContext RuleDefs Tokens Token ParsePoints
grammar = Ptera.fixGrammar do
    RuleDefs
        {}


rProgramEos :: RuleExpr (Ast.Program AstParsed.T)
rProgramEos = ruleExpr
    [ varA @"program" <^> tokA @"EOS"
        <:> \(program :* _ :* _ :* HNil) ->
            program
    ]

rProgram :: RuleExpr (Ast.Program AstParsed.T)
rProgram = ruleExpr
    [ varA @"decl_body"
        <:> \(declBody :* HNil) ->
            [||case $$(declBody) of
                (declItems, ms) -> Ast.Program declItems ms
            ||]
    ]


rDeclBody :: RuleExpr ([Ast.Decl AstParsed.T], Maybe Spanned.Span)
rDeclBody = ruleExpr
    [ varA @"{{" <^> varA @"decl_items" <^> varA @"}}"
        <:> \(expDbo :* declItems :* expDbc :* HNil) ->
            [||case $$(declItems) of { (declItems, ms) ->
                ( declItems
                , Just do AstParsed.sp ($$(expDbo), ms, $$(expDbc))
                )
            }||]
    , varA @"{" <^> varA @"decl_items" <^> varA @"}"
        <:> \(expBo :* declItems :* expBc :* HNil) ->
            [||case $$(declItems) of { (declItems, ms) ->
                ( declItems
                , Just do AstParsed.sp ($$(expBo), ms, $$(expBc))
                )
            }||]
    , varA @"imp_bo" <^> varA @"decl_items" <^> varA @"imp_bc"
        <:> \(impBo :* declItems :* impBc :* HNil) ->
            [||case $$(declItems) of { (declItems, ms) ->
                ( declItems
                , AstParsed.maySp [$$(impBo), ms, $$(impBc)]
                )
            }||]
    ]

rDeclItems :: RuleExpr ([Ast.Decl AstParsed.T], Maybe Spanned.Span)
rDeclItems = ruleExpr
    [ varA @"lsemis?" <^> varA @"(decl_item lsemis)* decl_item?"
        <:> \(mayLsemis :* declItems :* HNil) ->
            [||case $$(declItems) of { (declItems, ms) ->
                ( declItems
                , AstParsed.maySp [$$(mayLsemis), ms]
                )
            }||]
    ]

rDeclItems0 :: RuleExpr ([Ast.Decl AstParsed.T], Maybe Spanned.Span)
rDeclItems0 = ruleExpr
    [ varA @"decl_item" <^> varA @"lsemis" <^> varA @"(decl_item lsemis)* decl_item?"
        <:> \(declItem :* lsemis :* declItems :* HNil) ->
            [||case ($$(declItem), $$(lsemis), $$(declItems)) of
                (declItem, ms1, (declItems, ms2)) ->
                    ( declItem:declItems
                    , AstParsed.maySp (declItem, ms1, ms2)
                    )
            ||]
    , varA @"decl_item"
        <:> \(declItem :* HNil) ->
            [||([$$(declItem)], Just do AstParsed.sp $$(declItem))||]
    , eps
        <:> \HNil ->
            [||([], Nothing)||]
    ]

rDeclItem :: RuleExpr (Ast.Decl AstParsed.T)
rDeclItem = ruleExpr
    [ varA @"type_decl"
        <:> \(typeDecl :* HNil) ->
            typeDecl
    , varA @"data_decl"
        <:> \(dataDecl :* HNil) ->
            dataDecl
    , varA @"val_decl"
        <:> \(valDecl :* HNil) ->
            valDecl
    , varA @"sig_item"
        <:> \(sigItem :* HNil) ->
            sigItem
    ]


rTypeSigDecl :: RuleExpr (Ast.Decl AstParsed.T)
rTypeSigDecl = ruleExpr
    [ tokA @"#type" <^> varA @"declcon" <^> tokA @":" <^> varA @"type"
        <:> \(_ :* ktype :* declcon :* _ :* kcolon :* ty :* HNil) ->
            [||case $$(declcon) of { (declcon, spDeclCon) ->
                Ast.DeclTypeSig declcon $$(ty) do
                    AstParsed.sp ($$(ktype), spDeclCon, $$(kcolon), $$(ty))
            }||]
    ]

rValSigDecl :: RuleExpr (Ast.Decl AstParsed.T)
rValSigDecl = ruleExpr
    [ varA @"declvar" <^> tokA @":" <^> varA @"type"
        <:> \(declvar :* _ :* kcolon :* ty :* HNil) ->
            [||case $$(declvar) of { (declvar, spDeclVar) ->
                Ast.DeclValSig declvar $$(ty) do
                    AstParsed.sp (spDeclVar, $$(kcolon), $$(ty))
            }||]
    ]

rConSigDecl :: RuleExpr (Ast.Decl AstParsed.T)
rConSigDecl = ruleExpr
    [ varA @"declcon" <^> tokA @":" <^> varA @"type"
        <:> \(declcon :* _ :* kcolon :* ty :* HNil) ->
            [||case $$(declcon) of { (declcon, spDeclCon) ->
                Ast.DeclConSig declcon $$(ty) do
                    AstParsed.sp (spDeclCon, $$(kcolon), $$(ty))
            }||]
    ]


rTypeDecl :: RuleExpr (Ast.Decl AstParsed.T)
rTypeDecl = ruleExpr
    [ tokA @"#type" <^> varA @"decltype" <^> tokA @"=" <^> varA @"type" <^> tokA @"#where" <^> varA @"type_decl_where_body"
        <:> \(_ :* ktype :* decltype :* _ :* keq :* ty :* _ :* kwhere :* typeDeclWhereBody :* HNil) ->
            [||case $$(typeDeclWhereBody) of { (whereItems, ms) ->
                Ast.DeclType $$(decltype) $$(ty) whereItems do
                    AstParsed.sp
                        ( $$(ktype), $$(decltype), $$(keq), $$(ty)
                        , $$(kwhere) AstParsed.:<< ms
                        )
            }||]
    , tokA @"#type" <^> varA @"decltype" <^> tokA @"=" <^> varA @"type"
        <:> \(_ :* ktype :* decltype :* _ :* keq :* ty :* HNil) ->
            [||
                Ast.DeclType $$(decltype) $$(ty) [] do
                    AstParsed.sp ($$(ktype), $$(decltype), $$(keq), $$(ty))
            ||]
    ]

rTypeDeclWhereBody :: RuleExpr ([Ast.Decl AstParsed.T], Maybe Spanned.Span)
rTypeDeclWhereBody = ruleExpr
    [ varA @"{{" <^> varA @"type_decl_where_items" <^> varA @"}}"
        <:> \(expDbo :* whereItems :* expDbc :* HNil) ->
            [||case $$(whereItems) of { (whereItems, ms) ->
                ( whereItems
                , Just do AstParsed.sp ($$(expDbo), ms AstParsed.:>> $$(expDbc))
                )
            }||]
    , varA @"{" <^> varA @"type_decl_where_items" <^> varA @"}"
        <:> \(expBo :* whereItems :* expBc :* HNil) ->
            [||case $$(whereItems) of { (whereItems, ms) ->
                ( whereItems
                , Just do AstParsed.sp ($$(expBo), ms AstParsed.:>> $$(expBc))
                )
            }||]
    , varA @"imp_bo" <^> varA @"type_decl_where_items" <^> varA @"imp_bc"
        <:> \(impBo :* whereItems :* impBc :* HNil) ->
            [||case $$(whereItems) of { (whereItems, ms) ->
                ( whereItems
                , AstParsed.maySp ($$(impBo), ms, $$(impBc))
                )
            }||]
    ]

rTypeDeclWhereItems :: RuleExpr ([Ast.Decl AstParsed.T], Maybe Spanned.Span)
rTypeDeclWhereItems = ruleExpr
    [ varA @"lsemis?" <^> varA @"(type_decl_where_item lsemis)* type_decl_where_item?"
        <:> \(mayLsemis :* whereItems :* HNil) ->
            [||case $$(whereItems) of { (whereItems, ms) ->
                ( otoList whereItems
                , AstParsed.maySp ($$(mayLsemis), ms)
                )
            }||]
    ]

rTypeDeclWhereItems0 :: RuleExpr (Bag.T (Ast.Decl AstParsed.T), Maybe Spanned.Span)
rTypeDeclWhereItems0 = ruleExpr
    [ varA @"type_decl_where_item" <^> varA @"lsemis" <^> varA @"(type_decl_where_item lsemis)* type_decl_where_item?"
        <:> \(whereItem :* lsemis :* whereItems :* HNil) ->
            [||case $$(whereItems) of { (whereItems, ms) ->
                ( cons $$(whereItem) whereItems
                , AstParsed.maySp (Just $$(whereItem), $$(lsemis), ms)
                )
            }||]
    , varA @"type_decl_where_item"
        <:> \(whereItem :* HNil) ->
            [||
                ( pure $$(whereItem)
                , Just do AstParsed.sp $$(whereItem)
                )
            ||]
    , eps
        <:> \HNil ->
            [||
                ( mempty
                , Nothing
                )
            ||]
    ]

rTypeDeclWhereItem :: RuleExpr (Ast.Decl AstParsed.T)
rTypeDeclWhereItem = ruleExpr
    [ varA @"type_decl"
        <:> \(typeDecl :* HNil) ->
            typeDecl
    , varA @"typesig_decl"
        <:> \(typeSigDecl :* HNil) ->
            typeSigDecl
    ]


rDataDecl :: RuleExpr (Ast.Decl AstParsed.T)
rDataDecl = ruleExpr
    [ tokA @"#data" <^> varA @"decltype" <^> tokA @"=" <^> varA @"alg_data_type" <^> tokA @"#where" <^> varA @"type_decl_where_body"
        <:> \(_ :* kdata :* decltype :* _ :* keq :* algDataType :* _ :* kwhere :* typeDeclWhereBody :* HNil) ->
            [||case $$(algDataType) of { (implTypes, msImplTypes) ->
                case $$(typeDeclWhereBody) of { (whereItems, msWhereItems) ->
                    Ast.DeclAlgDataType $$(decltype) implTypes whereItems do
                        AstParsed.sp
                            ( $$(kdata), $$(decltype)
                            , $$(keq) AstParsed.:<< msImplTypes
                            , $$(kwhere) AstParsed.:<< msWhereItems
                            )
                }
            }||]
    , tokA @"#data" <^> varA @"decltype" <^> tokA @"=" <^> varA @"alg_data_type"
        <:> \(_ :* kdata :* decltype :* _ :* keq :* algDataType :* HNil) ->
            [||case $$(algDataType) of { (implTypes, msImplTypes) ->
                Ast.DeclAlgDataType $$(decltype) implTypes [] do
                    AstParsed.sp
                        ( $$(kdata), $$(decltype)
                        , $$(keq) AstParsed.:<< msImplTypes
                        )
            }||]
    , tokA @"#data" <^> varA @"decltype" <^> tokA @"#where" <^> varA @"type_decl_where_body"
        <:> \(_ :* kdata :* decltype :* _ :* kwhere :* typeDeclWhereBody :* HNil) ->
            [||case $$(typeDeclWhereBody) of { (whereItems, msWhereItems) ->
                Ast.DeclAlgDataType $$(decltype) [] whereItems do
                    AstParsed.sp
                        ( $$(kdata), $$(decltype)
                        , $$(kwhere) AstParsed.:<< msWhereItems
                        )
            }||]
    , tokA @"#data" <^> varA @"decltype"
        <:> \(_ :* kdata :* decltype :* HNil) ->
            [||
                Ast.DeclAlgDataType $$(decltype) [] [] do
                    AstParsed.sp
                        ( $$(kdata), $$(decltype)
                        )
            ||]
    , tokA @"#data" <^> varA @"declcon" <^> varA @"(':' type)?" <^> tokA @"#where" <^> varA @"data_decl_body"
        <:> \(_ :* kdata :* declcon :* mayTy :* _ :* kwhere :* dataDeclBody :* HNil) ->
            [||case $$(declcon) of { (declcon, spDeclcon) ->
                case $$(mayTy) of { (mayTy, msMayTy) ->
                    case $$(dataDeclBody) of { (dataDeclItems, msDataDeclItems) ->
                        Ast.DeclDataType declcon mayTy dataDeclItems do
                            AstParsed.sp
                                ( $$(kdata), spDeclcon AstParsed.:<< msMayTy
                                , $$(kwhere) AstParsed.:<< msDataDeclItems
                                )
                    }
                }
            }||]
    , tokA @"#data" <^> varA @"declcon" <^> varA @"(':' type)?"
        <:> \(_ :* kdata :* declcon :* mayTy :* HNil) ->
            [||case $$(declcon) of { (declcon, spDeclcon) ->
                case $$(mayTy) of { (mayTy, msMayTy) ->
                    Ast.DeclDataType declcon mayTy [] do
                        AstParsed.sp
                            ( $$(kdata), spDeclcon AstParsed.:<< msMayTy
                            )
                }
            }||]
    , tokA @"#newtype" <^> varA @"decltype" <^> tokA @"=" <^> varA @"type" <^> tokA @"#where" <^> varA @"type_decl_where_body"
        <:> \(_ :* knewtype :* decltype :* _ :* keq :* ty :* _ :* kwhere :* typeDeclWhereBody :* HNil) ->
            [||case $$(typeDeclWhereBody) of { (whereItems, msWhereItems) ->
                Ast.DeclNewType $$(decltype) $$(ty) whereItems do
                    AstParsed.sp
                        ( $$(knewtype), $$(decltype)
                        , $$(keq), $$(ty)
                        , $$(kwhere) AstParsed.:<< msWhereItems
                        )
            }||]
    , tokA @"#newtype" <^> varA @"decltype" <^> tokA @"=" <^> varA @"type"
        <:> \(_ :* knewtype :* decltype :* _ :* keq :* ty :* HNil) ->
            [||
                Ast.DeclNewType $$(decltype) $$(ty) [] do
                    AstParsed.sp
                        ( $$(knewtype), $$(decltype)
                        , $$(keq), $$(ty)
                        )
            ||]
    ]

rDataDeclBody :: RuleExpr ([Ast.Decl AstParsed.T], Maybe Spanned.Span)
rDataDeclBody = ruleExpr
    [ varA @"{{" <^> varA @"data_decl_items" <^> varA @"}}"
        <:> \(expDbo :* declItems :* expDbc :* HNil) ->
            [||case $$(declItems) of { (declItems, ms) ->
                ( declItems
                , Just do AstParsed.sp ($$(expDbo), ms AstParsed.:>> $$(expDbc))
                )
            }||]
    , varA @"{" <^> varA @"data_decl_items" <^> varA @"}"
        <:> \(expBo :* declItems :* expBc :* HNil) ->
            [||case $$(declItems) of { (declItems, ms) ->
                ( declItems
                , Just do AstParsed.sp ($$(expBo), ms AstParsed.:>> $$(expBc))
                )
            }||]
    , varA @"imp_bo" <^> varA @"data_decl_items" <^> varA @"imp_bc"
        <:> \(impBo :* declItems :* impBc :* HNil) ->
            [||case $$(declItems) of { (declItems, ms) ->
                ( declItems
                , AstParsed.maySp ($$(impBo), ms, $$(impBc))
                )
            }||]
    ]

rDataDeclItems :: RuleExpr ([Ast.Decl AstParsed.T], Maybe Spanned.Span)
rDataDeclItems = ruleExpr
    [ varA @"lsemis?" <^> varA @"(data_decl_item lsemis)* data_decl_item?"
        <:> \(mayLsemis :* declItems :* HNil) ->
            [||case $$(declItems) of { (declItems, ms) ->
                ( otoList declItems
                , AstParsed.maySp ($$(mayLsemis), ms)
                )
            }||]
    ]

rDataDeclItems0 :: RuleExpr (Bag.T (Ast.Decl AstParsed.T), Maybe Spanned.Span)
rDataDeclItems0 = ruleExpr
    [ varA @"data_decl_item" <^> varA @"lsemis" <^> varA @"(data_decl_item lsemis)* data_decl_item?"
        <:> \(dataDeclItem :* lsemis :* declItems :* HNil) ->
            [||case $$(declItems) of { (declItems, ms) ->
                ( cons $$(dataDeclItem) declItems
                , AstParsed.maySp (Just $$(dataDeclItem), $$(lsemis), ms)
                )
            }||]
    , varA @"data_decl_item"
        <:> \(dataDeclItem :* HNil) ->
            [||
                ( pure $$(dataDeclItem)
                , Just do AstParsed.sp $$(dataDeclItem)
                )
            ||]
    , eps
        <:> \HNil ->
            [||
                ( mempty
                , Nothing
                )
            ||]
    ]

rDataDeclItem :: RuleExpr (Ast.Decl AstParsed.T)
rDataDeclItem = ruleExpr
    [ varA @"type_decl"
        <:> \(typeDecl :* HNil) ->
            typeDecl
    , varA @"typesig_decl"
        <:> \(typeSigDecl :* HNil) ->
            typeSigDecl
    , varA @"consig_decl"
        <:> \(conSigDecl :* HNil) ->
            conSigDecl
    ]

rAlgDataType :: RuleExpr ([Ast.ImplType AstParsed.T], Maybe Spanned.Span)
rAlgDataType = ruleExpr
    [ varA @"alg_data_type_items"
        <:> \(algDataTypeItems :* HNil) ->
            [||case $$(algDataTypeItems) of { (implTypes, ms) ->
                ( otoList implTypes
                , ms
                )
            }||]
    ]

rAlgDataTypeItems :: RuleExpr (Bag.T (Ast.ImplType AstParsed.T), Maybe Spanned.Span)
rAlgDataTypeItems = ruleExpr
    [ tokA @"|" <^> varA @"(impltype '|')* impltype?"
        <:> \(_ :* kmid :* implTypes :* HNil) ->
            [||case $$(implTypes) of { (implTypes, ms) ->
                ( implTypes
                , Just do AstParsed.sp do $$(kmid) AstParsed.:<< ms
                )
            }||]
    , varA @"(impltype '|')* impltype?"
        <:> \(implTypes :* HNil) ->
            implTypes
    ]

rAlgDataTypeItems0 :: RuleExpr (Bag.T (Ast.ImplType AstParsed.T), Maybe Spanned.Span)
rAlgDataTypeItems0 = ruleExpr
    [ varA @"impltype" <^> tokA @"|" <^> varA @"(impltype '|')* impltype?"
        <:> \(implType :* _ :* kmid :* implTypes :* HNil) ->
            [||case $$(implTypes) of { (implTypes, ms) ->
                ( cons $$(implType) implTypes
                , Just do AstParsed.sp ($$(implType), $$(kmid) AstParsed.:<< ms)
                )
            }||]
    , varA @"impltype"
        <:> \(implType :* HNil) ->
            [||
                ( pure $$(implType)
                , Just do AstParsed.sp $$(implType)
                )
            ||]
    ]


rValDecl :: RuleExpr (Ast.Decl AstParsed.T)
rValDecl = ruleExpr
    [ varA @"declvarexpr" <^> tokA @"=" <^> varA @"expr" <^> tokA @"#where" <^> varA @"val_decl_where_body"
        <:> \(declVarExpr :* _ :* keq :* expr :* _ :* kwhere :* valDeclWhereBody :* HNil) ->
            [||case $$(valDeclWhereBody) of { (whereItems, msWhereItems) ->
                Ast.DeclVal $$(declVarExpr) $$(expr) whereItems do
                    AstParsed.sp
                        ( $$(declVarExpr)
                        , $$(keq)
                        , $$(expr) AstParsed.:<< msWhereItems
                        )
            }||]
    , varA @"declvarexpr" <^> tokA @"=" <^> varA @"expr"
        <:> \(declVarExpr :* _ :* keq :* expr :* HNil) ->
            [||
                Ast.DeclVal $$(declVarExpr) $$(expr) [] do
                    AstParsed.sp ($$(declVarExpr), $$(keq), $$(expr))
            ||]
    ]

rValBind :: RuleExpr (Ast.Decl AstParsed.T)
rValBind = ruleExpr
    [ varA @"pat" <^> tokA @"=" <^> varA @"expr" <^> tokA @"#where" <^> varA @"val_decl_where_body"
        <:> \(pat :* _ :* keq :* expr :* _ :* kwhere :* valDeclWhereBody :* HNil) ->
            [||case $$(valDeclWhereBody) of { (whereItems, msWhereItems) ->
                Ast.DeclValBind $$(pat) $$(expr) whereItems do
                    AstParsed.sp ($$(pat), $$(keq), $$(expr) AstParsed.:<< msWhereItems)
            }||]
    , varA @"pat" <^> tokA @"=" <^> varA @"expr"
        <:> \(pat :* _ :* keq :* expr :* HNil) ->
            [||
                Ast.DeclValBind $$(pat) $$(expr) [] do
                    AstParsed.sp ($$(pat), $$(keq), $$(expr))
            ||]
    ]

rValDeclWhereBody :: RuleExpr ([Ast.Decl AstParsed.T], Maybe Spanned.Span)
rValDeclWhereBody = ruleExpr
    [ tokVarA @"{{" <^> varA @"val_decl_where_items" <^> tokVarA @"}}"
        <:> \(_ :* kodbrace :* declItems :* _ :* kcdbrace :* HNil) ->
            [||case $$(declItems) of { (declItems, ms) ->
                ( declItems
                , Just do AstParsed.sp ($$(kodbrace), ms AstParsed.:>> $$(kcdbrace))
                )
            }||]
    , tokVarA @"{" <^> varA @"val_decl_where_items" <^> tokVarA @"}"
        <:> \(_ :* kobrace :* declItems :* _ :* kcbrace :* HNil) ->
            [||case $$(declItems) of { (declItems, ms) ->
                ( declItems
                , Just do AstParsed.sp ($$(kobrace), ms AstParsed.:>> $$(kcbrace))
                )
            }||]
    , varA @"imp_bo" <^> varA @"val_decl_where_items" <^> varA @"imp_bc"
        <:> \(impBo :* declItems :* impBc :* HNil) ->
            [||case $$(declItems) of { (declItems, ms) ->
                ( declItems
                , AstParsed.maySp ($$(impBo), ms, $$(impBc))
                )
            }||]
    ]

rValDeclWhereItems :: RuleExpr ([Ast.Decl AstParsed.T], Maybe Spanned.Span)
rValDeclWhereItems = ruleExpr
    [ varA @"lsemis?" <^> varA @"(val_decl_where_item lsemis)* val_decl_where_item?"
        <:> \(mayLsemis :* whereItems :* HNil) ->
            [||case $$(whereItems) of { (declItems, ms) ->
                ( declItems
                , AstParsed.maySp ($$(mayLsemis), ms)
                )
            }||]
    ]

rValDeclWhereItems0 :: RuleExpr ([Ast.Decl AstParsed.T], Maybe Spanned.Span)
rValDeclWhereItems0 = ruleExpr
    [ varA @"val_decl_where_item" <^> varA @"lsemis" <^> varA @"(val_decl_where_item lsemis)* val_decl_where_item?"
        <:> \(whereItem :* lsemis :* whereItems :* HNil) ->
            [||case $$(whereItems) of { (whereItems, ms) ->
                ( cons $$(whereItem) whereItems
                , AstParsed.maySp (Just $$(whereItem), $$(lsemis), ms)
                )
            }||]
    , varA @"val_decl_where_item"
        <:> \(whereItem :* HNil) ->
            [||
                ( pure $$(whereItem)
                , Just do AstParsed.sp $$(whereItem)
                )
            ||]
    , eps
        <:> \HNil ->
            [||
                ( mempty
                , Nothing
                )
            ||]
    ]

rValDeclWhereItem :: RuleExpr (Ast.Decl AstParsed.T)
rValDeclWhereItem = ruleExpr
    [ varA @"let_bind_item"
        <:> \(declItem :* HNil) ->
            declItem
    ]


rDeclType :: RuleExpr (Ast.DeclType AstParsed.T)
rDeclType = ruleExpr
    [ varA @"actual_bind_var" <^> varA @"declconop" <^> varA @"actual_bind_var" <^> tokA @":" <^> varA @"type"
        <:> \(bindVar1 :* declconop :* bindVar2 :* _ :* kcolon :* ty :* HNil) ->
            [||case $$(declconop) of { (declconop, spDeclconop) ->
                Ast.DeclInfixType $$(bindVar1) declconop $$(bindVar2)
                    do Just $$(ty)
                    do AstParsed.sp ($$(bindVar1), spDeclconop, $$(bindVar2), $$(kcolon), $$(ty))
            }||]
    , varA @"actual_bind_var" <^> varA @"declconop" <^> varA @"actual_bind_var"
        <:> \(bindVar1 :* declconop :* bindVar2 :* HNil) ->
            [||case $$(declconop) of { (declconop, spDeclconop) ->
                Ast.DeclInfixType $$(bindVar1) declconop $$(bindVar2)
                    do Nothing
                    do AstParsed.sp ($$(bindVar1), spDeclconop, $$(bindVar2))
            }||]
    , varA @"declcon" <^> varA @"bind_var*" <^> tokA @":" <^> varA @"type"
        <:> \(declcon :* bindVars :* _ :* kcolon :* ty :* HNil) ->
            [||case $$(declcon) of { (declcon, spDeclcon) ->
                case $$(bindVars) of { (bindVars, ms) ->
                    Ast.DeclAppType declcon
                        do otoList bindVars
                        do Just $$(ty)
                        do AstParsed.sp (spDeclcon AstParsed.:<< ms, $$(kcolon), $$(ty))
                }
            }||]
    , varA @"declcon" <^> varA @"bind_var*"
        <:> \(declcon :* bindVars :* HNil) ->
            [||case $$(declcon) of { (declcon, spDeclcon) ->
                case $$(bindVars) of { (bindVars, ms) ->
                    Ast.DeclAppType declcon
                        do otoList bindVars
                        do Nothing
                        do AstParsed.sp do spDeclcon AstParsed.:<< ms
                }
            }||]
    ]

rImplType :: RuleExpr (Ast.ImplType AstParsed.T)
rImplType = ruleExpr
    [ varA @"type_qualified" <^> varA @"conop_qualified" <^> varA @"type_qualified"
        <:> \(ty1 :* conop :* ty2 :* HNil) ->
            [||case $$(conop) of { (conop, spConop) ->
                Ast.ImplInfixType $$(ty1) conop $$(ty2) do
                    AstParsed.sp ($$(ty1), spConop, $$(ty2))
            }||]
    , varA @"con_qualified" <^> varA @"type_qualified*"
        <:> \(con :* types :* HNil) ->
            [||case $$(con) of { (con, spCon) ->
                case $$(types) of { (types, msTypes) ->
                    Ast.ImplAppType con types do
                        AstParsed.sp do spCon AstParsed.:<< msTypes
                }
            }||]
    ]

rDeclVarExpr :: RuleExpr (Ast.DeclExpr AstParsed.T)
rDeclVarExpr = ruleExpr
    [ varA @"actual_bind_var" <^> varA @"declop" <^> varA @"actual_bind_var" <^> tokA @":" <^> varA @"type"
        <:> \(bindVar1 :* declop :* bindVar2 :* _ :* kcolon :* ty :* HNil) ->
            [||case $$(declop) of { (declop, spDeclop) ->
                Ast.DeclInfixExpr $$(bindVar1) declop $$(bindVar2)
                    do Just $$(ty)
                    do AstParsed.sp ($$(bindVar1), spDeclop, $$(bindVar2), $$(kcolon), $$(ty))
            }||]
    , varA @"actual_bind_var" <^> varA @"declop" <^> varA @"actual_bind_var"
        <:> \(bindVar1 :* declop :* bindVar2 :* HNil) ->
            [||case $$(declop) of { (declop, spDeclop) ->
                Ast.DeclInfixExpr $$(bindVar1) declop $$(bindVar2)
                    do Nothing
                    do AstParsed.sp ($$(bindVar1), spDeclop, $$(bindVar2))
            }||]
    , varA @"declvar" <^> varA @"bind_var*" <^> tokA @":" <^> varA @"type"
        <:> \(declvar :* bindVars :* _ :* kcolon :* ty :* HNil) ->
            [||case $$(declvar) of { (declVar, spDeclVar) ->
                case $$(bindVars) of { (bindVars, msBindVars) ->
                    Ast.DeclAppExpr declVar
                        do otoList bindVars
                        do Just $$(ty)
                        do AstParsed.sp (spDeclVar AstParsed.:<< msBindVars, $$(kcolon), $$(ty))
                }
            }||]
    , varA @"declvar" <^> varA @"bind_var*"
        <:> \(declvar :* bindVars :* HNil) ->
            [||case $$(declvar) of { (declVar, spDeclVar) ->
                case $$(bindVars) of { (bindVars, msBindVars) ->
                    Ast.DeclAppExpr declVar
                        do otoList bindVars
                        do Nothing
                        do AstParsed.sp do spDeclVar AstParsed.:<< msBindVars
                }
            }||]
    ]


rType :: RuleExpr (Ast.TypeExpr AstParsed.T)
rType = ruleExpr
    [ varA @"type_infix"
        <:> \(ty :* HNil) ->
            ty
    ]

rTypeInfix :: RuleExpr (Ast.TypeExpr AstParsed.T)
rTypeInfix = ruleExpr
    [ varA @"type_apps" <^> varA @"type_op" <^> varA @"type_infix"
        <:> \(typeApps :* typeOp :* typeInfix :* HNil) ->
            [||
                Ast.TypeInfix $$(typeApps) $$(typeOp) $$(typeInfix) do
                    AstParsed.sp ($$(typeApps), $$(typeOp), $$(typeInfix))
            ||]
    , varA @"type_apps"
        <:> \(ty :* HNil) ->
            ty
    ]

rTypeOp :: RuleExpr (Ast.TypeExpr AstParsed.T)
rTypeOp = ruleExpr
    [ tokA @"`" <^> varA @"type_qualified_op" <^> tokA @"`"
        <:> \(_ :* kbacktick1 :* tyOp :* _ :* kbacktick2 :* HNil) ->
            [||
                Ast.TypeAnn $$(tyOp) do
                    AstParsed.sp ($$(kbacktick1), $$(tyOp), $$(kbacktick2))
            ||]
    , varA @"con_sym_ext"
        <:> \(conSymExt :* HNil) ->
            [||case $$(conSymExt) of { (conSymExt, spConSymExt) ->
                Ast.TypeCon conSymExt spConSymExt
            }||]
    , varA @"var_sym_ext"
        <:> \(varSymExt :* HNil) ->
            [||case $$(varSymExt) of { (varSymExt, spVarSymExt) ->
                Ast.TypeVar varSymExt spVarSymExt
            }||]
    ]

rTypeQualifiedOp :: RuleExpr (Ast.TypeExpr AstParsed.T)
rTypeQualifiedOp = ruleExpr
    [ varA @"con_sym_ext"
        <:> \(conSymExt :* HNil) ->
            [||case $$(conSymExt) of { (conSymExt, spConSymExt) ->
                Ast.TypeCon conSymExt spConSymExt
            }||]
    , varA @"var_sym_ext"
        <:> \(varSymExt :* HNil) ->
            [||case $$(varSymExt) of { (varSymExt, spVarSymExt) ->
                Ast.TypeVar varSymExt spVarSymExt
            }||]
    , varA @"type_apps"
        <:> \(ty :* HNil) ->
            ty
    ]

rTypeApps :: RuleExpr (Ast.TypeExpr AstParsed.T)
rTypeApps = ruleExpr
    [ varA @"type_qualified" <^> varA @"type_app+"
        <:> \(ty :* types :* HNil) ->
            [||case $$(types) of { (types, spTypes) ->
                Ast.TypeApp $$(ty)
                    do otoList types
                    do AstParsed.sp ($$(ty), spTypes)
            }||]
    , varA @"type_qualified"
        <:> \(ty :* HNil) ->
            ty
    ]

rTypeApps1 :: RuleExpr (Bag.T (Ast.AppType AstParsed.T), Spanned.Span)
rTypeApps1 = ruleExpr
    [ varA @"type_app" <^> varA @"type_app+"
        <:> \(ty :* types :* HNil) ->
            [||case $$(types) of { (types, spTypes) ->
                ( cons $$(ty) types
                , AstParsed.sp ($$(ty), spTypes)
                )
            }||]
    , varA @"type_app"
        <:> \(ty :* HNil) ->
            [||
                ( pure $$(ty)
                , AstParsed.sp $$(ty)
                )
            ||]
    ]

rTypeApp :: RuleExpr (Ast.AppType AstParsed.T)
rTypeApp = ruleExpr
    [ tokA @"@" <^> varA @"type_qualified"
        <:> \(_ :* kat :* ty :* HNil) ->
            [||Ast.UnivAppType $$(ty) do
                AstParsed.sp (lexToken $$(kat), $$(ty))
            ||]
    , tokA @"#@" <^> varA @"type_block_body"
        <:> \(_ :* kbat :* ty :* HNil) ->
            [||Ast.UnivAppType $$(ty) do
                AstParsed.sp (lexToken $$(kbat), $$(ty))
            ||]
    , varA @"type_qualified"
        <:> \(ty :* HNil) ->
            [||Ast.AppType $$(ty) do
                AstParsed.sp $$(ty)
            ||]
    ]

rTypeQualified :: RuleExpr (Ast.TypeExpr AstParsed.T)
rTypeQualified = ruleExpr
    [ varA @"type_block"
        <:> \(ty :* HNil) ->
            ty
    ]

rTypeBlock :: RuleExpr (Ast.TypeExpr AstParsed.T)
rTypeBlock = ruleExpr
    [ tokA @"^" <^> varA @"bind_var*" <^> tokA @"#>" <^> varA @"type"
        <:> \(_ :* kcaret :* bindVars :* _ :* karr :* ty :* HNil) ->
            [||case $$(bindVars) of { (bindVars, msBindVars) ->
                Ast.TypeForall
                    do otoList bindVars
                    do $$(ty)
                    do AstParsed.sp
                        ( $$(kcaret) AstParsed.:<< msBindVars
                        , $$(karr), $$(ty)
                        )
            }||]
    , tokA @"##" <^> varA @"type_block_body"
        <:> \(_ :* kblock :* ty :* HNil) ->
            [||Ast.TypeAnn $$(ty) do
                AstParsed.sp ($$(kblock), $$(ty))
            ||]
    , varA @"type_atomic"
        <:> \(ty :* HNil) ->
            ty
    ]

rTypeAtomic :: RuleExpr (Ast.TypeExpr AstParsed.T)
rTypeAtomic = ruleExpr
    [ tokVarA @"(" <^> varA @"type" <^> tokA @":" <^> varA @"type" <^> tokVarA @")"
        <:> \(_ :* kparenl :* ty1 :* _ :* kcolon :* ty2 :* _ :* kparenr :* HNil) ->
            [||Ast.TypeSig $$(ty1) $$(ty2) do
                AstParsed.sp ($$(kparenl), $$(ty1), $$(kcolon), $$(ty2), $$(kparenr))
            ||]
    , tokVarA @"(" <^> varA @"type" <^> tokVarA @")"
        <:> \(_ :* kparenl :* ty :* _ :* kparenr :* HNil) ->
            [||Ast.TypeAnn $$(ty) do
                AstParsed.sp ($$(kparenl), $$(ty), $$(kparenr))
            ||]
    , varA @"type_literal"
        <:> \(ty :* HNil) ->
            ty
    , varA @"con"
        <:> \(con :* HNil) ->
            [||case $$(con) of { (con, spCon) ->
                Ast.TypeCon con spCon
            }||]
    , varA @"var"
        <:> \(var :* HNil) ->
            [||case $$(var) of { (var, spVar) ->
                Ast.TypeVar var spVar
            }||]
    ]

rTypeLiteral :: RuleExpr (Ast.TypeExpr AstParsed.T)
rTypeLiteral = ruleExpr
    [ varA @"literal"
        <:> \(lit :* HNil) ->
            [||Ast.TypeLit $$(lit) do
                AstParsed.sp $$(lit)
            ||]
    , varA @"(" <^> varA @"type_tuple_items" <^> varA @")"
        <:> \(kparenl :* typeTupleItems :* kparenr :* HNil) ->
            [||case $$(typeTupleItems) of { (items, spItems) ->
                Ast.TypeTuple items do
                    AstParsed.sp ($$(kparenl), spItems, $$(kparenr))
            }||]
    , varA @"[" <^> varA @"type_array_items" <^> varA @"]"
        <:> \(kbrackl :* typeArrayItems :* kbrackr :* HNil) ->
            [||case $$(typeArrayItems) of { (items, msItems) ->
                Ast.TypeArray items do
                    AstParsed.sp ($$(kbrackl), msItems AstParsed.:>> $$(kbrackr))
            }||]
    , varA @"{" <^> varA @"type_simplrecord_items" <^> varA @"}"
        <:> \(kbracel :* typeRecordItems :* kbracer :* HNil) ->
            [||case $$(typeRecordItems) of { (items, msItems) ->
                Ast.TypeRecord items do
                    AstParsed.sp ($$(kbracel), msItems AstParsed.:>> $$(kbracer))
            }||]
    ]

rTypeBlockBody :: RuleExpr (Ast.TypeExpr AstParsed.T)
rTypeBlockBody = ruleExpr
    [ varA @"{{" <^> varA @"type_block_item" <^> varA @"}}"
        <:> \(expDbo :* typeBlockItem :* expDbc :* HNil) ->
            [||Ast.TypeAnn $$(typeBlockItem) do
                AstParsed.sp ($$(expDbo), $$(typeBlockItem), $$(expDbc))
            ||]
    , varA @"{" <^> varA @"type_block_item" <^> varA @"}"
        <:> \(expBo :* typeBlockItem :* expBc :* HNil) ->
            [||Ast.TypeAnn $$(typeBlockItem) do
                AstParsed.sp ($$(expBo), $$(typeBlockItem), $$(expBc))
            ||]
    , varA @"imp_bo" <^> varA @"type_block_item" <^> varA @"imp_bc"
        <:> \(impBo :* typeBlockItem :* impBc :* HNil) ->
            [||Ast.TypeAnn $$(typeBlockItem) do
                AstParsed.sp ($$(impBo), $$(typeBlockItem), $$(impBc))
            ||]
    ]

rTypeBlockItem :: RuleExpr (Ast.TypeExpr AstParsed.T)
rTypeBlockItem = ruleExpr
    [ varA @"lsemis?" <^> varA @"type" <^> varA @"lsemis?"
        <:> \(mlsemis1 :* ty :* mlsemis2 :* HNil) ->
            [||Ast.TypeAnn $$(ty) do
                AstParsed.sp
                    ($$(mlsemis1) AstParsed.:>> $$(ty) AstParsed.:<< $$(mlsemis2))
            ||]
    ]

rTypeTupleItems :: RuleExpr ([Ast.TypeExpr AstParsed.T], Spanned.Span)
rTypeTupleItems = ruleExpr
    [ tokA @"," <^> varA @"(type ',')+ type ','?"
        <:> \(_ :* kcomma :* items :* HNil) ->
            [||case $$(items) of { (items, spItems) ->
                ( items
                , AstParsed.sp ($$(kcomma), spItems)
                )
            }||]
    , varA @"(type ',')+ type ','?"
        <:> \(items :* HNil) ->
            items
    ]

rTypeTupleItems0 :: RuleExpr ([Ast.TypeExpr AstParsed.T], Spanned.Span)
rTypeTupleItems0 = ruleExpr
    [ varA @"type" <^> tokA @"," <^> varA @"(type ',')+ type ','?"
        <:> \(ty :* _ :* kcomma :* items :* HNil) ->
            [||case $$(items) of { (items, spItems) ->
                ( cons $$(ty) items
                , AstParsed.sp ($$(ty), $$(kcomma), spItems)
                )
            }||]
    , varA @"type" <^> tokA @"," <^> varA @"type" <^> tokA @","
        <:> \(ty1 :* _ :* kcomma1 :* ty2 :* _ :* kcomma2 :* HNil) ->
            [||
                ( cons $$(ty1) do pure $$(ty2)
                , AstParsed.sp ($$(ty1), $$(kcomma1), $$(ty2), $$(kcomma2))
                )
            ||]
    , varA @"type" <^> tokA @"," <^> varA @"type"
        <:> \(ty1 :* _ :* kcomma1 :* ty2 :* HNil) ->
            [||
                ( cons $$(ty1) do pure $$(ty2)
                , AstParsed.sp ($$(ty1), $$(kcomma1), $$(ty2))
                )
            ||]
    ]

rTypeArrayItems :: RuleExpr ([Ast.TypeExpr AstParsed.T], Maybe Spanned.Span)
rTypeArrayItems = ruleExpr
    [ tokA @"," <^> varA @"(type ',')* type?"
        <:> \(_ :* kcomma :* items :* HNil) ->
            [||case $$(items) of { (items, msItems) ->
                ( items
                , Just do AstParsed.sp do $$(kcomma) AstParsed.:>> msItems
                )
            }||]
    , varA @"(type ',')* type?"
        <:> \(items :* HNil) ->
            items
    ]

rTypeArrayItems0 :: RuleExpr ([Ast.TypeExpr AstParsed.T], Maybe Spanned.Span)
rTypeArrayItems0 = ruleExpr
    [ varA @"type" <^> tokA @"," <^> varA @"(type ',')* type?"
        <:> \(ty :* _ :* kcomma :* items :* HNil) ->
            [||case $$(items) of { (items, msItems) ->
                ( cons $$(ty) items
                , Just do AstParsed.sp ($$(ty), $$(kcomma) AstParsed.:<< msItems)
                )
            }||]
    , varA @"type"
        <:> \(ty :* HNil) ->
            [||
                ( pure $$(ty)
                , Just do AstParsed.sp $$(ty)
                )
            ||]
    , eps
        <:> \HNil ->
            [||
                ( mempty
                , Nothing
                )
            ||]
    ]

rTypeSimpleRecordItems :: RuleExpr ([Ast.TypeRecordItem AstParsed.T], Maybe Spanned.Span)
rTypeSimpleRecordItems = ruleExpr
    [ tokA @"," <^> varA @"(type_simplrecord_item ',')* type_simplrecord_item?"
        <:> \(_ :* kcomma :* items :* HNil) ->
            [||case $$(items) of { (items, msItems) ->
                ( items
                , Just do AstParsed.sp do $$(kcomma) AstParsed.:<< msItems
                )
            }||]
    , varA @"(type_simplrecord_item ',')* type_simplrecord_item?"
        <:> \(items :* HNil) ->
            items
    ]

rTypeSimpleRecordItems0 :: RuleExpr ([Ast.TypeRecordItem AstParsed.T], Maybe Spanned.Span)
rTypeSimpleRecordItems0 = ruleExpr
    [ varA @"type_simplrecord_item" <^> tokA @"," <^> varA @"(type_simplrecord_item ',')* type_simplrecord_item?"
        <:> \(recordItem :* _ :* kcomma :* items :* HNil) ->
            [||case $$(items) of { (items, msItems) ->
                ( cons $$(recordItem) items
                , Just do AstParsed.sp ($$(recordItem), $$(kcomma) AstParsed.:<< msItems)
                )
            }||]
    , varA @"type_simplrecord_item"
        <:> \(item :* HNil) ->
            [||
                ( pure $$(item)
                , Just do AstParsed.sp item
                )
            ||]
    , eps
        <:> \HNil ->
            [||
                ( mempty
                , Nothing
                )
            ||]
    ]

rTypeSimpleRecordItem :: RuleExpr (Ast.TypeRecordItem AstParsed.T)
rTypeSimpleRecordItem = ruleExpr
    [ varA @"declvar" <^> tokA @":" <^> varA @"type"
        <:> \(declvar :* _ :* kcolon :* ty :* HNil) ->
            [||case $$(declvar) of { (declvar, spDeclVar) ->
                Ast.TypeRecordItem declvar $$(ty) do
                    AstParsed.sp (spDeclVar, $$(kcolon), $$(ty))
            }||]
    ]


rSigItem :: RuleExpr (Ast.Decl AstParsed.T)
rSigItem = ruleExpr
    [ varA @"typesig_decl"
        <:> \(typeSigDecl :* HNil) ->
            typeSigDecl
    , varA @"valsig_decl"
        <:> \(valSigDecl :* HNil) ->
            valSigDecl
    , varA @"consig_decl"
        <:> \(conSigDecl :* HNil) ->
            conSigDecl
    ]


rExpr :: RuleExpr (Ast.Expr AstParsed.T)
rExpr = ruleExpr
    [ varA @"expr_infix" <^> tokA @":" <^> varA @"type"
        <:> \(expr :* _ :* kcolon :* ty :* HNil) ->
            [||Ast.ExprSig $$(expr) $$(ty) do
                AstParsed.sp ($$(expr), $$(kcolon), $$(ty))
            ||]
    , varA @"expr_infix"
        <:> \(expr :* HNil) ->
            expr
    ]

rExprInfix :: RuleExpr (Ast.Expr AstParsed.T)
rExprInfix = ruleExpr
    [ varA @"expr_apps" <^> varA @"expr_op" <^> varA @"expr_infix"
        <:> \(expr1 :* op :* expr2 :* HNil) ->
            [||Ast.ExprInfix $$(expr1) $$(op) $$(expr2) do
                AstParsed.sp ($$(expr1), $$(op), $$(expr2))
            ||]
    , varA @"expr_apps"
        <:> \(expr :* HNil) ->
            expr
    ]

rExprOp :: RuleExpr (Ast.Expr AstParsed.T)
rExprOp = ruleExpr
    [ tokA @"`" <^> varA @"expr_op_block" <^> tokA @"`"
        <:> \(_ :* kbacktick1 :* expr :* _ :* kbacktick2 :* HNil) ->
            [||Ast.ExprAnn $$(expr) do
                AstParsed.sp ($$(kbacktick1), $$(expr), $$(kbacktick2))
            ||]
    , varA @"con_sym_ext"
        <:> \(con :* HNil) ->
            [||case $$(con) of { (con, spCon) ->
                Ast.ExprCon con spCon
            }||]
    , varA @"var_sym_ext"
        <:> \(var :* HNil) ->
            [||case $$(var) of { (var, spVar) ->
                Ast.ExprVar var spVar
            }||]
    ]

rExprOpBlock :: RuleExpr (Ast.Expr AstParsed.T)
rExprOpBlock = ruleExpr
    [ varA @"con_sym_ext"
        <:> \(con :* HNil) ->
            [||case $$(con) of { (con, spCon) ->
                Ast.ExprCon con spCon
            }||]
    , varA @"var_sym_ext"
        <:> \(var :* HNil) ->
            [||case $$(var) of { (var, spVar) ->
                Ast.ExprVar var spVar
            }||]
    , varA @"expr_apps"
        <:> \(expr :* HNil) ->
            expr
    ]

rExprApps :: RuleExpr (Ast.Expr AstParsed.T)
rExprApps = ruleExpr
    [ varA @"expr_qualified" <^> varA @"expr_app+"
        <:> \(expr :* exprs :* HNil) ->
            [||case $$(exprs) of { (exprs, spExprs) ->
                Ast.ExprApp $$(expr)
                    do otoList exprs
                    do AstParsed.sp ($$(expr), spExprs)
            }||]
    , varA @"expr_qualified"
        <:> \(expr :* HNil) ->
            expr
    ]

rExprApps1 :: RuleExpr (Bag.T (Ast.AppExpr AstParsed.T), Spanned.Span)
rExprApps1 = ruleExpr
    [ varA @"expr_app" <^> varA @"expr_app+"
        <:> \(expr :* exprs :* HNil) ->
            [||case $$(exprs) of { (exprs, spExprs) ->
                ( cons $$(expr) exprs
                , AstParsed.sp ($$(expr), spExprs)
                )
            }||]
    , varA @"expr_app"
        <:> \(expr :* HNil) ->
            [||
                ( pure $$(expr)
                , AstParsed.sp $$(expr)
                )
            ||]
    ]

rExprApp :: RuleExpr (Ast.AppExpr AstParsed.T)
rExprApp = ruleExpr
    [ tokA @"@" <^> varA @"type_qualified"
        <:> \(_ :* kat :* ty :* HNil) ->
            [||Ast.UnivAppExpr $$(ty) do
                AstParsed.sp ($$(kat), $$(ty))
            ||]
    , tokA @"#@" <^> varA @"type_block_body"
        <:> \(_ :* kat :* ty :* HNil) ->
            [||Ast.UnivAppExpr $$(ty) do
                AstParsed.sp ($$(kat), $$(ty))
            ||]
    , varA @"expr_qualified"
        <:> \(expr :* HNil) ->
            [||Ast.AppExpr $$(expr) do
                AstParsed.sp $$(expr)
            ||]
    ]

rExprQualified :: RuleExpr (Ast.Expr AstParsed.T)
rExprQualified = ruleExpr
    [ varA @"expr_block"
        <:> \(expr :* HNil) ->
            expr
    ]

rExprBlock :: RuleExpr (Ast.Expr AstParsed.T)
rExprBlock = ruleExpr
    [ tokA @"\\" <^> varA @"pat_atomic*" <^> varA @"guarded_alts"
        <:> \(_ :* kbackslash :* pats :* alts :* HNil) ->
            [||case $$(pats) of { (pats, msPats) ->
                case $$(alts) of { (alts, msAlts) ->
                    let msAlt = AstParsed.maySp (msPats, msAlts)
                    in Ast.ExprLambda
                        [ Ast.CaseAlt
                            do otoList pats
                            alts msAlt
                        ]
                        do AstParsed.sp
                            do $$(kbackslash) AstParsed.:<< msAlt
                }
            }||]
    , tokA @"#case" <^> varA @"case_alt_body"
        <:> \(_ :* kcase :* alts :* HNil) ->
            [||case $$(alts) of { (alts, msAlts) ->
                Ast.ExprLambda alts do
                    AstParsed.sp do $$(kcase) AstParsed.:<< msAlts
            }||]
    , tokA @"#letrec" <^> varA @"let_binds" <^> tokA @"#in" <^> varA @"expr"
        <:> \(_ :* kletrec :* binds :* _ :* kin :* expr :* HNil) ->
            [||case $$(binds) of { (binds, msBinds) ->
                Ast.ExprLetrec binds $$(expr) do
                    AstParsed.sp
                        ( $$(kletrec) AstParsed.:<< msBinds
                        , $$(kin), $$(expr)
                        )
            }||]
    , tokA @"#let" <^> varA @"let_binds" <^> tokA @"#in" <^> varA @"expr"
        <:> \(_ :* klet :* binds :* _ :* kin :* expr :* HNil) ->
            [||case $$(binds) of { (binds, msBinds) ->
                Ast.ExprLetrec binds $$(expr) do
                    AstParsed.sp
                        ( $$(klet) AstParsed.:<< msBinds
                        , $$(kin), $$(expr)
                        )
            }||]
    , tokA @"#match" <^> varA @"','? (expr ',')* expr?" <^> tokA @"#with" <^> varA @"case_alt_body"
        <:> \(_ :* kmatch :* exprs :* _ :* kwith :* alts :* HNil) ->
            [||case $$(exprs) of { (exprs, msExprs) ->
                case $$(alts) of { (alts, msAlts) ->
                    Ast.ExprMatch exprs alts do
                        AstParsed.sp
                            ( $$(kmatch) AstParsed.:<< msExprs
                            , $$(kwith) AstParsed.:<< msAlts
                            )
                }
            }||]
    , tokA @"#do" <^> varA @"do_body"
        <:> \(_ :* kdo :* doBody :* HNil) ->
            [||case $$(doBody) of { (stmts, expr, spBody) ->
                Ast.ExprDo stmts expr do
                    AstParsed.sp ($$(kdo), spBody)
            }||]
    , tokA @"##" <^> varA @"expr_block_body"
        <:> \(_ :* kblock :* expr :* HNil) ->
            [||Ast.ExprAnn $$(expr) do
                AstParsed.sp ($$(kblock), $$(expr))
            ||]
    , varA @"expr_atomic"
        <:> \(expr :* HNil) ->
            expr
    ]

rPatAtomics0 :: RuleExpr (Bag.T (Ast.Pat AstParsed.T), Maybe Spanned.Span)
rPatAtomics0 = ruleExpr
    [ varA @"pat_atomic" <^> varA @"pat_atomic*"
        <:> \(pat :* pats :* HNil) ->
            [||case $$(pats) of { (pats, msPats) ->
                ( cons $$(pat) pats
                , Just do AstParsed.sp do $$(pat) AstParsed.:<< msPats
                )
            }||]
    , eps
        <:> \HNil ->
            [||
                ( mempty
                , Nothing
                )
            ||]
    ]

rExprs0WithComma :: RuleExpr ([Ast.Expr AstParsed.T], Maybe Spanned.Span)
rExprs0WithComma = ruleExpr
    [ tokA @"," <^> varA @"(expr ',')* expr?"
        <:> \(_ :* kcomma :* exprs :* HNil) ->
            [||case $$(exprs) of { (exprs, msExprs) ->
                ( otoList exprs
                , Just do AstParsed.sp do $$(kcomma) AstParsed.:<< msExprs
                )
            }||]
    , varA @"(expr ',')* expr?"
        <:> \(exprs :* HNil) ->
            [||case $$(exprs) of { (exprs, msExprs) ->
                ( otoList exprs
                , msExprs
                )
            }||]
    ]

rExprs0 :: RuleExpr (Bag.T (Ast.Expr AstParsed.T), Maybe Spanned.Span)
rExprs0 = ruleExpr
    [ varA @"expr" <^> tokA @"," <^> varA @"(expr ',')* expr?"
        <:> \(expr :* _ :* kcomma :* exprs :* HNil) ->
            [||case $$(exprs) of { (exprs, msExprs) ->
                ( cons $$(expr) exprs
                , Just do AstParsed.sp ($$(expr), $$(kcomma) AstParsed.:<< msExprs)
                )
            }||]
    , varA @"expr"
        <:> \(expr :* HNil) ->
            [||
                ( pure $$(expr)
                , Just do AstParsed.sp $$(expr)
                )
            ||]
    , eps
        <:> \HNil ->
            [||
                ( mempty
                , Nothing
                )
            ||]
    ]

rExprAtomic :: RuleExpr (Ast.Expr AstParsed.T)
rExprAtomic = ruleExpr
    [ tokVarA @"(" <^> varA @"expr" <^> tokVarA @")"
        <:> \(_ :* kparenl :* expr :* _ :* kparenr :* HNil) ->
            [||Ast.ExprAnn $$(expr) do
                AstParsed.sp ($$(kparenl), $$(expr), $$(kparenr))
            ||]
    , varA @"expr_literal"
        <:> \(expr :* HNil) ->
            expr
    , varA @"con"
        <:> \(con :* HNil) ->
            [||case $$(con) of { (con, spCon) ->
                Ast.ExprCon con spCon
            }||]
    , varA @"var"
        <:> \(var :* HNil) ->
            [||case $$(var) of { (var, spVar) ->
                Ast.ExprVar var spVar
            }||]
    ]

rExprLiteral :: RuleExpr (Ast.Expr AstParsed.T)
rExprLiteral = ruleExpr
    [ varA @"literal"
        <:> \(lit :* HNil) ->
            [||Ast.ExprLit $$(lit) do
                AstParsed.sp $$(lit)
            ||]
    , varA @"expr_interp_string"
        <:> \(parts :* HNil) ->
            [||case $$(parts) of { (parts, spParts) ->
                Ast.ExprInterpString parts spParts
            }||]
    , tokVarA @"(" <^> varA @"expr_tuple_items" <^> tokVarA @")"
        <:> \(_ :* kparenl :* items :* _ :* kparenr :* HNil) ->
            [||case $$(items) of { (items, spItems) ->
                Ast.ExprTuple items do
                    AstParsed.sp ($$(kparenl), spItems, $$(kparenr))
            }||]
    , tokVarA @"[" <^> varA @"expr_array_items" <^> tokVarA @"]"
        <:> \(_ :* kbrackl :* items :* _ :* kbrackr :* HNil) ->
            [||case $$(items) of { (items, msItems) ->
                Ast.ExprArray items do
                    AstParsed.sp ($$(kbrackl), msItems AstParsed.:>> $$(kbrackr))
            }||]
    , tokVarA @"{" <^> varA @"expr_simplrecord_items" <^> tokVarA @"}"
        <:> \(_ :* kbracel :* items :* _ :* kbracer :* HNil) ->
            [||case $$(items) of { (items, msItems) ->
                Ast.ExprRecord items do
                    AstParsed.sp ($$(kbracel), msItems AstParsed.:>> $$(kbracer))
            }||]
    ]

rExprBlockBody :: RuleExpr (Ast.Expr AstParsed.T)
rExprBlockBody = ruleExpr
    [ tokVarA @"{{" <^> varA @"expr_block_item" <^> tokVarA @"}}"
        <:> \(_ :* kdbraceo :* expr :* _ :* kdbracec :* HNil) ->
            [||Ast.ExprAnn $$(expr) do
                AstParsed.sp ($$(kdbraceo), $$(expr), $$(kdbracec))
            ||]
    , tokVarA @"{" <^> varA @"expr_block_item" <^> tokVarA @"}"
        <:> \(_ :* kbraceo :* expr :* _ :* kbracec :* HNil) ->
            [||Ast.ExprAnn $$(expr) do
                AstParsed.sp ($$(kbraceo), $$(expr), $$(kbracec))
            ||]
    , varA @"imp_bo" <^> varA @"expr_block_item" <^> varA @"imp_bc"
        <:> \(impBo :* expr :* impBc :* HNil) ->
            [||Ast.ExprAnn $$(expr) do
                AstParsed.sp ($$(impBo), $$(expr), $$(impBc))
            ||]
    ]

rExprBlockItem :: RuleExpr (Ast.Expr AstParsed.T)
rExprBlockItem = ruleExpr
    [ varA @"lsemis?" <^> varA @"expr" <^> varA @"lsemis?"
        <:> \(mlsemis1 :* expr :* mlsemis2 :* HNil) ->
            [||Ast.ExprAnn $$(expr) do
                AstParsed.sp do $$(mlsemis1) AstParsed.:>> $$(expr) AstParsed.:<< $$(mlsemis2)
            ||]
    ]

rExprInterpString :: RuleExpr (NonEmpty (Ast.InterpStringPart AstParsed.T), Spanned.Span)
rExprInterpString = ruleExpr
    [ tokA @"interp_string_without_interp"
        <:> \(_ :* lpart :* HNil) ->
            [||let litPart = interpStringLit do lexToken $$(lpart) in
                ( pure litPart
                , AstParsed.sp litPart
                )
            ||]
    , tokVarA @"interp_string_start" <^> varA @"expr" <^> varA @"(interp_string_cont expr)* interp_string_end"
        <:> \(_ :* part :* expr :* parts :* HNil) ->
            [||case $$(parts) of { (parts, spParts) ->
                let exprPart = interpStringExpr $$(expr)
                in
                    ( $$(part) :| exprPart : otoList parts
                    , AstParsed.sp ($$(part), exprPart, spParts)
                    )
            }||]
    ]

rExprInterpStringContParts :: RuleExpr (Bag.T (Ast.InterpStringPart AstParsed.T), Spanned.Span)
rExprInterpStringContParts = ruleExpr
    [ tokVarA @"interp_string_cont" <^> varA @"expr" <^> varA @"(interp_string_cont expr)* interp_string_end"
        <:> \(_ :* part :* expr :* parts :* HNil) ->
            [||case $$(parts) of { (parts, spParts) ->
                let exprPart = interpStringExpr $$(expr)
                in
                    ( cons $$(part) do cons exprPart parts
                    , AstParsed.sp ($$(part), exprPart, spParts)
                    )
            }||]
    , tokVarA @"interp_string_end"
        <:> \(_ :* part :* HNil) ->
            [||
                ( pure $$(part)
                , AstParsed.sp $$(part)
                )
            ||]
    ]


rExprTupleItems :: RuleExpr ([Ast.Expr AstParsed.T], Spanned.Span)
rExprTupleItems = ruleExpr
    [ tokA @"," <^> varA @"(expr ',')+ expr ','?"
        <:> \(_ :* kcomma :* items :* HNil) ->
            [||case $$(items) of { (items, spItems) ->
                ( otoList items
                , AstParsed.sp ($$(kcomma), spItems)
                )
            }||]
    , varA @"(expr ',')+ expr ','?"
        <:> \(items :* HNil) ->
            [||case $$(items) of { (items, spItems) ->
                ( otoList items
                , spItems
                )
            }||]
    ]

rExprTupleItems2 :: RuleExpr (Bag.T (Ast.Expr AstParsed.T), Spanned.Span)
rExprTupleItems2 = ruleExpr
    [ varA @"expr" <^> tokA @"," <^> varA @"(expr ',')+ expr ','?"
        <:> \(expr :* _ :* kcomma :* items :* HNil) ->
            [||case $$(items) of { (items, spItems) ->
                ( cons $$(expr) items
                , AstParsed.sp ($$(expr), $$(kcomma), spItems)
                )
            }||]
    , varA @"expr" <^> tokA @"," <^> varA @"expr" <^> tokA @","
        <:> \(expr1 :* _ :* kcomma1 :* expr2 :* _ :* kcomma2 :* HNil) ->
            [||
                ( cons $$(expr1) do pure $$(expr2)
                , AstParsed.sp ($$(expr1), $$(kcomma1), $$(expr2), $$(kcomma2))
                )
            ||]
    , varA @"expr" <^> tokA @"," <^> varA @"expr"
        <:> \(expr1 :* _ :* kcomma1 :* expr2 :* HNil) ->
            [||
                ( cons $$(expr1) do pure $$(expr2)
                , AstParsed.sp ($$(expr1), $$(kcomma1), $$(expr2))
                )
            ||]
    ]

rExprArrayItems :: RuleExpr ([Ast.Expr AstParsed.T], Maybe Spanned.Span)
rExprArrayItems = ruleExpr
    [ tokA @"," <^> varA @"(expr ',')* expr?"
        <:> \(_ :* kcomma :* items :* HNil) ->
            [||case $$(items) of { (items, msItems) ->
                ( otoList items
                , Just do AstParsed.sp do $$(kcomma) AstParsed.:<< msItems
                )
            }||]
    , varA @"(expr ',')* expr?"
        <:> \(items :* HNil) ->
            [||case $$(items) of { (items, msItems) ->
                ( otoList items
                , msItems
                )
            }||]
    ]

rExprArrayItems0 :: RuleExpr (Bag.T (Ast.Expr AstParsed.T), Maybe Spanned.Span)
rExprArrayItems0 = ruleExpr
    [ varA @"expr" <^> tokA @"," <^> varA @"(expr ',')* expr?"
        <:> \(expr :* _ :* kcomma :* items :* HNil) ->
            [||case $$(items) of { (items, msItems) ->
                ( cons $$(expr) items
                , Just do AstParsed.sp ($$(expr), $$(kcomma) AstParsed.:<< msItems)
                )
            }||]
    , varA @"expr"
        <:> \(expr :* HNil) ->
            [||
                ( pure $$(expr)
                , Just do AstParsed.sp $$(expr)
                )
            ||]
    , eps
        <:> \HNil ->
            [||
                ( mempty
                , Nothing
                )
            ||]
    ]

rExprSimpleRecordItems :: RuleExpr ([Ast.ExprRecordItem AstParsed.T], Maybe Spanned.Span)
rExprSimpleRecordItems = ruleExpr
    [ tokA @"," <^> varA @"(expr_simplrecord_item ',')* expr_simplrecord_item?"
        <:> \(_ :* kcomma :* items :* HNil) ->
            [||case $$(items) of { (items, msItems) ->
                ( otoList items
                , Just do AstParsed.sp do $$(kcomma) AstParsed.:<< msItems
                )
            }||]
    , varA @"(expr_simplrecord_item ',')* expr_simplrecord_item?"
        <:> \(items :* HNil) ->
            [||case $$(items) of { (items, msItems) ->
                ( otoList items
                , msItems
                )
            }||]
    ]

rExprSimpleRecordItems0 :: RuleExpr (Bag.T (Ast.ExprRecordItem AstParsed.T), Maybe Spanned.Span)
rExprSimpleRecordItems0 = ruleExpr
    [ varA @"expr_simplrecord_item" <^> tokA @"," <^> varA @"(expr_simplrecord_item ',')* expr_simplrecord_item?"
        <:> \(item :* _ :* kcomma :* items :* HNil) ->
            [||case $$(items) of { (items, msItems) ->
                ( cons $$(item) items
                , Just do AstParsed.sp ($$(item), $$(kcomma) AstParsed.:<< msItems)
                )
            }||]
    , varA @"expr_simplrecord_item"
        <:> \(item :* HNil) ->
            [||
                ( pure $$(item)
                , Just do AstParsed.sp $$(item)
                )
            ||]
    , eps
        <:> \HNil ->
            [||
                ( mempty
                , Nothing
                )
            ||]
    ]

rExprSimpleRecordItem :: RuleExpr (Ast.ExprRecordItem AstParsed.T)
rExprSimpleRecordItem = ruleExpr
    [ varA @"declvar" <^> tokA @"=" <^> varA @"expr"
        <:> \(declvar :* _ :* keq :* expr :* HNil) ->
            [||case $$(declvar) of { (declVar, spDeclVar) ->
                Ast.ExprRecordItem declVar $$(expr) do
                    AstParsed.sp (spDeclVar, $$(keq), $$(expr))
            }||]
    ]


rPat :: RuleExpr (Ast.Pat AstParsed.T)
rPat = ruleExpr
    [ varA @"pat_unit" <^> tokA @":" <^> varA @"type"
        <:> \(pat :* _ :* kcolon :* ty :* HNil) ->
            [||Ast.PatSig $$(pat) $$(ty) do
                AstParsed.sp ($$(pat), $$(kcolon), $$(ty))
            ||]
    , varA @"pat_unit"
        <:> \(pat :* HNil) ->
            pat
    ]

rPatUnit :: RuleExpr (Ast.Pat AstParsed.T)
rPatUnit = ruleExpr
    [ tokA @"|" <^> varA @"(pat_infix '|')* pat_infix '|'?"
        <:> \(_ :* kor :* pats :* HNil) ->
            [||case $$(pats) of { (pats, spPats) ->
                Ast.PatOr
                    do otoList pats
                    do AstParsed.sp ($$(kor), spPats)
            }||]
    ]

rPatInfixes1 :: RuleExpr (Bag.T (Ast.Pat AstParsed.T), Spanned.Span)
rPatInfixes1 = ruleExpr
    [ varA @"pat_infix" <^> tokA @"|" <^> varA @"(pat_infix '|')* pat_infix '|'?"
        <:> \(pat :* _ :* kor :* pats :* HNil) ->
            [||case $$(pats) of { (pats, spPats) ->
                ( cons $$(pat) pats
                , AstParsed.sp ($$(pat), $$(kor), spPats)
                )
            }||]
    , varA @"pat_infix" <^> tokA @"|"
        <:> \(pat :* _ :* kor :* HNil) ->
            [||
                ( pure $$(pat)
                , AstParsed.sp ($$(pat), $$(kor))
                )
            ||]
    , varA @"pat_infix"
        <:> \(pat :* HNil) ->
            [||
                ( pure $$(pat)
                , AstParsed.sp $$(pat)
                )
            ||]
    ]

rPatInfix :: RuleExpr (Ast.Pat AstParsed.T)
rPatInfix = ruleExpr
    [ varA @"pat_apps" <^> varA @"pat_op" <^> varA @"(pat_apps pat_op)* pat_apps"
        <:> \(pat1 :* op :* pat2 :* HNil) ->
            [||case $$(op) of { (op, spOp) ->
                Ast.PatInfix $$(pat1) op $$(pat2) do
                    AstParsed.sp ($$(pat1), spOp, $$(pat2))
            }||]
    , varA @"pat_apps"
        <:> \(pat :* HNil) ->
            pat
    ]

rPatOp :: RuleExpr (Ast.Pat AstParsed.T)
rPatOp = ruleExpr
    [ tokA @"`" <^> varA @"pat_op_block" <^> tokA @"`"
        <:> \(_ :* kcaret1 :* pat :* _ :* kcaret2 :* HNil) ->
            [||Ast.PatAnn $$(pat) do
                AstParsed.sp ($$(kcaret1), $$(pat), $$(kcaret2))
            ||]
    , varA @"con_sym_ext"
        <:> \(con :* HNil) ->
            [||Ast.PatConApp
                do Spanned.unSpanned $$(con)
                do []
                do AstParsed.sp $$(con)
            ||]
    ]

rPatOpBlock :: RuleExpr (Ast.Pat AstParsed.T)
rPatOpBlock = ruleExpr
    [ varA @"con_sym_ext"
        <:> \(con :* HNil) ->
            [||Ast.PatConApp
                do Spanned.unSpanned $$(con)
                do []
                do AstParsed.sp $$(con)
            ||]
    , varA @"pat_apps"
        <:> \(pat :* HNil) ->
            pat
    ]

rPatApps :: RuleExpr (Ast.Pat AstParsed.T)
rPatApps = ruleExpr
    [ varA @"con_qualified" <^> varA @"pat_app*"
        <:> \(con :* pats :* HNil) ->
            [||case $$(con) of { (con, spCon) ->
                case $$(pats) of { (pats, ms) ->
                    Ast.PatConApp con pats do
                        AstParsed.sp do spCon AstParsed.:<< ms
                }
            }||]
    ]


rLsemis :: RuleExpr (Maybe Spanned.Span)
rLsemis = ruleExpr
    [ varA @"lsemi" <^> varA @"lsemis?"
        <:> \(lsemi :* mayLsemis :* HNil) ->
            [||AstParsed.maySp (lsemi, mayLsemis)||]
    ]

rMayLsemis :: RuleExpr (Maybe Spanned.Span)
rMayLsemis = ruleExpr
    [ varA @"lsemi" <^> varA @"lsemis?"
        <:> \(lsemi :* mayLsemis :* HNil) ->
            [||AstParsed.maySp (lsemi, mayLsemis)||]
    , eps
        <:> \HNil ->
            [||Nothing||]
    ]

rLsemi :: RuleExpr (Maybe Spanned.Span)
rLsemi = ruleExpr
    [ Ptera.tokA @"<n>"
        <::> \(t :* HNil) ->
            [||case $$(t) of { Layout.Newline lpos1 -> do
                ctx <- Ptera.getAction
                case layoutStack ctx of
                    ImplicitLayout lpos2:_ | lpos1 == lpos2 ->
                        pure Nothing
                    ExplicitScopedLayout lpos2:_ | lpos1 == lpos2 ->
                        pure Nothing
                    NoLayout:_ ->
                        Ptera.failAction
                    [] ->
                        Ptera.failAction
            }||]
    , tokA @";"
        <:> \(_ :* t :* HNil) ->
            [||case $$(t) of { Layout.Token t ->
                Just do Spanned.getSpan t
            }||]
    ]


tokA :: forall t.
    Ptera.TokensMember Tokens t => TypedExpr '[(), Token]
tokA = varA @"skip" <^> Ptera.tokA @t

lexToken :: Token -> Spanned.Spanned Token.LexToken
lexToken = \case
    Layout.Token st ->
        st
    _ ->
        error "unreachable: expect lexed token, but actually a layout token is given."

type family RuleSymbol (t :: Symbol) :: Symbol
type RuleSymbolReturnType t = Ptera.RuleExprReturnType RuleDefs (RuleSymbol t)

class
    ( KnownSymbol (RuleSymbol t)
    , Ptera.LiftType (RuleSymbolReturnType t)
    , Ptera.TokensMember Tokens t
    ) => RuleSymbolAction t where

    ruleSymbolActionM :: proxy t
        -> Spanned.Spanned Token.LexToken -> ActionTask (RuleSymbolReturnType t)

tokVarA :: forall t. RuleSymbolAction t => TypedExpr '[(), RuleSymbolReturnType t]
tokVarA = varA @"skip" <^> varA @(RuleSymbol t)

type instance RuleSymbol "(" = "tok_open_paren_without_skip"
instance RuleSymbolAction "(" where
    ruleSymbolActionM _ t = do
        pushLayoutItem NoLayout
        pure do AstParsed.sp t

type instance RuleSymbol "{" = "tok_open_brace_without_skip"
instance RuleSymbolAction "{" where
    ruleSymbolActionM _ t = do
        pushLayoutItem NoLayout
        pure do AstParsed.sp t

type instance RuleSymbol "[" = "tok_open_brack_without_skip"
instance RuleSymbolAction "[" where
    ruleSymbolActionM _ t = do
        pushLayoutItem NoLayout
        pure do AstParsed.sp t

type instance RuleSymbol "interp_string_start" = "tok_interp_string_start_without_skip"
instance RuleSymbolAction "interp_string_start" where
    ruleSymbolActionM _ t = do
        pushLayoutItem NoLayout
        pure do interpStringLit t

type instance RuleSymbol ")" = "tok_close_paren_without_skip"
instance RuleSymbolAction ")" where
    ruleSymbolActionM _ t = do
        popNoLayout
        pure do AstParsed.sp t

type instance RuleSymbol "}" = "tok_close_brace_without_skip"
instance RuleSymbolAction "}" where
    ruleSymbolActionM _ t = do
        popNoLayout
        pure do AstParsed.sp t

type instance RuleSymbol "]" = "tok_close_brack_without_skip"
instance RuleSymbolAction "]" where
    ruleSymbolActionM _ t = do
        popNoLayout
        pure do AstParsed.sp t

type instance RuleSymbol "interp_string_end" = "tok_interp_string_end_without_skip"
instance RuleSymbolAction "interp_string_end" where
    ruleSymbolActionM _ t = do
        popNoLayout
        pure do interpStringLit t

type instance RuleSymbol "interp_string_cont" = "tok_interp_string_cont_without_skip"
instance RuleSymbolAction "interp_string_cont" where
    ruleSymbolActionM _ t = do
        popNoLayout
        pushLayoutItem NoLayout
        pure do interpStringLit t

type instance RuleSymbol "{{" = "tok_open_dbrace_without_skip"
instance RuleSymbolAction "{{" where
    ruleSymbolActionM _ t = do
        let pos = Layout.PositionByCol do
                Spanned.locCol do Spanned.beginLoc do Spanned.getSpan t
        pushLayoutItem do ExplicitScopedLayout pos
        pure do AstParsed.sp t

type instance RuleSymbol "}}" = "tok_close_dbrace_without_skip"
instance RuleSymbolAction "}}" where
    ruleSymbolActionM _ t = do
        popExplicitScopedLayout
        pure do AstParsed.sp t


pushLayoutItem :: LayoutItem -> ActionTask ()
pushLayoutItem item = Ptera.modifyAction \ctx -> ctx
    { layoutStack = item:layoutStack ctx
    }

popLayoutItem :: ActionTask ()
popLayoutItem = Ptera.modifyAction \ctx -> ctx
    { layoutStack = List.tail do layoutStack ctx
    }

popNoLayout :: ActionTask ()
popNoLayout = do
    layoutStack <$> Ptera.getAction >>= \case
        NoLayout:_ ->
            pure ()
        _ ->
            Ptera.failAction
    popLayoutItem

popExplicitScopedLayout :: ActionTask ()
popExplicitScopedLayout = do
    layoutStack <$> Ptera.getAction >>= \case
        ExplicitScopedLayout{}:_ ->
            pure ()
        _ ->
            Ptera.failAction
    popLayoutItem


interpStringLit :: Spanned.Spanned Token.LexToken -> Ast.InterpStringPart AstParsed.T
interpStringLit t = case Spanned.unSpanned t of
    Token.LitInterpStringWithoutInterp txt ->
        Ast.InterpStringLit txt do
            AstParsed.sp t
    Token.LitInterpStringStart txt ->
        Ast.InterpStringLit txt do
            AstParsed.sp t
    Token.LitInterpStringContinue txt ->
        Ast.InterpStringLit txt do
            AstParsed.sp t
    Token.LitInterpStringEnd txt ->
        Ast.InterpStringLit txt do
            AstParsed.sp t
    _ ->
        error "unreachable: expected interp string literal token, but actually the other token is given"

interpStringExpr :: Ast.Expr AstParsed.T -> Ast.InterpStringPart AstParsed.T
interpStringExpr e = Ast.InterpStringExpr e do AstParsed.sp e