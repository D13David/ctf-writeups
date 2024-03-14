# Cyber Apocalypse 2024

## Crushing

> You managed to intercept a message between two event organizers. Unfortunately, it's been compressed with their proprietary message transfer format. Luckily, they're gamemakers first and programmers second - can you break their encoding?
> 
> Author: clubby789
> 
> [`rev_crushing.zip`](rev_crushing.zip)

Tags: _rev_

## Solution
For this challenge we get two files. A binary and a file called `message.txt.cz` that contains encrypted or compressed data. In `Ghidra` we check out what the main function does.

```c
undefined8 main(void)
{
  long i;
  entry_s **ptr;
  entry_s *charMap [256];
  int input;
  long index;
  
  ptr = charMap;
  for (i = 0xff; i != 0; i = i + -1) {
    *ptr = (entry_s *)0x0;
    ptr = ptr + 1;
  }
  index = 0;
  while( true ) {
    input = getchar();
    if (input == -1) break;
    add_char_to_map(charMap,(char)input,index);
    index = index + 1;
  }
  serialize_and_output(charMap);
  return 0;
}
```

After a bit of renaming the code becomes quite clear. A array of 256 elements is first filled with `nullptr` values. Then a loop starts that reads user input. Char by char until the user enters `-1`, and calls `add_char_to_map`. Afterwards the `charMap` is serialized.

```c
void add_char_to_map(entry_s **charMap,byte value,long index)
{
  entry_s *newEntry;
  entry_s *entry;
  
  entry = charMap[value];
  newEntry = (entry_s *)malloc(16);
  newEntry->index = index;
  newEntry->next = (int *)0x0;
  if (entry == (entry_s *)0x0) {
    charMap[value] = newEntry;
  }
  else {
    for (; entry->next != (int *)0x0; entry = (entry_s *)entry->next) {
    }
    entry->next = (int *)newEntry;
  }
  return;
}
```

The char-map is basically a lookup table for every possible byte value. And every slot holds a linked list of `entry_s` elements. Every element has a `index` that points to the position of the character within the "compressed" text.

```c
void serialize_and_output(entry_s **charMap)
{
  undefined8 len;
  entry_s **entry;
  entry_s *ptr;
  int i;
  
  for (i = 0; i < 0xff; i = i + 1) {
    entry = charMap + i;
    len = list_len(entry);
    fwrite(&len,8,1,stdout);
    for (ptr = *entry; ptr != (entry_s *)0x0; ptr = (entry_s *)ptr->next) {
      fwrite(ptr,8,1,stdout);
    }
  }
  return;
}
```

And finally, `serialize_and_output` serializes all the linked lists for every slot in the lookup table. The text can easily be reversed by deserializing the char-map and then mapping each entry to the text positon.

```python
char_map = [[] for _ in range(255)]

with open("message.txt.cz", "rb") as file:
    for index in range(255):
        count = int.from_bytes(file.read(8), 'little')
        print(chr(index), count)
        if count != 0:
            for i in range(count):
                char_map[index].append(int.from_bytes(file.read(8), 'little'))

text = [' ']*900

for i in range(len(char_map)):
    for j in char_map[i]:
        text[j] = chr(i)

print("".join(text))
```

Running this gives us the decompressed text with the flag.

```bash
Organizer 1: Hey, did you finalize the password for the next... you know?

Organizer 2: Yeah, I did. It's "HTB{4_v3ry_b4d_compr3ss1on_sch3m3}"

Organizer 1: "HTB{4_v3ry_b4d_compr3ss1on_sch3m3}," got it. Sounds ominous enough to keep things interesting. Where do we spread the word?

Organizer 2: Let's stick to the usual channels: encrypted messages to the leaders and discreetly slip it into the training manuals for the participants.

Organizer 1: Perfect. And let's make sure it's not leaked this time. Last thing we need is an early bird getting the worm.

Organizer 2: Agreed. We can't afford any slip-ups, especially with the stakes so high. The anticipation leading up to it should be palpable.

Organizer 1: Absolutely. The thrill of the unknown is what keeps them coming back for more. "HTB{4_v3ry_b4d_compr3ss1on_sch3m3}" it is then.
```

Flag `HTB{4_v3ry_b4d_compr3ss1on_sch3m3}`