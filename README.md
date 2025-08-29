Compensator Controller Design for Voltage-Mode Buck Converter using Type-II/III Compensation
Objective:- Design a Type II/III compensator for a regular Buck Converter.
Design Parameters:- Vin = 60V, Vout =15V, Iout=2A, voltage ripple =1%,  L= 300uH, rL= 25mohm, rC = 400mohm, C = 20uF,  fs= 100kHz.
Target:- Design a compensator to achieve a crossover frequency of 10kHz and Phase Margin of 55 degrees.
Buck Controller IC LM5146 specs:- Vin (5.5V-100V), Imax=20A, Vref=0.8V, Vramp=Vin/Kff=60/15=4, A(openloop)= 94dB, GBW= 6.5MHz,     fpe = 129.7Hz.
Transfer Functions:-
I. Filter and load TF:- (1+jwrC*C)/((1+rL/R)-(1+(rC/R)LCw^2+jw(L/R+(rL+rC)C+rLrC*C/R))
II. Modulator TF:- 
 Vin/Vramp
III.Compensated Error Amplifier Transfer Function:-
 -1/(R3C1)*(s+1/(R1C3))(s+1/(R2C2)) / s(s+1/(R3C3))(s+1/R2C1)
Phase Calculations at Crossover Frequecny 100kHz (Wo):-
arg(F(jWo)) = -146 degrees
arg(L(jWo)) = -125 degrees
Thus compensated angle = 180+146-125= 201 degrees
Calculations of R and C’s using K-factor method:-
K= 10.4, R1 = 200Kohm, R2= 89.18Kohm, C1 = 55.34pF, C2= 575.5pF,       C3 = 256.6pF, R3 = 19.23 Kohm, R4 = 11.27 pF
