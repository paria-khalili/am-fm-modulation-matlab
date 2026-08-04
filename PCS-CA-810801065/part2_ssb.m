clear; clc; close all;
Fs     = 48000;
fc     = 15000;
sigma2 = 0.01;
W      = 4000;
[m_raw, Fs_read] = audioread('m_a1.mp3');
if size(m_raw,2) > 1, m_raw = mean(m_raw,2); end
if Fs_read ~= Fs, Fs = Fs_read; end
m = m_raw / max(abs(m_raw));
 
N  = length(m);
Ts = 1/Fs;
t  = (0:N-1)' * Ts;
m_hilb = manualHilbert(m, Fs);
 
xc_usb = m .* cos(2*pi*fc*t) - m_hilb .* sin(2*pi*fc*t);   % Upper Sideband
xc_lsb = m .* cos(2*pi*fc*t) + m_hilb .* sin(2*pi*fc*t);   % Lower Sideband
 
n = sqrt(sigma2) * randn(N,1);
 
sidebands = struct('name', {'USB', 'LSB'}, 'sig', {xc_usb, xc_lsb});
 
MSE_all = zeros(1,2);
SNR_all = zeros(1,2);
 
for k = 1:2
    r = sidebands(k).sig + n;
    m_hat = 2 * idealLPF(z, Fs, W);
 
    plotTimeFreq(t, sidebands(k).sig, Fs, ['x_c(t) - SSB modulated signal (' sidebands(k).name ')']);
    saveas(gcf, ['fig_ssb_' lower(sidebands(k).name) '_xc.png']);
 
    plotTimeFreq(t, m_hat, Fs, ['m hat(t) - SSB recovered signal (' sidebands(k).name ')']);
    saveas(gcf, ['fig_ssb_' lower(sidebands(k).name) '_mhat.png']);
 
    MSE_all(k) = mean((m - m_hat).^2);
    signal_power = mean(m.^2);
    error_power  = mean((m - m_hat).^2);
    SNR_all(k) = 10*log10(signal_power / error_power);
 
    fprintf('[SSB-%s] MSE = %.6g , SNR = %.3f dB\n', sidebands(k).name, MSE_all(k), SNR_all(k));
end
 
r_usb = xc_usb + n;
 
phase_errors  = [pi/2, pi/4, pi/3];
MSE_phase_ssb = zeros(size(phase_errors));
for i = 1:numel(phase_errors)
    dphi    = phase_errors(i);
    z_p     = r_usb .* cos(2*pi*fc*t + dphi);
    m_hat_p = 2 * idealLPF(z_p, Fs, W);
    MSE_phase_ssb(i) = mean((m - m_hat_p).^2);
    fprintf('[SSB-USB - phase error] dphi = %.4f rad -> MSE = %.6g\n', dphi, MSE_phase_ssb(i));
end
z_rep_phase = r_usb .* cos(2*pi*fc*t + pi/4);
plotTimeFreq(t, 2*idealLPF(z_rep_phase, Fs, W), Fs, 'SSB-USB: m hat(t), phase error = pi/4');
saveas(gcf, 'fig_ssb_phase_rep.png');
 
freq_errors  = [0.1, 0.01, 0.001] * fc;
MSE_freq_ssb = zeros(size(freq_errors));
for i = 1:numel(freq_errors)
    df      = freq_errors(i);
    z_f     = r_usb .* cos(2*pi*(fc+df)*t);
    m_hat_f = 2 * idealLPF(z_f, Fs, W);
    MSE_freq_ssb(i) = mean((m - m_hat_f).^2);
    fprintf('[SSB-USB - frequency error] df = %.2f Hz -> MSE = %.6g\n', df, MSE_freq_ssb(i));
end
z_rep_freq = r_usb .* cos(2*pi*(fc+freq_errors(1))*t);
plotTimeFreq(t, 2*idealLPF(z_rep_freq, Fs, W), Fs, 'SSB-USB: m hat(t), frequency error = 0.1 fc');
saveas(gcf, 'fig_ssb_freq_rep.png');
 
order = 6;
Wn    = W / (Fs/2);
[b, a] = butter(order, Wn, 'low');
 
z0 = r_usb .* cos(2*pi*fc*t);
m_hat_butter_ssb = 2 * filtfilt(b, a, z0);
MSE_butter_ssb   = mean((m - m_hat_butter_ssb).^2);
fprintf('[SSB-USB - Butterworth order %d] MSE = %.6g\n', order, MSE_butter_ssb);
plotTimeFreq(t, m_hat_butter_ssb, Fs, 'SSB-USB: m hat(t), Butterworth LPF');
saveas(gcf, 'fig_ssb_butter.png');
 
fprintf('\n=== SSB summary for comparison table ===\n');
fprintf('USB ideal: MSE = %.6g, SNR = %.3f dB\n', MSE_all(1), SNR_all(1));
fprintf('LSB ideal: MSE = %.6g, SNR = %.3f dB\n', MSE_all(2), SNR_all(2));
fprintf('USB phase error (pi/2,pi/4,pi/3): MSE = [%.6g, %.6g, %.6g]\n', MSE_phase_ssb);
fprintf('USB frequency error (10%%,1%%,0.1%%): MSE = [%.6g, %.6g, %.6g]\n', MSE_freq_ssb);
fprintf('USB Butterworth filter: MSE = %.6g\n', MSE_butter_ssb);