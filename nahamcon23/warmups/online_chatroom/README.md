# NahamCon 2023

## Online Chatroom

> We are on the web and we are here to chat!
>
>  Author: @JohnHammond#6971
>
> [`main.go`](main.go)

Tags: _warmups_

## Solution
Provided is the source code of a simple chat application which runs on the provided container. In the chat users can input text but by inspecting the code there are also special commands that can be handled. One command is `!history`. When entering this command an error is shown:

```
Error: Please request a valid history index (1 to 6)
```

So the history can be shown by typing `!history <number>`:

```
!history 1
User2: Oh hey User0, was it you? You can use !help as a command to learn more :)

!history 2
User1: Wait, has someone been here before us?

etc
```

Inspecting the source code further there is a hint that User5 writes the flag to the chat at some point but no of the items 1-6 gives the specific line. Inspecting the endpoint that gives the number of history items `/allHistory`:

```go
func allHistory(w http.ResponseWriter, r *http.Request) {
        w.Write([]byte(strconv.Itoa(len(chatHistory)-1)))
}
```

This gives us the length of the history minus one. So there is one more item that can be queried.

```
!history 7
User5: Aha! You're right, I was here before all of you! Here's your flag for finding me: flag{c398112ed498fa2cacc41433a3e3190b}
```

Flag `flag{c398112ed498fa2cacc41433a3e3190b}`