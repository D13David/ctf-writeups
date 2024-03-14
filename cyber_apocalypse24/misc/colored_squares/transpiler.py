import os, re
from enum import Enum

class Command(Enum):
    If = 0
    While = 1
    Declare = 2
    Let = 3
    Print = 4
    Input = 5

class Expression(Enum):
    Variable = 0
    Add = 1
    Subtract = 2
    Multiply = 3
    Divide = 4
    LiteralValue = 5
    EqualTo = 6
    GreaterThan = 7
    LessThan = 8

class FType(Enum):
    Int = 0
    Float = 1
    String = 2
    Char = 3

def order(x):
    try:
        # This searches and returns the first number found in the folder name
        return int(re.search("\d+", x).group(0))
    except (ValueError, TypeError, AttributeError):
        return 0

def get_sub_dirs(path):
    entries = []
    for entry in os.scandir(path):
        if entry.is_dir():
            entries.append(f"{entry.name}")
    entries.sort(key=order)
    return [f"{path}{name}/" for name in entries]

def decode_literal(path):
    subDirs = get_sub_dirs(path)

    currentValue = 0
    bitDigitCounter = 0
    nibDigitCounter = 0
    for hexdir in subDirs[::-1]:
        bitdirs = get_sub_dirs(hexdir)
        for bitdir in bitdirs[::-1]:
            currentValue += (2**bitDigitCounter)*(len(get_sub_dirs(bitdir)))
            bitDigitCounter += 1
        nibDigitCounter += 1
        bitDigitCounter = nibDigitCounter * 4
    return currentValue

def parse_type(path):
    subDirs = get_sub_dirs(path)
    return FType(len(subDirs))

def parse_expression(path):
    subDirs = get_sub_dirs(path)
    subDirs0 = get_sub_dirs(subDirs[0])

    expId = Expression(len(subDirs0))

    match expId:
        case Expression.Variable:
            print(f"_{str(len(get_sub_dirs(subDirs[1])))}",end="")
        case Expression.Add:
            print("(",end="")
            parse_expression(subDirs[1])
            print("+",end="")
            parse_expression(subDirs[2])
            print(")",end="")
        case Expression.Subtract:
            print("(",end="")
            parse_expression(subDirs[1])
            print("-",end="")
            parse_expression(subDirs[2])
            print(")",end="")
        case Expression.Multiply:
            print("(",end="")
            parse_expression(subDirs[1])
            print("*",end="")
            parse_expression(subDirs[2])
            print(")",end="")
        case Expression.Divide:
            print("(",end="")
            parse_expression(subDirs[1])
            print("//",end="")
            parse_expression(subDirs[2])
            print(")",end="")
        case Expression.LiteralValue:
            t = parse_type(subDirs[1])
            match t:
                case FType.Int:
                    value = decode_literal(subDirs[2])
                    print(value,end="")
                case FType.Float: print("float")
                case FType.String:
                    value = ""
                    for charDir in get_sub_dirs(subDirs[2]):
                        value += chr(decode_literal(charDir))
                    print(f'"{value}"',end="")
                case FType.Char: print("char")
        case Expression.EqualTo:
            print("(",end="")
            parse_expression(subDirs[1])
            print("==",end="")
            parse_expression(subDirs[2])
            print(")",end="")
        case Expression.GreaterThan:
            print("(",end="")
            parse_expression(subDirs[1])
            print(">=",end="")
            parse_expression(subDirs[2])
            print(")",end="")
        case Expression.LessThan:
            print("(",end="")
            parse_expression(subDirs[1])
            print("<=",end="")
            parse_expression(subDirs[2])
            print(")",end="")

def compile(path, tab):
    subDirs = get_sub_dirs(path)
    subDirs0 = get_sub_dirs(subDirs[0])

    cmd = Command(len(subDirs0))

    print("\n"+" "*tab, end="")

    match cmd:
        case Command.If:
            print("if ", end="")
            parse_expression(subDirs[1])
            commandDirs = get_sub_dirs(subDirs[2])
            for commandDir in commandDirs:
                compile(commandDir, tab+1)
        case Command.While:
            print("while")
        case Command.Declare:
            print("declare")
        case Command.Let:
            print("let")
        case Command.Print:
            print("print(",end="")
            parse_expression(subDirs[1])
            print(")")
        case Command.Input: # input
            print(f"_{len(get_sub_dirs(subDirs[1]))} = input()")

programs = get_sub_dirs("src/")
for i in range(0, len(programs)):
    compile(programs[i], 0)