clear; clc; close all;
Fs = 48000;
duration_sec = 8; 
fprintf('Recording starts in 2 seconds...\n');
pause(2);
recObj = audiorecorder(Fs, 16, 1);
recordblocking(recObj, duration_sec);
fprintf('Recording finished.\n');
m_raw = getaudiodata(recObj);
audiowrite('my_voice_raw.wav', m_raw, Fs);
 
m = m_raw / max(abs(m_raw));
audiowrite('normalized_my_voice.wav', m, Fs);
 
sound(m, Fs);
pause(length(m)/Fs + 0.3);
N  = length(m);
Ts = 1/Fs;
t  = (0:N-1)' * Ts;
label = 'my-voice';
 
figure('Name', ['Time domain - ' label], 'NumberTitle', 'off');
plot(t, m);
xlabel('Time (s)'); ylabel('Normalized amplitude');
title(['Time domain signal - ' label]);
grid on;
 
M = fftshift(fft(m));
f = (-N/2 : N/2-1) * (Fs/N);
figure('Name', ['FFT Magnitude & Phase - ' label], 'NumberTitle', 'off');
subplot(2,1,1);
plot(f, abs(M));
xlabel('Frequency (Hz)'); ylabel('|M(f)|');
title(['Magnitude spectrum - ' label]);
grid on;
 
subplot(2,1,2);
plot(f, angle(M));
xlabel('Frequency (Hz)'); ylabel('Phase (rad)');
title(['Phase spectrum - ' label]);
grid on;
 
figure('Name', ['Zoomed magnitude spectrum - ' label], 'NumberTitle', 'off');
plot(f, abs(M));
xlim([-4000 4000]);
ylim([0 1.05*max(abs(M))]);
xlabel('Frequency (Hz)'); ylabel('|M(f)|');
title(['Zoomed dominant band - ' label]);
grid on;
pos_idx = f >= 0;
[peak_val, rel_idx] = max(abs(M(pos_idx)));
f_pos = f(pos_idx);
fprintf('%s: Approximate Dominant Frequency = %.1f Hz\n', label, f_pos(rel_idx));