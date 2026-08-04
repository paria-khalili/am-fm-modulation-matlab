clear; clc; close all;
 
Fs = 48000;
files  = {'normalized_m_a1.mp3', 'normalized_m_r1.mp3', 'normalized_m_r2.mp3', ...
          'normalized_m_t1.mp3', 'normalized_m_t2.mp3'};
labels = {'m-a1', 'm-r1', 'm-r2', 'm-t1', 'm-t2'};
 
for k = 1:numel(files)
    [m, Fs_read] = audioread(files{k});
    if size(m,2) > 1
        m = mean(m,2);
    end
    if Fs_read ~= Fs
        Fs = Fs_read;
    end
    N  = length(m);
    Ts = 1/Fs;
    t  = (0:N-1)' * Ts;             
    figure('Name', ['Time domain - ' labels{k}], 'NumberTitle', 'off');
    plot(t, m);
    xlabel('Time(s)'); ylabel('Normalized Amplitude');
    title([labels{k}]);
    grid on;
 
    M = fftshift(fft(m));
    f = (-N/2 : N/2-1) * (Fs/N);     
 
    figure('Name', ['FFT Magnitude & Phase - ' labels{k}], 'NumberTitle', 'off');
    subplot(2,1,1);
    plot(f, abs(M));
    xlabel('frequency'); ylabel('magnitude');
    title(['(Magnitude) - ' labels{k}]);
    grid on;
 
    subplot(2,1,2);
    plot(f, angle(M));
    xlabel('frequency'); ylabel('phase');
    title(['(Phase) - ' labels{k}]);
    grid on;
 
    figure('Name', ['Zoomed magnitude spectrum - ' labels{k}], 'NumberTitle', 'off');
    plot(f, abs(M));
    xlim([-4000 4000]);        
    ylim([0 1.05*max(abs(M))]);  
    xlabel('frequency(Hz)'); ylabel('Magnitude |M(f)|');
    title(['Zoom on Dominant Frequency Band - ' labels{k}]);
    grid on;
 
    pos_idx = f >= 0;
    [peak_val, rel_idx] = max(abs(M(pos_idx)));
    f_pos = f(pos_idx);
    fprintf('%s: Approximate Dominant Frequency = %.1f Hz\n', labels{k}, f_pos(rel_idx));
end