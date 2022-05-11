#include <stdio.h>
#include <stdlib.h>

void setup(){
    setvbuf(stdout,(char *)0x0,2,0);
    setvbuf(stderr,(char *)0x0,2,0);
    setvbuf(stdin,(char *)0x0,2,0);
}

void banner(){
    puts(
"       ┌┬┐┬─┐┬ ┬┬ ┬┌─┐┌─┐┬┌─┌┬┐┌─┐\n"
"        │ ├┬┘└┬┘├─┤├─┤│  ├┴┐│││├┤ \n"
"        ┴ ┴└─ ┴ ┴ ┴┴ ┴└─┘┴ ┴┴ ┴└─┘\n"
"                 pwn 104          \n"
    );
}

void main(){
    setup();
    banner();
    char exploit_the_powers[80];
    printf("I think I have some super powers 💪\n");
    printf("especially executable powers 😎💥\n\n");
    printf("Can we go for a fight? 😏💪\n");
    printf("I'm waiting for you at %p\n", (void*)&exploit_the_powers);
    read(0,exploit_the_powers,200);
}
