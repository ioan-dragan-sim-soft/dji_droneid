clear all;
symbol_number = 6;
file_path = ['/opt/dji/collects/zc_symbol_', mat2str(symbol_number), '_15360KSPS_time_domain.fc32'];

file_handle = fopen(file_path, 'r');
reals = fread(file_handle, inf, 'single');
fclose(file_handle);

received_samples = reals(1:2:end) + 1j * reals(2:2:end);

figure(1); plot(10 * log10(abs(received_samples).^2));

root_sequnce_attempts = 1000;
scores = zeros(root_sequnce_attempts, 1);

for root=1:length(scores)
    try
        % Not all ZC roots are valid and the function will throw an error if the root is invalid
        zc = zadoffChuSeq(root, 601);

        % Remove the center sample as this is what's done on the transmitter.
        zc = [zc(1:300); zc(302:end)];
    catch
        continue
    end
    
    % Correlate the 
    scores(root) = abs(xcorr(received_samples, zc(1:end), 0, 'normalized')).^2;
end

figure(2);
plot(scores);
title('ZC Normalized XCorr Results')

[value, index] = max(scores);
if (value < 0.7)
    warning('Unable to find matching sequence');
end

zc = zadoffChuSeq(index, 601);
figure(3);
subplot(2, 1, 1);
spectrogram(zc);
title('Calculated ZC')
subplot(2, 1, 2);
spectrogram(received_samples);
title('Received ZC')

figure(4)
subplot(2, 1, 1);
plot(abs(fftshift(fft(zc))).^2);
title('Calculated ZC')
subplot(2, 1, 2);
plot(abs(fftshift(fft(received_samples))).^2);
title('Received ZC')