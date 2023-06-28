# Google CTF 2023

## SYMATRIX

> The CIA has been tracking a group of hackers who communicate using PNG files embedded with a custom steganography algorithm. 
An insider spy was able to obtain the encoder, but it is not the original code. 
You have been tasked with reversing the encoder file and creating a decoder as soon as possible in order to read the most recent PNG file they have sent.
>
>  Author: N/A
>
> [`attachment.zip`](attachment.zip)

Tags: _misc_

## Solution
For this challenge a image is given as well as the c code for the encoder. Looking up the code it seems to be generated from a python script and some python snippets are left in for debugging purpose. Snippets are given in the following form

```c
/* "encoder.py":49
 *
 * for i in range(0, y_len):
 *     for j in range(0, x_len):             # <<<<<<<<<<<<<<
 *
 *         pixel = new_matrix[j, i] = base_matrix[j, i]
 */
 ```

On the top the python file and the line number is given and the marker `# <<<<<<<<<<<<<<` shows the specific line. By going through all the snippets the original python script can be reconstructed.

```python
from PIL import Image
from random import randint
import binascii

def hexstr_to_binstr(hexstr):
    n = int(hexstr, 16)
    bstr = ''
    while n > 0:
        bstr = str(n % 2) + bstr
        n = n >> 1
    if len(bstr) % 8 != 0:
        bstr = '0' + bstr
    return bstr


def pixel_bit(b):
    return tuple((0, 1, b))


def embed(t1, t2):
    return tuple((t1[0] + t2[0], t1[1] + t2[1], t1[2] + t2[2]))


def full_pixel(pixel):
    return pixel[1] == 255 or pixel[2] == 255

print("Embedding file...")

bin_data = open("./flag.txt", 'rb').read()
data_to_hide = binascii.hexlify(bin_data).decode('utf-8')

base_image = Image.open("./original.png")

x_len, y_len = base_image.size
nx_len = x_len * 2

new_image = Image.new("RGB", (nx_len, y_len))

base_matrix = base_image.load()
new_matrix = new_image.load()

binary_string = hexstr_to_binstr(data_to_hide)
remaining_bits = len(binary_string)

nx_len = nx_len - 1
next_position = 0

for i in range(0, y_len):
    for j in range(0, x_len):

        pixel = new_matrix[j, i] = base_matrix[j, i]

        if remaining_bits > 0 and next_position <= 0 and not full_pixel(pixel):
            new_matrix[nx_len - j, i] = embed(pixel_bit(int(binary_string[0])),pixel)
            next_position = randint(1, 17)
            binary_string = binary_string[1:]
            remaining_bits -= 1
        else:
            new_matrix[nx_len - j, i] = pixel
            next_position -= 1


new_image.save("./symatrix.png")
new_image.close()
base_image.close()

print("Work done!")
exit(1)
```

This is better to comprehend. In short, a image is loaded and a new image with double the width is created and filled with values from the original image.

```python
for i in range(0, y_len):
    for j in range(0, x_len):

        pixel = new_matrix[j, i] = base_matrix[j, i]
        # ...
```

The left side of the new image is just a copy of the original image.

```python
        if remaining_bits > 0 and next_position <= 0 and not full_pixel(pixel):
            new_matrix[nx_len - j, i] = embed(pixel_bit(int(binary_string[0])),pixel)
            next_position = randint(1, 17)
            binary_string = binary_string[1:]
            remaining_bits -= 1
        else:
            new_matrix[nx_len - j, i] = pixel
            next_position -= 1
```

The right half of the image is the vertically flipped variant of the original image and in some pixels bits of the flag message are hidden. The rules are that bits are only hidden in pixels where `b` and `g` are 0. Also the next potential candidate position is randomized by choosing a value between 1 and 17, meaning the hidden data cannot be just read as a consecutive bit string. But since we have the original pixels we can just test if the mirrored pixel value differs from the original pixel value.

```python
flag_bits = int('0')
for j in range(0, y_len):
    for i in range(0, half_x_len):
        t1 = matrix[i, j]
        t2 = matrix[x_len - i - 1, j]
        if t1 != t2:
            flag_bits = (flag_bits << 1) | (t2[2] - t1[2])
```

We iterate over the image data one half line at a time and read the current and the mirrored pixel. If the pixels differ we know a flag bit is hidden and we substract the original value of channel 2 from the new value and add the bit to our bit string. After this the resulting number just needs to be converted back to a byte array.

As a side node, the original code has a out of bound read because the code iterates `j=0..x_len-1` but writes to `new_matrix[nx_len - j, i]` where `nx_len = 2 * x_len`, meaning for `j=0` the read happens at `nx_len, i` which is out of bound of the array. The read seems not to happen since the randomization jumps over the right border and the first pixel is never considered as `next_position` is initialized with 0. Therefore the solver script compensates for this by decrementing one `t2 = matrix[x_len - i - 1, j]`. The full solver script can be seen here.

```python
from PIL import Image
from Crypto.Util.number import long_to_bytes as l2b

image = Image.open("symatrix.png")
x_len, y_len = image.size
half_x_len = x_len // 2

matrix = image.load()

flag_bits = int('0')
for j in range(0, y_len):
    for i in range(0, half_x_len):
        t1 = matrix[i, j]
        t2 = matrix[x_len - i - 1, j]
        if t1 != t2:
            flag_bits = (flag_bits << 1) | (t2[2] - t1[2])

print(l2b(flag_bits))
image.close()
```

Flag `CTF{W4ke_Up_Ne0+Th1s_I5_Th3_Fl4g!}`