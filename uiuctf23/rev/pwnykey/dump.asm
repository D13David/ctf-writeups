[34musing devs: v2.11.6, runtime: v2.11.6, node: v14.18.2 from C:\work\sdks\emsdk\node\14.18.2_64bit\bin\node_modules\@devicescript\cli\built[0m
// img size 12416
// 14 globals

proc main_F0(): @1120
  locals: loc0,loc1,loc2
   0:     CALL prototype_F1()
   
		  ; fetch key from localhost
  10:     CALL ds."format"("start!")
  22:     CALL ds."print"(62, ret_val())
  34:     CALL fetch_F2("http://localhost/check")
  46:     CALL ret_val()."text"()
  57:     CALL ret_val()."trim"()
  68:     {G4} := ret_val()
  78:     CALL ds."format"("fetched key: {0}", {G4})
  92:     CALL ds."print"(62, ret_val())
  
		  ; check key format
 104:     JMP 143 IF NOT ({G4}."length" !== 29)			; first condition, key length is 29 characters
 121:     CALL (new Error)("Invalid key")
 134:     THROW ret_val()
 143:     CALL {G4}."split"("-")
 157:     {G5} := ret_val()
 167:     JMP 206 IF NOT ({G5}."length" !== 5)			; key has 5 parts seperated by '-'
 184:     CALL (new Error)("Invalid key")
 197:     THROW ret_val()
 206:     CALL {G5}."some"(inline_F7)					; every key part is 5 characters long: XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
 220:     JMP 254 IF NOT ret_val()
 232:     CALL (new Error)("Invalid key")
 245:     THROW ret_val()
 254:     CALL {G5}."some"(CLOSURE(inline_F8))			; every key part uses '0123456789ABCDFGHJKLMNPQRSTUWXYZ' alphabet
 268:     JMP 302 IF NOT ret_val()
 280:     CALL (new Error)("Invalid key")
 293:     THROW ret_val()
 302:     CALL ds."format"("key format ok")
 314:     CALL ds."print"(62, ret_val())
 
		  ; key validation of first part ('YANXA')
 326:     CALL {G5}."map"(CLOSURE(inline_F9))			; create index mapping for all the parts
 340:     loc0 := ret_val()
 350:     {G6} := loc0[0]
 363:     {G7} := loc0[1]
 376:     {G8} := loc0[2]
 389:     {G9} := loc0[3]
 402:     {G10} := loc0[4]
 415:     CALL ds."format"("{0}", {G6})
 429:     loc0 := ret_val()
 439:     ALLOC_ARRAY initial_size=5
 448:     loc1 := ret_val()
 458:     loc1[0] := 30									; Y
 470:     loc1[1] := 10									; A
 482:     loc1[2] := 21									; N
 494:     loc1[3] := 29									; X
 506:     loc1[4] := 10									; A
 518:     CALL ds."format"("{0}", loc1)
 532:     JMP 569 IF NOT (loc0 !== ret_val())
 547:     CALL (new Error)("Invalid key")
 560:     THROW ret_val()
 569:     CALL ds."format"("passed check1")
 581:     CALL ds."print"(62, ret_val())
 
		  ; key validation of second and third part ('2569A-CDHYZ')
 593:     CALL concat_F10({G7}, {G8})					; concat second and third part to one array
 607:     {G11} := ret_val()
 617:     CALL {G11}."reduce"(inline_F11, 0)			; sum over all indice is expected to be 134
 632:     loc0 := (ret_val() !== 134)
 645:     JMP 687 IF NOT !loc0
 659:     CALL {G11}."reduce"(inline_F12, 1)			; product over all indice is expected to be 12534912000
 674:     loc0 := (ret_val() !== 12534912000)
 687:     JMP 722 IF NOT loc0
 700:     CALL (new Error)("Invalid key")
 713:     THROW ret_val()
 722:     CALL ds."format"("passed check2")
 734:     CALL ds."print"(62, ret_val())
 
		  ; key validation of fourth part ('FBP2U')
 746:     {G12} := {G9}
 757:     {G13} := 1337
 770:     loc2 := 0
 780:     JMP 832 IF NOT (loc2 < 420)
 798:     CALL nextInt_F13()
 808:     loc2 := (loc2 + 1)
 821:     JMP 780
 832:     ALLOC_ARRAY initial_size=3
 841:     loc0 := ret_val()
 851:     CALL nextInt_F13()
 861:     loc0[0] := ret_val()
 873:     CALL nextInt_F13()
 883:     loc0[1] := ret_val()
 895:     CALL nextInt_F13()
 905:     loc0[2] := ret_val()
 917:     CALL ds."format"("{0}", loc0)
 931:     loc0 := ret_val()
 941:     ALLOC_ARRAY initial_size=3
 950:     loc1 := ret_val()
 960:     loc1[0] := 2897974129
 973:     loc1[1] := -549922559
 990:     loc1[2] := -387684011
1007:     CALL ds."format"("{0}", loc1)
1021:     JMP 1058 IF NOT (loc0 !== ret_val())
1036:     CALL (new Error)("Invalid key")
1049:     THROW ret_val()
1058:     CALL ds."format"("passed check3")
1070:     CALL ds."print"(62, ret_val())
1082:     CALL ds."format"("success!")
1094:     CALL ds."print"(62, ret_val())
1106:     RETURN 0

proc prototype_F1(): @2228
   0:     Array_prototype["map"] := map_F16
  14:     Array_prototype["some"] := some_F17
  28:     Array_prototype["pop"] := pop_F18
  42:     Array_prototype["unshift"] := unshift_F19
  56:     Array_prototype["reduce"] := reduce_F20
  70:     String."prototype"["trim"] := trim_F21
  86:     String."prototype"["includes"] := includes_F22
 102:     String."prototype"["startsWith"] := startsWith_F23
 118:     String."prototype"["split"] := split_F24
 134:     DeviceScript["emitter"] := emitter_F25
 148:     Socket_F5."prototype"["error"] := error_F26
 164:     Socket_F5."prototype"["check"] := check_F27
 180:     Socket_F5."prototype"["close"] := close_F28
 196:     Socket_F5."prototype"["recv"] := recv_F29
 212:     Socket_F5."prototype"["readLine"] := readLine_F30
 228:     Socket_F5."prototype"["send"] := send_F31
 244:     Socket_F5."prototype"["finish"] := finish_F32
 260:     Socket_F5["_socketOnEvent"] := _socketOnEvent_F33
 274:     Socket_F5["_connect"] := _connect_F34
 288:     Headers_F3."prototype"["append"] := append_F35
 304:     Headers_F3."prototype"["has"] := has_F36
 320:     Headers_F3."prototype"["set"] := set_F37
 336:     Headers_F3."prototype"["serialize"] := serialize_F38
 352:     Response_F6."prototype"["text"] := text_F40
 368:     DeviceScript["assert"] := assert_F44
 382:     Array_prototype["shift"] := shift_F45
 396:     Buffer."prototype"["concat"] := concat_F46
 412:     Buffer."prototype"["slice"] := slice_F47
 428:     Buffer["concat"] := concat_F48
 442:     Emitter_F43."prototype"["subscribe"] := subscribe_F49
 458:     Emitter_F43."prototype"["emit"] := emit_F54
 474:     DeviceScript["wait"] := CLOSURE(wait_F55)
 488:     Headers_F3."prototype"["forEach"] := forEach_F56
 504:     Response_F6."prototype"["buffer"] := buffer_F57
 520:     Array_prototype["indexOf"] := indexOf_F60
 534:     Buffer."prototype"["set"] := set_F61
 550:     Headers_F3."prototype"["get"] := get_F62
 566:     RETURN undefined

proc fetch_F2(par0, par1): @2796
  locals: loc0,loc1,loc2,loc3,loc4,loc5,loc6,loc7,loc8,loc9,loc10,loc11,loc12,loc13,loc14,loc15,loc16,loc17,loc18,loc19,loc20
   0:     JMP 32 IF NOT !par1
  14:     ALLOC_MAP 
  22:     par1 := ret_val()
  32:     JMP 62 IF NOT !par1."method"
  48:     par1["method"] := "GET"
  62:     JMP 113 IF NOT !par1."headers"
  78:     loc0 := par1
  89:     CALL (new Headers_F3)()
 100:     loc0["headers"] := ret_val()
 113:     JMP 143 IF NOT !par1."body"
 129:     par1["body"] := ""
 143:     loc2 := "tcp"
 154:     loc3 := 80
 164:     CALL par0."startsWith"("https://")
 178:     JMP 248 IF NOT ret_val()
 190:     loc2 := "tls"
 201:     loc3 := 443
 214:     CALL par0."slice"(8)
 227:     loc4 := ret_val()
 343:     CALL loc4."indexOf"("/")
 357:     loc5 := ret_val()
 367:     JMP 395 IF NOT (loc5 < 0)
 382:     loc5 := loc4."length"
 395:     CALL loc4."slice"(0, loc5)
 410:     loc6 := ret_val()
 420:     CALL loc4."slice"(loc5)
 434:     loc0 := ret_val()
 444:     JMP 469 IF NOT !loc0
 458:     loc0 := "/"
 469:     loc7 := loc0
 480:     CALL loc6."includes"("@")
 494:     JMP 541 IF NOT ret_val()
 506:     CALL ds."format"("credentials in URL not supported: {0}", par0)
 520:     CALL (new TypeError)(ret_val())
 532:     THROW ret_val()
 541:     CALL loc6."indexOf"(":")
 555:     loc8 := ret_val()
 565:     JMP 681 IF NOT (0 < loc8)
 580:     CALL loc6."slice"(0, loc8)
 595:     loc6 := ret_val()
 605:     CALL loc6."slice"((loc8 + 1))
 621:     loc3 := +ret_val()
 632:     JMP 681 IF NOT !loc3
 646:     CALL ds."format"("invalid port in url: {0}", par0)
 660:     CALL (new TypeError)(ret_val())
 672:     THROW ret_val()
 681:     JMP 723 IF NOT instance_of(obj=par1."headers", cls=Headers_F3)
 699:     loc9 := par1."headers"
 865:     loc10 := 0
 875:     JMP 920 IF NOT (typeof_str(par1."body") === "string")
 894:     loc10 := par1."body"."byteLength"
1001:     CALL loc9."has"("user-agent")
1015:     JMP 1044 IF NOT !ret_val()
1028:     CALL loc9."set"("user-agent", "DeviceScript fetch()")
1044:     CALL loc9."has"("accept")
1058:     JMP 1087 IF NOT !ret_val()
1071:     CALL loc9."set"("accept", "*/*")
1087:     CALL loc9."set"("host", loc6)
1103:     CALL loc9."set"("connection", "close")
1119:     JMP 1151 IF NOT loc10
1132:     CALL loc9."set"("content-length", (loc10 + ""))
1151:     loc1 := loc7
1162:     loc0 := par1."method"
1175:     CALL loc9."serialize"()
1187:     CALL ds."format"("{0} {1} HTTP/1.1\r\n{2}\r\n", loc0, loc1, ret_val())
1204:     loc11 := ret_val()
1214:     ALLOC_MAP 
1222:     loc0 := ret_val()
1232:     loc0["host"] := loc6
1246:     loc0["port"] := loc3
1260:     loc0["proto"] := loc2
1274:     CALL connect_F4(loc0)
1286:     loc12 := ret_val()
1296:     CALL ds."format"("req: {0}", loc11)
1310:     CALL ds."print"(63, ret_val())
1322:     CALL loc12."send"(loc11)
1336:     JMP 1365 IF NOT loc10
1349:     CALL loc12."send"(par1."body")
1365:     CALL (new Response_F6)(loc12)
1378:     loc13 := ret_val()
1388:     CALL loc12."readLine"()
1400:     loc14 := ret_val()
1410:     CALL loc14."startsWith"("HTTP/1.1 ")
1424:     JMP 1684 IF NOT ret_val()
1436:     CALL loc14."slice"(9)
1449:     loc14 := ret_val()
1459:     loc0 := loc13
1470:     CALL ds."parseInt"(loc14)
1482:     loc0["status"] := ret_val()
1495:     CALL loc14."indexOf"(" ")
1509:     loc16 := ret_val()
1519:     JMP 1585 IF NOT (0 < loc16)
1534:     loc0 := loc13
1545:     CALL loc14."slice"((loc16 + 1))
1561:     loc0["statusText"] := ret_val()
1599:     loc0 := (200 <= loc13."status")
1615:     JMP 1647 IF NOT !!loc0
1629:     loc0 := (loc13."status" <= 299)
1647:     JMP 1673 IF NOT loc0
1660:     loc13["ok"] := true()
1711:     CALL ds."format"("HTTP {0}: {1}", loc13."status", loc13."statusText")
1731:     CALL ds."print"(63, ret_val())
1743:     CALL loc12."readLine"()
1755:     loc17 := ret_val()
1765:     JMP 1792 IF NOT (loc17 === "")
1933:     CALL loc13."headers"."serialize"()
1947:     CALL ds."format"("{0}", ret_val())
1960:     CALL ds."print"(63, ret_val())
1972:     RETURN loc13

ctor Headers_F3(this): @4772
   0:     ALLOC_MAP 
   8:     this["data"] := ret_val()
  21:     RETURN undefined

proc connect_F4(par0): @4796
   0:     CALL Socket_F5."_connect"(par0)
  14:     RETURN ret_val()

ctor Socket_F5(this, par0): @4812
   0:     ALLOC_ARRAY initial_size=0
   9:     this["buffers"] := ret_val()
  22:     CALL DeviceScript."emitter"()
  34:     this["emitter"] := ret_val()
  47:     this["name"] := par0
  61:     RETURN undefined

ctor Response_F6(this, par0): @4876
   0:     this["socket"] := par0
  14:     CALL (new Headers_F3)()
  25:     this["headers"] := ret_val()
  38:     RETURN undefined

proc inline_F7(par0): @4916
   0:     RETURN (par0."length" !== 5)

proc inline_F8(par0): @4924
   0:     CALL par0."split"("")
  14:     CALL ret_val()."some"(inline_F14)
  27:     RETURN ret_val()

proc inline_F9(par0): @4956
   0:     CALL par0."split"("")
  14:     CALL ret_val()."map"(inline_F15)
  27:     RETURN ret_val()

proc concat_F10(par0, par1): @4988
  locals: loc0,loc1,loc2
   0:     ALLOC_ARRAY initial_size=0
   9:     loc0 := ret_val()
  19:     loc1 := 0
  29:     JMP 88 IF NOT (loc1 < par0."length")
  47:     CALL loc0."push"(par0[loc1])
  64:     loc1 := (loc1 + 1)
  77:     JMP 29
  88:     loc2 := 0
  98:     JMP 157 IF NOT (loc2 < par1."length")
 116:     CALL loc0."push"(par1[loc2])
 133:     loc2 := (loc2 + 1)
 146:     JMP 98
 157:     RETURN loc0

proc inline_F11(par0, par1): @5148
   0:     RETURN (par0 + par1)

proc inline_F12(par0, par1): @5156
   0:     RETURN (par0 * par1)

proc nextInt_F13(): @5164
  locals: loc0
   0:     CALL {G12}."pop"()
  12:     loc0 := ret_val()
  22:     loc0 := (loc0 ^ ((loc0 >> 2) & 4294967295))
  41:     loc0 := (loc0 ^ ((loc0 << 1) & 4294967295))
  60:     loc0 := (loc0 ^ (({G12}[0] ^ ({G12}[0] << 4)) & 4294967295))
  86:     {G13} := (({G13} + 13371337) & 4294967295)
 106:     CALL {G12}."unshift"(loc0)
 120:     RETURN (loc0 + {G13})

proc inline_F14(par0): @5292
   0:     CALL "0123456789ABCDFGHJKLMNPQRSTUWXYZ"."includes"(par0)
  14:     RETURN !ret_val()

proc inline_F15(par0): @5312
   0:     CALL "0123456789ABCDFGHJKLMNPQRSTUWXYZ"."indexOf"(par0)
  14:     RETURN ret_val()

method map_F16(this, par0): @5328
  locals: loc0,loc1,loc2,loc3
   0:     ALLOC_ARRAY initial_size=0
   9:     loc0 := ret_val()
  19:     loc1 := this."length"
  32:     loc2 := 0
  42:     JMP 125 IF NOT (loc2 < loc1)
  58:     par1 := loc0."push"
  71:     CALL par0(this[loc2], loc2, this)
  90:     CALL par1(ret_val())
 101:     loc2 := (loc2 + 1)
 114:     JMP 42
 125:     RETURN loc0

method some_F17(this, par0): @5456
  locals: loc0,loc1
   0:     par1 := this."length"
  13:     loc0 := 0
  23:     JMP 103 IF NOT (loc0 < par1)
  39:     CALL par0(this[loc0], loc0, this)
  58:     JMP 79 IF NOT ret_val()
  70:     RETURN true()
  79:     loc0 := (loc0 + 1)
  92:     JMP 23
 103:     RETURN false()

method pop_F18(this): @5564
  locals: loc0,loc1
   0:     par0 := (this."length" - 1)
  15:     JMP 39 IF NOT (par0 < 0)
  30:     RETURN undefined
  39:     loc0 := this[par0]
  53:     CALL this."insert"(par0, -1)
  68:     RETURN loc0

method unshift_F19(this, par0): @5636
  locals: loc0
   0:     CALL this."insert"(0, par0."length")
  17:     par1 := 0
  27:     JMP 86 IF NOT (par1 < par0."length")
  45:     this[par1] := par0[par1]
  62:     par1 := (par1 + 1)
  75:     JMP 27
  86:     RETURN this."length"

method reduce_F20(this, par0, par1): @5728
  locals: loc0,loc1
   0:     par2 := this."length"
  13:     loc0 := 0
  23:     JMP 92 IF NOT (loc0 < par2)
  39:     CALL par0(par1, this[loc0], loc0)
  58:     par1 := ret_val()
  68:     loc0 := (loc0 + 1)
  81:     JMP 23
  92:     RETURN par1

method trim_F21(this): @5824
  locals: loc0,loc1
   0:     par0 := 0
  10:     JMP 91 IF NOT (par0 < this."length")
  28:     CALL isSpace_F41(this[par0])
  43:     JMP 67 IF NOT !ret_val()
  91:     loc0 := (this."length" - 1)
 106:     JMP 185 IF NOT (par0 <= loc0)
 122:     CALL isSpace_F41(this[loc0])
 137:     JMP 161 IF NOT !ret_val()
 185:     CALL this."slice"(par0, (loc0 + 1))
 203:     RETURN ret_val()

method includes_F22(this, par0, par1): @6032
   0:     CALL this."indexOf"(par0, par1)
  16:     RETURN (0 <= ret_val())

method startsWith_F23(this, par0, par1): @6052
   0:     JMP 26 IF NOT !(0 < par1)
  16:     par1 := 0
  26:     CALL this."indexOf"(par0, par1, (par1 + 1))
  46:     RETURN (0 <= ret_val())

method split_F24(this, par0, par1): @6104
  locals: loc0,loc1,loc2,loc3,loc4,loc5,loc6,loc7,loc8,loc9
   0:     par2 := this
  11:     ALLOC_ARRAY initial_size=0
  20:     loc0 := ret_val()
  30:     loc1 := 0
  40:     JMP 83 IF NOT (par1 === undefined)
  55:     loc1 := (536870912 - 1)
 132:     loc2 := par2."length"
 145:     loc3 := 0
 155:     loc4 := par0
 166:     JMP 191 IF NOT (loc1 === 0)
 181:     RETURN loc0
 191:     JMP 229 IF NOT (par0 === undefined)
 206:     loc0[0] := par2
 219:     RETURN loc0
 229:     JMP 317 IF NOT (loc2 === 0)
 244:     CALL splitMatch_F42(par2, 0, loc4)
 259:     loc7 := ret_val()
 269:     JMP 294 IF NOT (-1 < loc7)
 284:     RETURN loc0
 294:     loc0[0] := par2
 307:     RETURN loc0
 317:     loc6 := loc3
 328:     JMP 550 IF NOT (loc6 !== loc2)
 344:     CALL splitMatch_F42(par2, loc6, loc4)
 360:     loc8 := ret_val()
 370:     JMP 409 IF NOT (loc8 < 0)
 385:     loc6 := (loc6 + 1)
 539:     JMP 328
 550:     CALL par2."slice"(loc3, loc6)
 566:     loc5 := ret_val()
 576:     CALL loc0."push"(loc5)
 590:     RETURN loc0

proc emitter_F25(): @6700
   0:     CALL (new Emitter_F43)()
  11:     RETURN ret_val()

method error_F26(this, par0): @6716
   0:     CALL ds."format"("socket {0}: {1}", this."name", par0)
  18:     CALL (new Error)(ret_val())
  30:     RETURN ret_val()

method check_F27(this): @6748
   0:     JMP 39 IF NOT (this !== {G3})
  16:     CALL this."error"("old socket used")
  30:     THROW ret_val()
  39:     RETURN undefined

method close_F28(this): @6792
  locals: loc0
   0:     JMP 46 IF NOT (this === {G3})
  16:     CALL ds."_socketClose"()
  26:     par0 := ret_val()
  36:     {G3} := null
  46:     RETURN undefined

method recv_F29(this, par0): @6840
  locals: loc0,loc1
   0:     JMP 51 IF NOT this."buffers"."length"
  17:     CALL this."buffers"."shift"()
  31:     loc0 := ret_val()
  41:     RETURN loc0
  51:     JMP 78 IF NOT this."lastError"
  66:     THROW this."lastError"
  78:     JMP 102 IF NOT this."closed"
  93:     RETURN null
 102:     CALL ds."wait"(this."emitter", par0)
 118:     par1 := ret_val()
 128:     JMP 152 IF NOT (par1 === undefined)
 143:     RETURN undefined
 152:     JMP 0
 163:     RETURN undefined

method readLine_F30(this): @7008
  locals: loc0,loc1,loc2,loc3,loc4,loc5,loc6
   0:     ALLOC_ARRAY initial_size=0
   9:     loc1 := ret_val()
  19:     CALL this."recv"()
  31:     loc3 := ret_val()
  41:     JMP 67 IF NOT (loc3 == null)
 308:     JMP 334 IF NOT (loc1."length" === 0)
 325:     RETURN null
 334:     par0 := Buffer."concat"
 347:     ALLOC_ARRAY initial_size=0
 356:     loc0 := ret_val()
 366:     CALL loc0."pushRange"(loc1)
 380:     CALL par0(...loc0)
 392:     loc2 := ret_val()
 402:     CALL loc2."toString"("utf-8")
 416:     RETURN ret_val()

method send_F31(this, par0): @7428
  locals: loc0,loc1
   0:     CALL this."check"()
  12:     CALL ds."_socketWrite"(par0)
  24:     loc0 := ret_val()
  34:     JMP 60 IF NOT (loc0 === 0)
 144:     RETURN undefined

method finish_F32(this, par0): @7576
   0:     JMP 42 IF NOT (par0 !== null)
  15:     CALL this."error"(par0)
  29:     this["lastError"] := ret_val()
  42:     this["closed"] := true()
  55:     {G3} := null
  65:     CALL this."emitter"."emit"(false())
  80:     RETURN undefined

method _socketOnEvent_F33(this, par0, par1): @7660
  locals: loc0
   0:     JMP 77 IF NOT (par0 !== "data")
  16:     ret_val := {G3}
  26:     JMP 48 IF ret_val is nullish
  37:     ret_val := ret_val()."name"
  48:     CALL ds."format"("socket {0} {1} {2}", ret_val(), par0, par1)
  65:     CALL ds."print"(63, ret_val())
  77:     JMP 100 IF NOT !{G3}
  91:     RETURN undefined
 100:     par2 := par0
 111:     JMP 186 IF NOT (par2 !== "open")
 127:     JMP 212 IF NOT (par2 !== "close")
 143:     JMP 236 IF NOT (par2 !== "error")
 159:     JMP 264 IF NOT (par2 !== "data")
 306:     CALL ds."format"("unknown event {0}", par0)
 320:     CALL ds."print"(42, ret_val())
 332:     RETURN undefined

method _connect_F34(this, par0): @7996
  locals: loc0,loc1,loc2,loc3,loc4,loc5,loc6,loc7,loc8,loc9
   0:     par1 := par0
  11:     loc1 := par1."host"
  24:     loc2 := par1."port"
  37:     loc3 := par1."proto"
  50:     JMP 75 IF NOT !loc3
  64:     loc3 := "tcp"
  75:     JMP 114 IF NOT (loc3 === "tls")
  91:     par1 := -loc2
 125:     loc4 := par1
 136:     DeviceScript["_socketOnEvent"] := Socket_F5."_socketOnEvent"
 152:     ret_val := {G3}
 162:     JMP 195 IF ret_val is nullish
 173:     CALL ret_val()."finish"("terminated")
 186:     ret_val := ret_val()
 195:     CALL ds."format"("{0}://{1}:{2}", loc3, loc1, loc2)
 213:     CALL (new Socket_F5)(ret_val())
 225:     loc5 := ret_val()
 235:     {G3} := loc5
 246:     CALL ds."format"("connecting to {0}", {G3}."name")
 262:     CALL ds."print"(63, ret_val())
 274:     CALL ds."_socketOpen"(par0."host", loc4)
 290:     loc6 := ret_val()
 300:     JMP 383 IF NOT (loc6 !== 0)
 315:     par1 := loc5."error"
 328:     CALL ds."format"("can't connect: {0}", loc6)
 342:     CALL par1(ret_val())
 353:     loc8 := ret_val()
 363:     {G3} := null
 373:     THROW loc8
 383:     loc0 := loc5."emitter"
 396:     par1 := par0."timeout"
 409:     JMP 436 IF NOT !par1
 423:     par1 := 30000
 436:     CALL ds."wait"(loc0, par1)
 450:     loc7 := ret_val()
 460:     JMP 487 IF NOT loc5."lastError"
 475:     THROW loc5."lastError"
 487:     JMP 525 IF NOT (loc7 === undefined)
 502:     CALL loc5."error"("Timeout")
 516:     THROW ret_val()
 525:     ret_val := {G3}
 535:     JMP 557 IF ret_val is nullish
 546:     ret_val := ret_val()."closed"
 557:     CALL ds."assert"(!ret_val())
 569:     CALL ds."assert"((loc7 === true()))
 583:     RETURN {G3}

method append_F35(this, par0, par1): @8584
   0:     CALL par0."toLowerCase"()
  12:     par0 := ret_val()
  22:     CALL this."has"(par0)
  36:     JMP 86 IF NOT ret_val()
  48:     this."data"[par0] := ((this."data"[par0] + ", ") + par1)
 102:     RETURN undefined

method has_F36(this, par0): @8688
  locals: loc0
   0:     par1 := this."data"
  13:     CALL par0."toLowerCase"()
  25:     RETURN (par1[ret_val()] !== undefined)

method set_F37(this, par0, par1): @8720
  locals: loc0
   0:     par2 := this."data"
  13:     CALL par0."toLowerCase"()
  25:     par2[ret_val()] := par1
  38:     RETURN undefined

method serialize_F38(this): @8760
  locals: loc0
   0:     ALLOC_ARRAY initial_size=0
   9:     par0 := ret_val()
  19:     CALL this."forEach"(CLOSURE(inline_F39))
  33:     CALL par0."push"("")
  47:     CALL par0."join"("\r\n")
  61:     RETURN ret_val()

proc inline_F39(par0, par1): @8824
  locals: loc0
   0:     loc0 := load_closure(local_clo_idx=1, levels=1)."push"
  14:     CALL ds."format"("{0}: {1}", par1, par0)
  30:     CALL loc0(ret_val())
  41:     RETURN undefined

method text_F40(this): @8868
   0:     CALL this."buffer"()
  12:     CALL ret_val()."toString"("utf-8")
  25:     RETURN ret_val()

proc isSpace_F41(par0): @8896
   0:     CALL " \t\n\r\u000b\f                 　﻿"."indexOf"(par0)
  14:     RETURN (0 <= ret_val())

proc splitMatch_F42(par0, par1, par2): @8916
  locals: loc0
   0:     CALL par0."indexOf"(par2, par1, (par1 + 1))
  20:     JMP 62 IF NOT (ret_val() === par1)
  35:     loc0 := (par1 + par2."length")
  72:     RETURN loc0

ctor Emitter_F43(this): @8992
   0:     RETURN undefined

proc assert_F44(par0, par1): @8996
  locals: loc0
   0:     JMP 87 IF NOT !par0
  14:     JMP 51 IF NOT (par1 !== undefined)
  29:     loc0 := par1
  62:     CALL (new Error)(("Assertion failed: " + loc0))
  78:     THROW ret_val()
  87:     RETURN undefined

method shift_F45(this): @9088
  locals: loc0
   0:     JMP 26 IF NOT (this."length" === 0)
  17:     RETURN undefined
  26:     par0 := this[0]
  39:     CALL this."insert"(0, -1)
  53:     RETURN par0

method concat_F46(this, par0): @9144
  locals: loc0
   0:     CALL Buffer."alloc"((this."length" + par0."length"))
  21:     par1 := ret_val()
  31:     CALL par1."set"(this)
  45:     CALL par1."set"(par0, this."length")
  63:     RETURN par1

method slice_F47(this, par0, par1): @9212
  locals: loc0,loc1,loc2
   0:     JMP 28 IF NOT (par1 === undefined)
  15:     par1 := this."length"
  28:     JMP 53 IF NOT (par0 === undefined)
  43:     par0 := 0
  53:     loc0 := (par1 - par0)
  67:     par2 := (loc0 <= 0)
  80:     JMP 110 IF NOT !par2
  94:     par2 := (this."length" <= par0)
 110:     JMP 145 IF NOT par2
 123:     CALL Buffer."alloc"(0)
 136:     RETURN ret_val()
 145:     CALL Buffer."alloc"(loc0)
 159:     loc1 := ret_val()
 169:     CALL loc1."blitAt"(0, this, par0, loc0)
 188:     RETURN loc1

proc concat_F48(par0): @9404
  locals: loc0,loc1,loc2,loc3,loc4,loc5
   0:     loc2 := 0
  10:     loc0 := par0
  21:     loc1 := 0
  31:     loc4 := undefined
  41:     JMP 113 IF NOT (loc1 < loc0."length")
  59:     loc4 := loc0[loc1]
  73:     loc2 := (loc2 + loc4."length")
  89:     loc1 := (loc1 + 1)
 102:     JMP 41
 113:     CALL Buffer."alloc"(loc2)
 127:     loc3 := ret_val()
 137:     loc2 := 0
 147:     loc0 := par0
 158:     loc1 := 0
 168:     loc5 := undefined
 178:     JMP 271 IF NOT (loc1 < loc0."length")
 196:     loc5 := loc0[loc1]
 210:     CALL loc3."blitAt"(loc2, loc5, 0, loc5."length")
 231:     loc2 := (loc2 + loc5."length")
 247:     loc1 := (loc1 + 1)
 260:     JMP 178
 271:     RETURN loc3

method subscribe_F49(this, par0): @9680
  locals: loc0,loc1
   0:     JMP 38 IF NOT !this."handlers"
  16:     ALLOC_ARRAY initial_size=0
  25:     this["handlers"] := ret_val()
  38:     CALL handlerWrapper_F50(par0)
  50:     par1 := ret_val()
  60:     CALL this."handlers"."push"(par1)
  76:     loc0 := this
  87:     RETURN CLOSURE(inline_F53)

proc handlerWrapper_F50(par0): @9772
  locals: loc0,loc1,loc2
   0:     loc2 := CLOSURE(emit_F51)
  11:     loc0 := 0
  21:     RETURN CLOSURE(inline_F52)

proc emit_F51(): @9796
  locals: loc0
   0:     TRY 63
  11:     JMP 63 IF NOT (load_closure(local_clo_idx=1, levels=1) === 1)
  27:     STORE_CLOSURE local_clo_idx=1 levels=1 2
  38:     CALL load_closure(local_clo_idx=0, levels=1)(load_closure(local_clo_idx=2, levels=1))
  52:     JMP 11
  63:     FINALLY 
  71:     loc0 := ret_val()
  81:     STORE_CLOSURE local_clo_idx=1 levels=1 0
  92:     RE_THROW loc0
 102:     RETURN undefined

proc inline_F52(par0): @9900
   0:     STORE_CLOSURE local_clo_idx=2 levels=1 par0
  12:     JMP 41 IF NOT (load_closure(local_clo_idx=1, levels=1) === 0)
  28:     CALL load_closure(local_clo_idx=3, levels=1)."start"()
  41:     STORE_CLOSURE local_clo_idx=1 levels=1 1
  52:     RETURN undefined

proc inline_F53(): @9956
  locals: loc0
   0:     CALL load_closure(local_clo_idx=3, levels=1)."handlers"."indexOf"(load_closure(local_clo_idx=2, levels=1))
  18:     loc0 := ret_val()
  28:     JMP 61 IF NOT (0 <= loc0)
  43:     CALL load_closure(local_clo_idx=3, levels=1)."handlers"."insert"(loc0, -1)
  61:     RETURN undefined

method emit_F54(this, par0): @10020
  locals: loc0,loc1,loc2
   0:     ret_val := this."handlers"
  12:     JMP 34 IF ret_val is nullish
  23:     ret_val := ret_val()."length"
  34:     JMP 56 IF NOT !ret_val()
  47:     RETURN undefined
  56:     par1 := this."handlers"
  69:     loc0 := 0
  79:     loc1 := undefined
  89:     JMP 157 IF NOT (loc0 < par1."length")
 107:     loc1 := par1[loc0]
 121:     CALL loc1(par0)
 133:     loc0 := (loc0 + 1)
 146:     JMP 89
 157:     RETURN undefined

proc wait_F55(par0, par1): @10180
  locals: loc0,loc1,loc2
   0:     CALL DsFiber."self"()
  12:     loc0 := ret_val()
  22:     CALL par0."subscribe"(CLOSURE(inline_F58))
  36:     loc1 := ret_val()
  46:     CALL ds."suspend"(par1)
  58:     loc2 := ret_val()
  68:     CALL loc1()
  78:     loc1 := noop_F59
  89:     RETURN loc2

method forEach_F56(this, par0): @10272
  locals: loc0,loc1,loc2
   0:     CALL Object."keys"(this."data")
  14:     par1 := ret_val()
  24:     loc0 := 0
  34:     loc1 := undefined
  44:     JMP 121 IF NOT (loc0 < par1."length")
  62:     loc1 := par1[loc0]
  76:     CALL par0(this."data"[loc1], loc1, this)
  97:     loc0 := (loc0 + 1)
 110:     JMP 44
 121:     RETURN undefined

method buffer_F57(this): @10396
  locals: loc0,loc1,loc2,loc3,loc4,loc5
   0:     JMP 27 IF NOT this."_buffer"
  15:     RETURN this."_buffer"
  27:     CALL this."headers"."get"("content-length")
  43:     CALL ds."parseInt"(ret_val())
  54:     loc1 := ret_val()
  64:     ALLOC_ARRAY initial_size=0
  73:     loc2 := ret_val()
  83:     loc3 := 0
  93:     CALL this."socket"."recv"()
 107:     loc4 := ret_val()
 117:     JMP 142 IF NOT !loc4
 210:     CALL this."socket"."close"()
 224:     par0 := Buffer."concat"
 237:     ALLOC_ARRAY initial_size=0
 246:     loc0 := ret_val()
 256:     CALL loc0."pushRange"(loc2)
 270:     CALL par0(...loc0)
 282:     this["_buffer"] := ret_val()
 295:     RETURN this."_buffer"

proc inline_F58(par0): @10696
   0:     CALL load_closure(local_clo_idx=3, levels=1)()
  11:     STORE_CLOSURE local_clo_idx=3 levels=1 noop_F59
  23:     JMP 54 IF NOT load_closure(local_clo_idx=2, levels=1)."suspended"
  39:     CALL load_closure(local_clo_idx=2, levels=1)."resume"(par0)
  54:     RETURN undefined

proc noop_F59(): @10752
   0:     RETURN undefined

method indexOf_F60(this, par0, par1): @10756
  locals: loc0
   0:     par2 := this."length"
  13:     JMP 38 IF NOT (par1 == undefined)
  28:     par1 := 0
  38:     JMP 107 IF NOT (par1 < par2)
  54:     JMP 83 IF NOT (this[par1] === par0)
  73:     RETURN par1
  83:     par1 := (par1 + 1)
  96:     JMP 38
 107:     RETURN -1

method set_F61(this, par0, par1): @10868
   0:     JMP 24 IF NOT !par1
  14:     par1 := 0
  24:     CALL this."blitAt"(par1, par0, 0, par0."length")
  45:     RETURN undefined

method get_F62(this, par0): @10916
  locals: loc0,loc1
   0:     par1 := this."data"
  13:     CALL par0."toLowerCase"()
  25:     loc0 := par1[ret_val()]
  38:     JMP 62 IF NOT (loc0 === undefined)
  53:     RETURN null
  62:     RETURN loc0

Strings ASCII:
   0: "start!"
   1: "fetch"
   2: "method"
   3: "GET"
   4: "headers"
   5: "Headers"
   6: "body"
   7: "tcp"
   8: "startsWith"
   9: "https://"
  10: "tls"
  11: "http://"
  12: "invalid url: {0}"
  13: "/"
  14: "includes"
  15: "@"
  16: "credentials in URL not supported: {0}"
  17: ":"
  18: "invalid port in url: {0}"
  19: "body has to be string or buffer; got {0}"
  20: "has"
  21: "user-agent"
  22: "DeviceScript fetch()"
  23: "accept"
  24: "*/*"
  25: "host"
  26: "connection"
  27: "content-length"
  28: "{0} {1} HTTP/1.1\r\n{2}\r\n"
  29: "serialize"
  30: "connect"
  31: "Socket"
  32: "buffers"
  33: "emitter"
  34: "_connect"
  35: "port"
  36: "proto"
  37: "req: {0}"
  38: "send"
  39: "Response"
  40: "socket"
  41: "readLine"
  42: "HTTP/1.1 "
  43: "status"
  44: " "
  45: "statusText"
  46: "ok"
  47: "HTTP {0}: {1}"
  48: "trim"
  49: "append"
  50: "{0}"
  51: "http://localhost/check"
  52: "text"
  53: "fetched key: {0}"
  54: "Invalid key"
  55: "split"
  56: "-"
  57: "some"
  58: "key format ok"
  59: "passed check1"
  60: "concat"
  61: "reduce"
  62: "passed check2"
  63: "nextInt"
  64: "passed check3"
  65: "success!"
  66: "0123456789ABCDFGHJKLMNPQRSTUWXYZ"
  67: "socket {0}: {1}"
  68: "check"
  69: "old socket used"
  70: "recv"
  71: "lastError"
  72: "closed"
  73: "send error {0}"
  74: "finish"
  75: "emit"
  76: "socket {0} {1} {2}"
  77: "unknown event {0}"
  78: "terminated"
  79: "{0}://{1}:{2}"
  80: "connecting to {0}"
  81: "can't connect: {0}"
  82: "timeout"
  83: "Timeout"
  84: ", "
  85: "\r\n"
  86: "{0}: {1}"
  87: "isSpace"
  88: "splitMatch"
  89: "Emitter"
  90: "handlers"
  91: "handlerWrapper"
  92: "_buffer"
  93: "Assertion failed: "
  94: "noop"
  95: "start!"

Strings UTF8:
   0: " \t\n\r\u000b\f                 　﻿" (62 bytes 25 codepoints)

Strings buffer:

Doubles:
   0: 12534912000
   1: 4294967295
   2: 2897974129

DCFG: h=0100000000000000 sz=148 {
    "@name": "(no name)"
}


