clc; clear; close all;
s = tf('s'); % Laplace parameter

%% SPECIFICATIONS
Vs = 60; Vo = 15; % Input and output DC voltage values

%% SELECTIONS
f_s = 1e5; % Switching frequency

%% BUCK CONTROLLER IC: LM5146
Vref = 0.8; % Reference voltage from Buck Controller LM5146
Vramp = Vs/15; % Ramp voltage amplitude from Buck Controller LM5146
A_DC = 50119; % Error amplifier open-loop DC gain
GBW = 6.5e6; % Error amplifier gain bandwidth product
f_pe = GBW/A_DC; % Error amplifier open-loop pole: f_pe = 129.7 Hz.

%% COMPONENTS
R = 7.5; L = 300e-6; C = 20e-6; % Buck converter output filter values
r_C = 400e-3; % ESR of the capacitor C 
r_L = 25e-3; % ESR of the inductor L

%% TRANSFER FUNCTIONS
M = Vs/Vramp; % PWM modulator transfer function
F = (1+r_C*C*s) / (1+r_L/R + (L/R+(r_C+r_L)*C+r_C*r_L*C/R)*s + (1+r_C/R)*L*C*s^2); % Filter and Load

%% FREQUENCIES and PARAMETERS
f_t = 0.1*f_s; % Crossover frequency (selected one decade below f_s)
phase_comp = 201*pi/180; % Required compensator phase
K_comp = 1/(M*0.04636); % Required compensator gain at crossover
K = (tan(0.25*(phase_comp + pi/2)))^2; % K factor

%% CONTROLLER COMPONENT VALUES
R1 = 2e5; % Upper resistor for reference voltage divider (selected).
R2 = K_comp*R1/sqrt(K);
C1 = 1/(2*pi*f_t*R2*sqrt(K));
C2 = sqrt(K)/(2*pi*f_t*R2);
C3 = sqrt(K)/(2*pi*f_t*R1);
R3 = 1/(2*pi*f_t*C3*sqrt(K));
R4 = Vref*R1/(Vo-Vref); % Lower resistor for reference voltage divider.

%% COMPENSATOR TRANSFER FUNCTION
G_OL = -A_DC/(1+s/(2*pi*f_pe)); % Error amplifier transfer function
beta = (R1*R3*C1*s*(s+(C1+C2)/(C1*C2*R2))*(s+1/(R3*C3))) / ...
       ((R1+R3)*(s+1/(R2*C2))*(s+1/((R1+R3)*C3)));
G_comp = G_OL/(1+G_OL*beta); % Compensator transfer function
G_loop = M*F*G_comp;         % Open-loop transfer function

%% --- Bode Plots ---
figure;

% Plant (F)
subplot(2,2,1);
bode(F);
grid on;
title('Plant: F(s)');

% Plant + PWM Modulator (M*F)
subplot(2,2,2);
bode(M*F);
grid on;
title('PWM Modulator * Plant: M*F(s)');

% Compensator (G_comp)
subplot(2,2,3);
bode(G_comp);
grid on;
title('Compensator: G_{comp}(s)');

% Open-Loop (G_loop)
subplot(2,2,4);
bode(G_loop);
grid on;
title('Open-Loop: G_{loop}(s)');

%% Overlayed Comparison
figure;
bode(F, M*F, G_comp, G_loop,{1e1,1e7});
legend('F(s)', 'M*F(s)', 'G_{comp}(s)', 'G_{loop}(s)');
grid on;
title('Bode Plot Comparison');

%% Stability Margins for Open Loop
figure;
margin(G_loop);
grid on;
title('Open-Loop Bode Plot with Gain/Phase Margins');
