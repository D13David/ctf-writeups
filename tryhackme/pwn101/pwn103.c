#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void setup(){
    setvbuf(stdout,(char *)0x0,2,0);
    setvbuf(stderr,(char *)0x0,2,0);
    setvbuf(stdin,(char *)0x0,2,0);
}

void rules(){
    printf("\n📜 Rules:\n\n");
    printf("1  Don't ping @everyone 😾\n");
    printf("2  Don't rick roll anyone 😒 Rick roll yourself 😎\n");
    printf("3  Don't post memes 😑, otherwise you'll become a meme 🤡\n");
    printf("4  We know sharing is caring 🤗, But don't share your writeups here lmao🤦♂\n");
    printf("5  Respect everyone in our community🤗\n\n");
    main();
}

void announcements(){
    printf("\n📢 Announcements:\n\n");
    printf("A new room is available!\n");
    printf("Check it out: \033[0;34mhttps://tryhackme.com/room/binaryexploitation\033[0m\n\n");
    puts(
"┌┐ ┬┌┐┌┌─┐┬─┐┬ ┬┌─┐─┐ ┬┌─┐┬  ┌─┐┬┌┬┐┌─┐┌┬┐┬┌─┐┌┐┌\n"
"├┴┐││││├─┤├┬┘└┬┘├┤ ┌┴┬┘├─┘│  │ ││ │ ├─┤ │ ││ ││││\n"
"└─┘┴┘└┘┴ ┴┴└─ ┴ └─┘┴ └─┴  ┴─┘└─┘┴ ┴ ┴ ┴ ┴ ┴└─┘┘└┘\n");
    printf("👾 Beginner level room has some challenges based on stack exploitation\n\n");
    main();
}

void general(){
    char message[20];

    printf("\n🗣  General:\n\n");
    printf("------[jopraveen]: Hello pwners 👋\n");
    printf("------[jopraveen]: Hope you're doing well 😄\n");
    printf("------[jopraveen]: You found the vuln, right? 🤔\n\n");
    printf("------[pwner]: ");
    scanf("%s",&message);
    if (strcmp(message,"yes") == 0){
        printf("------[jopraveen]: GG 😄\n\n");
        main();
    }
    else{
        printf("Try harder!!! 💪\n");
    }
}

void bot_cmd(){
    char command[10];
    printf("🤖 Bot commands:\n\n");
    for (int i = 0; i < 4; ++i)
    {
        printf("root@pwn101:~/root# ");
        read(0,&command,10);
        if (strncmp(command,"/help",5) == 0){
            printf("\n⚙  Available commands:\n\n");
            printf("/rank\n");
            printf("/invite\n");
            printf("/help\n");
            printf("/meme\n\n");
        }
        else if (strncmp(command,"/rank",5) == 0){
            puts(
            "\n┌───────────────────┐\n"
            "│  ╔═══╗ pwner      │\n"
            "│  ╚═╦═╝ rank: 1337 |\n"
            "╞═╤══╩══╤═══════════╡\n"
            "│ level : 18        │\n"
            "└───────────────────┘\n"
            );
        }
        else if (strncmp(command,"/invite",7) == 0){
            printf("\nOur Discord server link: \033[0;34mhttps://discord.gg/JxhCHPajsv\033[0m\n\n");
        }
        else if (strncmp(command,"/meme",5) == 0){
            puts(
            "\n░░▄▀░░░░░░░░░░░░░░░▀▀▄▄░░░░░ \n"
            "░░▄▀░░░░░░░░░░░░░░░░░░░░▀▄░░░\n"
            "░▄▀░░░░░░░░░░░░░░░░░░░░░░░█░░\n"
            "░█░░░░░░░░░░░░░░░░░░░░░░░░░█░\n"
            "▐░░░░░░░░░░░░░░░░░░░░░░░░░░░█\n"
            "█░░░░▀▀▄▄▄▄░░░▄▌░░░░░░░░░░░░▐\n"
            "▌░░░░░▌░░▀▀█▀▀░░░▄▄░░░░░░░▌░▐\n"
            "▌░░░░░░▀▀▀▀░░░░░░▌░▀██▄▄▄▀░░▐\n"
            "▌░░░░░░░░░░░░░░░░░▀▄▄▄▄▀░░░▄▌\n"
            "▐░░░░▐░░░░░░░░░░░░░░░░░░░░▄▀░\n"
            "░█░░░▌░░▌▀▀▀▄▄▄▄░░░░░░░░░▄▀░░\n"
            "░░█░░▀░░░░░░░░░░▀▌░░▌░░░█░░░░\n"
            "░░░▀▄░░░░░░░░░░░░░▄▀░░▄▀░░░░░\n"
            "░░░░░▀▄▄▄░░░░░░░░░▄▄▀▀░░░░░░░\n"
            "░░░░░░░░▐▌▀▀▀▀▀▀▀▀░░░░░░░░░░░\n"
            "░░░░░░░░█░░░░░░░░░░░░░░░░░░░░\n"
            "░░╔═╗╔═╗╔═╗░░░░░║░║╔═╗║░║░░░░\n"
            "░░╠═╣╠╦╝╠╣░░░░░░╚╦╝║░║║░║░░░░\n"
            "░░║░║║╚═╚═╝░░░░░░║░╚═╝╚═╝░░░░\n"
            "║╔═░╦░╦═╗╦═╗╦╔╗║╔═╗░░╔╦╗╔═╗╔╗\n"
            "╠╩╗░║░║░║║░║║║║║║═╗░░║║║╠╣░╔╝\n"
            "║░╚░╩░╩═╝╩═╝╩║╚╝╚═╝░░║║║╚═╝▄░\n\n"
            );
        }
    }
    main();
}

void discussion(){
    printf("\n🏠 rooms discussion:\n\n");
    printf("--[Welcome to Room Discussion]--\n\n");
    printf("-----[jopraveen]: Don't post spoilers here 🙂\n");
    printf("-----[jopraveen]: Keep the chats relevent to this room 🙂\n");
    printf("-----[jopraveen]: Good luck everyone 😄\n\n");
    main();
}

void banner(){
    puts(
"\033[0;34m⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿\n"
"⣿⣿⣿⡟⠁⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠈⢹⣿⣿⣿\n"
"⣿⣿⣿⡇⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢸⣿⣿⣿\n"
"⣿⣿⣿⡇⠄⠄⠄\033[0;37m⢠⣴⣾⣵⣶⣶⣾⣿⣦⡄\033[0;34m⠄⠄⠄⢸⣿⣿⣿\n"
"⣿⣿⣿⡇⠄⠄\033[0;37m⢀⣾⣿⣿⢿⣿⣿⣿⣿⣿⣿⡄\033[0;34m⠄⠄⢸⣿⣿⣿\n"
"⣿⣿⣿⡇⠄⠄\033[0;37m⢸⣿⣿⣧⣀⣼⣿⣄⣠⣿⣿⣿\033[0;34m⠄⠄⢸⣿⣿⣿\n"
"⣿⣿⣿⡇⠄⠄\033[0;37m⠘⠻⢷⡯⠛⠛⠛⠛⢫⣿⠟⠛\033[0;34m⠄⠄⢸⣿⣿⣿\n"
"⣿⣿⣿⡇⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢸⣿⣿⣿\n"
"⣿⣿⣿⣧⡀⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢡⣀⠄⠄⢸⣿⣿⣿\n"
"⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣆⣸⣿⣿⣿\n"
"⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿\n\n"
"  [THM Discord Server]\033[0m\n"
);
}

void admins_only(){
    char command[7];
    printf("\n👮  Admins only:\n\n");
    printf("Welcome admin 😄\n");
    system("/bin/sh");
}

void main(){
    setup();
    banner();
    int option;

    printf("➖➖➖➖➖➖➖➖➖➖➖\n");
    printf("1) 📢 Announcements\n2) 📜 Rules\n3) 🗣  General\n4) 🏠 rooms discussion\n5) 🤖 Bot commands\n");
    printf("➖➖➖➖➖➖➖➖➖➖➖\n");
    printf("⌨  Choose the channel: ");
    scanf("%d",&option);

    switch(option){
        case 1: announcements();break;
        case 2: rules();break;
        case 3: general();break;
        case 4: discussion();break;
        case 5: bot_cmd();break;
        default: main();
    }
}
