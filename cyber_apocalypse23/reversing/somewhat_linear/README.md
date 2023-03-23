# Cyber Apocalypse 2023

## Somewhat Linear

> Deep in the alien cave system, you find a strange device. It seems to be some sort of communication cipherer, but only a couple of recordings are still intact. Can you figure out what the aliens were trying to say? The flag is all lower case
>
>  Author: N/A
>
> [`rev_somewhat_linear.zip`](rev_somewhat_linear.zip)

Tags: _rev_

## Solution
For this challenge there are three files. Two wav files and a python script. Looking at the script it can be seen that the input file `flag.wav` was overlayd with random amplitudes. We basically also get the amplited in form of a second wav `impulse_response.wav`.

```python
import numpy as np
import soundfile as sf

flag, rate = sf.read('../htb/flag.wav')


# randomly shuffle the frequencies
freqs = np.fft.rfftfreq(len(flag), 1.0/rate)
filter_frequency_response = np.random.uniform(-10, 10, len(freqs))

# get the amplitudes
def filter(sample):
    amplitudes = np.fft.rfft(sample)
    shuffled_amplitudes = amplitudes * filter_frequency_response

    return np.fft.irfft(shuffled_amplitudes)

impulse = np.zeros(len(flag))
impulse[0] = 1

shuffled_signal = filter(impulse)
sf.write('impulse_response.wav', shuffled_signal, rate)

shuffled_flag = filter(flag)
sf.write('shuffled_flag.wav', shuffled_flag, rate)
```

Reversing this is actually very easy. The random amplitudes can be recreated from `impulse_response.wav` and with that we can reverse the overlay in `shuffled_flag.wav` signal by [`dividing it by the amplitudes`](solution.py).

```python
import numpy as np
import soundfile as sf

impulse, rate = sf.read('impulse_response.wav')
shuffled_flag, rate = sf.read('shuffled_flag.wav')
amplitudes1 = np.fft.rfft(impulse)
amplitudes2 = np.fft.rfft(shuffled_flag)
amplitudes2 = amplitudes2 / amplitudes1
sf.write('flag.wav', np.fft.irfft(amplitudes2), rate)
```

After doing so we can just play the `flag.wav` file can listen to a reader reading the flag `HTB{th1s_w@s_l0w_eff0rt}`.