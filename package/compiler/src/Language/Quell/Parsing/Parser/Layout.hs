{-# LANGUAGE TemplateHaskell #-}

module Language.Quell.Parsing.Parser.Layout (
    TokenWithL (..),
    preParseForProgram,
    preParseForPart,
    preParse,

    Position (..),
    nextPosition,

    isLayoutKeyword,
    isExplicitOpenBrace,
) where

import           Language.Quell.Prelude

import qualified Conduit
import qualified Language.Parser.Ptera.TH.Class.LiftType as LiftType
import qualified Language.Quell.Parsing.Spanned          as Spanned
import qualified Language.Quell.Type.Token               as Token


data TokenWithL
    = Token (Spanned.T Token.LexToken)
    | ExpectNewImplicitLayout Position
    | Newline Position
    deriving (Eq, Show)

instance LiftType.LiftType TokenWithL where
    liftType _ = [t|TokenWithL|]

data Position
    = PositionByCol Int
    | PositionEos
    deriving (Eq, Show)

instance Ord Position where
    compare p1 p2 = case p1 of
        PositionByCol i1 -> case p2 of
            PositionByCol i2 ->
                compare i1 i2
            PositionEos ->
                GT
        PositionEos -> case p2 of
            PositionByCol{} ->
                LT
            PositionEos ->
                EQ

nextPosition :: Position -> Position
nextPosition = \case
    PositionByCol i ->
        PositionByCol do i + 1
    PositionEos ->
        PositionEos

type WithLConduit = Conduit.ConduitT (Spanned.T Token.LexToken) TokenWithL

preParseForProgram :: Monad m => WithLConduit m ()
preParseForProgram = preParse True do Spanned.locLine Spanned.initialLoc

preParseForPart :: Monad m => WithLConduit m ()
preParseForPart = preParse False do Spanned.locLine Spanned.initialLoc

preParse :: Monad m => Bool -> Int -> WithLConduit m ()
preParse = go1 where
    go1 expBrace l0 = Conduit.await >>= \case
        Nothing
            | expBrace -> do
                Conduit.yield do ExpectNewImplicitLayout PositionEos
                Conduit.yield do Newline PositionEos
                pure ()
            | otherwise ->
                pure ()
        Just tok -> do
            let loc1 = Spanned.beginLoc do Spanned.getSpan tok
            if
                | isExplicitOpenBrace do Spanned.unSpanned tok -> do
                    go2 tok
                | expBrace -> do
                    let pos = PositionByCol do Spanned.locCol loc1
                    Conduit.yield do ExpectNewImplicitLayout pos
                    Conduit.yield do Newline pos
                    go2 tok
                | l0 < Spanned.locLine loc1 -> do
                    let pos = PositionByCol do Spanned.locCol loc1
                    Conduit.yield do Newline pos
                    go2 tok
                | otherwise -> do
                    go2 tok

    go2 tok = do
        Conduit.yield do Token tok
        go1
            do isLayoutKeyword do Spanned.unSpanned tok
            do Spanned.locLine do Spanned.endLoc do Spanned.getSpan tok

isLayoutKeyword :: Token.LexToken -> Bool
isLayoutKeyword = \case
    Token.KwCase       -> True
    Token.KwLet        -> True
    Token.KwLetrec     -> True
    Token.KwWith       -> True
    Token.KwWhen       -> True
    Token.KwWhere      -> True
    Token.SymBlock     -> True
    Token.SymTypeBlock -> True
    _                  -> False

isExplicitOpenBrace :: Token.LexToken -> Bool
isExplicitOpenBrace = \case
    Token.SpBraceOpen  -> True
    Token.SpDBraceOpen -> True
    _                  -> False
