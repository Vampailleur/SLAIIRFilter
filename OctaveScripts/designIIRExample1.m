pkg load signal
pkg load control

clear all;
close all;
clc;


fs = 100e6;




iirQuant.nbBitsInput = 16; %% Based on your datachain
iirQuant.nbFracBitsInput = 0;
iirQuant.nbBitsCoef = 18;
iirQuant.nbFracBitsCoef = 16;
iirQuant.nbBitsFIRGain = 2; %% 
iirQuant.nbBitsIIRGain = 0; %% 0 = gain is 0 dB or less for all frequencies
iirQuant.nbBitsOutput = 18;
iirQuant.nbFracBitsOutput = 0; %% additional fractional bits for the output. Useful when cascading many filters
iirQuant.nbAddPrecisionBits = 10; %% Number of additional precision bits for the all-pole calculation
iirQuant.saturateOutput = 1; 


% design an IIR filter with 0.001*fs/2 cut-off frequency 
% fcut 500 kHz



% design analog notch filter
fo = 1e6;
fc = fo/100;
type = 2;

numAnalog = [1, 0, (2*pi*fo)^2];
denAnalog = [1, 2*pi*fc, (2*pi*fo)^2];

tfAnalog = tf(numAnalog,denAnalog);

tfDiscrete = c2d(tfAnalog, 1/fs, 'tustin');
figure
step(tfAnalog, tfDiscrete);
[num, den, tsam] = tfdata (tfDiscrete, 'vector');


[num2, den2] = scattered_lookahead_transform(num,den, 2);


[numQuant, denQuant] = quantize_coefs(num2,den2, iirQuant.nbFracBitsCoef);
% Adjust coefs so they have a gain of 0 at DC if high-pass, and a gain of 1 at DC if low-pass
%numQuant = adjust_power2_coefs(numQuant, type);

% for DC sum = 0


%if (sum(numQuant) ~= 0)
 % numQuant(1) = numQuant - sum(numQuant)
%end  


[H, W] = freqz(num, 1);

max_num = max(abs(H));[H, W] = freqz(num, 1);
iirQuant.nbBitsFIRGain = ceil(log(max_num)/log(2));



step = (2^(iirQuant.nbBitsInput-1)-1).*ones(1,20000);

step_response_orig = filter(num,den, step);
stepResponseQuant = IIRSLAFixedPointFilter(numQuant, denQuant, iirQuant, step); 


indexVec = 1 : length(step);
figure
plot(indexVec, stepResponseQuant, indexVec, step_response_orig);
legend('Quantized','Original','debug')

error = stepResponseQuant - step_response_orig;

sumAbsError = sum(abs(error));


convertSLAtoVHDL('test_iir',numQuant, denQuant, iirQuant);
%createSLASelfCheckingTB('test_iir', iirQuant, step, stepResponseQuant);

createVHDLInputFiles('input_vectors.txt',step);


% copy generated files outside the git project 
status = copyfile('test_iir.vhd', 'C:\FPGA\test_iir.vhd');
status = copyfile('test_iir_tb.vhd', 'C:\FPGA\test_iir_tb.vhd');
status = copyfile('input_vectors.txt', 'C:\FPGA\input_vectors.txt');

currentPath = pwd;

% to do : run simulation


chdir('C:\FPGA');
system('runsim.bat');
chdir(currentPath);
status = copyfile('C:\FPGA\output_vectors.txt','output_vectors.txt');
fid = fopen('output_vectors.txt');

stepResponseFPGA = fscanf(fid, '%d');

errorFPGA = stepResponseQuant' - stepResponseFPGA;

figure
plot(errorFPGA);


%% chirp response

finit = 100;

fend = fs/20;

T = 0.001;

nbPoints = T*fs;
wVec = 2*pi.*linspace(finit, fend, nbPoints)./fs;

ph = cumsum(wVec);
clear wVec;

chirp = round((2^(iirQuant.nbBitsInput-1)-1).*sin(ph));
clear ph;


chirp_response_orig = filter(num,den, chirp);
chirpResponseQuant = IIRSLAFixedPointFilter(numQuant, denQuant, iirQuant, chirp); 

indexVec = 1 : length(chirp_response_orig);

figure
plot(indexVec, chirpResponseQuant, indexVec, chirp_response_orig);
legend('Quantized','Original')
title('Chirp response');


createVHDLInputFiles('input_vectors.txt',chirp);


% copy generated files outside the git project 
status = copyfile('test_iir.vhd', 'C:\FPGA\test_iir.vhd');
status = copyfile('test_iir_tb.vhd', 'C:\FPGA\test_iir_tb.vhd');
status = copyfile('input_vectors.txt', 'C:\FPGA\input_vectors.txt');

currentPath = pwd;

% to do : run simulation


chdir('C:\FPGA');
system('runsim.bat');
chdir(currentPath);
status = copyfile('C:\FPGA\output_vectors.txt','output_vectors.txt');
fid = fopen('output_vectors.txt');

ResponseFPGA = fscanf(fid, '%d');

errorFPGA = chirpResponseQuant' - ResponseFPGA;

figure
plot(errorFPGA);
title('FPGA implementation error');