# 1337UP LIVE CTF 2023

## FlagChecker

> Anonymous has hidden a message inside this exe, can you extract it?
> 
> Author: Mohamed Adil
> 
> Password is "infected"
> 
> [`Anonymous.zip`](Anonymous.zip)

Tags: _rev_

## Solution
After extracting the zipfile we get a `.NET binary`. Inspecting with `ILspy` gives us the following code.

```csharp
private static void Main(string[] args)
{
    Console.WriteLine(Resources.anon);
    string text = "We are Anonymous";
    for (int i = 0; i < text.Length; i++)
    {
        Console.Write(text[i]);
        Thread.Sleep(30);
    }
    Console.WriteLine("\nEnter Password:");
    string text2 = Console.ReadLine();
    text = "Checking Password......";
    for (int i = 0; i < text.Length; i++)
    {
        Console.Write(text[i]);
        Thread.Sleep(30);
    }
    Console.WriteLine();
    if (IsBase64String(text2) && text2.Length > 20 && text2.Length <= 30 && Resources.anon.Contains(text2))
    {
        string @string = Encoding.ASCII.GetString(Convert.FromBase64String(text2));
        if (@string[1] == 'n' && @string[3] == 'i')
        {
            text = "MayBe Your Password Isn't Correct I'm Not Sure : " + @string;
            for (int i = 0; i < text.Length; i++)
            {
                Console.Write(text[i]);
                Thread.Sleep(30);
            }
        }
    }
    else
    {
        text = "Password Incorrect";
        for (int i = 0; i < text.Length; i++)
        {
            Console.Write(text[i]);
            Thread.Sleep(30);
        }
    }
    Console.ReadLine();
}
```

We can't read the flag from this, but the code gives a few informations. The flag is between 21 and 30 characters long, is a `base64` encoded string and is contained in the banner that is printed at program start. The banner is some ascii art that we can extract from the binaries resource section. After this it's only about scanning the string for fitting base64 sequences until it gives us the flag.

```python
import base64 

s = ".hssMy/  `.`   .````.``o/sy-`.````.   `.` `+yM/dh``-mN-sod: .`    .    .  `y:/My  .    .    `. /dso:My/``d`MyyNy.`.```` .     `    .y:   `     . ````.`.yNhmd:dsM.Nmos. .    `.`````.`````/:`````.`````.     . :o+dh+M+hM/ooNo .`     .     .     yy     .     .     `. oNs/sMs:sMomN+  .     ``     .     --     .     ``     .  +NNyM/+`m`mNd:o ``     ``     . `/`oyyo`/` .     ``     `` y-hNy.N`My-d-N/ `.`````..``-:/shNd `hh` dNhs/:-``..`````.` +N:y.dNhMo-NN` `.     ```NMMMMMM/ .++. /MMMMMMN```     .` `NM-hMs:NMyM+/  .     `.sMMMMMMMs  dd  sMMMMMMMs.`     .  o/MhMd:`h-yNm`N. ``     -NMMMMMMMN. MM .NMMMMMMMN-     `` :N`dN+:msNo/s/M+  .` ```+MMMMMMMMMm-MM-mMMMMMMMMM+``` `. `oM:o:yM/oMN+/My:- ..`  yMMLjKYleQcOuaspJRvVAKvMMy  `.. /:yM/yMm:`/sNdNm`N+ `.  NMMMFxz5\fxC2FzvnbtMg4XvMN  .` sN NNmm++`:y:/yN:hM/  `:MMMMbM90gfG65GcGKsTrfxMMMM:`  +My+do:+d-.hNhoo-NN:o.:MMMW4vf2ScKgE5gSzV9o0XgMMM:-s:Nm-oymNs`.smMaNhmd:NyyNaW50aWdyaXRpe0Jhc2VfUl9Fej99NdMNho`.+o++ooo:yMddNMAzE3tYXvrft43Fh7NdmmNs-ooo++o+`-sdMMNNmmNmmMfjVBGe3l4sMcQ9t1QVMdddmNMMMNh+..++//:/odMOW4t1WUJ4otsj7UuNhZWms+://++-:oyddhNB0lABs8YATzKPXmT4oajNyhys+-`2nDxDEXJsYx1aSvN38Ht`-+sydmNNMMMMNNmdys+-`"

for x in range(20,31):
    for i in range(len(s)):
        try:
            s1 = s[i:i+x]
            print(base64.b64decode(s1))
        except:
            pass
```

Flag `intigriti{Base_R_Ez?}`