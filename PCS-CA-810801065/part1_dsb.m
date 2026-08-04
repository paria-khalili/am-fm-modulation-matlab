clear; clc; close all;
Fs = 48000;
fc = 15000; 
sigma2 = 0.01;
W = 4000;   
[m_raw, Fs_read] = audioread('m_t1.mp3');
if size(m_raw,2) > 1, m_raw = mean(m_raw,2); end
if Fs_read ~= Fs, Fs = Fs_read; end
m = m_raw / max(abs(m_raw));

N  = length(m);
Ts = 1/Fs;
t  = (0:N-1)' * Ts;
xc = m .* cos(2*pi*fc*t);
n = sqrt(sigma2) * randn(N,1);
r = xc + n;
z     = r .* cos(2*pi*fc*t);
m_hat = idealLPF(z, Fs, W);

plotTimeFreq(t, xc,    Fs, 'x_c(t) - DSB modulated signal');
saveas(gcf, 'fig_dsb_xc.png');
plotTimeFreq(t, z,     Fs, 'z(t) - receiver mixer output');
saveas(gcf, 'fig_dsb_z.png');
plotTimeFreq(t, m_hat, Fs, 'm hat(t) - recovered signal');
saveas(gcf, 'fig_dsb_mhat.png');

MSE_ideal = mean((m - m_hat).^2);
fprintf('[DSB - ideal case] MSE = %.6g\n', MSE_ideal);

signal_power = mean(m.^2);
error_power  = mean((m - m_hat).^2);
SNR_dB       = 10*log10(signal_power / error_power);
fprintf('[DSB - ideal case] Output SNR = %.3f dB\n', SNR_dB);

phase_errors  = [pi/2, pi/4, pi/3];
phase_labels  = {'pi_2', 'pi_4', 'pi_3'};
MSE_phase     = zeros(size(phase_errors));
for i = 1:numel(phase_errors)
    dphi        = phase_errors(i);
    z_p         = r .* cos(2*pi*fc*t + dphi);
    m_hat_p     = idealLPF(z_p, Fs, W);
    MSE_phase(i) = mean((m - m_hat_p).^2);
    fprintf('[DSB - phase error] dphi = %.4f rad -> MSE = %.6g\n', dphi, MSE_phase(i));

    plotTimeFreq(t, m_hat_p, Fs, sprintf('DSB: m hat(t), phase error = %.4f rad', dphi));
    saveas(gcf, sprintf('fig_dsb_phase_%s.png', phase_labels{i}));
end

freq_errors  = [0.1, 0.01, 0.001] * fc;
freq_labels  = {'10pct', '1pct', '0p1pct'};
MSE_freq     = zeros(size(freq_errors));
for i = 1:numel(freq_errors)
    df          = freq_errors(i);
    z_f         = r .* cos(2*pi*(fc+df)*t);
    m_hat_f     = idealLPF(z_f, Fs, W);
    MSE_freq(i) = mean((m - m_hat_f).^2);
    fprintf('[DSB - frequency error] df = %.2f Hz (%.3f%% of fc) -> MSE = %.6g\n', ...
             df, 100*freq_errors(i)/fc, MSE_freq(i));

    plotTimeFreq(t, m_hat_f, Fs, sprintf('DSB: m hat(t), freq error = %.3f%% of fc', 100*freq_errors(i)/fc));
    saveas(gcf, sprintf('fig_dsb_freq_%s.png', freq_labels{i}));
end

order = 6;
Wn    = W / (Fs/2);
[b, a] = butter(order, Wn, 'low');
z0 = r .* cos(2*pi*fc*t);
m_hat_butter = filtfilt(b, a, z0);
MSE_butter   = mean((m - m_hat_butter).^2);
fprintf('[DSB - Butterworth order %d] MSE = %.6g\n', order, MSE_butter);
plotTimeFreq(t, m_hat_butter, Fs, 'DSB: m hat(t), Butterworth LPF');
saveas(gcf, 'fig_dsb_butter.png');
fprintf('\n=== DSB summary for comparison table ===\n');
fprintf('Ideal (no impairment): MSE = %.6g, SNR = %.3f dB\n', MSE_ideal, SNR_dB);
fprintf('Phase error (pi/2,pi/4,pi/3): MSE = [%.6g, %.6g, %.6g]\n', MSE_phase);
fprintf('Frequency error (10%%,1%%,0.1%%): MSE = [%.6g, %.6g, %.6g]\n', MSE_freq);
fprintf('Butterworth filter: MSE = %.6g\n', MSE_butter);