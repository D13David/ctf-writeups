[Code]
    File Name: chal.py
    Object Name: <module>
    Qualified Name: <module>
    Arg Count: 0
    Pos Only Arg Count: 0
    KW Only Arg Count: 0
    Stack Size: 3
    Flags: 0x00000000
    [Names]
        'codecs'
        'base64'
        'sys'
        'KSA'
        'PRGA'
        'encrypt'
        'input'
        'flag'
        'enc_flag'
        'print'
    [Locals+Names]
    [Constants]
        0
        None
        [Code]
            File Name: chal.py
            Object Name: KSA
            Qualified Name: KSA
            Arg Count: 1
            Pos Only Arg Count: 0
            KW Only Arg Count: 0
            Stack Size: 7
            Flags: 0x00000003 (CO_OPTIMIZED | CO_NEWLOCALS)
            [Names]
                'list'
                'range'
                'len'
            [Locals+Names]
                'key'
                'S'
                'j'
                'i'
            [Constants]
                None
                256
                0
            [Disassembly]
                0       RESUME                        0
                2       LOAD_GLOBAL                   1: NULL + list
                14      LOAD_GLOBAL                   3: NULL + range
                26      LOAD_CONST                    1: 256
                28      PRECALL                       1
                32      CALL                          1
                42      PRECALL                       1
                46      CALL                          1
                56      STORE_FAST                    1: S
                58      LOAD_CONST                    2: 0
                60      STORE_FAST                    2: j
                62      LOAD_GLOBAL                   3: NULL + range
                74      LOAD_CONST                    1: 256
                76      PRECALL                       1
                80      CALL                          1
                90      GET_ITER
                92      FOR_ITER                      64 (to 222)
                94      STORE_FAST                    3: i
                96      LOAD_FAST                     2: j
                98      LOAD_FAST                     1: S
                100     LOAD_FAST                     3: i
                102     BINARY_SUBSCR
                112     BINARY_OP                     0 (+)
                116     LOAD_FAST                     0: key
                118     LOAD_FAST                     3: i
                120     LOAD_GLOBAL                   5: NULL + len
                132     LOAD_FAST                     0: key
                134     PRECALL                       1
                138     CALL                          1
                148     BINARY_OP                     6 (%)
                152     BINARY_SUBSCR
                162     BINARY_OP                     0 (+)
                166     LOAD_CONST                    1: 256
                168     BINARY_OP                     6 (%)
                172     STORE_FAST                    2: j
                174     LOAD_FAST                     1: S
                176     LOAD_FAST                     2: j
                178     BINARY_SUBSCR
                188     LOAD_FAST                     1: S
                190     LOAD_FAST                     3: i
                192     BINARY_SUBSCR
                202     SWAP                          2
                204     LOAD_FAST                     1: S
                206     LOAD_FAST                     3: i
                208     STORE_SUBSCR
                212     LOAD_FAST                     1: S
                214     LOAD_FAST                     2: j
                216     STORE_SUBSCR
                220     JUMP_BACKWARD                 65
                222     LOAD_FAST                     1: S
                224     RETURN_VALUE
        [Code]
            File Name: chal.py
            Object Name: PRGA
            Qualified Name: PRGA
            Arg Count: 1
            Pos Only Arg Count: 0
            KW Only Arg Count: 0
            Stack Size: 4
            Flags: 0x00000023 (CO_OPTIMIZED | CO_NEWLOCALS | CO_GENERATOR)
            [Names]
            [Locals+Names]
                'S'
                'i'
                'j'
                'K'
            [Constants]
                None
                0
                True
                1
                256
            [Disassembly]
                0       RETURN_GENERATOR
                2       POP_TOP
                4       RESUME                        0
                6       LOAD_CONST                    1: 0
                8       STORE_FAST                    1: i
                10      LOAD_CONST                    1: 0
                12      STORE_FAST                    2: j
                14      NOP
                16      LOAD_FAST                     1: i
                18      LOAD_CONST                    3: 1
                20      BINARY_OP                     0 (+)
                24      LOAD_CONST                    4: 256
                26      BINARY_OP                     6 (%)
                30      STORE_FAST                    1: i
                32      LOAD_FAST                     2: j
                34      LOAD_FAST                     0: S
                36      LOAD_FAST                     1: i
                38      BINARY_SUBSCR
                48      BINARY_OP                     0 (+)
                52      LOAD_CONST                    4: 256
                54      BINARY_OP                     6 (%)
                58      STORE_FAST                    2: j
                60      LOAD_FAST                     0: S
                62      LOAD_FAST                     2: j
                64      BINARY_SUBSCR
                74      LOAD_FAST                     0: S
                76      LOAD_FAST                     1: i
                78      BINARY_SUBSCR
                88      SWAP                          2
                90      LOAD_FAST                     0: S
                92      LOAD_FAST                     1: i
                94      STORE_SUBSCR
                98      LOAD_FAST                     0: S
                100     LOAD_FAST                     2: j
                102     STORE_SUBSCR
                106     LOAD_FAST                     0: S
                108     LOAD_FAST                     0: S
                110     LOAD_FAST                     1: i
                112     BINARY_SUBSCR
                122     LOAD_FAST                     0: S
                124     LOAD_FAST                     2: j
                126     BINARY_SUBSCR
                136     BINARY_OP                     0 (+)
                140     LOAD_CONST                    4: 256
                142     BINARY_OP                     6 (%)
                146     BINARY_SUBSCR
                156     STORE_FAST                    3: K
                158     LOAD_FAST                     3: K
                160     YIELD_VALUE
                162     RESUME                        1
                164     POP_TOP
                166     JUMP_BACKWARD                 76
        [Code]
            File Name: chal.py
            Object Name: encrypt
            Qualified Name: encrypt
            Arg Count: 1
            Pos Only Arg Count: 0
            KW Only Arg Count: 0
            Stack Size: 7
            Flags: 0x00000003 (CO_OPTIMIZED | CO_NEWLOCALS)
            [Names]
                'PRGA'
                'KSA'
                'range'
                'len'
                'append'
                'next'
                'bytes'
                'base64'
                'b64encode'
            [Locals+Names]
                'plaintext'
                'key'
                'keystream'
                'enc'
                'i'
                'byte_string'
                'b64_enc'
            [Constants]
                None
                'Rivest'
                [Code]
                    File Name: chal.py
                    Object Name: <listcomp>
                    Qualified Name: encrypt.<locals>.<listcomp>
                    Arg Count: 1
                    Pos Only Arg Count: 0
                    KW Only Arg Count: 0
                    Stack Size: 5
                    Flags: 0x00000013 (CO_OPTIMIZED | CO_NEWLOCALS | CO_NESTED)
                    [Names]
                        'ord'
                    [Locals+Names]
                        '.0'
                        'p'
                    [Constants]
                    [Disassembly]
                        0       RESUME                        0
                        2       BUILD_LIST                    0
                        4       LOAD_FAST                     0: .0
                        6       FOR_ITER                      17 (to 42)
                        8       STORE_FAST                    1: p
                        10      LOAD_GLOBAL                   1: NULL + ord
                        22      LOAD_FAST                     1: p
                        24      PRECALL                       1
                        28      CALL                          1
                        38      LIST_APPEND                   2
                        40      JUMP_BACKWARD                 18
                        42      RETURN_VALUE
                [Code]
                    File Name: chal.py
                    Object Name: <listcomp>
                    Qualified Name: encrypt.<locals>.<listcomp>
                    Arg Count: 1
                    Pos Only Arg Count: 0
                    KW Only Arg Count: 0
                    Stack Size: 5
                    Flags: 0x00000013 (CO_OPTIMIZED | CO_NEWLOCALS | CO_NESTED)
                    [Names]
                        'ord'
                    [Locals+Names]
                        '.0'
                        'k'
                    [Constants]
                    [Disassembly]
                        0       RESUME                        0
                        2       BUILD_LIST                    0
                        4       LOAD_FAST                     0: .0
                        6       FOR_ITER                      17 (to 42)
                        8       STORE_FAST                    1: k
                        10      LOAD_GLOBAL                   1: NULL + ord
                        22      LOAD_FAST                     1: k
                        24      PRECALL                       1
                        28      CALL                          1
                        38      LIST_APPEND                   2
                        40      JUMP_BACKWARD                 18
                        42      RETURN_VALUE
            [Disassembly]
                0       RESUME                        0
                2       LOAD_CONST                    1: 'Rivest'
                4       STORE_FAST                    1: key
                6       LOAD_CONST                    2: <CODE> <listcomp>
                8       MAKE_FUNCTION                 0
                10      LOAD_FAST                     0: plaintext
                12      GET_ITER
                14      PRECALL                       0
                18      CALL                          0
                28      STORE_FAST                    0: plaintext
                30      LOAD_CONST                    3: <CODE> <listcomp>
                32      MAKE_FUNCTION                 0
                34      LOAD_FAST                     1: key
                36      GET_ITER
                38      PRECALL                       0
                42      CALL                          0
                52      STORE_FAST                    1: key
                54      LOAD_GLOBAL                   1: NULL + PRGA
                66      LOAD_GLOBAL                   3: NULL + KSA
                78      LOAD_FAST                     1: key
                80      PRECALL                       1
                84      CALL                          1
                94      PRECALL                       1
                98      CALL                          1
                108     STORE_FAST                    2: keystream
                110     BUILD_LIST                    0
                112     STORE_FAST                    3: enc
                114     LOAD_GLOBAL                   5: NULL + range
                126     LOAD_GLOBAL                   7: NULL + len
                138     LOAD_FAST                     0: plaintext
                140     PRECALL                       1
                144     CALL                          1
                154     PRECALL                       1
                158     CALL                          1
                168     GET_ITER
                170     FOR_ITER                      45 (to 262)
                172     STORE_FAST                    4: i
                174     LOAD_FAST                     3: enc
                176     LOAD_METHOD                   4: append
                198     LOAD_FAST                     0: plaintext
                200     LOAD_FAST                     4: i
                202     BINARY_SUBSCR
                212     LOAD_GLOBAL                   11: NULL + next
                224     LOAD_FAST                     2: keystream
                226     PRECALL                       1
                230     CALL                          1
                240     BINARY_OP                     12 (^)
                244     PRECALL                       1
                248     CALL                          1
                258     POP_TOP
                260     JUMP_BACKWARD                 46
                262     LOAD_GLOBAL                   13: NULL + bytes
                274     LOAD_FAST                     3: enc
                276     PRECALL                       1
                280     CALL                          1
                290     STORE_FAST                    5: byte_string
                292     LOAD_GLOBAL                   15: NULL + base64
                304     LOAD_ATTR                     8: b64encode
                314     LOAD_FAST                     5: byte_string
                316     PRECALL                       1
                320     CALL                          1
                330     STORE_FAST                    6: b64_enc
                332     LOAD_FAST                     6: b64_enc
                334     RETURN_VALUE
        'Please enter the flag: '
        b'aJlQBCwh9JM2RHmXLy+PA6cUIFDC3A=='
        'Correct!'
        'Wrong!'
    [Disassembly]
        0       RESUME                        0
        2       LOAD_CONST                    0: 0
        4       LOAD_CONST                    1: None
        6       IMPORT_NAME                   0: codecs
        8       STORE_NAME                    0: codecs
        10      LOAD_CONST                    0: 0
        12      LOAD_CONST                    1: None
        14      IMPORT_NAME                   1: base64
        16      STORE_NAME                    1: base64
        18      LOAD_CONST                    0: 0
        20      LOAD_CONST                    1: None
        22      IMPORT_NAME                   2: sys
        24      STORE_NAME                    2: sys
        26      LOAD_CONST                    2: <CODE> KSA
        28      MAKE_FUNCTION                 0
        30      STORE_NAME                    3: KSA
        32      LOAD_CONST                    3: <CODE> PRGA
        34      MAKE_FUNCTION                 0
        36      STORE_NAME                    4: PRGA
        38      LOAD_CONST                    4: <CODE> encrypt
        40      MAKE_FUNCTION                 0
        42      STORE_NAME                    5: encrypt
        44      PUSH_NULL
        46      LOAD_NAME                     6: input
        48      LOAD_CONST                    5: 'Please enter the flag: '
        50      PRECALL                       1
        54      CALL                          1
        64      STORE_NAME                    7: flag
        66      PUSH_NULL
        68      LOAD_NAME                     5: encrypt
        70      LOAD_NAME                     7: flag
        72      PRECALL                       1
        76      CALL                          1
        86      STORE_NAME                    8: enc_flag
        88      LOAD_NAME                     8: enc_flag
        90      LOAD_CONST                    6: b'aJlQBCwh9JM2RHmXLy+PA6cUIFDC3A=='
        92      COMPARE_OP                    2 (==)
        98      POP_JUMP_FORWARD_IF_FALSE     13 (to 126)
        100     PUSH_NULL
        102     LOAD_NAME                     9: print
        104     LOAD_CONST                    7: 'Correct!'
        106     PRECALL                       1
        110     CALL                          1
        120     POP_TOP
        122     LOAD_CONST                    1: None
        124     RETURN_VALUE
        126     PUSH_NULL
        128     LOAD_NAME                     9: print
        130     LOAD_CONST                    8: 'Wrong!'
        132     PRECALL                       1
        136     CALL                          1
        146     POP_TOP
        148     LOAD_CONST                    1: None
        150     RETURN_VALUE