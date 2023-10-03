# BuckeyeCTF 2023

## Beginner Menu

> I just made this menu for my coding class. I think I covered all the switch cases.
> 
> Author: geekgeckoalex
>
> [`makefile`](makefile), [`beginner-menu.c`](beginner-menu.c), [`menu`](menu)

Tags: _pwn_

## Solution
For this challenge we get the source and binary of a small application. The source is basically a menu structure where the program exits after every choice. At the bottom the flag is printed but for all positive numbers there is a matching branch, so  we don't reach the print_flag call. But negative numbers are not handled though. Also `atoi` returns 0 when conversion fails, so any non digit string would cause the result to be 0 and since the case for `0` is tested with a strcmp (`strcmp(buf, "0\n")==0`) we can bypass here as well.

```c
    fgets(buf, 50, stdin);
    if(strcmp(buf, "0\n")==0){
        printf("That's not an option\n");
        exit(0);
    }
    

	if(atoi(buf) ==1){
	    printf(joke[(rand()%5)]);
	    exit(0);
    }
	else if(atoi(buf) == 2){
	    printf(weather[(rand()%5)]);
	    exit(0);
    }
	else if(atoi(buf) ==3){
        while(num!=atoi(guess)){
	        printf("Guess the number I'm thinking of: ");
            fgets(guess, 50, stdin);
            if(atoi(guess)<num){
                printf("Guess higher!\n");
            }
            else if(atoi(guess)>num){
                printf("Guess lower!\n");
            }
        }
	    exit(0);
    }
	else if(atoi(buf)==4){
	    exit(0);
    }
	else if(atoi(buf)>4){
	    printf("That's not an option\n");
	    exit(0);
    }

    print_flag();
```

```bash
$ nc chall.pwnoh.io 13371
Enter the number of the menu item you want:
1: Hear a joke
2: Tell you the weather
3: Play the number guessing game
4: Quit
a
bctf{y0u_ARe_sNeaKy}
```

Flag `bctf{y0u_ARe_sNeaKy}`