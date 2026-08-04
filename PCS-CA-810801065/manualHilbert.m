function mh = manualHilbert(m, Fs)
    m = m(:);
    N = length(m);
    M = fft(m);

    f = (0:N-1) * (Fs/N);
    f(f > Fs/2) = f(f > Fs/2) - Fs;  

    H = -1i * sign(f(:));
    H(f == 0) = 0;       
    Mh = M .* H;
    mh = real(ifft(Mh));
end
