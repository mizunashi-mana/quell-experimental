module Language.Quell.Parsing.Parser.AstParsed (
    SpannedBuilder (..),
    AstParsed,
) where

import Language.Quell.Prelude

import qualified Language.Quell.Parsing.Spanned         as Spanned
import qualified Language.Quell.Type.Ast                as Ast


class SpannedBuilder s where
    sp :: s -> Spanned.Span

    spn :: s -> a -> Spanned.Spanned a
    spn s x = Spanned.Spanned
        {
            getSpan = sp s,
            unSpanned = x
        }

    spAnn :: s -> (Spanned.Span -> a) -> a
    spAnn s f = f do sp s

instance SpannedBuilder Spanned.Span where
    sp s = s

instance SpannedBuilder (Spanned.Spanned a) where
    sp sx = Spanned.getSpan sx

instance SpannedBuilder (Ast.TypeExpr AstParsed) where
    sp = \case
        Ast.TypeForall _ _ x -> x
        Ast.TypeInfix _ _ _ x -> x
        Ast.TypeApp _ _ x -> x
        Ast.TypeSig _ _ x -> x
        Ast.TypeCon _ x -> x
        Ast.TypeVar _ x -> x
        Ast.TypeLit _ x -> x
        Ast.TypeTuple _ x -> x
        Ast.TypeArray _ x -> x
        Ast.TypeRecord _ x -> x
        Ast.TypeAnn _ x -> x

instance (SpannedBuilder s1, SpannedBuilder s2) => SpannedBuilder (s1, s2) where
    sp (s1, s2) = sp s1 <> sp s2

instance (SpannedBuilder s1, SpannedBuilder s2, SpannedBuilder s3)
        => SpannedBuilder (s1, s2, s3) where
    sp (s1, s2, s3) = sp s1 <> sp s2 <> sp s3

instance (SpannedBuilder s1, SpannedBuilder s2, SpannedBuilder s3, SpannedBuilder s4)
        => SpannedBuilder (s1, s2, s3, s4) where
    sp (s1, s2, s3, s4) = sp s1 <> sp s2 <> sp s3 <> sp s4

instance (
            SpannedBuilder s1,
            SpannedBuilder s2,
            SpannedBuilder s3,
            SpannedBuilder s4,
            SpannedBuilder s5
        ) => SpannedBuilder (s1, s2, s3, s4, s5) where
    sp (s1, s2, s3, s4, s5) = sp s1 <> sp s2 <> sp s3 <> sp s4 <> sp s5


data AstParsed

type instance Ast.XAppExpr AstParsed = Spanned.Span
type instance Ast.XUnivAppExpr AstParsed = Spanned.Span
type instance Ast.XBindVar AstParsed = Spanned.Span
type instance Ast.XUnivBindVar AstParsed = Spanned.Span
type instance Ast.XLitRational AstParsed = Spanned.Span
type instance Ast.XLitInteger AstParsed = Spanned.Span
type instance Ast.XLitByteString AstParsed = Spanned.Span
type instance Ast.XLitString AstParsed = Spanned.Span
type instance Ast.XLitByteChar AstParsed = Spanned.Span
type instance Ast.XLitChar AstParsed = Spanned.Span
type instance Ast.XLitInterpString AstParsed = Spanned.Span
type instance Ast.XTypeForall AstParsed = Spanned.Span
type instance Ast.XTypeInfix AstParsed = Spanned.Span
type instance Ast.XTypeApp AstParsed = Spanned.Span
type instance Ast.XTypeSig AstParsed = Spanned.Span
type instance Ast.XTypeCon AstParsed = Spanned.Span
type instance Ast.XTypeVar AstParsed = Spanned.Span
type instance Ast.XTypeLit AstParsed = Spanned.Span
type instance Ast.XTypeTuple AstParsed = Spanned.Span
type instance Ast.XTypeArray AstParsed = Spanned.Span
type instance Ast.XTypeRecord AstParsed = Spanned.Span
type instance Ast.XTypeAnn AstParsed = Spanned.Span

instance Ast.XEq AstParsed
instance Ast.XShow AstParsed