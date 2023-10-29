# UDCTF 2023

## Classic Checkers

> https://gist.github.com/AndyNovo/f1d9d18cbdbc4901066234077dac9b90
>
>  Author: ProfNinja
>

Tags: _rev_

## Solution
No file is given, but a link to some `Lisp` code. The code is a simple flag checker and all we have to do is to go, case by case and find the corresponding characters. Some cases are easy, some a bit more complex. But all in all its just a bit of tedious work to do and being able to read the Lisp syntax.

To do this I pasted the code to a online interpreter and replaced the `nil` return values with numbers 1, 2... etc. So I could quickly see which check failed. The first check is easy enough, the flag length is expected to be `34`. Then the first six characters are `UDCTF{`, the next character has ascii code 104, which is an `h`. 

Doing this we resolve the easy cases, and then try to get the harder ones. For instance check `6` translates to `input[7] - input[9] == 1`. We can try to find candidates and find that `3` and `4` match the requirements.

```bash
(defun checkFlag (input)
    (if (not (= (length input) 34))
        nil
        (if (not (string= (subseq input 0 6) "UDCTF{"))
            nil
            (if (not (= (char-code (char input 6)) 104))
                nil
                (if (not (= (+ (char-code (char input 9)) 15) (- (char-code (char input 8)) (char-code (char input 7)))))
                    nil
                    (if (not (= (* (char-code (char input 7)) (char-code (char input 9))) 2652))
                        nil
                        (if (not (= (- (char-code (char input 7)) (char-code (char input 9))) 1))
                            nil
                            (if (not (string= (char input 10) (char input 14) ) )
                                nil
                                (if (not (string= (char input 14) (char input 21) ) )
                                    nil
                                    (if (not (string= (char input 10) (char input 25) ) )
                                        nil
                                        (if (not (string= (char input 21) (char input 27) ) )
                                            nil
                                            (if (not (= (ceiling (char-code (char input 10)) 2) (char-code (char input 12)) ) )
                                                nil
                                                (if (not (=  952 (- (expt (char-code (char input 11)) 2) (expt (char-code (char input 13)) 2)) ) )
                                                    nil
                                                    (if (not (string= (subseq input 14 21) (reverse "sy4wla_")))
                                                        nil
                                                        (if (not (string= (subseq input 22 24) (subseq input 6 8)))
                                                            nil
                                                            (if (not (= (mod (char-code (char input 24)) 97)  3))
                                                                nil
                                                                (if (not (string= (subseq input 14 16) (reverse (subseq input 26 28))))
                                                                    nil
                                                                    (if (not (= (complex (char-code (char input 28)) (char-code (char input 29)))  (conjugate (complex 76 -49))))
                                                                        nil
                                                                        (if (not (= (lcm (char-code (char input 30)) (char-code (char input 31))) 6640))
                                                                            nil
                                                                            (if (not (> (char-code (char input 30)) (char-code (char input 31)) ) )
                                                                                nil
                                                                                (if (not (= (char-code (char input 32)) (- (+ (char-code (char input 31)) (char-code (char input 30))) (char-code (char input 24)))))
                                                                                    nil
                                                                                    (if (not (= (char-code (char input 33)) 125))
                                                                                        nil
                                                                                        t))))))))))))))))))))))

(print (checkFlag "FLAGHERE"))
```

In this fashion we resolve each character one by one until we finally get the flag.

Flag `UDCTF{h4v3_y0u_alw4ys_h4d_a_L1SP?}`