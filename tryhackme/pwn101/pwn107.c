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
"                 pwn 107         \n"
    );
}


void get_streak(){
    printf("This your last streak back, don't do this mistake again\n");
    system("/bin/sh");
}

void main(){
    setup();
    banner();
    char streak[20];
    char question[20];

    puts("You are a good THM player 😎");
    puts("But yesterday you lost your streak 🙁");
    puts("You mailed about this to THM, and they responsed back with some questions");
    puts("Answer those questions and get your streak back\n");
    printf("THM: What's your last streak? ");
    read(0,streak,20);
    printf("Thanks, Happy hacking!!\nYour current streak: ");
    printf(streak);
    printf("\n\n[Few days latter.... a notification pops up]\n\n");
    printf("Hi pwner 👾, keep hacking👩💻 - We miss you!😢\n");
    read(0,question,0x200);
}
