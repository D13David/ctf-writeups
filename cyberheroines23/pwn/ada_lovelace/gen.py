import sys

code = sys.argv[1]

rows = 20
cols = 63

card = [[' ' for _ in range(cols)] for _ in range(rows)]

card[0] = "  ____________________________________________________________"
card[1] = " /  1   2   3   4   5   6   7   8   9   a   b   c   d   e   f |"
card[2] = "/                                                             |"

for i in range(3, 19):
    card[i][0] = '|'
    card[i][1] = hex(i-3)[2:]
    card[i][cols-1] = '|'

card[0xc+3][2] = '*'

card[19] = "|_____________________________________________________________|"

parts = []

num_parts = len(code) // 14 + (len(code) % 14 > 0)

for i in range(num_parts):
    part = code[i * 14:(i + 1) * 14]
    parts.append(part)

def clear():
    for row in range(3, rows-1):
        for col in range(3, cols-1):
            card[row][col] = ' '

for part, code in enumerate(parts):
    for i, c in enumerate(code):
        offsetX = (i)*4+4

        if c.isupper():
            c = c.lower()
            card[0xc+3][offsetX] = 'o'

        offsetY = int(c,16) + 3
        card[offsetY][offsetX] = 'o'

    if part < len(parts)-1:
        card[0xc+3][cols-3] = 'o'
        card[0xe+3][cols-3] = 'o'

    for row in card:
        print(''.join(row))
    clear()