% Resource-explicit nonlinear dynamics of temperate phage
% resident-mutant system with superinfection
% state vec: (R,S,E,L,I,V,Em,Lm,Im,Vm)
function dxdt = ode_resource_explicit_res_mut_superinfect(t,x,p)

% population states
R = x(1); S = x(2); E = x(3); L = x(4); I = x(5); V = x(6); 
Em = x(7); Lm = x(8); Im = x(9); Vm = x(10);

% total hosts
N = S + E + Em + L + Lm + I + Im;

% resources comsumption and growth rates
psi = p.b0*R/(R + p.Rmod); % Monod growth function

bs = (1 - p.alphaS)*psi; % growth rate of S
bl = psi; % growth rate of L

f_uptake = p.e*(bl*L + bs*S + bl*Lm); % resources consumption

% Nonlinear ODE system - strategy : (p.pb, p.gamma)
drdt = p.J - p.rho*R - f_uptake;
dsdt = bs*S - p.phi*S*V  - p.phi*S*Vm - p.ds*S;
dedt = p.phi*S*V + (1 - p.ep)*p.phi*Lm*V - p.alpha*E - p.de*E;
dldt = bl*L + p.pb*p.alpha*E - p.gamma*L - p.dl*L;
didt = (1 - p.pb)*p.alpha*E - p.eta*I + p.gamma*L - p.di*I;
dvdt = p.beta*p.eta*I - p.phi*N*V - p.m*V;
demdt = p.phi*S*Vm - p.alpha*Em - p.de*Em;
dlmdt = bl*Lm + p.pbm*p.alpha*Em - (1 - p.ep)*p.phi*Lm*V - p.gamma*Lm - p.dl*Lm;
dimdt = (1 - p.pbm)*p.alpha*Em - p.eta*Im + p.gamma*Lm - p.di*Im;
dvmdt = p.beta*p.eta*Im - p.phi*N*Vm - p.m*Vm;


dxdt = [drdt;dsdt;dedt;dldt;didt;dvdt;demdt;dlmdt;dimdt;dvmdt];

end