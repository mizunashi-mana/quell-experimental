Syntax
======

Notational Conventions
----------------------

.. glossary::

    ``( pattern )``
        grouping

    ``pattern?``
        greedy optional

    ``pattern*``
        greedy zero or more repetitions

    ``pattern+``
        greedy one or more repetitions

    ``pattern / pattern``
        ordered choice

    ``! pattern``
        not predicate (not consuming input)

    ``"..."``
        terminal by unicode properties

    ``'...'``
        virtual layout terminal (See `Layout`_)

    ``EOS``
        end of source

.. productionlist::
    A   : B1
        : ...
        : BN

is equal

.. productionlist::
    A   : B1 / ... / BN

Lexical Syntax
--------------

.. productionlist::
    lexical_program: (lexeme / whitespace)* EOS?
    lexeme  : literal
            : interp_string_part
            : special
            : brace
            : reserved_id
            : reserved_sym
            : var_id
            : var_sym
            : con_id
            : con_sym

.. productionlist::
    var_id: small id_char*
    con_id: large id_char*
    var_sym: (! ":") symbol sym_char*
    con_sym: ":" sym_char*

.. productionlist::
    reserved_id : reserved_id_unit ! id_char
    reserved_id_unit    : "#as"
                        : "#case"
                        : "#data"
                        : "#derive"
                        : "#do"
                        : "#export"
                        : "#family"
                        : "#foreign"
                        : "#impl"
                        : "#infix"
                        : "#letrec"
                        : "#let"
                        : "#match"
                        : "#mod"
                        : "#newtype"
                        : "#pattern"
                        : "#record"
                        : "#role"
                        : "#sig"
                        : "#static"
                        : "#trait"
                        : "#type"
                        : "#use"
                        : "#with"
                        : "#when"
                        : "#where"
                        : "#yield"
                        : "#Default"
                        : "#Self"
                        : '_'
    reserved_sym    : reserved_sym_unit ! sym_char
    reserved_sym_unit   : "!"
                        : "="
                        : "?"
                        : "@"
                        : "^" / "???"
                        : "\\" / "??"
                        : "|"
                        : "~"
                        : ":"
                        : "##" / "???"
                        : "#@" / "???"
                        : "#>" / "???"
                        : "#<" / "???"
                        : "#=>"
                        : "#->"
    special : "("
            : ")"
            : ","
            : "["
            : "]"
            : "`"
            : ";"
            : ".." / "???"
            : "."
    brace   : "{{" / "}}" / "???" / "???"
            : "{" / "}"

.. productionlist::
    literal : rational
            : integer
            : bytestring
            : string
            : bytechar
            : char

.. productionlist::
    rational: sign? decimal "." decimal exponent?
            : sign? decimal exponent
    integer : sign? zero ("b" / "B") bit (bit / "_")*
            : sign? zero ("o" / "O") octit (octit / "_")*
            : sign? zero ("x" / "X") hexit (hexit / "_")*
            : sign? (! zero) decimal
    decimal: digit (digit / "_")*
    sign: "+"
        : "-"
    zero: "0"
    exponent: ("e" / "E") sign? decimal
    bit: "0" / "1"
    octit: "0" / "1" / ... / "7"
    hexit   : digit
            : "A" / "B" / ... / "F"
            : "a" / "b" / ... / "f"

.. productionlist::
    bytestring: "#r" str_sep bstr_graphic* str_sep
    string: str_sep (bstr_graphic / uni_escape)* str_sep
    bytechar: "#r" char_sep bchar_graphic char_sep
    char: char_sep (bchar_graphic / uni_escape) char_sep
    str_sep: "\""
    char_sep: "'"
    escape_open: "\\"
    bstr_graphic: byte_escape
                : gap
                : whitechar
                : ! (str_sep / escape_open) graphic
    bchar_graphic   : byte_escape
                    : " "
                    : ! (char_sep / escape_open) graphic
    byte_escape: escape_open (charesc / asciiesc / byteesc)
    uni_escape: escape_open "u{" hexit+ "}"
    gap: escape_open "|" whitechar* "|"
    charesc : "0" / "a" / "b" / "f" / "n" / "r" / "t" / "v"
            : "$" / escape_open / str_sep / char_sep
    asciiesc: "^" cntrlesc
            : "NUL" / "SOH" / "STX" / "ETX" / "EOT" / "ENQ"
            : "ACK" / "BEL" / "BS" / "HT" / "LF" / "VT"
            : "FF" / "CR" / "SO" / "SI" / "DLE" / "DC1"
            : "DC2" / "DC3" / "DC4" / "NAK" / "SYN" / "ETB"
            : "CAN" / "EM" / "SUB" / "ESC" / "FS" / "GS"
            : "RS" / "US" / "SP" / "DEL"
    cntrlesc: "A" / "B" / ... / "Z" / "@" / "[" / "\\" / "]"
            : "^" / "_"
    byteesc: "x" hexit hexit

.. productionlist::
    interp_string_part  : interp_string_without_interp
                        : interp_string_start
                        : interp_string_cont
                        : interp_string_end
    interp_str_open: "#s" str_sep
    interp_str_graphic  : ! ("$" / str_sep / escape_open) bstr_graphic
                        : uni_escape
    interp_open: "$" ( "{#" / "???" )
    interp_close: "#}" / "???"
    interp_string_without_interp: interp_str_open interp_str_graphic* str_sep
    interp_string_start: interp_str_open interp_str_graphic* interp_open
    interp_string_cont: interp_close interp_str_graphic* interp_open
    interp_string_end: interp_close interp_str_graphic* str_sep

.. productionlist::
    whitespace: whitestuff+
    whitestuff  : whitechar
                : comment

.. productionlist::
    comment : line_comment
            : doc_comment
            : pragma_comment
            : multiline_comment
    line_comment: "--" "-"* (! sym_char any+)? (newline / EOS)
    multiline_comment: comment_open (! ("!" / "#")) ANYs (nested_comment ANYs)* comment_close
    doc_comment: comment_open "!" ((! newline "|" comment_close) ANY)* newline "|" comment_close
    pragma_comment: comment_open "#" ANYs (nested_comment ANYs)* "#" comment_close
    nested_comment: comment_open ANYs (nested_comment ANYs)* comment_close
    comment_open: "{-"
    comment_close: "-}"
    any: graphic / space
    ANYs: ((! (comment_open / comment_close)) ANY)*
    ANY: graphic / whitechar

.. productionlist::
    graphic : small
            : large
            : symbol
            : digit
            : other
            : special
            : other_special
            : other_graphic
    id_char : small
            : large
            : digit
            : other
    sym_char    : symbol
                : other
    whitechar  : "\v"
                : space
                : newline
    space   : "\t" / "\u200E" / "\u200F"
            : "\p{General_Category=Space_Separator}"
    newline : "\r\n" / "\r" / "\n" / "\f"
            : "\p{General_Category=Line_Separator}"
            : "\p{General_Category=Paragraph_Separator}"
    small   : "\p{General_Category=Lowercase_Letter}"
            : "\p{General_Category=Other_Letter}"
            : "_"
    large   : "\p{General_Category=Uppercase_Letter}"
            : "\p{General_Category=Titlecase_Letter}"
    symbol  : (! (special / other_special / "_" / "'")) symbol_category
    symbol_category : "\p{General_Category=Connector_Punctuation}"
                    : "\p{General_Category=Dash_Punctuation}"
                    : "\p{General_Category=Other_Punctuation}"
                    : "\p{General_Category=Symbol}"
    digit   : "\p{General_Category=Decimal_Number}"
    other   : ! whitechar other_category
    other_category  : "\p{General_Category=Modifier_Letter}"
                    : "\p{General_Category=Mark}"
                    : "\p{General_Category=Letter_Number}"
                    : "\p{General_Category=Other_Number}"
                    : "\p{General_Category=Format}"
                    : "'"
    other_special: "#" / "\"" / "{" / "}" / "???" / "???" / "???" / "???"
    other_graphic: (! (symbol_category / special / other_special)) other_graphic_category
    other_graphic_category: "\p{General_Category=Punctuation}"

Specifications for Lexical Nonterminals
:::::::::::::::::::::::::::::::::::::::

These nonterminals must be disjoint:

* ``whitespace``
* ``! ('_' ! sym_char) var_id``
* ``! reserved_sym var_sym``
* ``con_id``
* ``! reserved_sym con_sym``
* ``reserved_sym``
* ``reserved_id``
* ``special``
* ``brace``
* ``literal``

These nonterminals must be disjoint:

* ``whitechar``
* ``small``
* ``large``
* ``symbol``
* ``digit``
* ``other``
* ``special``
* ``other_special``
* ``other_graphic``

These nonterminals must be disjoint:

* ``space``
* ``newline``

These expressions must be empty:

* ``(! ANY+) (lexeme / whitespace)``
* ``(! ('_' / '#' id_char*)) reserved_id``
* ``(! (('#' / symbol) sym_char*)) reserved_sym``
* ``(! other_special*) brace``
* ``(! ("+" / "-" / digit / "'" / other_special)) literal``
* ``(! comment_open) (multiline_comment / doc_comment / pragma_comment / nested_comment)``
* ``(! comment_open ANY* comment_close) (multiline_comment / doc_comment / pragma_comment / nested_comment)``
* ``(! nested_comment) (multiline_comment / pragma_comment)``
* ``(! (graphic / whitechar)) ("\p{General_Category=Letter}" / "\p{General_Category=Mark}" / "\p{General_Category=Number}" / "\p{General_Category=Punctuation}" / "\p{General_Category=Symbol}" / "\p{General_Category=Separator}" / "\p{General_Category=Format}")``

Aliases
-------

.. productionlist::
    ".."    : ".." / "???"
    "#<"    : "#<" / "???"
    "#>"    : "#>" / "???"
    "^"     : "^" / "???"
    "\\"    : "\\" / "??"
    "{{"    : "{{" / "???"
    "}}"    : "}}" / "???"
    "##"    : "##" / "???"
    "#@"    : "#@" / "???"

Grammar
-------

TODO: module support

.. productionlist::
    program: decl_body

.. productionlist::
    decl_body   : "{{" decl_items "}}"
                : "{" decl_items "}"
                : '{' decl_items '}'
    decl_items  : lsemis? (decl_item lsemis)* decl_item?
    decl_item   : type_decl
                : data_decl
                : val_decl
                : sig_item

.. productionlist::
    typesig_decl: "#type" declcon ":" type
    valsig_decl: declvar ":" type
    consig_decl: declcon ":" type

.. productionlist::
    type_decl: "#type" decltype "=" type ("where" type_decl_where_body)?
    type_decl_where_body: "{{" type_decl_where_items "}}"
                        : "{" type_decl_where_items "}"
                        : '{' type_decl_where_items '}'
    type_decl_where_items: lsemis? (type_decl_where_item lsemis)* type_decl_where_item?
    type_decl_where_item: type_decl
                        : typesig_decl

.. productionlist::
    data_decl   : "#data" decltype ("=" alg_data_type)? ("#where" type_decl_where_body)?
                : "#data" declcon (":" type)? ("#where" data_decl_body)?
                : "#newtype" decltype "=" type ("#where" type_decl_where_body)?
    data_decl_body  : "{{" data_decl_items "}}"
                    : "{" data_decl_items "}"
                    : '{' data_decl_items '}'
    data_decl_items: lsemis? (data_decl_item lsemis)* data_decl_item?
    data_decl_item  : type_decl
                    : typesig_decl
                    : consig_decl
    alg_data_type   : "(" alg_data_type_items ")"
                    : alg_data_type_items
    alg_data_type_items : "|"? (contype "|")* contype?

.. productionlist::
    val_decl: declvarexpr "=" expr ("#where" val_decl_where_body)?
    val_bind: pat "=" expr ("#where" val_decl_where_body)?
    val_decl_where_body : "{{" val_decl_where_items "}}"
                        : "{" val_decl_where_items "}"
                        : '{' val_decl_where_items '}'
    val_decl_where_items: lsemis? (val_decl_where_item lsemis)* val_decl_where_item?
    val_decl_where_item: let_bind_item

.. productionlist::
    decltype    : actual_bind_var declconop actual_bind_var (":" type)?
                : declcon bind_var* (":" type)?
    contype     : type_qualified conop_qualified type_qualified
                : con_qualified type_app*
    declvarexpr : actual_bind_var declop actual_bind_var (":" type)?
                : declvar bind_var* (":" type)?

.. productionlist::
    type: (type_apps type_op)* type_apps
    type_op : "`" type_op_block "`"
            : type_op_sym_qualified
    type_op_block   : type_op_sym_qualified
                    : type_apps
    type_op_sym_qualified   : sym
    type_apps: type_qualified type_app*
    type_app: "@" type_qualified
            : "#@" type_block_body
            : type_qualified
    type_qualified: type_block
    type_block  : "^" bind_var* "#>" type
                : "##" type_block_body
                : type_atomic
    type_atomic : "(" type (":" type)? ")"
                : type_literal
                : con
                : var
    type_literal: literal
                : "(" type_tuple_items ")"
                : "[" type_array_items "]"
                : "{" type_simplrecord_items "}"
    type_block_body : "{{" type_block_item "}}"
                    : "{" type_block_item "}"
                    : '{' type_block_item '}'
    type_block_item   : lsemis? type lsemis?
    type_tuple_items: ","? (type ",")+ type ","?
    type_array_items: ","? (type ",")* type?
    type_simplrecord_items: ","? (type_simplrecord_item ",")* type_simplrecord_item?
    type_simplrecord_item: declvar ":" type

.. productionlist::
    sig_item: typesig_decl
            : valsig_decl
            : consig_decl

.. productionlist::
    expr: expr_infix ":" type
        : expr_infix
    expr_infix: (expr_apps expr_op)* expr_apps
    expr_op : "`" expr_op_block "`"
            : expr_op_sym_qualified
    expr_op_block   : expr_op_sym_qualified
                    : expr_apps
    expr_op_sym_qualified : sym
    expr_apps: expr_qualified expr_app*
    expr_app: "@" type_qualified
            : "#@" type_block_body
            : expr_qualified
    expr_qualified: expr_block
    expr_block  : "\\" pat_atomic* guarded_alts
                : "#case" case_alt_body
                : "#letrec" let_binds "#in" expr
                : "#let" let_binds "#in" expr
                : "#match" expr_match_items "#with" case_alt_body
                : "#do" do_body
                : "##" expr_block_body
                : expr_atomic
    expr_atomic : "(" expr ")"
                : expr_literal
                : con
                : var
    expr_literal: literal
                : expr_interp_string
                : "(" expr_tuple_items ")"
                : "[" expr_array_items "]"
                : "{" expr_simplrecord_items "}"
    expr_block_body : "{{" expr_block_item "}}"
                    : "{" expr_block_item "}"
                    : '{' expr_block_item '}'
    expr_block_item   : lsemis? expr lsemis?
    expr_interp_string  : interp_string_without_interp
                        : interp_string_start expr (interp_string_cont expr)* interp_string_end
    expr_match_items: ","? (expr ",")* expr?
    expr_tuple_items: ","? (expr ",")+ expr ","?
    expr_array_items: ","? (expr ",")* expr?
    expr_simplrecord_items: ","? (expr_simplrecord_item ",")* expr_simplrecord_item?
    expr_simplrecord_item: declvar "=" expr

.. productionlist::
    pat : pat_unit ":" type
        : pat_unit
    pat_unit: "|"? (pat_infix "|")* pat_infix "|"?
    pat_infix: (pat_apps pat_op)* pat_apps
    pat_op  : "`" pat_op_block "`"
            : pat_op_sym_qualified
    pat_op_block    : pat_op_sym_qualified
                    : con_qualified pat_app*
    pat_op_sym_qualified : con_sym_ext
    pat_apps: con_qualified pat_app*
            : pat_qualified pat_univ_app*
    pat_app : pat_univ_app
            : pat_qualified
    pat_univ_app    : "@" type_qualified
                    : "#@" type_block_body
    pat_qualified: pat_block
    pat_block   : "##" pat_block_body
                : pat_atomic
    pat_atomic  : "(" pat ")"
                : pat_literal
                : con
                : var
    pat_literal : literal
                : "(" pat_tuple_items ")"
                : "[" pat_array_items "]"
                : "{" pat_simplrecord_items "}"
    pat_block_body  : "{" pat_block_items "}"
                    : "{{" pat_block_items "}}"
                    : '{' pat_block_items '}'
    pat_block_items : lsemis? pat lsemis?
    pat_tuple_items: ","? (pat ",")+ pat ","?
    pat_array_items: ","? (pat ",")* pat?
    pat_simplrecord_items: ","? (pat_simplrecord_item ",")* pat_simplrecord_item?
    pat_simplrecord_item: declvar "=" pat

.. productionlist::
    let_binds   : "{{" let_bind_items "}}"
                : "{" let_bind_items "}"
                : '{' let_bind_items '}'
    let_bind_items: lsemis? (let_bind_item lsemis)* let_bind_item?
    let_bind_item   : type_decl
                    : data_decl
                    : val_bind
                    : sig_item

.. productionlist::
    case_alt_body   : "{{" case_alt_items "}}"
                    : "{" case_alt_items "}"
                    : '{' case_alt_items '}'
    case_alt_items: lsemis? (case_alt_item lsemis)* case_alt_item?
    case_alt_item: ","? (pat ",")* pat? guarded_alts
    guarded_alts: "#>" expr
                : "#when" guarded_alt_body
    guarded_alt_body: "{{" guarded_alt_items "}}"
                    : "{" guarded_alt_items "}"
                    : '{' guarded_alt_items '}'
    guarded_alt_items: lsemis? (guarded_alt_item lsemis)* guarded_alt_item?
    guarded_alt_item: guard_qual "#>" expr
    guard_qual: expr

.. productionlist::
    do_body : "{{" do_stmt_items "}}"
            : "{" do_stmt_items "}"
            : '{' do_stmt_items '}'
    do_stmt_items   : lsemis? (do_stmt_item lsemis)* do_yield_item lsemis?
    do_stmt_item    : "#letrec" let_binds
                    : pat "#<" expr ("#where" val_decl_where_body)?
                    : pat "=" expr ("#where" val_decl_where_body)?
    do_yield_item   : "#yield" expr

.. productionlist::
    bind_var: "#@" block_bind_var
            : "@" simple_bind_var
            : actual_bind_var
    actual_bind_var : "##" block_bind_var
                    : simple_bind_var
    simple_bind_var : "(" block_bind_var_item ")"
                    : var_id_ext
    block_bind_var  : "{{" block_bind_var_items "}}"
                    : "{" block_bind_var_items "}"
                    : '{' block_bind_var_items '}'
    block_bind_var_items: lsemis? block_bind_var_item lsemis?
    block_bind_var_item : var_id_ext (":" type)?
    sym : var_sym_ext
        : con_sym_ext
    con_qualified : con
    conop_qualified : conop
    con : "(" con_sym_ext ")"
        : "(" con_id_ext ")"
        : con_id_ext
    conop   : "`" con_sym_ext "`"
            : "`" con_id_ext "`"
            : con_sym_ext
    var : "(" var_sym_ext ")"
        : var_id_ext
    con_id_ext  : "(" ")"
                : con_id
    con_sym_ext : "#->"
                : "#=>"
                : con_sym
    var_id_ext  : "_"
                : var_id
    var_sym_ext : var_sym

.. productionlist::
    declcon : "(" con_sym ")"
            : "(" con_id ")"
            : con_id
    declconop   : "`" con_sym "`"
                : "`" con_id "`"
                : con_sym
    declvar : "(" var_sym ")"
            : "(" var_id ")"
            : var_id
    declop  : "`" var_sym "`"
            : "`" var_id "`"
            : var_sym

.. productionlist::
    lsemis: (';' / ";")+

Layout
-------

.. code-block:: haskell

    preParse = go1 True 1 where
        go1 expBrace l0 ts0 = case ts0 of
            []
                | expBrace ->
                    {0}:[]
                | otherwise ->
                    []
            ((l1,c1),(l2,c2),t):ts1
                | isWhiteSpace t ->
                    go1 expBrace l0 ts1
                | isExplicitOpenBrace t ->
                    go2 c1 l2 t ts1
                | expBrace ->
                    {c1}:<c1>:go2 c1 l2 t ts1
                | l0 < l1 ->
                    <c1>:go2 c1 l2 t ts1
                | otherwise ->
                    go2 c1 l2 t ts1

        go2 c1 l2 t ts = if
            | isLayoutKeyword t ->
                (c1,t):go1 True l2 ts
            | otherwise ->
                (c1,t):go1 False l2 ts

    isWhiteSpace t =
        t match whitespace

    isLayoutKeyword t = case t of
        "#case"     -> True
        "#let"      -> True
        "#letrec"   -> True
        "#with"     -> True
        "#when"     -> True
        "#where"    -> True
        "##"        -> True
        "#@"        -> True
        _           -> False

    isExplicitOpenBrace t = case t of
        "{{"        -> True
        "{"         -> True
        _           -> False

.. code-block:: haskell

    parseWithoutL p ts = case ts of
        [] ->
            ParseOk p
        {n}:ts ->
            parseWithoutL p ts
        <n>:ts ->
            parseWithoutL p ts
        (_,t):ts -> p t \r -> case r of
            ParseOk p ->
                parseWithoutL p ts
            ParseError ->
                ParseError

.. code-block:: haskell

    parseWithL p ts = withL p ts []

    withL p ms ts = case ts of
        [] ->
            tryEnd p ms
        {n}:ts ->
            resolveImpBo p ms n ts
        <n>:ts ->
            resolveNewline p ms n ts
        (n,t):ts ->
            resolveToken p ms n t ts

    resolveImpBo p ms n ts = p "{" \r -> case r of
        ParseOk p -> case ms of
            [] ->
                withL p (<n,"{">:ms) ts
            <m,"{">:_
                | m < n ->
                    withL p (<n,"{">:ms) ts
                | otherwise ->
                    withL p (<n+1,"{">:ms) ts
            <m,"{{">:_
                | m < n ->
                    withL p (<n,"{">:ms) ts
                | otherwise ->
                    withL p (<n+1,"{">:ms) ts
            <>:_ ->
                withL p (<n,"{">:ms) ts
        ParseError ->
            parseError p ms ({n}:ts)

    resolveNewline p ms n ts = case ms of
        [] ->
            withL p ms ts
        <m,"{">:ms1
            | m == n -> p ";" \r -> case r of
                ParseOk p ->
                    withL p ms ts
                ParseError ->
                    parseError p ms (<n>:ts)
            | m < n ->
                withL p ms ts
            | m > n -> p "}" \r -> case r of
                ParseOk p ->
                    withL p ms1 (<n>:ts)
                ParseError ->
                    parseError p ms (<n>:ts)
        <m,"{{">:_
            | m == n -> p ";" \r -> case r of
                ParseOk p ->
                    withL p ms ts
                ParseError ->
                    parseError p ms (<n>:ts)
            | m < n ->
                withL p ms ts
            | m > n ->
                parseError p ms (<n>:ts)
        <>:_ ->
            withL p ms ts

    resolveToken p ms n t ts
        | t match "{{" = p t \r -> case r of
            ParseOk p ->
                withL p (<n,"{{">:ms) ts
            ParseError ->
                parseError p ms ((n,t):ts)
        | t match "}}" = case ms of
            <m,"{{">:ms1 -> p t \r -> case r of
                ParseOk p ->
                    withL p ms1 ts
                ParseError ->
                    parseError p ms ((n,t):ts)
            _ ->
                parseError p ms ((n,t):ts)
        | isNoLayoutClose t = case ms of
            <>:ms1 -> p t \r -> case r of
                ParseOk p
                    | isNoLayoutOpen t ->
                        withL p (<>:ms1) ts
                    | otherwise ->
                        withL p ms1 ts
                ParseError ->
                    parseError p ms ((n,t):ts)
            _ ->
                parseError p ms ((n,t):ts)
        | isNoLayoutOpen t = p t \r -> case r of
            ParseOk p ->
                withL p (<>:ms) ts
            ParseError ->
                parseError p ms ((n,t):ts)
        | otherwise = p t \r -> case r of
            ParseOk p ->
                withL p ms ts
            ParseError ->
                parseError p ms ts

    tryEnd p ms = case ms of
        [] ->
            ParseOk p
        <_,"{">:ms -> p "}" \r -> case r of
            ParseOk p ->
                tryEnd p ms
            ParseError ->
                ParseError
        <_,"{{">:_ ->
            ParseError
        <>:_ ->
            ParseError

    parseError p ms ts = case ms of
        <_,"{">:ms -> p "}" \r -> case r of
            ParseOk p ->
                withL p ms ts
            ParseError ->
                ParseError
        _:_ ->
            ParseError
        [] ->
            ParseError

    isNoLayoutOpen t
        | t match "{"   = True
        | t match "("   = True
        | t match "["   = True
        | t match interp_string_start
                        = True
        | t match interp_string_cont
                        = True
        | otherwise     = False

    isNoLayoutClose t
        | t match "}"   = True
        | t match ")"   = True
        | t match "]"   = True
        | t match interp_string_end
                        = True
        | t match interp_string_cont
                        = True
        | otherwise     = False

Fixity Resolution
-----------------

Reference
---------

* `Parsing Expression Grammars: A Recognition-Based Syntactic Foundation <https://bford.info/pub/lang/peg/>`_
* `Unicode Identifier and Pattern Syntax <https://unicode.org/reports/tr31/>`_
* `Unicode Character Database - 5.7.1 General Category Values <http://www.unicode.org/reports/tr44/#General_Category_Values>`_
