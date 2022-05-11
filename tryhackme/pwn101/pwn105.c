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
"                 pwn 105          \n\n"
    );
}

void main(){
    setup();
    banner();

    int a,b,c;

    printf("-------=[ BAD INTEGERS ]=-------\n");
    printf("|-< Enter two numbers to add >-|\n\n");
    printf("]>> ");
    scanf("%d",&a);
    printf("]>> ");
    scanf("%d",&b);
    c = a+b;

    if(a >=0 && b >=0)
        if(c >= 0){
            printf("\n[*] ADDING %d + %d",a,b);
            printf("\n[*] RESULT: %d\n",c);
        }
        else{
            printf("\n[*] C: %d",c);
            printf("\n[*] Popped Shell\n[*] Switching to interactive mode\n");
                system("/bin/sh");
        }
    else
        printf("\n[o.O] Hmmm... that was a Good try!\n",a,b,c);
}
