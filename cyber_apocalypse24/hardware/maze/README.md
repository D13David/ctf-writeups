# Cyber Apocalypse 2024

## Maze

> In a world divided by factions, "AM," a young hacker from the Phreaks, found himself falling in love with "echo," a talented security researcher from the Revivalists. Despite the different backgrounds, you share a common goal: dismantling The Fray. You still remember the first interaction where you both independently hacked into The Fray's systems and stumbled upon the same vulnerability in a printer. Leaving behind your hacker handles, "AM" and "echo," you connected through IRC channels and began plotting your rebellion together. Now, it's finally time to analyze the printer's filesystem. What can you find?
> 
> Author: WizardAlfredo
> 
> [`hardware_maze.zip`](hardware_maze.zip)

Tags: _hardware_

## Solution
For this challenge we get a zip archive containing a printers file system. After unpacking we check the contents.

```bash
$ tree fs
fs
├── PJL
├── PostScript
├── saveDevice
│   └── SavedJobs
│       ├── InProgress
│       │   └── Factory.pdf
│       └── KeepJob
└── webServer
    ├── default
    │   └── csconfig
    ├── home
    │   ├── device.html
    │   └── hostmanifest
    ├── lib
    │   ├── keys
    │   └── security
    ├── objects
    └── permanent
```

Interesting, there is a saved print job that is currently in progress. Opening the pdf reveals the flag.

Flag `HTB{1n7323571n9_57uff_1n51d3_4_p21n732}`