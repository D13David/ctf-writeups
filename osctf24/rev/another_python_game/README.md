# OS CTF 2024

## Another Python Game

> You know, I love Pygame why don't you. Prove your love for Pygame by solving this challenge Note: It is necessary to keep the background.png file in the same place as the exe file so that the exe file runs properly
>
>  Author: @5h1kh4r
>
> [`source.exe`](source.exe), [`background.png`])(background.png)

Tags: _rev_

## Solution
The challenge comes with a small game. The executable is a pyinstaller executable, we can find traces á la `Failed to pre-initialize embedded python interpreter!` when searching for strings. To unpack the resources we can use [`PyInstaller Extractor`](https://github.com/extremecoders-re/pyinstxtractor).

After the resources are extracted we browse the `source.exe_extracted` folder and find the compiled game source in `source.pyc`. From here we can use [`Decompyle++`](https://github.com/zrax/pycdc) to decompile to `python` or to dissassemble. 

In this case, the decompile process didn't finish fully, but luckily for us, it shows enough so we can just grab the flag.

```python
# Source Generated with Decompyle++
# File: source.pyc (Python 3.8)

Unsupported opcode: BUILD_TUPLE_UNPACK
import pygame
import sys
pygame.init()
screen_width = 800
screen_height = 600
screen = pygame.display.set_mode((screen_width, screen_height))
pygame.display.set_caption('CTF Challenge')
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
RED = (255, 0, 0)
BLUE = (0, 0, 255)
font = pygame.font.Font(None, 74)
small_font = pygame.font.Font(None, 36)
flag_hidden = True
flag_text = "OSCTF{1_5W3ar_I_D1dn'7_BruT3f0rc3}"
hidden_combination = [
    'up',
    'up',
    'down',
    'down',
    'left',
    'right',
    'left',
    'right']
input_combination = []
player_size = 50
player_pos = [
    screen_width // 2,
    screen_height // 2]
player_color = BLUE
player_speed = 5
background_image = pygame.image.load('background.png')
background_image = pygame.transform.scale(background_image, (screen_width, screen_height))

def show_message(text, font, color, pos):
    message = font.render(text, True, color)
    screen.blit(message, pos)

running = True
# WARNING: Decompyle incomplete
```

Find a the fully (manual) decompiled code [`here`](source.py).

Flag `OSCTF{1_5W3ar_I_D1dn'7_BruT3f0rc3}`