# Hack The Boo 2022

## EncodedPayload

> Buried in your basement you've discovered an ancient tome. The pages are full of what look like warnings, but luckily you can't read the language! What will happen if you invoke the ancient spells here?
>
>  Author: N/A
>
> [`rev_encodedpayload.zip`](rev_encodedpayload.zip)

Tags: _rev_

## Solution

Looking quickly at Ghidra leads a mess of decompiled code. So going one step back and running this in ```strace```

```
$ strace ./encodedpayload
execve("./encodedpayload", ["./encodedpayload"], 0x7ffd309cfcb0 /* 24 vars */) = 0
[ Process PID=952 runs in 32 bit mode. ]
socket(AF_INET, SOCK_STREAM, IPPROTO_IP) = 3
dup2(3, 2)                              = 2
dup2(3, 1)                              = 1
dup2(3, 0)                              = 0
connect(3, {sa_family=AF_INET, sin_port=htons(1337), sin_addr=inet_addr("127.0.0.1")}, 102) = -1 ECONNREFUSED (Connection refused)
syscall_0xffffffffffffff0b(0xff95d9a8, 0xff95d9a0, 0, 0, 0, 0) = -1 ENOSYS (Function not implemented)
execve("/bin/sh", ["/bin/sh", "-c", "echo HTB{PLz_strace_M333}"], NULL) = 0
[ Process PID=952 runs in 64 bit mode. ]

/// snip /// 

rt_sigaction(SIGINT, NULL, {sa_handler=SIG_DFL, sa_mask=[], sa_flags=0}, 8) = 0
rt_sigaction(SIGINT, {sa_handler=0x563414892ca0, sa_mask=~[RTMIN RT_1], sa_flags=SA_RESTORER, sa_restorer=0x7f7a09260920}, NULL, 8) = 0
rt_sigaction(SIGQUIT, NULL, {sa_handler=SIG_DFL, sa_mask=[], sa_flags=0}, 8) = 0
rt_sigaction(SIGQUIT, {sa_handler=SIG_DFL, sa_mask=~[RTMIN RT_1], sa_flags=SA_RESTORER, sa_restorer=0x7f7a09260920}, NULL, 8) = 0
rt_sigaction(SIGTERM, NULL, {sa_handler=SIG_DFL, sa_mask=[], sa_flags=0}, 8) = 0
rt_sigaction(SIGTERM, {sa_handler=SIG_DFL, sa_mask=~[RTMIN RT_1], sa_flags=SA_RESTORER, sa_restorer=0x7f7a09260920}, NULL, 8) = 0
write(1, "HTB{PLz_strace_M333}\n", 21)  = -1 EPIPE (Broken pipe)
--- SIGPIPE {si_signo=SIGPIPE, si_code=SI_USER, si_pid=952, si_uid=1000} ---
+++ killed by SIGPIPE +++
```

And clearly, there is the flag ```HTB{PLz_strace_M333}```