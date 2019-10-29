pkg load signal

clear all;
close all;
clc;


fs = 100e6;
nbBitsInput = 12;

iirQuant.nbBitsInput = 16;
iirQuant.nbFracBitsInput = 0;
iirQuant.nbBitsCoef = 22;
iirQuant.nbFracBitsCoef = 20;
iirQuant.nbBitsFIRGain = 2;
iirQuant.nbBitsIIRGain = 0; %% 0 = gain is 0 dB or less for all frequencies
iirQuant.nbBitsOutput = 18;
iirQuant.nbFracBitsOutput = 0;
iirQuant.nbAddPrecisionBits = 4; %% Number of additional precision bits for the all-pole calculation
iirQuant.saturateOutput = 1; 


% design an IIR filter with 0.01*fs/2 cut-off frequency 
% fcut 500 kHz
[num,den] = butter(2,0.001,'high');



[num2, den2] = scattered_lookahead_transform(num,den, 2);




[numQuant, denQuant] = quantize_coefs(num2,den2, iirQuant.nbFracBitsCoef);
numQuant = adjust_power2_coefs(numQuant, 1);




[H, W] = freqz(num, 1);

max_num = max(abs(H));[H, W] = freqz(num, 1);
iirQuant.nbBitsFIRGain = ceil(log(max_num)/log(2));




step = (2^(iirQuant.nbBitsInput-1)-1).*ones(1,2000);
length_step = length(step);


step_response_orig = filter(num,den, step);
stepResponseQuant = IIRSLAFixedPointFilter(numQuant, denQuant, iirQuant, step); 




figure
plot(1:length_step, stepResponseQuant, 1:length_step, step_response_orig);
legend('Quantized','Original')


%% if quantization is deemed acceptable, generate Model

generateModel('test_iir', '..\High-pass IIR', numQuant, denQuant, iirQuant, step, stepResponseQuant);

