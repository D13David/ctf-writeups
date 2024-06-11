# BCACTF 5.0

## magic

> I found this piece of paper on the floor. I was going to throw it away, but it somehow screamed at me while I was holding it?!
> 
> Author: Marvin
> 
> [`magic.pdf`](magic.pdf)

Tags: _forensics_

## Solution
For this challenge we get a `pdf` file. It contains some logic, as it's interactively checks our user input. For this we can use `pdfinfo -js` to extract the code.

```bash
$ pdfinfo -js magic.pdf
Name Dictionary "01 c":
    (function(_0x18b13a,_0x4d582d){var _0x3da883=_0x4113,_0x1d0353=_0x18b13a();while(!![]){try{var _0x10c45c=parseInt(_0x3da883(0x1be))/0x1*(-parseInt(_0x3da883(0x1cc))/0x2)+parseInt(_0x3da883(0x1c2))/0x3+parseInt(_0x3da883(0x1c6))/0x4*(parseInt(_0x3da883(0x1c7))/0x5)+-parseInt(_0x3da883(0x1cb))/0x6*(parseInt(_0x3da883(0x1c1))/0x7)+-parseInt(_0x3da883(0x1ca))/0x8+parseInt(_0x3da883(0x1c0))/0x9+parseInt(_0x3da883(0x1c4))/0xa*(parseInt(_0x3da883(0x1bf))/0xb);if(_0x10c45c===_0x4d582d)break;else _0x1d0353['push'](_0x1d0353['shift']());}catch(_0x53c9c0){_0x1d0353['push'](_0x1d0353['shift']());}}}(_0x43c8,0xe20be));function _0x4113(_0x44cfd2,_0x23b14b){var _0x43c873=_0x43c8();return _0x4113=function(_0x4113e1,_0x43c2ed){_0x4113e1=_0x4113e1-0x1bd;var _0x2522f0=_0x43c873[_0x4113e1];return _0x2522f0;},_0x4113(_0x44cfd2,_0x23b14b);}function _0x43c8(){var _0x1355d8=['getField','charCodeAt','100554TvjbzQ','11jHxsKn','7564617EnopjV','2219BJkXWe','3372363teHOVr','alert','5165870pcLTuS','producer','32KYViix','925835vZTXso','Flag is incorrect!','length','8132288HsoZUP','13494jFFdda','26rtwUNT'];_0x43c8=function(){return _0x1355d8;};return _0x43c8();}function update(){var _0x3d0e72=_0x4113,_0x2923fd=this[_0x3d0e72(0x1cd)]('A')['value'],_0x12e8ec=[];for(var _0x28002d=0x0;_0x28002d<_0x2923fd[_0x3d0e72(0x1c9)];_0x28002d++){_0x12e8ec['push'](_0x2923fd[_0x3d0e72(0x1bd)](_0x28002d)^parseInt(info[_0x3d0e72(0x1c5)])%(0x75+_0x28002d));}k=[0x46,0x2d,0x62,0x11,0x6b,0x4c,0x72,0x5f,0x76,0x38,0x19,0x28,0x5f,0x31,0x36,0x63,0xf7,0xb1,0x69,0x2a,0x18,0x5e,0x36,0x1,0x37,0x3a,0x1c,0x5,0x11,0x56,0xe5,0x7b,0x64,0x2c,0x11,0x14,0x53,0x5a,0x35,0x17,0x41,0x62,0x3];if(_0x12e8ec['length']!=k[_0x3d0e72(0x1c9)]){app[_0x3d0e72(0x1c3)](_0x3d0e72(0x1c8));return;}for(var _0x28002d=0x0;_0x28002d<k[_0x3d0e72(0x1c9)];_0x28002d++){if(_0x12e8ec[_0x28002d]!=k[_0x28002d]){app[_0x3d0e72(0x1c3)](_0x3d0e72(0x1c8));return;}}app[_0x3d0e72(0x1c3)]('Flag is correct!');}

Field Activated:
update();

Widget Annotation Activated:
update();
```

This is some obfuscated javascript. After beatifying it we can clean it up, mostly by resolving the encoded strings. For this we copy the functionality that is relevant for decoding to the java console (function _0x4113, _0x43c8, anonymous function at the top). Then we can just call the function with the numeric parameters and see the resolved string value.

For instance: `_0x2923fd = this[_0x3d0e72(0x1cd)]('A')['value']`, the call `_0x3d0e72(0x1cd)` resolves to `getField` so we have `_0x2923fd = this['getField']('A')['value']` or if we don't want the lookup with `[]` we can write `_0x2923fd = this.getField('A')['value']`. After doing this, and some variable renaming, for the script we get.

```js
function update() {
    var user_input = this.getField('A')['value'],
        temp = [];
    for (var i = 0x0; i < user_input.length; i++) {
        temp.push(user_input.charCodeAt(i) ^ parseInt(info.producer) % (0x75 + i));
    }
    k = [0x46, 0x2d, 0x62, 0x11, 0x6b, 0x4c, 0x72, 0x5f, 0x76, 0x38, 0x19, 0x28, 0x5f, 0x31, 0x36, 0x63, 0xf7, 0xb1, 0x69, 0x2a, 0x18, 0x5e, 0x36, 0x1, 0x37, 0x3a, 0x1c, 0x5, 0x11, 0x56, 0xe5, 0x7b, 0x64, 0x2c, 0x11, 0x14, 0x53, 0x5a, 0x35, 0x17, 0x41, 0x62, 0x3];
    if (temp.length != k.length) {
        app.alert('Flag is incorrect!');
        return;
    }
    for (var i = 0x0; i < k.length; i++) {
        if (temp[i] != k[i]) {
            app.alert('Flag is incorrect!');
            return;
        }
    }
    app.alert('Flag is correct!');
}
```

Thats readable. In `k` we have the "encrypted" flag and we can decrypt it by just reapplying the xor operations. Since this comes from a pdf it interacts with the pdf, for instance `this.getField` refrences a input field within the pdf. Also `info.producer` does access metadata, to get the value we can use `exiftool`.

```bash
$ exiftool magic.pdf
ExifTool Version Number         : 12.67
File Name                       : magic.pdf
...
Producer                        : 283548893274
Create Date                     : 2024:05:28 13:48:25-04:00
Modify Date                     : 2024:05:28 13:48:25-04:00
Trapped                         : False
PTEX Fullbanner                 : This is pdfTeX, Version 3.141592653-2.6-1.40.26 (TeX Live 2024/Arch Linux) kpathsea version 6.4.0
```

Now we have all the informations together, lets write a script that decrypts the flag:

```js
let k = [0x46, 0x2d, 0x62, 0x11, 0x6b, 0x4c, 0x72, 0x5f, 0x76, 0x38, 0x19, 0x28, 0x5f, 0x31, 0x36, 0x63, 0xf7, 0xb1, 0x69, 0x2a, 0x18, 0x5e, 0x36, 0x1, 0x37, 0x3a, 0x1c, 0x5, 0x11, 0x56, 0xe5, 0x7b, 0x64, 0x2c, 0x11, 0x14, 0x53, 0x5a, 0x35, 0x17, 0x41, 0x62, 0x3];

let producer = 283548893274

var flag = ""
for (let i = 0; i < k.length; ++i)
{
  flag = flag + String.fromCharCode(k[i] ^ producer % (0x75 + i))
}
console.log(flag)
```

Flag `bcactf{InTerACtIv3_PdFs_W0W_cbd14436e6aea8}`