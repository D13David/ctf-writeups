# BraekerCTF 2024

## e

> "Grrrrr". This robot just growls. The other bots tell you that it is angry because it can't count very high. Can you teach it how?
>
>  Author: spipm
>
> [`e.cpp`](e.cpp)

Tags: _misc_

## Solution
We get a small c++ that does three stages of tests and gives us the flag if we succeed all stages.

So, lets tackle this one by one:

```c++
bool flow_start() {

	// Get user input
	float a = get_user_input("Number that is equal to two: ");

	// Can't be two
	if (a <= 2)
		return false;

	// Check if equal to 2
	return (unsigned short)a == 2;
}
```

The user input is stored as float and then cast to an `unsigned short`. Here we can use the integer overflow at 16-bit to get back to value `2`. Passing in `65538` will overflow the maximum value by 3 (0xffff-65538 = -3) giving us the value 2.

```bash
$ nc 0.cloud.chals.io 30531
Welcome!
Number that is equal to two:
65538
Well done! This is the second round:
```

Lets move on to the second stage.

```c++
bool round_2() {

	float total = 0;

	// Sum these numbers to 0.9
	for (int i = 0; i < 9; i++)
		total += 0.1;

	// Add user input
	total += get_user_input("Number to add to 0.9 to make 1: ");

	// Check if equal to one
	return total == 1.0;
}
```

This is a typical precision issue. Mathematically we need to add `0.1` but that will overshoot by a tiny amount giving us something line ~`1.00000012`. We rather give `0.0999999` to get to the sum of `1.0`.

```bash
Number to add to 0.9 to make 1:
0.0999999
Great! Up to level three:
```

Perfect, now for the last stage.

```c++
bool level_3() {

	float total = 0;

	unsigned int *seed;
	vector<float> n_arr;

	// Random seed
	seed = (unsigned int *)getauxval(AT_RANDOM);
	srand(*seed);

	// Add user input
	add_user_input(&n_arr, "Number to add to array to equal zero: ");

	// Add many random integers
	for (int i = 0; i < 1024 * (8 + rand() % 1024); i++)
		n_arr.push_back((rand() % 1024) + 1);

	// Add user input
	add_user_input(&n_arr, "Number to add to array to equal zero: ");

	// Get sum
	for (int i = 0; i < n_arr.size(); i++)
		total += n_arr[i];

	// Check if equal to zero
	return total == 0;
}
```

Here we can specify two numbers. After the first number a random number of float values is put into an array. After this we can specify a final number. The test succeeds if the sum of all the numbers is `0`. Since there is no way to know what the sum of the random numbers is we have to find another way. Thankfully we can squeeze the faily small values (range between 1 and 1024) by just specifying a very big value at the beginning and a big negative value at the end. This rendering the random values pretty much without any impact and leading to the sum of zero.

```bash
Number to add to array to equal zero:
30000000000
Number to add to array to equal zero:
-30000000000
Well done! Here is the flag: brck{Th3_3pS1l0n_w0rkS_In_M15t3riOuS_W4yS}
```

Flag `brck{Th3_3pS1l0n_w0rkS_In_M15t3riOuS_W4yS}`