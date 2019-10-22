pkg load signal

clear all;
close all;
clc;


fs = 100e6;
nbBitsInput = 12;

iirQuant.nbBitsInput = 16;
iirQuant.nbFracBitsInput = 0;
iirQuant.nbBitsCoef = 18;
iirQuant.nbFracBitsCoef = 16;
iirQuant.nbBitsFIRGain = 2;
iirQuant.nbBitsIIRGain = 0; %% 0 = gain is 0 dB or less for all frequencies
iirQuant.nbBitsOutput = 18;
iirQuant.nbFracBitsOutput = 0;
iirQuant.nbAddPrecisionBits = 4; %% Number of additional precision bits for the all-pole calculation
iirQuant.saturateOutput = 1; 


% design an IIR filter with 0.001*fs/2 cut-off frequency 
% fcut 500 kHz
[num,den] = butter(2,0.01,'high');



[num2, den2] = scattered_lookahead_transform(num,den, 2);




[numQuant, denQuant] = quantize_coefs(num2,den2, iirQuant.nbFracBitsCoef);
numQuant = adjust_power2_coefs(numQuant, 'high');

% for DC sum = 0


%if (sum(numQuant) ~= 0)
 % numQuant(1) = numQuant - sum(numQuant)
%end  




[H, W] = freqz(num, 1);

max_num = max(abs(H));[H, W] = freqz(num, 1);
iirQuant.nbBitsFIRGain = ceil(log(max_num)/log(2));

figure
subplot(2,1,1)
plot(W,abs(H));
title('Amplitude response of FIR part');

subplot(2,1,2)
plot(W,angle(H));

[H2, W2] = freqz(2^(iirQuant.nbFracBitsCoef), denQuant);
figure
subplot(2,1,1)
plot(W2,abs(H2));
title('Amplitude response of All-pole part');
subplot(2,1,2)
plot(W2,angle(H2));



step = (2^(iirQuant.nbBitsInput-1)-1).*ones(1,900);
length_step = length(step);


iir_states = zeros(1,5);


step_response_orig = filter(num,den, step);
stepResponseQuant = IIRSLAFixedPointFilter(numQuant, denQuant, iirQuant, step); 




figure
plot(1:length_step, stepResponseQuant, 1:length_step, step_response_orig);
legend('Quantized','Original')

error = stepResponseQuant - step_response_orig;

sumAbsError = sum(abs(error));
indexVec = 1 : length(error);
sumAbsErrorWithTime = sum(indexVec.*abs(error))


convertSLAtoVHDL('test_iir',numQuant, denQuant, iirQuant);
createSLASelfCheckingTB('test_iir', iirQuant, step, stepResponseQuant);

createVHDLInputFiles('input_vectors.txt',step);

status = copyfile('test_iir.vhd', 'C:\FPGA\test_iir.vhd');
status = copyfile('test_iir_tb.vhd', 'C:\FPGA\test_iir_tb.vhd');
status = copyfile('input_vectors.txt', 'C:\FPGA\input_vectors.txt');

currentPath = pwd;

% to do : run simulation


chdir('C:\FPGA');
%%system('runsim.bat');
chdir(currentPath);
status = copyfile('C:\FPGA\output_vectors.txt','output_vectors.txt');
fid = fopen('output_vectors.txt');

stepResponseFPGA = fscanf(fid, '%d');

errorFPGA = stepResponseQuant' - stepResponseFPGA;

figure
plot(errorFPGA);