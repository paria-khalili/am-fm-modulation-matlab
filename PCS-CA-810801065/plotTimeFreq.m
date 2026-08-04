function plotTimeFreq(t, x, Fs, sigName)
    x = x(:);
    N = length(x);
    X = fftshift(fft(x));
    f = (-N/2 : N/2-1) * (Fs/N);

    figure('Name', sigName, 'NumberTitle', 'off');

    subplot(2,1,1);
    plot(t, x);
    xlabel('Time (s)'); ylabel('Amplitude');
    title(['Time Domain: ' sigName]);
    grid on;

    subplot(2,1,2);
    plot(f, abs(X));
    xlabel('Frequency (Hz)'); ylabel('|X(f)|');
    title(['Frequency Domain: ' sigName]);
    grid on;
end
