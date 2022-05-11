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
"                 pwn 108          \n"
    );
}

void holidays(){
    char idk[] = "exams";
    printf("\nNo more %s for you enjoy your holidays 🎉\nAnd here is a small gift for you\n",idk);
    system("/bin/sh");
}


void main(){
    setup();
    banner();
    char student_name[20];
    char register_no[100];

    printf("      THM University 📚\n");
    printf("👨🎓 Student login portal 👩🎓\n");
    printf("\n=[Your name]: ");
    read(0,student_name,18);
    printf("=[Your Reg No]: ");
    read(0,register_no,100);

    printf("\n=[ STUDENT PROFILE ]=\n");
    printf("Name         : %s",student_name);
    printf("Register no  : ");
    printf(register_no);
    printf("Institue     : THM");
    printf("\nBranch       : B.E (Binary Exploitation)\n\n");

    puts("\n                    =[ EXAM SCHEDULE ]=                  \n"
" --------------------------------------------------------\n"
"|  Date     |           Exam               |    FN/AN    |\n"
"|--------------------------------------------------------\n"
"| 1/2/2022  |  PROGRAMMING IN ASSEMBLY     |     FN      |\n"
"|--------------------------------------------------------\n"
"| 3/2/2022  |  DATA STRUCTURES             |     FN      |\n"
"|--------------------------------------------------------\n"
"| 3/2/2022  |  RETURN ORIENTED PROGRAMMING |     AN      |\n"
"|--------------------------------------------------------\n"
"| 7/2/2022  |  SCRIPTING WITH PYTHON       |     FN      |\n"
" --------------------------------------------------------");
}

