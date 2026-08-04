clear; clc;

fc = 10000;  
kf = 2500;
fm = 2000;  
Am = 1;   

delta_f = kf * Am;
fprintf('Peak frequency deviation: Delta_f = %.1f Hz\n', delta_f);

%% FM: beta = Delta_f / fm
beta = delta_f / fm;
fprintf('FM modulation index: beta = %.3f\n', beta);

%% Carson: B = 2*(Delta_f + fm)
B_carson = 2 * (delta_f + fm);
fprintf('Carson bandwidth: B = %.1f Hz\n', B_carson);

%% Spectrum Analyzer
f_low  = fc - B_carson/2;
f_high = fc + B_carson/2;
fprintf('Expected significant spectral content: %.1f Hz to %.1f Hz\n', f_low, f_high);
fprintf('(Compare this range against the Spectrum Analyzer plot from the Simulink model.)\n');
