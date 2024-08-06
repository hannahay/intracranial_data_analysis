function envelope = getEnvelopeOfFrequencyBandWithHilbert(...
    signal,sr,lowFreqBoundry, highFreqBoundry)

tmp = bandpass(signal, [lowFreqBoundry, highFreqBoundry],sr);
envelope = abs(hilbert(tmp));


end
