import numpy as np
import soundfile as sf

impulse, rate = sf.read('impulse_response.wav')
shuffled_flag, rate = sf.read('shuffled_flag.wav')
amplitudes1 = np.fft.rfft(impulse)
amplitudes2 = np.fft.rfft(shuffled_flag)
amplitudes2 = amplitudes2 / amplitudes1
sf.write('flag.wav', np.fft.irfft(amplitudes2), rate)