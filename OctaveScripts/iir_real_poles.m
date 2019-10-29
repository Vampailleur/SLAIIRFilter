pkg load signal

clear all;
close all;
clc;


fs = 100e6;


iirQuant.nbBitsInput = 16;
iirQuant.nbFracBitsInput = 0;
iirQuant.nbBitsCoef = 30;
iirQuant.nbFracBitsCoef = 28;
iirQuant.nbBitsFIRGain = 0;
iirQuant.nbBitsIIRGain = 0; %% 0 = gain is 0 dB or less for all frequencies
iirQuant.nbBitsOutput = 16; %% should be equal to number of input bits + number of bits for FIR gain + number of bits for IIR gain + number 
iirQuant.nbFracBitsOutput = 0;
iirQuant.nbGuardBits = 1; %% should always be 1, setting 0 could lead to problem
iirQuant.nbAddPrecisionBits = 10; %% Number of additional precision bits for the all-pole calculation
iirQuant.saturateOutput = 1; 


% design an IIR filter with 2 distinct real poles
% i.e. a cascade of 2 order-1 IIR filter
r1 = 0.999;
r2 = 0.998;
num = [(1 - (r1 + r2) + r1*r2), 0, 0];
den = [1, -(r1 + r2), r1*r2];

[num2, den2] = scattered_lookahead_transform(num,den, 2);




[numQuant, denQuant] = quantize_coefs(num2,den2, iirQuant.nbFracBitsCoef);



step = (2^(iirQuant.nbBitsInput-1)-1).*ones(1,20000);
length_step = length(step);


step_response_orig = filter(num,den, step);
stepResponseQuant = IIRSLAFixedPointFilter(numQuant, denQuant, iirQuant, step); 




figure
plot(1:length_step, stepResponseQuant, 1:length_step, step_response_orig);
legend('Quantized','Original')


%% if quantization is deemed acceptable, generate Model

generateModel('IIR_with_real_poles', '..\IIR with real poles', numQuant, denQuant, iirQuant, step, stepResponseQuant);

