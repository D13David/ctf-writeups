# UIUCTF 2023

## Corny Kernel

> Use our corny little driver to mess with the Linux kernel at runtime!
>
>  Author: Nitya
>
> [`pwnymodule.c`](pwnymodule.c)

Tags: _misc_

## Solution
The challenge comes with a very basic kernel module source file. The kernel module only logs at initialization and exit time half of the flag. 

```c
static int __init pwny_init(void)
{
	pr_alert("%s\n", flag1);
	return 0;
}

static void __exit pwny_exit(void)
{
	pr_info("%s\n", flag2);
}

module_init(pwny_init);
module_exit(pwny_exit);
```

After logging into the machine we find the compiled kernel module gzipped. After unzipping the module with `gunz -d pwnmodule.ko.gz` the module can be installed and will give a way the first part of the flag:

```
/root # insmod pwnymodule.ko
[  309.435372] pwnymodule: uiuctf{m4ster_
```

After this the kernel module only needs to be removed again so the second part of the flag is logged from the exit callback. Since the message will not be displayed on screen directly the logmessages can be retrieved from the kernel ring buffer with `dmesg`.

```
/root # rmmod pwnymodule
/root # dmesg
[    0.000000] Linux version 6.3.8-uiuctf-2023 (root@buildkitsandbox) (gcc (Ubuntu 11.3.0-1ubuntu1~22.04.1) 11.3.0, GNU ld (GNU Binutils for Ubuntu) 2.38) #1 PREEMPT_DYNAMIC Wed Jun 21 05:28:15 UTC 2023
[    0.000000] Kernel is locked down from Kernel configuration; see man kernel_lockdown.7

...

[    0.185556] Freeing unused kernel image (rodata/data gap) memory: 1452K
[    0.185561] Run /init as init process
[    0.185561]   with arguments:
[    0.185562]     /init
[    0.185563]   with environment:
[    0.185563]     HOME=/
[    0.185564]     TERM=linux
[    0.192659] mount (31) used greatest stack depth: 13464 bytes left
[  309.435372] pwnymodule: uiuctf{m4ster_
[  425.997902] pwnymodule: k3rNE1_haCk3r}
```

Flag `uiuctf{m4ster_k3rNE1_haCk3r}`