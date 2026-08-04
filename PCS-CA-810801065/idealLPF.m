function y = idealLPF(x, Fs, W)
    x = x(:);
    N = length(x);
    X = fft(x);

    f = (0:N-1) * (Fs/N);
    f(f > Fs/2) = f(f > Fs/2) - Fs;

    mask = (abs(f) <= W);
    X(~mask) = 0;

    y = real(ifft(X));
end
