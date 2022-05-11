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
"                 pwn 102          \n"
    );
}

void main(){
    setup();
    banner();
    char is_this_right[100];
    int need_what = 0xBADF00D;
    int to_do = 0xFEE1DEAD;

    printf("I need %x to %x\nAm I right? ",need_what,to_do);
    scanf("%s",&is_this_right);

    if (need_what == 0xc0ff33 && to_do == 0xc0d3){
        printf("Yes, I need %x to %x\n",need_what,to_do);
        system("/bin/sh");
    }
    else{
        printf("I'm feeling dead, coz you said I need bad food :(\n");
        exit(1337);
    }
}

