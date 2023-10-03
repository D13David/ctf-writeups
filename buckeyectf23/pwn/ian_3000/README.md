# BuckeyeCTF 2023

## Igpay Atinlay Natoriay 3000

> ustray isyay ayay afesay, efficientyay, emssystay ogramingpray anguagelay.
> 
> Author: rene
>
> [`dist.zip`](dist.zip)

Tags: _pwn_

## Solution
For this challenge we get the source of a Rust application. If we inspect we can't really find the flag target in the source but there is a bash script to run the application that gives us the flag when the Rust application crashes. 

```bash
#!/bin/sh

./igpay-atinlay-natoriay-3000 \
    || printf "You crashed my program :(\n$FLAG"
```

So our goal is to crash the program. Rust being notoriously safe is surely hard to crash, right? The user input part at least has some error handling and looks ok. Then the input is split at whitespaces. For each word the first character is taken and concatenated at the end of the word, so we have something like `hello -> elloh`, then `ay` and a space is concatenated as well and after all words are written to the output string the string is printed. This looks fine as well since `split_whitespace` is guaranteed to deliver a list of non empty strings, so no out of index access can happen. And that is exactly the one spot that could cause a (uncatched) panic. 

```rust
use std::io::{self, Read, BufRead};

fn main() {
    let input = loop {
        match get_line() {
            Ok(my_str) => break my_str,
            Err(_) => {
                print!("Try again.");
                continue;
            }
        }
    };


    let mut output = String::new();

    for word in input.split_whitespace() {
        let first = &word[0..1];
        let rest = &word[1..];

        output += rest;
        output += first;
        output += "ay";
        output += " ";
    }

    print!("{output}");
}

fn get_line() -> Result<String, io::Error> {
    let mut input = String::new();

    io::BufReader::new(io::stdin().take(1862)).read_line(&mut input)?;

    Ok(input)
}
```

The problem with that code is that it assumes characters are one byte wide. This is of course not the case for unicode characters, as Rust uses [`UTF-8`](https://en.wikipedia.org/wiki/UTF-8) to store unicode data in strings, characters can be longer than one byte and this is there Rust panics when the program tries to index not at char boundary (index in the middle of a multi byte character). Lets do some tests:

```rust
let foo = "a";
    
let length = foo.len();
print!("length: {length}\n");

let first_char = &foo[0..1];
print!("first char: {first_char}"); 
```

This is fine as "a" is part if the `basic latin` block (0x0000 - 0x007f) and will only need on character to be stored. The program prints `length: 1\nfirst char: a`. Now we take another character.

```rust
let foo = "☢";
    
let length = foo.len();
print!("length: {length}\n");

let first_char = &foo[0..1];
print!("first char: {first_char}");
```

This time the program prints `length: 3` and crashes with the message `thread 'main' panicked at 'byte index 1 is not a char boundary; it is inside '☢' (bytes 0..3) of `☢`'`. Why is this? We can see the length is 3 except we only have one character. But this character is utf-8 encoded and uses 3 bytes causing Rust to carfully mentioning to us that, if we want to get the first character, we need to take three bytes instead of just one. So if we change the code things will work again:

```rust
let foo = "☢";
    
let length = foo.len();
print!("length: {length}\n");

let first_char = &foo[0..3];
print!("first char: {first_char}"); 
```

Back to our challenge. If we send a string starting with some unicode character that takes more than a byte Rust will crash the application and we will get the flag.

```bash
$ nc chall.pwnoh.io 13370
☺
thread 'main' panicked at 'byte index 1 is not a char boundary; it is inside '☺' (bytes 0..3) of `☺`', src/main.rs:18:22
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
You crashed my program :(
bctf{u$trAy_1SyAy_Af3$ay_aNDy@Y_3cUR3s@y}
```

Flag `bctf{u$trAy_1SyAy_Af3$ay_aNDy@Y_3cUR3s@y}`