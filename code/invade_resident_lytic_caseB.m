%% Model parameters
% Note: same as the evolutionary invasion analysis section
% resource parameters
p.Rmod = 5; % half saturation
p.rho = 0.5; % dilution rate 
p.e = 5e-7; % conversion coefficient
p.b0 = 1.2; % maximum growth rate
% explicit infection parameters 
p.eta = 1; % lysis rate
p.beta = 50; % burst rate
p.phi = 3.4e-10;  % adsorption rate
p.alpha = 2; % transit decision rate
% cell traits
p.ds = 0.2; % death rate of susceptible cells
p.de = 0.2; % death rate of infected cells
p.dl = 0.2; % death rate of lysogenic cells
p.di = 0.2; % death rate of lytic cells
p.m = 1/24; % phage decay rate

% (R*, S*) is varied by the parameter space (alphaS, J);
theta_set = [0.01:0.01:0.1, 0.2:0.05:1, 2:0.5:10]; % augumented parameter range
alphaS_set = -1:0.02:0.5; % alphaS < 0, S grows faster than L; alphaS > 0, ...

dl_set = [0.5, 0.08]; % indirect benefits and direct benefits

% choose free parameters to control initial S* and R* to make sure desease
% free invasion. Note that alphaS_index goes up can increase Rver,
% theta_index goes up can increase Rhor
% alphaS_index = 60; theta_index = length(theta_set)-5; % R_star = 1.28, S_star = 7.5e7; most up
alphaS_index = 55; theta_index = length(theta_set)-10; % R_star = 1.10, S_star = 5e7; balance

p.alphaS = alphaS_set(alphaS_index);
p.J = theta_set(theta_index) + (p.Rmod*p.ds/((1 - p.alphaS)*p.b0 - p.ds))*p.rho;

% compute virus-free environmental states
R_star = p.Rmod*p.ds/((1 - p.alphaS)*p.b0 - p.ds);
S_star = theta_set(theta_index)/(p.e*p.ds);

% compute two transmission fitness values
R_hor = p.beta*p.eta*p.phi*S_star*p.alpha/...
            ((p.eta + p.di)*(p.phi*S_star + p.m)*(p.alpha + p.de));
psi_star = p.b0*R_star/(R_star + p.Rmod);      
R_ver_ind = psi_star/dl_set(1); 
R_ver_di = psi_star/dl_set(2);

%% --------------------------- Simulation --------------------------------------
V_init = 1; t0 = 0; tf = 1e4;
tol = 1e-6; options = odeset('RelTol',tol,'AbsTol',tol);
IC = [R_star,S_star,0,0,0,V_init]; % initial condition
p.dl = dl_set(1);
p.pb = 0; p.gamma = 1e-2;
[t,x] = ode45(@ode_resource_explicit_NoSuperinfection,[t0,tf],IC,options,p);
%{
eps_shift = 1e-4; % shift time series epsilon, convenience for plt
figure(1);
semilogy(t, x(:,1) + eps_shift, 'g', 'LineWidth',2); hold on; % resource
semilogy(t, x(:,2) + eps_shift, '--g', 'LineWidth',2); hold on; % susceptible host
semilogy(t, x(:,3) + eps_shift, 'm', 'LineWidth',2); hold on; % E
semilogy(t, x(:,4) + eps_shift, 'b', 'LineWidth',2); hold on; % lysogen
semilogy(t, x(:,5) + eps_shift, 'r', 'LineWidth',2); hold on; % lytic cell
semilogy(t, x(:,6) + eps_shift, 'k', 'LineWidth',2); hold on; % free viruses
legend({'$R$','$S$','$E$','$L$','$I$','$V$'},...
    'Interpreter','latex','FontSize',15); legend boxoff;    
axis square; ax = gca; 
xlim([min(t) max(t)]); ylim([1e-2 1e10]); yticks(10.^[-2:2:10]);
set(gca,'FontSize',20); set(gca,'TickLabelInterpreter', 'latex'); % set Xtick/Ytick in latex interp
xlabel({'time, $t$ (hr)'}, 'Interpreter','latex', 'FontName', 'Times New Roman','FontSize',20'); 
ylabel({'Density (ml$^{-1}$)'}, 'Interpreter','latex', 'FontName', 'Times New Roman','FontSize',20'); 
ax.XAxis.LineWidth = 2; ax.YAxis.LineWidth = 2;
%}

% endemic equilibrium density
eps_set = 0:0.2:1;
env_R = x(end,1); env_S = x(end,2); env_V = x(end,6);
env_cond = [env_R, env_S, env_V];
% env_cond = [env_R, env_S];
model_option = 3;
gg = 1e-2; % fixed induction rate 
pp_set = 5e-2:5e-2:1;
pp_range = 0:1e-2:1;
R_inv_ind = zeros(length(eps_set),length(pp_set)); 

for j = 1:length(eps_set)
    p.eps = eps_set(j);
 for k = 1:length(pp_set)
    p.dl = dl_set(1);
    R_inv_ind(j,k) = R0_intermediate(p, env_cond, pp_set(k), gg, model_option);
 end
 
end


figure(2);
plot(pp_set, R_inv_ind(1,:), '-ok','LineWidth',1.5,...
    'MarkerSize',8, 'MarkerEdgeColor','k',...
    'MarkerFaceColor','g'); hold on;
plot(pp_set, R_inv_ind(2,:), '-ok','LineWidth',1.5,...
    'MarkerSize',8, 'MarkerEdgeColor','k',...
    'MarkerFaceColor','r'); hold on;
plot(pp_set, R_inv_ind(3,:), '-ok','LineWidth',1.5,...
    'MarkerSize',8, 'MarkerEdgeColor','k',...
    'MarkerFaceColor','b'); hold on;
plot(pp_set, R_inv_ind(4,:),  '-ok','LineWidth',1.5,...
    'MarkerSize',8, 'MarkerEdgeColor','k',...
    'MarkerFaceColor','m'); hold on;
plot(pp_set, R_inv_ind(5,:),  '-ok','LineWidth',1.5,...
    'MarkerSize',8, 'MarkerEdgeColor','k',...
    'MarkerFaceColor','y'); hold on;
plot(pp_set, R_inv_ind(6,:),  '-ok','LineWidth',1.5,...
    'MarkerSize',8, 'MarkerEdgeColor','k',...
    'MarkerFaceColor','c'); hold on;
plot(pp_range(1), 1,  'd',...
    'MarkerSize',13, 'MarkerEdgeColor','k',...
    'MarkerFaceColor','k'); hold on;
plot(pp_range, ones(length(pp_range),1), '--k', 'LineWidth',2); hold on;

% text on plots
tmptA = text(0.45, 1.54, {'$\epsilon = 1$, super immunity (full)'});
set(tmptA,'fontsize',15,'interpreter','latex');
tmptA = text(0.85, 1.3, {'$\epsilon = 0.8$'});
set(tmptA,'fontsize',15,'interpreter','latex');
tmptA = text(0.85, 1.13, {'$\epsilon = 0.6$'});
set(tmptA,'fontsize',15,'interpreter','latex');
tmptA = text(0.85, 0.98, {'$\epsilon = 0.4$'});
set(tmptA,'fontsize',15,'interpreter','latex');
tmptA = text(0.85, 0.89, {'$\epsilon = 0.2$'});
set(tmptA,'fontsize',15,'interpreter','latex');
tmptA = text(0.85, 0.81, {'$\epsilon = 0$'});
set(tmptA,'fontsize',15,'interpreter','latex');
ylim([round(min(min(R_inv_ind)),1)-0.1, max(max(R_inv_ind))+0.1]); 
yticks(round(min(min(R_inv_ind)),1) - 0.1: 0.1: max(max(R_inv_ind)) + 0.1); 
axis square; ax = gca; 
set(gca,'FontSize',20); set(gca,'TickLabelInterpreter', 'latex'); % set Xtick/Ytick in latex interp
xlabel({'$p_{m}$,\ probability of lysogeny'}, 'Interpreter','latex', 'FontName', 'Times New Roman','FontSize',20'); 
ylabel({'$\mathcal{R}_{inv}$'}, 'Interpreter','latex', 'FontName', 'Times New Roman','FontSize',20'); 
ax.XAxis.LineWidth = 2; ax.YAxis.LineWidth = 2;

ff = figure(2);
ff.Units = 'inches';
Width = 17; Height = 17;
ff.PaperSize = [Width, Height];
ff.PaperPosition = [0 0 Width, Height];
ff.Position = [0 0 Width, Height];
Name = 'balanced_mutant_inv_lysogeny_indirect_benefits';
print(ff, Name, '-depsc2','-r600');
print(ff, Name, '-dpdf','-r600');

%% Simulation resident-mutant system
p.dl = dl_set(1); % 
p.ep = 1; % full immunity protection
V_init = 1; t1_0 = 0; t1_f = 2e2;
tol = 1e-6; options = odeset('RelTol',tol,'AbsTol',tol);
IC = [R_star,S_star,0,0,0,V_init, 0, 0, 0, 0]; % initial condition

p.pbm = 1; % temperate viruses is set as purely lysogeny

% lysogenic transmission (failure)
p.pb = 1; p.gamma = 1e-2; 
[t1,x1] = ode45(@ode_resource_explicit_res_mut_superinfect,[t1_0,t1_f],IC,options,p);
t1 = [t1;t1(end)];
x1_f = x1(end,:); x1_f(6) = 0;
x1 = [x1; x1_f];
% lytic invasion
t2_0 = t1_f; t2_f = t2_0 + 4e2;
IC = [R_star,S_star,0,0,0,1, 0, 0, 0, 0]; % initial condition
p.pb = 0;
[t2,x2] = ode45(@ode_resource_explicit_res_mut_superinfect,[t2_0,t2_f],IC,options,p);

% temperate phage invasion 
t3_0 = t2_f; t3_f = t3_0 + 5e2;
IC = x2(end,:) + [0,0,0,0,0,0, 0, 0, 0, 1]; % initial condition
[t3,x3] = ode45(@ode_resource_explicit_res_mut_superinfect,[t3_0,t3_f],IC,options,p);
% decompose full data stack 
X = [x1;x2;x3]; tt = [t1;t2;t3];
Rt = X(:,1); % resource
St = X(:,2); % susceptible hosts 
Et = X(:,3); % infected
Lt = X(:,4); % Lysogens
It = X(:,5); % lytic infected 
Vt = X(:,6); % viruses (resident)
Emt = X(:,7); % infected mutant
Lmt = X(:,8); % lysogens mutant class
Imt = X(:,9); % lytic infected mutant
Vmt = X(:,10); % viruses (mutant) - lysogens

figure(3);
semilogy(tt, Rt, 'Color', [0.8 0.8 0.8], 'LineWidth',2);
hold on;
semilogy(tt, St, 'k','LineWidth',2);
hold on;
semilogy(tt, Et, 'y','LineWidth',2);
hold on;
%semilogy(tt, Lt, 'm', 'LineWidth',2);
%hold on;
semilogy(tt, It, 'g', 'LineWidth',2);
hold on;
semilogy(tt, Vt, 'r','LineWidth',2);
hold on;
semilogy(tt, Emt, 'c','LineWidth',2);
hold on;
semilogy(tt, Lmt, 'Color', [0.5 0 1],'LineWidth',2);
hold on;
semilogy(tt, Imt, 'Color', [1 0 0.8],'LineWidth',2);
hold on;
semilogy(tt, Vmt, 'b','LineWidth',2);
hold on;
semilogy(tt(1:500), Vt(1:500), 'b','LineWidth',2); % overlapping original color
hold on;

semilogy(t1(1), x1(1,6),'db', 'MarkerSize',12, 'MarkerFaceColor', 'b');
hold on
semilogy(t2(1), x2(1,6),'or', 'MarkerSize',12, 'MarkerFaceColor', 'r');
hold on;
semilogy(t3(1), x3(1,10),'db', 'MarkerSize',12, 'MarkerFaceColor', 'b');

ylim([1e-1 1e10]);  yticks(10.^[-1:2:10]);
%legend({'$R$','$S$','$E$','$L$','$I$','$V$', '$E_{m}$','$L_{m}$','$I_{m}$','$V_{m}$'},...
%    'Position',[0.20 0.50 0.05 0.05],...
%    'Interpreter','latex','FontSize',15); legend boxoff;
legend({'$R$','$S$','$E$','$I$','$V$', '$E_{m}$','$L_{m}$','$I_{m}$','$V_{m}$'},...
    'Position',[0.20 0.50 0.05 0.05],...
    'Interpreter','latex','FontSize',15); legend boxoff;

% set some labels 
tmptA = text(20, 3, {'temperate'; 'viruses'});
set(tmptA,'fontsize',13,'interpreter','latex');
%set(tmptA, 'b');

tmptA = text(225, 0.4, {'lytic'; 'viruses'});
set(tmptA,'fontsize',13,'interpreter','latex');
%set(tmptA, 'r');

tmptA = text(660, 1, {'temperate'; 'viruses'});
set(tmptA,'fontsize',13,'interpreter','latex');
%set(tmptA, 'b');



axis square; ax = gca; 
set(gca,'FontSize',20); set(gca,'TickLabelInterpreter', 'latex'); % set Xtick/Ytick in latex interp
xlabel({'time, $t$ (hr)'}, 'Interpreter','latex', 'FontName', 'Times New Roman','FontSize',20'); 
ylabel({'Density (ml$^{-1}$)'}, 'Interpreter','latex', 'FontName', 'Times New Roman','FontSize',20'); 
ax.XAxis.LineWidth = 2; ax.YAxis.LineWidth = 2;

ff3 = figure(3);
ff3.Units = 'inches';
Width = 17; Height = 17;
ff3.PaperSize = [Width, Height];
ff3.PaperPosition = [0 0 Width, Height];
ff3.Position = [0 0 Width, Height];
Name3 = 'time_series_balanced_mutant_inv_lysogeny_indirect_benefits';
print(ff3, Name3, '-depsc2','-r600');
print(ff3, Name3, '-dpdf','-r600');






