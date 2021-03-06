Evaluate Semantics
==================

Desugaring
----------

Do Block
::::::::

.. code-block:: none

    do { e }                = e
    do { e ; stmts }        = e >> do { stmts }
    do { p <- e ; stmts }   = e >>= \p -> do { stmts }
    do { let decls; stmts } = let decls in do { stmts }

Integer Literal
:::::::::::::::

.. code-block:: none

    fromIntegerLiteral :: IntegerLiteral -> a

Primitive:

.. code-block:: none

    Integer.fromIntegerLiteral :: IntegerLiteral -> Integer
    Int.fromIntegerLiteral :: IntegerLiteral -> Int
    Word.fromIntegerLiteral :: IntegerLiteral -> Word
    Byte.fromIntegerLiteral :: IntegerLiteral -> Byte
    Int8.fromIntegerLiteral :: IntegerLiteral -> Int8
    Int16.fromIntegerLiteral :: IntegerLiteral -> Int16
    Int32.fromIntegerLiteral :: IntegerLiteral -> Int32
    Int64.fromIntegerLiteral :: IntegerLiteral -> Int64
    Word8.fromIntegerLiteral :: IntegerLiteral -> Word8
    Word16.fromIntegerLiteral :: IntegerLiteral -> Word16
    Word32.fromIntegerLiteral :: IntegerLiteral -> Word32
    Word64.fromIntegerLiteral :: IntegerLiteral -> Word64
    Rational.fromIntegerLiteral :: IntegerLiteral -> Rational
    Float.fromIntegerLiteral :: IntegerLiteral -> Float
    Double.fromIntegerLiteral :: IntegerLiteral -> Double

.. code-block:: none

    Int8.1 == Int8.(fromIntegerLiteral ...) -- 1 of Int8
