  0           0 RESUME                   0

  1           2 LOAD_CONST               0 (0)
              4 LOAD_CONST               1 (('md5',))
              6 IMPORT_NAME              0 (hashlib)
              8 IMPORT_FROM              1 (md5)
             10 STORE_NAME               1 (md5)
             12 POP_TOP

  2          14 LOAD_CONST               0 (0)
             16 LOAD_CONST               2 (None)
             18 IMPORT_NAME              2 (time)
             20 STORE_NAME               2 (time)

  4          22 LOAD_CONST               3 (<code object crackme at 0x558a3158ccd0, file "byteme.py", line 4>)
             24 MAKE_FUNCTION
             26 STORE_NAME               3 (crackme)

 55          28 LOAD_CONST               4 (<code object solveme at 0x558a315b3210, file "byteme.py", line 55>)
             30 MAKE_FUNCTION
             32 STORE_NAME               4 (solveme)

142          34 LOAD_CONST               5 (<code object breakme at 0x558a31538040, file "byteme.py", line 142>)
             36 MAKE_FUNCTION
             38 STORE_NAME               5 (breakme)

245          40 LOAD_NAME                6 (__name__)
             42 LOAD_CONST               6 ('__main__')
             44 COMPARE_OP              88 (bool(==))
             48 POP_JUMP_IF_FALSE       97 (to 246)

246          52 LOAD_NAME                3 (crackme)
             54 PUSH_NULL
             56 CALL                     0
             64 STORE_NAME               7 (spell)

247          66 LOAD_NAME                4 (solveme)
             68 PUSH_NULL
             70 CALL                     0
             78 STORE_NAME               8 (answer)

248          80 LOAD_NAME                5 (breakme)
             82 PUSH_NULL
             84 CALL                     0
             92 STORE_NAME               9 (chain)

250          94 LOAD_NAME               10 (print)
             96 PUSH_NULL
             98 LOAD_CONST               7 ('Thalor has risen!')
            100 CALL                     1
            108 POP_TOP

251         110 LOAD_NAME               10 (print)
            112 PUSH_NULL
            114 LOAD_CONST               8 ('The prophecy has been fulfilled')
            116 CALL                     1
            124 POP_TOP

252         126 LOAD_NAME               10 (print)
            128 PUSH_NULL
            130 CALL                     0
            138 POP_TOP

253         140 LOAD_NAME               10 (print)
            142 PUSH_NULL
            144 LOAD_CONST               9 ('#######################################')
            146 CALL                     1
            154 POP_TOP

254         156 LOAD_NAME               10 (print)
            158 PUSH_NULL
            160 LOAD_CONST              10 ('##')
            162 LOAD_CONST              11 ('                                 ')
            164 LOAD_CONST              10 ('##')
            166 CALL                     3
            174 POP_TOP

255         176 LOAD_NAME               10 (print)
            178 PUSH_NULL
            180 LOAD_CONST              10 ('##')
            182 LOAD_NAME                7 (spell)
            184 FORMAT_SIMPLE
            186 LOAD_NAME                8 (answer)
            188 FORMAT_SIMPLE
            190 LOAD_NAME                9 (chain)
            192 FORMAT_SIMPLE
            194 BUILD_STRING             3
            196 LOAD_CONST              10 ('##')
            198 CALL                     3
            206 POP_TOP

256         208 LOAD_NAME               10 (print)
            210 PUSH_NULL
            212 LOAD_CONST              10 ('##')
            214 LOAD_CONST              11 ('                                 ')
            216 LOAD_CONST              10 ('##')
            218 CALL                     3
            226 POP_TOP

257         228 LOAD_NAME               10 (print)
            230 PUSH_NULL
            232 LOAD_CONST               9 ('#######################################')
            234 CALL                     1
            242 POP_TOP
            244 RETURN_CONST             2 (None)

245     >>  246 RETURN_CONST             2 (None)

Disassembly of <code object crackme at 0x558a3158ccd0, file "byteme.py", line 4>:
  4           0 RESUME                   0

  5           2 LOAD_GLOBAL              1 (print + NULL)
             12 LOAD_CONST               1 ("                           o                    \n                       _---|         _ _ _ _ _ \n                    o   ---|     o   ]-I-I-I-[ \n   _ _ _ _ _ _  _---|      | _---|    \\ ` ' / \n   ]-I-I-I-I-[   ---|      |  ---|    |.   | \n    \\ `   '_/       |     / \\    |    | /^\\| \n     [*]  __|       ^    / ^ \\   ^    | |*|| \n     |__   ,|      / \\  /    `\\ / \\   | ===| \n  ___| ___ ,|__   /    /=_=_=_=\\   \\  |,  _|\n  I_I__I_I__I_I  (====(_________)___|_|____|____\n  \\-\\--|-|--/-/  |     I  [ ]__I I_I__|____I_I_| \n   |[]      '|   | []  |`__  . [  \\-\\--|-|--/-/  \n   |.   | |' |___|_____I___|___I___|---------| \n  / \\| []   .|_|-|_|-|-|_|-|_|-|_|-| []   [] | \n <===>  |   .|-=-=-=-=-=-=-=-=-=-=-|   |    / \\  \n ] []|`   [] ||.|.|.|.|.|.|.|.|.|.||-      <===> \n ] []| ` |   |/////////\\\\\\\\\\.||__.  | |[] [ \n <===>     ' ||||| |   |   | ||||.||  []   <===>\n  \\T/  | |-- ||||| | O | O | ||||.|| . |'   \\T/ \n   |      . _||||| |   |   | ||||.|| |     | |\n../|' v . | .|||||/____|____\\|||| /|. . | . ./\n.|//\\............/...........\\........../../\\\n")
             14 CALL                     1
             22 POP_TOP

 28          24 LOAD_GLOBAL              1 (print + NULL)
             34 CALL                     0
             42 POP_TOP

 29          44 LOAD_GLOBAL              1 (print + NULL)
             54 LOAD_CONST               2 ('Welcome Warrior! You have made it till here')
             56 CALL                     1
             64 POP_TOP

 30          66 LOAD_GLOBAL              1 (print + NULL)
             76 LOAD_CONST               3 ('This is where best of the best have fallen prey to the fate')
             78 CALL                     1
             86 POP_TOP

 31          88 LOAD_GLOBAL              1 (print + NULL)
             98 CALL                     0
            106 POP_TOP

 32         108 LOAD_GLOBAL              1 (print + NULL)
            118 LOAD_CONST               4 ('It is written that only the true Thalor can get The sword of Eldoria')
            120 CALL                     1
            128 POP_TOP

 33         130 LOAD_GLOBAL              1 (print + NULL)
            140 LOAD_CONST               5 ('Do you have what it takes to be Thalor?')
            142 CALL                     1
            150 POP_TOP

 34         152 LOAD_GLOBAL              1 (print + NULL)
            162 LOAD_CONST               6 ('Prove your mettle by bringing the sword out of the castle')
            164 CALL                     1
            172 POP_TOP

 35         174 LOAD_GLOBAL              1 (print + NULL)
            184 CALL                     0
            192 POP_TOP

 36         194 LOAD_GLOBAL              1 (print + NULL)
            204 LOAD_CONST               7 ('Go on! unlock the castle with XEKLEIDOMA spell')
            206 CALL                     1
            214 POP_TOP

 38         216 LOAD_GLOBAL              1 (print + NULL)
            226 CALL                     0
            234 POP_TOP

 39         236 LOAD_GLOBAL              3 (input + NULL)
            246 LOAD_CONST               8 ('> ')
            248 CALL                     1
            256 STORE_FAST               0 (spell)

 40         258 LOAD_GLOBAL              1 (print + NULL)
            268 CALL                     0
            276 POP_TOP

 42         278 LOAD_GLOBAL              5 (len + NULL)
            288 LOAD_FAST                0 (spell)
            290 LOAD_ATTR                7 (strip + NULL|self)
            310 CALL                     0
            318 CALL                     1
            326 LOAD_CONST               9 (12)
            328 COMPARE_OP             119 (bool(!=))
            332 POP_JUMP_IF_TRUE        57 (to 450)
            336 LOAD_GLOBAL              9 (md5 + NULL)
            346 LOAD_FAST                0 (spell)
            348 LOAD_ATTR                7 (strip + NULL|self)
            368 CALL                     0
            376 LOAD_ATTR               11 (encode + NULL|self)
            396 CALL                     0
            404 CALL                     1
            412 LOAD_ATTR               13 (hexdigest + NULL|self)
            432 CALL                     0
            440 LOAD_CONST              10 ('9ce86143889d80b01586f8a819d20f0c')
            442 COMPARE_OP             119 (bool(!=))
            446 POP_JUMP_IF_FALSE       43 (to 536)

 43     >>  450 LOAD_GLOBAL              1 (print + NULL)
            460 LOAD_CONST              11 ('You are not THE ONE')
            462 CALL                     1
            470 POP_TOP

 44         472 LOAD_GLOBAL              1 (print + NULL)
            482 LOAD_CONST              12 ('True Thalor is a master of sorcery')
            484 CALL                     1
            492 POP_TOP

 45         494 LOAD_GLOBAL              1 (print + NULL)
            504 LOAD_CONST              13 ('Ground beneath you opens up and you fall into the depths of hell')
            506 CALL                     1
            514 POP_TOP

 46         516 LOAD_GLOBAL             15 (exit + NULL)
            526 CALL                     0
            534 POP_TOP

 48     >>  536 LOAD_GLOBAL              1 (print + NULL)
            546 LOAD_CONST              14 ('The door is opened!')
            548 CALL                     1
            556 POP_TOP

 49         558 LOAD_GLOBAL              1 (print + NULL)
            568 LOAD_CONST              15 ('You surely mastered sorcery')
            570 CALL                     1
            578 POP_TOP

 50         580 LOAD_GLOBAL              1 (print + NULL)
            590 CALL                     0
            598 POP_TOP

 51         600 LOAD_GLOBAL             16 (time)
            610 LOAD_ATTR               18 (sleep)
            630 PUSH_NULL
            632 LOAD_CONST              16 (3)
            634 CALL                     1
            642 POP_TOP

 53         644 LOAD_FAST                0 (spell)
            646 RETURN_VALUE

Disassembly of <code object solveme at 0x558a315b3210, file "byteme.py", line 55>:
  55           0 RESUME                   0

  56           2 LOAD_GLOBAL              1 (print + NULL)
              12 LOAD_CONST               1 ('\n                                            .""--..__\n                     _                     []       ``-.._\n                  .\'` `\'.                  ||__           `-._\n                 /    ,-.\\                 ||_ ```---..__     `-.\n                /    /:::\\               /|//}          ``--._  `.\n                |    |:::||              |////}                `. |\n                |    |:::||             //\'///                   -\n                |    |:::||            //  ||\'     \n                /    |:::|/        _,-//\\  ||\n               /`    |:::|`-,__,-\'`  |/  \\ ||\n             /`  |   |\'\' ||           \\   |||\n           /`    \\   |   ||            |  /||\n         |`       |  |   |)            \\ | ||\n        |          \\ |   /      ,.__    \\| ||\n        /           `         /`    `\\   | ||\n       |                     /        \\  / ||\n       |                     |        | /  ||\n       /         /           |        `(   ||\n      /          .           /          )  ||\n     |            \\          |     ________||\n    /             |          /     `-------.|\n   |\\            /          |              ||\n   \\/`-._       |           /              ||\n    //   `.    /`           |              ||\n   //`.    `. |             \\              ||\n  ///\\ `-._  )/             |              ||\n //// )   .(/               |              ||\n ||||   ,\'` )               /              //\n ||||  /                    /             || \n `\\` /`                    |             // \n     |`                     \\            ||  \n    /                        |           //  \n  /`                          \\         //   \n/`                            |        ||    \n`-.___,-.      .-.        ___,\'        (/    \n         `---\'`   `\'----\'`\n')
              14 CALL                     1
              22 POP_TOP

  94          24 LOAD_GLOBAL              1 (print + NULL)
              34 CALL                     0
              42 POP_TOP

  95          44 LOAD_GLOBAL              1 (print + NULL)
              54 LOAD_CONST               2 ('As you walk in, you see a spectral figure Elyrian, the Guardian of Souls')
              56 CALL                     1
              64 POP_TOP

  96          66 LOAD_GLOBAL              1 (print + NULL)
              76 LOAD_CONST               3 ('He speaks to you in a voice that echoes through the chamber')
              78 CALL                     1
              86 POP_TOP

  97          88 LOAD_GLOBAL              1 (print + NULL)
              98 CALL                     0
             106 POP_TOP

  98         108 LOAD_GLOBAL              1 (print + NULL)
             118 LOAD_CONST               4 ('"Brave warrior, before you lies the next trial on your path. Answer my riddle, and prove your worthiness to continue your quest."')
             120 CALL                     1
             128 POP_TOP

 100         130 LOAD_GLOBAL              1 (print + NULL)
             140 LOAD_CONST               5 ('\n"I am a word of ten, with numbers and letters blend,\nUnravel me, and secrets I\'ll send.\nThough cryptic in sight, I hold the code tight,\nUnlock my mystery with wit and might."\n')
             142 CALL                     1
             150 POP_TOP

 107         152 LOAD_GLOBAL              3 (input + NULL)
             162 LOAD_CONST               6 ('> ')
             164 CALL                     1
             172 STORE_FAST               0 (answer)

 108         174 LOAD_GLOBAL              1 (print + NULL)
             184 CALL                     0
             192 POP_TOP

 109         194 LOAD_GLOBAL              5 (list + NULL)
             204 LOAD_GLOBAL              7 (map + NULL)
             214 LOAD_GLOBAL              8 (ord)
             224 LOAD_GLOBAL              5 (list + NULL)
             234 LOAD_FAST                0 (answer)
             236 LOAD_ATTR               11 (strip + NULL|self)
             256 CALL                     0
             264 CALL                     1
             272 CALL                     2
             280 CALL                     1
             288 STORE_FAST               0 (answer)

 111         290 NOP

 112         292 LOAD_GLOBAL             13 (len + NULL)
             302 LOAD_FAST                0 (answer)
             304 CALL                     1
             312 LOAD_CONST               7 (10)
             314 COMPARE_OP              88 (bool(==))
             318 POP_JUMP_IF_TRUE         2 (to 326)
             322 LOAD_ASSERTION_ERROR
             324 RAISE_VARARGS            1

 113     >>  326 LOAD_FAST                0 (answer)
             328 LOAD_CONST               8 (6)
             330 BINARY_SUBSCR
             334 LOAD_FAST                0 (answer)
             336 LOAD_CONST               9 (7)
             338 BINARY_SUBSCR
             342 BINARY_OP                0 (+)
             346 LOAD_FAST                0 (answer)
             348 LOAD_CONST              10 (8)
             350 BINARY_SUBSCR
             354 BINARY_OP                0 (+)
             358 LOAD_FAST                0 (answer)
             360 LOAD_CONST              11 (5)
             362 BINARY_SUBSCR
             366 BINARY_OP               10 (-)
             370 LOAD_CONST              12 (190)
             372 COMPARE_OP              88 (bool(==))
             376 POP_JUMP_IF_TRUE         2 (to 384)
             380 LOAD_ASSERTION_ERROR
             382 RAISE_VARARGS            1

 114     >>  384 LOAD_FAST                0 (answer)
             386 LOAD_CONST               8 (6)
             388 BINARY_SUBSCR
             392 LOAD_FAST                0 (answer)
             394 LOAD_CONST              11 (5)
             396 BINARY_SUBSCR
             400 BINARY_OP                0 (+)
             404 LOAD_FAST                0 (answer)
             406 LOAD_CONST              11 (5)
             408 BINARY_SUBSCR
             412 BINARY_OP                0 (+)
             416 LOAD_FAST                0 (answer)
             418 LOAD_CONST              13 (2)
             420 BINARY_SUBSCR
             424 BINARY_OP               10 (-)
             428 LOAD_CONST              14 (202)
             430 COMPARE_OP              88 (bool(==))
             434 POP_JUMP_IF_TRUE         2 (to 442)
             438 LOAD_ASSERTION_ERROR
             440 RAISE_VARARGS            1

 115     >>  442 LOAD_FAST                0 (answer)
             444 LOAD_CONST              15 (9)
             446 BINARY_SUBSCR
             450 LOAD_FAST                0 (answer)
             452 LOAD_CONST              16 (3)
             454 BINARY_SUBSCR
             458 BINARY_OP                0 (+)
             462 LOAD_FAST                0 (answer)
             464 LOAD_CONST              13 (2)
             466 BINARY_SUBSCR
             470 BINARY_OP                0 (+)
             474 LOAD_FAST                0 (answer)
             476 LOAD_CONST              11 (5)
             478 BINARY_SUBSCR
             482 BINARY_OP                0 (+)
             486 LOAD_CONST              17 (433)
             488 COMPARE_OP              88 (bool(==))
             492 POP_JUMP_IF_TRUE         2 (to 500)
             496 LOAD_ASSERTION_ERROR
             498 RAISE_VARARGS            1

 116     >>  500 LOAD_FAST                0 (answer)
             502 LOAD_CONST               9 (7)
             504 BINARY_SUBSCR
             508 LOAD_FAST                0 (answer)
             510 LOAD_CONST              18 (0)
             512 BINARY_SUBSCR
             516 BINARY_OP                0 (+)
             520 LOAD_FAST                0 (answer)
             522 LOAD_CONST              18 (0)
             524 BINARY_SUBSCR
             528 BINARY_OP               10 (-)
             532 LOAD_FAST                0 (answer)
             534 LOAD_CONST              16 (3)
             536 BINARY_SUBSCR
             540 BINARY_OP                0 (+)
             544 LOAD_CONST              19 (237)
             546 COMPARE_OP              88 (bool(==))
             550 POP_JUMP_IF_TRUE         2 (to 558)
             554 LOAD_ASSERTION_ERROR
             556 RAISE_VARARGS            1

 117     >>  558 LOAD_FAST                0 (answer)
             560 LOAD_CONST              20 (1)
             562 BINARY_SUBSCR
             566 LOAD_FAST                0 (answer)
             568 LOAD_CONST              15 (9)
             570 BINARY_SUBSCR
             574 BINARY_OP               10 (-)
             578 LOAD_FAST                0 (answer)
             580 LOAD_CONST              11 (5)
             582 BINARY_SUBSCR
             586 BINARY_OP               10 (-)
             590 LOAD_FAST                0 (answer)
             592 LOAD_CONST              21 (4)
             594 BINARY_SUBSCR
             598 BINARY_OP                0 (+)
             602 LOAD_CONST              22 (-50)
             604 COMPARE_OP              88 (bool(==))
             608 POP_JUMP_IF_TRUE         2 (to 616)
             612 LOAD_ASSERTION_ERROR
             614 RAISE_VARARGS            1

 118     >>  616 LOAD_FAST                0 (answer)
             618 LOAD_CONST              13 (2)
             620 BINARY_SUBSCR
             624 LOAD_FAST                0 (answer)
             626 LOAD_CONST              16 (3)
             628 BINARY_SUBSCR
             632 BINARY_OP               10 (-)
             636 LOAD_FAST                0 (answer)
             638 LOAD_CONST              20 (1)
             640 BINARY_SUBSCR
             644 BINARY_OP                0 (+)
             648 LOAD_FAST                0 (answer)
             650 LOAD_CONST              20 (1)
             652 BINARY_SUBSCR
             656 BINARY_OP               10 (-)
             660 LOAD_CONST              23 (-6)
             662 COMPARE_OP              88 (bool(==))
             666 POP_JUMP_IF_TRUE         2 (to 674)
             670 LOAD_ASSERTION_ERROR
             672 RAISE_VARARGS            1

 119     >>  674 LOAD_FAST                0 (answer)
             676 LOAD_CONST              10 (8)
             678 BINARY_SUBSCR
             682 LOAD_FAST                0 (answer)
             684 LOAD_CONST               9 (7)
             686 BINARY_SUBSCR
             690 BINARY_OP               10 (-)
             694 LOAD_FAST                0 (answer)
             696 LOAD_CONST               8 (6)
             698 BINARY_SUBSCR
             702 BINARY_OP               10 (-)
             706 LOAD_FAST                0 (answer)
             708 LOAD_CONST              11 (5)
             710 BINARY_SUBSCR
             714 BINARY_OP                0 (+)
             718 LOAD_CONST              24 (-88)
             720 COMPARE_OP              88 (bool(==))
             724 POP_JUMP_IF_TRUE         2 (to 732)
             728 LOAD_ASSERTION_ERROR
             730 RAISE_VARARGS            1

 120     >>  732 LOAD_FAST                0 (answer)
             734 LOAD_CONST              18 (0)
             736 BINARY_SUBSCR
             740 LOAD_FAST                0 (answer)
             742 LOAD_CONST              10 (8)
             744 BINARY_SUBSCR
             748 BINARY_OP                0 (+)
             752 LOAD_FAST                0 (answer)
             754 LOAD_CONST              11 (5)
             756 BINARY_SUBSCR
             760 BINARY_OP               10 (-)
             764 LOAD_FAST                0 (answer)
             766 LOAD_CONST              16 (3)
             768 BINARY_SUBSCR
             772 BINARY_OP               10 (-)
             776 LOAD_CONST              25 (-117)
             778 COMPARE_OP              88 (bool(==))
             782 POP_JUMP_IF_TRUE         2 (to 790)
             786 LOAD_ASSERTION_ERROR
             788 RAISE_VARARGS            1

 121     >>  790 LOAD_FAST                0 (answer)
             792 LOAD_CONST              11 (5)
             794 BINARY_SUBSCR
             798 LOAD_FAST                0 (answer)
             800 LOAD_CONST               8 (6)
             802 BINARY_SUBSCR
             806 BINARY_OP                0 (+)
             810 LOAD_FAST                0 (answer)
             812 LOAD_CONST              10 (8)
             814 BINARY_SUBSCR
             818 BINARY_OP                0 (+)
             822 LOAD_FAST                0 (answer)
             824 LOAD_CONST              13 (2)
             826 BINARY_SUBSCR
             830 BINARY_OP                0 (+)
             834 LOAD_CONST              26 (385)
             836 COMPARE_OP              88 (bool(==))
             840 POP_JUMP_IF_TRUE         2 (to 848)
             844 LOAD_ASSERTION_ERROR
             846 RAISE_VARARGS            1

 122     >>  848 LOAD_FAST                0 (answer)
             850 LOAD_CONST              11 (5)
             852 BINARY_SUBSCR
             856 LOAD_FAST                0 (answer)
             858 LOAD_CONST              21 (4)
             860 BINARY_SUBSCR
             864 BINARY_OP               10 (-)
             868 LOAD_FAST                0 (answer)
             870 LOAD_CONST              11 (5)
             872 BINARY_SUBSCR
             876 BINARY_OP               10 (-)
             880 LOAD_FAST                0 (answer)
             882 LOAD_CONST              15 (9)
             884 BINARY_SUBSCR
             888 BINARY_OP                0 (+)
             892 LOAD_CONST              21 (4)
             894 COMPARE_OP              88 (bool(==))
             898 POP_JUMP_IF_TRUE         2 (to 906)
             902 LOAD_ASSERTION_ERROR
             904 RAISE_VARARGS            1

 123     >>  906 LOAD_FAST                0 (answer)
             908 LOAD_CONST              13 (2)
             910 BINARY_SUBSCR
             914 LOAD_FAST                0 (answer)
             916 LOAD_CONST              15 (9)
             918 BINARY_SUBSCR
             922 BINARY_OP               10 (-)
             926 LOAD_FAST                0 (answer)
             928 LOAD_CONST              11 (5)
             930 BINARY_SUBSCR
             934 BINARY_OP                0 (+)
             938 LOAD_FAST                0 (answer)
             940 LOAD_CONST              18 (0)
             942 BINARY_SUBSCR
             946 BINARY_OP               10 (-)
             950 LOAD_CONST              27 (63)
             952 COMPARE_OP              88 (bool(==))
             956 POP_JUMP_IF_TRUE         2 (to 964)
             960 LOAD_ASSERTION_ERROR
             962 RAISE_VARARGS            1

 124     >>  964 LOAD_FAST                0 (answer)
             966 LOAD_CONST              13 (2)
             968 BINARY_SUBSCR
             972 LOAD_FAST                0 (answer)
             974 LOAD_CONST              11 (5)
             976 BINARY_SUBSCR
             980 BINARY_OP               10 (-)
             984 LOAD_FAST                0 (answer)
             986 LOAD_CONST              21 (4)
             988 BINARY_SUBSCR
             992 BINARY_OP                0 (+)
             996 LOAD_FAST                0 (answer)
             998 LOAD_CONST              15 (9)
            1000 BINARY_SUBSCR
            1004 BINARY_OP               10 (-)
            1008 LOAD_CONST              28 (13)
            1010 COMPARE_OP              88 (bool(==))
            1014 POP_JUMP_IF_TRUE         2 (to 1022)
            1018 LOAD_ASSERTION_ERROR
            1020 RAISE_VARARGS            1

 125     >> 1022 LOAD_FAST                0 (answer)
            1024 LOAD_CONST              10 (8)
            1026 BINARY_SUBSCR
            1030 LOAD_FAST                0 (answer)
            1032 LOAD_CONST              16 (3)
            1034 BINARY_SUBSCR
            1038 BINARY_OP                0 (+)
            1042 LOAD_FAST                0 (answer)
            1044 LOAD_CONST               9 (7)
            1046 BINARY_SUBSCR
            1050 BINARY_OP                0 (+)
            1054 LOAD_FAST                0 (answer)
            1056 LOAD_CONST               8 (6)
            1058 BINARY_SUBSCR
            1062 BINARY_OP               10 (-)
            1066 LOAD_CONST              29 (167)
            1068 COMPARE_OP              88 (bool(==))
            1072 POP_JUMP_IF_TRUE         2 (to 1080)
            1076 LOAD_ASSERTION_ERROR
            1078 RAISE_VARARGS            1

 126     >> 1080 LOAD_FAST                0 (answer)
            1082 LOAD_CONST               8 (6)
            1084 BINARY_SUBSCR
            1088 LOAD_FAST                0 (answer)
            1090 LOAD_CONST              11 (5)
            1092 BINARY_SUBSCR
            1096 BINARY_OP               10 (-)
            1100 LOAD_FAST                0 (answer)
            1102 LOAD_CONST              18 (0)
            1104 BINARY_SUBSCR
            1108 BINARY_OP               10 (-)
            1112 LOAD_FAST                0 (answer)
            1114 LOAD_CONST              11 (5)
            1116 BINARY_SUBSCR
            1120 BINARY_OP               10 (-)
            1124 LOAD_CONST              30 (-126)
            1126 COMPARE_OP              88 (bool(==))
            1130 POP_JUMP_IF_TRUE         2 (to 1138)
            1134 LOAD_ASSERTION_ERROR
            1136 RAISE_VARARGS            1

 127     >> 1138 LOAD_FAST                0 (answer)
            1140 LOAD_CONST              13 (2)
            1142 BINARY_SUBSCR
            1146 LOAD_FAST                0 (answer)
            1148 LOAD_CONST              11 (5)
            1150 BINARY_SUBSCR
            1154 BINARY_OP               10 (-)
            1158 LOAD_FAST                0 (answer)
            1160 LOAD_CONST               8 (6)
            1162 BINARY_SUBSCR
            1166 BINARY_OP               10 (-)
            1170 LOAD_FAST                0 (answer)
            1172 LOAD_CONST              21 (4)
            1174 BINARY_SUBSCR
            1178 BINARY_OP               10 (-)
            1182 LOAD_CONST              31 (-199)
            1184 COMPARE_OP              88 (bool(==))
            1188 POP_JUMP_IF_TRUE         2 (to 1196)
            1192 LOAD_ASSERTION_ERROR
            1194 RAISE_VARARGS            1
         >> 1196 NOP

 134     >> 1198 LOAD_GLOBAL              1 (print + NULL)
            1208 LOAD_CONST              35 ('You have proven your `wit and might`')
            1210 CALL                     1
            1218 POP_TOP

 135        1220 LOAD_GLOBAL              1 (print + NULL)
            1230 LOAD_CONST              36 ('Elyrian, the Guardian of Souls, bows to you')
            1232 CALL                     1
            1240 POP_TOP

 136        1242 LOAD_GLOBAL              1 (print + NULL)
            1252 LOAD_CONST              37 ('You have unlocked the next chamber')
            1254 CALL                     1
            1262 POP_TOP

 137        1264 LOAD_GLOBAL              1 (print + NULL)
            1274 CALL                     0
            1282 POP_TOP

 138        1284 LOAD_GLOBAL             18 (time)
            1294 LOAD_ATTR               20 (sleep)
            1314 PUSH_NULL
            1316 LOAD_CONST              21 (4)
            1318 CALL                     1
            1326 POP_TOP

 140        1328 LOAD_CONST              38 ('')
            1330 LOAD_ATTR               23 (join + NULL|self)
            1350 LOAD_FAST                0 (answer)
            1352 GET_ITER
            1354 LOAD_FAST_AND_CLEAR      1 (x)
            1356 SWAP                     2
            1358 BUILD_LIST               0
            1360 SWAP                     2
         >> 1362 FOR_ITER                14 (to 1394)
            1366 STORE_FAST               1 (x)
            1368 LOAD_GLOBAL             25 (chr + NULL)
            1378 LOAD_FAST                1 (x)
            1380 CALL                     1
            1388 LIST_APPEND              2
            1390 JUMP_BACKWARD           16 (to 1362)
         >> 1394 END_FOR
            1396 POP_TOP
            1398 SWAP                     2
            1400 STORE_FAST               1 (x)
            1402 CALL                     1
            1410 RETURN_VALUE

None     >> 1412 PUSH_EXC_INFO

 128        1414 LOAD_GLOBAL             14 (AssertionError)
            1424 CHECK_EXC_MATCH
            1426 POP_JUMP_IF_FALSE       46 (to 1522)
            1430 POP_TOP

 129        1432 LOAD_GLOBAL              1 (print + NULL)
            1442 LOAD_CONST              32 ('You are not worthy')
            1444 CALL                     1
            1452 POP_TOP

 130        1454 LOAD_GLOBAL              1 (print + NULL)
            1464 LOAD_CONST              33 ('Your soul has been cursed')
            1466 CALL                     1
            1474 POP_TOP

 131        1476 LOAD_GLOBAL              1 (print + NULL)
            1486 LOAD_CONST              34 ('You will seek your own death in a fortnight')
            1488 CALL                     1
            1496 POP_TOP

 132        1498 LOAD_GLOBAL             17 (exit + NULL)
            1508 CALL                     0
            1516 POP_TOP
            1518 POP_EXCEPT
            1520 JUMP_BACKWARD_NO_INTERRUPT 162 (to 1198)

 128     >> 1522 RERAISE                  0

None     >> 1524 COPY                     3
            1526 POP_EXCEPT
            1528 RERAISE                  1
         >> 1530 SWAP                     2
            1532 POP_TOP

 140        1534 SWAP                     2
            1536 STORE_FAST               1 (x)
            1538 RERAISE                  0
ExceptionTable:
  292 to 1194 -> 1412 [0]
  1358 to 1396 -> 1530 [4]
  1412 to 1516 -> 1524 [1] lasti
  1522 to 1522 -> 1524 [1] lasti

Disassembly of <code object breakme at 0x558a31538040, file "byteme.py", line 142>:
142           0 RESUME                   0

143           2 LOAD_CONST               1 ("\n                      _..._\n                     /MMMMM\\\n                    (I8H#H8I)\n                    (I8H#H8I)\n                     \\WWWWW/\n                      I._.I\n                      I._.I\n                      I._.I\n                      I._.I\n                      I._.I\n                      I._.I\n                      I._.I\n                      I.,.I\n                     / /#\\ \\\n                   .dH# # #Hb.\n               _.~d#XXP I 7XX#b~,_\n            _.dXV^XP^ Y X Y ^7X^VXb._\n           /AP^   \\PY   Y   Y7/   ^VA\\\n          /8/      \\PP  I  77/      \\8\\\n         /J/        IV     VI        \\L\\\n         L|         |  \\ /  |         |J\n         V          |  | |  |          V\n                    |  | |  |\n                    |  | |  |\n                    |  | |  |\n                    |  | |  |\n _                  |  | |  |                  _\n( \\                 |  | |  |                 / )\n \\ \\                |  | |  |                / /\n('\\ \\               |  | |  |               / /`)\n \\ \\ \\              |  | |  |              / / /\n('\\ \\ \\             |  | |  |             / / /`)\n \\ \\ \\ )            |  | |  |            ( / / /\n('\\ \\( )            |  | |  |            ( )/ /`)\n \\ \\ ( |            |  | |  |            | ) / /\n  \\ \\( |            |  | |  |            | )/ /\n   \\ ( |            |  | |  |            | ) /\n    \\( |            |   Y   |            | )/\n     | |            |   |   |            | |\n     J | ___...~~--'|   |   |`--~~...___ | L\n     >-+<...___     |   |   |     ___...>+-<\n    /     __   `--~.L___L___J.~--'   __     \\\n    K    /  ` --.     d===b     .-- '  \\    H\n    \\_._/        \\   // I \\   /        \\_._/\n      `--~.._     \\__\\ I //__/     _..~--'\n             `--~~..____ ____..~~--'\n                    |   T   |\n                    |   |   |\n                    |   |   |\n                    |   |   |\n                    |   |   |\n                    |   |   |\n                    |   |   |\n                    |   |   |\n                    |   |   |\n                    |   |   |\n                    |   |   |\n                    |   |   |\n                    |   |   |\n                    I   '   I\n                     \\     /\n                      \\   /\n                       \\ /\n                       ")
              4 STORE_FAST               0 (sword)

209           6 LOAD_FAST                0 (sword)
              8 LOAD_ATTR                1 (split + NULL|self)
             28 LOAD_CONST               2 ('\n')
             30 CALL                     1
             38 STORE_FAST               0 (sword)

211          40 LOAD_FAST                0 (sword)
             42 GET_ITER
        >>   44 FOR_ITER                36 (to 120)
             48 STORE_FAST               1 (line)

212          50 LOAD_GLOBAL              3 (print + NULL)
             60 LOAD_FAST                1 (line)
             62 CALL                     1
             70 POP_TOP

213          72 LOAD_GLOBAL              4 (time)
             82 LOAD_ATTR                6 (sleep)
            102 PUSH_NULL
            104 LOAD_CONST               3 (0.1)
            106 CALL                     1
            114 POP_TOP
            116 JUMP_BACKWARD           38 (to 44)

211     >>  120 END_FOR
            122 POP_TOP

215         124 LOAD_GLOBAL              3 (print + NULL)
            134 CALL                     0
            142 POP_TOP

216         144 LOAD_GLOBAL              3 (print + NULL)
            154 LOAD_CONST               4 ('There it is! The sword of Eldoria')
            156 CALL                     1
            164 POP_TOP

217         166 LOAD_GLOBAL              3 (print + NULL)
            176 LOAD_CONST               5 ("Break it's shackles and show that you are the Thalor")
            178 CALL                     1
            186 POP_TOP

218         188 LOAD_GLOBAL              3 (print + NULL)
            198 CALL                     0
            206 POP_TOP

220         208 LOAD_GLOBAL              9 (input + NULL)
            218 LOAD_CONST               6 ('> ')
            220 CALL                     1
            228 STORE_FAST               2 (chain)

221         230 LOAD_GLOBAL              3 (print + NULL)
            240 CALL                     0
            248 POP_TOP

223         250 BUILD_LIST               0
            252 LOAD_CONST               7 ((117, 84, 87, 108, 59, 85, 66, 71, 71, 30, 16))
            254 LIST_EXTEND              1
            256 STORE_FAST               3 (best)

224         258 LOAD_GLOBAL             11 (list + NULL)
            268 CALL                     0
            276 STORE_FAST               4 (mod)

225         278 LOAD_CONST               8 (69)
            280 STORE_FAST               5 (plier)

227         282 LOAD_GLOBAL             13 (range + NULL)
            292 LOAD_GLOBAL             15 (len + NULL)
            302 LOAD_FAST                2 (chain)
            304 CALL                     1
            312 CALL                     1
            320 GET_ITER
        >>  322 FOR_ITER                47 (to 420)
            326 STORE_FAST               6 (i)

228         328 LOAD_FAST                4 (mod)
            330 LOAD_ATTR               17 (append + NULL|self)
            350 LOAD_FAST                5 (plier)
            352 LOAD_GLOBAL             19 (ord + NULL)
            362 LOAD_FAST_LOAD_FAST     38 (chain, i)
            364 BINARY_SUBSCR
            368 CALL                     1
            376 BINARY_OP               12 (^)
            380 CALL                     1
            388 POP_TOP

229         390 LOAD_GLOBAL             19 (ord + NULL)
            400 LOAD_FAST_LOAD_FAST     38 (chain, i)
            402 BINARY_SUBSCR
            406 CALL                     1
            414 STORE_FAST               5 (plier)
            416 JUMP_BACKWARD           49 (to 322)

227     >>  420 END_FOR
            422 POP_TOP

231         424 LOAD_FAST_LOAD_FAST     67 (mod, best)
            426 COMPARE_OP              88 (bool(==))
            430 POP_JUMP_IF_FALSE       78 (to 590)

232         434 LOAD_GLOBAL              3 (print + NULL)
            444 LOAD_CONST               9 ('Oh! True Thalor, you have broken the shackles')
            446 CALL                     1
            454 POP_TOP

233         456 LOAD_GLOBAL              3 (print + NULL)
            466 LOAD_CONST              10 ('You are the chosen one')
            468 CALL                     1
            476 POP_TOP

234         478 LOAD_GLOBAL              3 (print + NULL)
            488 LOAD_CONST              11 ('I kneel before you')
            490 CALL                     1
            498 POP_TOP

235         500 LOAD_GLOBAL              3 (print + NULL)
            510 LOAD_CONST              12 ('Go on! Take the sword and fulfill your destiny')
            512 CALL                     1
            520 POP_TOP

236         522 LOAD_GLOBAL              3 (print + NULL)
            532 CALL                     0
            540 POP_TOP

237         542 LOAD_GLOBAL              4 (time)
            552 LOAD_ATTR                6 (sleep)
            572 PUSH_NULL
            574 LOAD_CONST              13 (2)
            576 CALL                     1
            584 POP_TOP

238         586 LOAD_FAST                2 (chain)
            588 RETURN_VALUE

240     >>  590 LOAD_GLOBAL              3 (print + NULL)
            600 LOAD_CONST              14 ('You are not worthy')
            602 CALL                     1
            610 POP_TOP

241         612 LOAD_GLOBAL              3 (print + NULL)
            622 LOAD_CONST              15 ("The fate has you in it's grip")
            624 CALL                     1
            632 POP_TOP

242         634 LOAD_GLOBAL              3 (print + NULL)
            644 LOAD_CONST              16 ('You will be forgotten in the sands of time')
            646 CALL                     1
            654 POP_TOP

243         656 LOAD_GLOBAL             21 (exit + NULL)
            666 CALL                     0
            674 POP_TOP
            676 RETURN_CONST             0 (None)
None
