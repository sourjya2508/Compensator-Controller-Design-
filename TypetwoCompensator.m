clc; clear; close all;
s = tf('s'); % Define Laplace variable

%% SPECIFICATIONS
Vs = 60; Vo = 15; % Input and output DC voltage values

%% SELECTIONS
f_s = 1e5; % Switching frequency

%% BUCK CONTROLLER IC: LM5146
Vref = 0.8; % Reference voltage
Vramp = Vs/15; % Ramp voltage amplitude
A_DC = 50119; % Error amplifier open-loop DC gain
f_pe = 129.7; % Error amplifier open-loop pole

%% COMPONENTS
R = 7.5; L = 300e-6; C = 20e-6; % Buck converter output filter values
r_C = 0.400; % ESR of capacitor
r_L = 0.025; % ESR of inductor

%% TRANSFER FUNCTIONS
M = Vs/Vramp; % PWM modulator gain
F = (1+r_C*C*s) / ...
    (1+r_L/R + (L/R+(r_C+r_L)*C+r_C*r_L*C/R)*s + (1+r_C/R)*L*C*s^2); % Filter & Load

%% BREAK FREQUENCIES
f_LC = 1/(2*pi*sqrt(L*C)); % LC resonance
f_z1 = 0.9*f_LC; % First zero frequency
f_t = 0.1*f_s;   % Target crossover frequency

%% CONTROLLER COMPONENT VALUES
R4 = 1e4; % Bottom resistor (reference divider)
R1 = (Vo/Vref - 1)*R4; % Top resistor (reference divider)
C3 = 1/(2*pi*f_z1*R1);
R3 = 1/(2*pi*f_t*C3);

G_MF = M*F; % Modulator * Plant
K_comp = 1.438; % Required compensator gain

R2 = K_comp*(R1^-1+R3^-1)^-1;
C2 = 1/(2*pi*0.9*f_LC*R2);
C1 = 1/(2*pi*10*f_t*R2);

%% COMPENSATOR TRANSFER FUNCTION
G_OL = -A_DC/(1+s/(2*pi*f_pe)); % Error amplifier
beta = (R1*R3*C1*s*(s+(C1+C2)/(C1*C2*R2))*(s+1/(R3*C3))) / ...
       ((R1+R3)*(s+1/(R2*C2))*(s+1/((R1+R3)*C3)));
G_comp = G_OL/(1+G_OL*beta); % Compensator
G_loop = M*F*G_comp; % Open-loop

%% --- BODE PLOTS ---

figure;

% Plant (F)
subplot(2,2,1);
bode(F);
grid on;
title('Plant: F(s)');

% Plant + Modulator (G_MF)
subplot(2,2,2);
bode(G_MF);
grid on;
title('Modulator * Plant: G_{MF}(s)');

% Compensator
subplot(2,2,3);
bode(G_comp);
grid on;
title('Compensator: G_{comp}(s)');

% Open-Loop
subplot(2,2,4);
bode(G_loop);
grid on;
title('Open-Loop: G_{loop}(s)');

%% Overlay Comparison
figure;
bode(F, G_MF, G_comp, G_loop, {1e1, 1e7});
legend('F(s)', 'G_{MF}(s)', 'G_{comp}(s)', 'G_{loop}(s)');
grid on;
title('Bode Plot Comparison');

%% Stability Margins (numerical + plot)
[GM, PM, Wcg, Wcp] = margin(G_loop);
fprintf('Gain Margin = %.2f dB at %.2f Hz\n', 20*log10(GM), Wcg/(2*pi));
fprintf('Phase Margin = %.2f deg at %.2f Hz\n', PM, Wcp/(2*pi));

figure;
margin(G_loop);
grid on;
title('Open-Loop Bode with Gain/Phase Margins');
