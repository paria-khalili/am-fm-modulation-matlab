clear; clc; close all;

Fs = 48000;           

files  = {'m_a1.mp3', 'm_r1.mp3', 'm_r2.mp3', 'm_t1.mp3', 'm_t2.mp3'};
for k = 1:numel(files)

    [m_raw, Fs_read] = audioread(files{k});
    if size(m_raw,2) > 1
        m_raw = mean(m_raw,2);        
    end
    if Fs_read ~= Fs
        warning(['Sample rate mismatch for ' files{k} ': found ' num2str(Fs_read) ...
         ' Hz, expected ' num2str(Fs) ' Hz. Using the rate read from file.']);
        Fs = Fs_read;
    end

    m = m_raw / max(abs(m_raw));

    output_filename = ['normalized_' files{k}];
    audiowrite(output_filename, m, Fs); 

    current_directory = pwd; 
    exact_file_location = fullfile(current_directory, output_filename);

    fprintf('Saved: %s\n', exact_file_location);

    sound(m, Fs);
    pause(length(m)/Fs + 0.3);          
    N  = length(m);
    Ts = 1/Fs;
    t  = (0:N-1)' * Ts;     
end