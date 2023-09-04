# DownUnderCTF 2023

## blinkybill

> Hey hey it's Blinky Bill!
> 
> NOTE: Flag is case-insensitive and requires placing inside `DUCTF{}` wrapper!
>
>  Author: Yo_Yo_Bro
>
> [`blinkybill.wav`](blinkybill.wav)

Tags: _pwn_

## Solution
This challenge comes with a `wav` file. When playing the file we can hear a song and some overlayed beep sounds. This strongly smells like `morse code`. Opening the file in `Audacity` and applying some high-/deep pass filters we can see the single beeps quite nicely isolated from each other. Putting them together we find `-... .-. .. -. --. -... .- -.-. -.- - .... . - .-. . . ...` which is `BRINGBACKTHETREES`.

Flag `DUCTF{BRINGBACKTHETREES}`