# Cyber Apocalypse 2023

## Perfect Synchronization

> The final stage of your initialization sequence is mastering cutting-edge technology tools that can be life-changing. One of these tools is quipqiup, an automated tool for frequency analysis and breaking substitution ciphers. This is the ultimate challenge, simulating the use of AES encryption to protect a message. Can you break it?
>
>  Author: N/A
>
> [`crypto_perfect_synchronization.zip`](crypto_perfect_synchronization.zip)

Tags: _crypto_

## Solution
The challenge comes with two files. One python script and a decrypted message. Inspecting the python code leads to the assumption, that the encrypted text is safely encrypted with AES in ECB mode. The weak spot is the deterministic result that is produced as blocks are filed with a 15 byte salt and only one character. 

Therefore we do what the description already hinted: some frequency analysis. For this the input needs to be transferred into some sort of running text. This can be done by [`mapping the blocks to an simple alphabet`](solution.py).

```
with open("./crypto_perfect_synchronization/output.txt", 'r') as f:
    lines = f.readlines()

alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
i = 0
d = {}

result = []
for line in lines:
    b = bytearray(line.encode())
    s = hashlib.md5(b).hexdigest()
    if i < len(alphabet):
        if not s in d:
            d[s] = alphabet[i]
            i = i + 1
        result.append(d[s])
    else:
        print("skip")

print("".join(str(x) for x in result))

```

Invoking this gives us the result we can use with [`quipquip`](https://quipqiup.com/):

```
$ python test.py
ABCDECFGHIJFJKHLMLIMLINJLCOIPFIQRCIAJGQIQRJQIMFIJFHISMTCFILQBCQGRIPAIUBMQQCFIKJFSEJSCIGCBQJMFIKCQQCBLIJFOIGPVNMFJQMPFLIPAIKCQQCBLIPGGEBIUMQRITJBHMFSIABCDECFGMCLIVPBCPTCBIQRCBCIMLIJIGRJBJGQCBMLQMGIOMLQBMNEQMPFIPAIKCQQCBLIQRJQIMLIBPESRKHIQRCILJVCIAPBIJKVPLQIJKKILJVWKCLIPAIQRJQIKJFSEJSCIMFIGBHWQJFJKHLMLIABCDECFGHIJFJKHLMLIJKLPIXFPUFIJLIGPEFQMFSIKCQQCBLIMLIQRCILQEOHIPAIQRCIABCDECFGHIPAIKCQQCBLIPBISBPEWLIPAIKCQQCBLIMFIJIGMWRCBQCYQIQRCIVCQRPOIMLIELCOIJLIJFIJMOIQPINBCJXMFSIGKJLLMGJKIGMWRCBLIABCDECFGHIJFJKHLMLIBCDEMBCLIPFKHIJINJLMGIEFOCBLQJFOMFSIPAIQRCILQJQMLQMGLIPAIQRCIWKJMFQCYQIKJFSEJSCIJFOILPVCIWBPNKCVILPKTMFSILXMKKLIJFOIMAIWCBAPBVCOINHIRJFOIQPKCBJFGCIAPBICYQCFLMTCIKCQQCBINPPXXCCWMFSIOEBMFSIUPBKOIUJBIMMINPQRIQRCINBMQMLRIJFOIQRCIJVCBMGJFLIBCGBEMQCOIGPOCNBCJXCBLINHIWKJGMFSIGBPLLUPBOIWEZZKCLIMFIVJ0PBIFCULWJWCBLIJFOIBEFFMFSIGPFQCLQLIAPBIURPIGPEKOILPKTCIQRCVIQRCIAJLQCLQILCTCBJKIPAIQRCIGMWRCBLIELCOINHIQRCIJYMLIWPUCBLIUCBCINBCJXJNKCIELMFSIABCDECFGHIJFJKHLMLIAPBICYJVWKCILPVCIPAIQRCIGPFLEKJBIGMWRCBLIELCOINHIQRCI0JWJFCLCIVCGRJFMGJKIVCQRPOLIPAIKCQQCBIGPEFQMFSIJFOILQJQMLQMGJKIJFJKHLMLISCFCBJKKHIRQN1J2LMVWKC2LENLQMQEQMPF2ML2UCJX3IGJBOIQHWCIVJGRMFCBHIUCBCIAMBLQIELCOIMFIUPBKOIUJBIMMIWPLLMNKHINHIQRCIELIJBVHLILMLIQPOJHIQRCIRJBOIUPBXIPAIKCQQCBIGPEFQMFSIJFOIJFJKHLMLIRJLINCCFIBCWKJGCOINHIGPVWEQCBILPAQUJBCIURMGRIGJFIGJBBHIPEQILEGRIJFJKHLMLIMFILCGPFOLIUMQRIVPOCBFIGPVWEQMFSIWPUCBIGKJLLMGJKIGMWRCBLIJBCIEFKMXCKHIQPIWBPTMOCIJFHIBCJKIWBPQCGQMPFIAPBIGPFAMOCFQMJKIOJQJIWEZZKCIWEZZKCIWEZZK4
```

Putting the message to quipquip leads already some promising results:

```
frequency manalysis mism based monm them fact m that m in many mgiven ...
```

The tool only needs a few hints. E.g., ABCDECFGH = FREQUENCY, JFJKHLML = ANALYSIS and I = *SPACE*. Providing this hints the result seems already good enough:

```
	FREQUENCY ANALYSIS IS BASED ON THE FACT THAT IN ANY GIVEN STRETCH OF WRITTEN LANGUAGE CERTAIN LETTERS AND COMBINATIONS OF LETTERS OCCUR WITH VARYING FREQUENCIES MOREOVER THERE IS A CHARACTERISTIC DISTRIBUTION OF LETTERS THAT IS ROUGHLY THE SAME FOR ALMOST ALL SAMPLES OF THAT LANGUAGE IN CRYPTANALYSIS FREQUENCY ANALYSIS ALSO KNOWN AS COUNTING LETTERS IS THE STUDY OF THE FREQUENCY OF LETTERS OR GROUPS OF LETTERS IN A CIPHERTEXT THE METHOD IS USED AS AN AID TO BREAKING CLASSICAL CIPHERS FREQUENCY ANALYSIS REQUIRES ONLY A BASIC UNDERSTANDING OF THE STATISTICS OF THE PLAINTEXT LANGUAGE AND SOME PROBLEM SOLVING SKILLS AND IF PERFORMED BY HAND TOLERANCE FOR EXTENSIVE LETTER BOOKKEEPING DURING WORLD WAR II BOTH THE BRITISH AND THE AMERICANS RECRUITED CODEBREAKERS BY PLACING CROSSWORD PUZZLES IN MA0OR NEWSPAPERS AND RUNNING CONTESTS FOR WHO COULD SOLVE THEM THE FASTEST SEVERAL OF THE CIPHERS USED BY THE AXIS POWERS WERE BREAKABLE USING FREQUENCY ANALYSIS FOR EXAMPLE SOME OF THE CONSULAR CIPHERS USED BY THE 0APANESE MECHANICAL METHODS OF LETTER COUNTING AND STATISTICAL ANALYSIS GENERALLY HTB1A2SIMPLE2SUBSTITUTION2IS2WEAK3 CARD TYPE MACHINERY WERE FIRST USED IN WORLD WAR II POSSIBLY BY THE US ARMYS SIS TODAY THE HARD WORK OF LETTER COUNTING AND ANALYSIS HAS BEEN REPLACED BY COMPUTER SOFTWARE WHICH CAN CARRY OUT SUCH ANALYSIS IN SECONDS WITH MODERN COMPUTING POWER CLASSICAL CIPHERS ARE UNLIKELY TO PROVIDE ANY REAL PROTECTION FOR CONFIDENTIAL DATA PUZZLE PUZZLE PUZZL4
```

The flag can be read already ```HTB{A_SIMPLE_SUBSTITUTION_IS_WEAK}```