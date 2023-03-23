# Cyber Apocalypse 2023

## Cave System

> Deep inside a cave system, 500 feet below the surface, you find yourself stranded with supplies running low. Ahead of you sprawls a network of tunnels, branching off and looping back on themselves. You don't have time to explore them all - you'll need to program your cave-crawling robot to find the way out...
>
>  Author: N/A
>
> [`rev_cavesystem.zip`](rev_cavesystem.zip)

Tags: _rev_

## Solution
After opening the executable `cave` in Ghidra we are presented with an huge if expression. After some cleaning one can see that the expression is pretty much a bunch of equations. Also we have the first three values given since they are hard tested against `HTB{`.

```c++
printf("What route will you take out of the cave? ");
  fgets((char *)&local_88,0x80,stdin);
  iVar1 = memcmp(&local_88,&DAT_00102033,4);
  if (((((((iVar1 == 0) && ((byte)(local_78._5_1_ * (char)local_58) == '\x14')) &&
         ((byte)((byte)local_68 - local_68._4_1_) == -6)) &&
        (((((((byte)(local_68._5_1_ - local_70._2_1_) == -0x2a &&
             ((byte)((byte)local_78 - (char)local_58) == '\b')) &&
            (((char)(local_58._7_1_ - (char)local_80) == -0x2b &&
             (((byte)(local_70._2_1_ * local_88._7_1_) == -0x13 &&
              ((char)(local_88._4_1_ * (char)local_70) == -0x38)))))) &&
           ((local_68._2_1_ ^ local_70._4_1_) == 0x55)) &&
          (((((byte)(local_70._6_1_ - local_58._7_1_) == '4' &&
             ((byte)(local_50._3_1_ + local_58._2_1_) == -0x71)) &&
            ((byte)(local_60._4_1_ + local_70._3_1_) == -0x2a)) &&
           (((local_78._1_1_ ^ local_80._6_1_) == 0x31 &&
            ((byte)((byte)local_50 * local_78._4_1_) == -0x54)))))) &&
         (((((byte)(local_50._2_1_ - local_70._2_1_) == -0x3e &&
            (((local_70._2_1_ ^ local_88._6_1_) == 0x2f &&
             ((local_80._6_1_ ^ local_68._7_1_) == 0x5a)))) &&
           ((local_60._4_1_ ^ local_68._7_1_) == 0x40)) &&
          ((((((byte)local_60 == local_70._2_1_ &&
              ((byte)(local_78._7_1_ + local_58._1_1_) == -0x68)) &&
             ((byte)(local_78._7_1_ * local_50._3_1_) == 'h')) &&
            (((byte)(local_88._1_1_ - local_70._4_1_) == -0x25 &&
             ((byte)((char)local_70 - local_70._5_1_) == -0x2e)))) &&
           (((char)(local_68._6_1_ - (char)local_70) == '.' &&
            ((((byte)local_68 ^ local_78._6_1_) == 0x1a &&
             ((byte)(local_60._4_1_ * local_88._4_1_) == -0x60)))))))))))) &&
       ((((((byte)(local_68._6_1_ * local_70._3_1_) == '^' &&
           ((((byte)(local_80._7_1_ - (byte)local_60) == -0x38 &&
             ((local_58._1_1_ ^ local_58._5_1_) == 0x56)) &&
            ((local_70._2_1_ ^ local_60._5_1_) == 0x2b)))) &&
          ((((((local_58._6_1_ ^ local_80._1_1_) == 0x19 &&
              ((byte)(local_70._4_1_ - local_60._7_1_) == '\x1a')) &&
             (((byte)(local_58._2_1_ + local_78._3_1_) == -0x5f &&
              (((byte)(local_68._5_1_ + local_50._1_1_) == 'V' &&
               ((local_70._5_1_ ^ local_78._2_1_) == 0x38)))))) &&
            ((local_60._4_1_ ^ local_50._4_1_) == 9)) &&
           ((((((char)(local_80._7_1_ * local_68._6_1_) == 'y' &&
               ((local_68._5_1_ ^ local_70._6_1_) == 0x5d)) &&
              ((byte)(local_88._2_1_ * (byte)local_68) == '\\')) &&
             (((byte)(local_80._2_1_ * local_78._2_1_) == '9' && (local_70._5_1_ == local_78._5_1_))
             )) && (((byte)(local_68._3_1_ * local_78._5_1_) == '/' &&
                    (((byte)((char)local_80 * local_68._5_1_) == -0x55 &&
                     ((byte)(local_68._7_1_ + local_70._2_1_) == -0x6d)))))))))) &&
         (((((((local_70._2_1_ ^ local_68._2_1_) == 0x73 &&
              ((((local_78._4_1_ ^ local_70._7_1_) == 0x40 &&
                ((byte)(local_70._1_1_ + (byte)local_78) == -0x57)) &&
               ((local_68._7_1_ ^ local_50._3_1_) == 0x15)))) &&
             ((((byte)((byte)local_88 + local_50._3_1_) == 'i' &&
               ((byte)(local_68._2_1_ + local_60._6_1_) == -0x5b)) &&
              (((local_70._6_1_ ^ local_58._4_1_) == 0x37 &&
               (((byte)((byte)local_88 * local_70._4_1_) == '\b' &&
                ((byte)(local_68._2_1_ - (byte)local_50) == -0x3b)))))))) &&
            ((byte)(local_78._2_1_ + local_50._4_1_) == -0x1c)) &&
           (((((local_68._3_1_ ^ (byte)local_60) == 0x6e &&
              ((byte)((byte)local_50 * (byte)local_78) == -0x54)) &&
             ((byte)(local_58._6_1_ - local_60._7_1_) == '\r')) &&
            ((((byte)(local_70._6_1_ + local_58._7_1_) == -100 &&
              ((byte)(local_88._6_1_ + local_68._1_1_) == -0x2c)) &&
             (((byte)(local_88._7_1_ * local_70._5_1_) == -0x13 &&
              ((((byte)local_50 ^ local_70._5_1_) == 0x38 &&
               ((byte)(local_88._1_1_ * local_68._5_1_) == 'd')))))))))) &&
          ((((byte)local_50 ^ local_50._2_1_) == 0x46 &&
           (((((((char)(local_88._2_1_ * local_78._3_1_) == '&' &&
                ((local_70._2_1_ ^ local_78._6_1_) == 0x2b)) &&
               ((byte)(local_88._1_1_ + local_88._7_1_) == -0x79)) &&
              (((local_70._3_1_ ^ (byte)local_88) == 0x2a &&
               ((byte)(local_78._5_1_ - local_88._1_1_) == '\v')))) &&
             ((byte)(local_70._3_1_ + local_58._6_1_) == -0x32)) &&
            (((local_78._1_1_ ^ local_80._5_1_) == 0x3b &&
             ((byte)(local_78._3_1_ - local_50._2_1_) == '\x12')))))))))) &&
        ((((local_78._1_1_ == local_80._2_1_ &&
           ((((byte)(local_80._6_1_ - local_50._2_1_) == 'M' &&
             ((byte)(local_60._2_1_ * local_58._4_1_) == 'N')) && (local_58._2_1_ == (byte)local_68)
            ))) && (((local_60._7_1_ ^ local_58._3_1_) == 0x38 &&
                    ((char)(local_68._6_1_ + local_70._1_1_) == -0x6c)))) &&
         ((byte)(local_60._1_1_ + local_58._4_1_) == -0x31)))))) &&
      ((((local_60._4_1_ == local_78._4_1_ && ((char)(local_80._4_1_ + local_70._1_1_) == 'f')) &&
        (((byte)(local_50._4_1_ + local_68._4_1_) == -0xf &&
         ((((byte)(local_60._1_1_ - local_78._5_1_) == '\x11' &&
           ((byte)(local_68._4_1_ - local_58._1_1_) == 'D')) &&
          ((byte)(local_80._1_1_ - local_68._3_1_) == 'D')))))) &&
       ((((local_58._5_1_ ^ local_58._3_1_) == 1 && ((local_68._2_1_ ^ local_50._1_1_) == 0xd)) &&
        ((((byte)(local_80._3_1_ - local_70._4_1_) == -0x15 &&
          (((((char)(local_78._7_1_ + (char)local_70) == -0x67 &&
             ((byte)((char)local_70 + local_80._5_1_) == -0x6b)) &&
            (((byte)(local_80._4_1_ - (byte)local_88) == -0x17 &&
             (((((byte)(local_68._2_1_ + local_70._7_1_) == '`' &&
                ((byte)(local_88._5_1_ + local_58._5_1_) == -0x6a)) &&
               ((byte)(local_58._1_1_ * local_60._2_1_) == '`')) &&
              (((byte)((char)local_58 * local_78._5_1_) == '\x14' &&
               ((byte)(local_70._3_1_ - local_58._4_1_) == '\x03')))))))) &&
           ((byte)(local_50._1_1_ + local_78._4_1_) == -0x6b)))) &&
         ((((byte)(local_80._2_1_ * local_58._5_1_) == -0x26 &&
           ((byte)(local_88._1_1_ + local_60._1_1_) == -0x3c)) &&
          (((byte)(local_60._7_1_ - local_88._1_1_) == '\v' &&
           (((local_60._3_1_ == local_78._3_1_ && ((byte)(local_68._7_1_ + local_60._7_1_) == -0x6d)
             ) && ((byte)(local_80._4_1_ * local_50._2_1_) == 'Q')))))))))))))) &&
     (((((byte)((char)local_80 * local_70._2_1_) == 'A' &&
        ((byte)(local_60._6_1_ - local_70._7_1_) == 'E')) &&
       ((byte)(local_88._7_1_ + local_68._5_1_) == 'h')) &&
      (((((char)(local_68._4_1_ + local_88._4_1_) == -0x44 &&
         ((byte)(local_70._7_1_ + (byte)local_68) == -0x5e)) &&
        (((char)(local_70._1_1_ + local_88._5_1_) == 'e' &&
         ((((byte)(local_60._3_1_ * local_70._5_1_) == -0x13 &&
           ((local_80._5_1_ ^ local_60._5_1_) == 0x10)) &&
          ((char)((char)local_58 - local_80._4_1_) == ';')))))) &&
       (((((char)(local_78._7_1_ - (char)local_80) == '\t' &&
          ((local_88._7_1_ ^ local_60._2_1_) == 0x41)) &&
         ((char)(local_88._5_1_ - local_60._3_1_) == -3)) &&
        (((((local_50._4_1_ ^ local_78._2_1_) == 0x1a && ((local_88._1_1_ ^ local_88._3_1_) == 0x2f)
           ) && (((byte)(local_78._1_1_ - local_68._7_1_) == '+' &&
                 (((((byte)((char)local_80 + local_78._4_1_) == -0x2d &&
                    ((byte)(local_80._3_1_ * local_58._5_1_) == -0x28)) &&
                   ((byte)(local_70._3_1_ + local_88._6_1_) == -0x2e)) &&
                  (((byte)(local_88._5_1_ + local_88._3_1_) == -0x55 &&
                   ((byte)(local_68._3_1_ - local_60._7_1_) == -0x2e)))))))) &&
         (((byte)local_78 ^ local_68._1_1_) == 0x10)))))))))) {
    puts("Freedom at last!");
  }
  else {
    puts("Lost in the darkness, you\'ll wander for eternity...");
  }
```
The whole thing can then be solved be replacing known values and calculating other unknowns until we have all values solved. Taking into account byte range and byte overflow of course. After doing this we have the full list of values:

```c++
s[0] = 72           H
s[1] = 84           T 
s[2] = 66           B
s[3] = 123          {
s[4] = 72           H
s[5] = 48           0
s[6] = 112          p
s[7] = 51           e

(_BYTE)v5 = 95
BYTE1(v5) = 117
BYTE2(v5) = 95
BYES3(v5) = 100
BYTE4(v5) = 49 
BYTE5(v5) = 100
BYTE6(v5) = 110
HIBYTE(v5)= 39

(_BYTE)v6 = 116     t
BYTE1(v6) = 95      _
BYTE2(v6) = 103     g
BYTE3(v6) = 51      3
BYTE4(v6) = 116     t
BYTE5(v6) = 95      _
BYTE6(v6) = 116     t
HIBYTE(v6)= 104     h

(_BYTE)v7 = 49      1
BYTE1(v7) = 53      5
BYTE2(v7) = 95      _
BYTE3(v7) = 98      b
BYTE4(v7) = 121     y
BYTE5(v7) = 95      _
BYTE6(v7) = 104     h
HIBYTE(v7)= 52      4

(_BYTE)v8 = 110     n
BYTE1(v8) = 100     d   ?
BYTE2(v8) = 44      ,   ?
BYTE3(v8) = 49      1
BYTE4(v8) = 116     t
BYTE5(v8) = 53      5
BYTE6(v8) = 95      _
HIBYTE(v8)= 52      4

(_BYTE)v9 = 95      _
BYTE1(v9) = 112     p
BYTE2(v9) = 114     r
BYTE3(v9) = 51      3
BYTE4(v9) = 116     t
BYTE5(v9) = 116     t
BYTE6(v9) = 121     y
HIBYTE(v9)= 95      _

(_BYTE)v10 = 108    l
BYTE1(v10) = 48     0
BYTE2(v10) = 110    n
BYTE3(v10) = 103    g
BYTE4(v10) = 95     _
BYTE5(v10) = 102    f
BYTE6(v10) = 108    l
HIBYTE(v10)= 52     4

(_BYTE)v11 = 103    g
BYTE1(v11) = 33     !
BYTE2(v11) = 33     !
BYTE3(v11) = 33     !
BYTE4(v11) = 125    }
```

And also the flag `HTB{H0p3_u_d1dn't_g3t_th15_by_h4nd,1t5_4_pr3tty_l0ng_fl4g!!!}`.