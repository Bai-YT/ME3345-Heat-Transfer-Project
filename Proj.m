% ME 3345 Project
% Yatong Bai
clear;

syms Mdot Tg Tp;
G = 1400; % Total Irradiation
Vis = 591; % Visible Irradiation
Infr = 668; % Infrared Irradiation
UV = G-Infr-Vis; % Ultravoilet Irradiation
qin = (G-Infr*.3)*cos(pi/4); % Energy absorbed by whole system
sig = 5.67e-8; % sigma
TDiff = 8; % Tplate - Tglass, assumed
qglass = (Infr+UV)*.7*cos(pi/4); % Energy absorbed by glass

% Solve the equations to find mdot
[Mdot, Tg, Tp] = solve(4182*70*Mdot==qin-.7*sig*(Tg^4-300^4), ...
    qglass-.7*sig*(Tg^4-300^4)==.7*sig*(Tg^4-Tp^4), ...
    Tg==Tp-TDiff, Tg>200);
Mdot = eval(vpa(Mdot));
Tg = eval(vpa(Tg));
Tp = eval(vpa(Tp));

% Calculate Natural Convection
Teff = (Tg+300)/2;
alpha = (38.3+29.9)/2*1e-6;
nu = (15.89+20.92)/2/1e6;
beta = 1/Teff;
Pr = 0.7034;
k = (26.3+30)/2/1000;
Ra = 9.81*beta*(Tg-300)*.5^3/nu/alpha;
Nu = (.825 + 0.387*Ra^(1/6) / (1+ (0.492/Pr)^(9/16) )^(8/27) )^2;
h = Nu*k;
qNat = h*(Tg-300); % Natural Convection
TgC = Tg-273.157; % Convert to Celsius
TpC = Tp-273.157;

% Plug in Natural Convection and reevaluate Mdot
Tg2 = Tg-.015;
Mdot2 = Mdot;
i = 0; % Counter
while abs(Tg2-Tg)>.01
    Tg = Tg2;
    oldM2 = Mdot2;
    i = i + 1;
    
    syms Mdot2 Tg2 Tp2;
    [Mdot2, Tg2, ~] = solve(4182*70*Mdot2==qin-.7*sig*(Tg2^4-300^4)-qNat, ...
        qglass-qNat-.7*sig*(Tg2^4-300^4)+.7*sig*(Tp2^4-Tg2^4)==0, ...
        Tg2==Tp2-TDiff, Tg2>200);
    Mdot2 = eval(vpa(Mdot2));
    Tg2 = eval(vpa(Tg2));
    Mdot2 = (Mdot2+oldM2)/2;
    Tg2 = (Tg2+Tg)/2;
    Tp2 = Tg2+TDiff;
    Teff2 = (Tg2+300)/2;

    % Recalculate Natural Convection
    Ra2 = 9.81*beta*(Tg2-300)*.5^3/nu/alpha;
    Nu2 = (.825 + 0.387*Ra2^(1/6) / (1+ (0.492/Pr)^(9/16) )^(8/27) )^2;
    h2 = Nu2*k;
    qNat = h2*(Tg2-300);
end
TgC2 = Tg2-273.157; % Convert to Celsius
TpC2 = Tp2-273.157;
qRad = .7*sig*(Tg2^4-300^4); % Energy lost by glass radiation
fprintf('Corrected Glass Temperature: %.2f Celsius.\n', TgC2);
fprintf('Corrected Plate Temperature: %.2f Celsius.\n', TpC2);
fprintf('Mass Flow Rate: %.2f g/s.\n', Mdot*1000);
fprintf('Corrected Mass Flow Rate: %.2f g/s.\n', Mdot2*1000);

% Calculate Thermal Resistivity of the plates
q = Mdot2*4182*70;
R = (TpC2-(15+85)/2) / q;