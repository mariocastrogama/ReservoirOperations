clc;
clear;
close all;
fclose all;
format long g;

% Emabalse
D  = 10.0;
K  = 20.0;
Rv =  7.5;
% Regla de operación estándar
ROEx = [0 D D+K D+K+Rv];
ROEy = [0 D D   D+Rv];

% Regla de Cobertura Tipo I
ADI1 = 7*cos(45*pi/180);
ADF1 = 24;
RCO1_x = [0 ADI1 ADF1 D+K];
RCO1_y = [0 ADI1 D    D ];
m1 = (D-ADI1)/(ADF1-ADI1);
xneg1 = ADI1-ADI1/(m1);

% Regla de Cobertura Tipo II
ADI2 = 7;
ADF2 = ADF1;
RCO2_x = [0 ADI2 ADF2 D+K];
RCO2_y = [0 0    D    D  ];
m2 = D/(ADF2-ADI2);
xneg2 = -m2*ADI2/(1-m2);

% Regla de operación estándar (NEGATIVO)
ROENx = [0 xneg2];
ROENy = [0 xneg2];

% Plotting series
figure(1)
set(gcf,'Color',[1 1 1]);
plot(ROEx,ROEy,'b-','linewidth',2); hold on;
plot(RCO1_x,RCO1_y,'k-','linewidth',2); hold on;
plot(RCO2_x,RCO2_y,'k-','linewidth',2); hold on;
% plot([ADF2-D, ADF2],[0, D],'k--'); hold on;
plot(ROENx,ROENy,'k:'); hold on;
plot([xneg1 ADI1],[0 ADI1],'k--'); hold on;

plot([0 ADI1],[ADI1 ADI1],'k:'); hold on;
plot([0 D D],[D D 0],'k:'); hold on;
plot([K K+D K+D],[0 D 0],'k:'); hold on;
plot([ADI1 ADI1],[ADI1 0],'k:'); hold on;
plot([xneg2 xneg2 0 ],[0 xneg2 xneg2],'k:'); hold on;
plot([mean([xneg1,xneg2]) 0 ADF2 ADF2],[mean([xneg1,xneg2])*D/ADF2 0 D 0],'k:'); hold on;

plot([ADI2, xneg2],[0 xneg2],'k--'); hold on;
xs = 7.0;
plot([xs+0.3, xs+1, xs+1, xs+0.3],[xs, xs, xs+0.7, xs],'m-','linewidth',2); hold on;
text(xs+0.35,xs-0.5,'1','Fontname','Cambria','Fontsize',14,'Fontweight','Bold');
text(xs+1.25,xs+0.5,'1','Fontname','Cambria','Fontsize',14,'Fontweight','Bold');

xs2 = 1.5;
plot([D+K+xs2+0.3, D+K+xs2+1, D+K+xs2+1, D+K+xs2+0.3],[D+xs2, D+xs2, D+xs2+0.7, D+xs2],'m-','linewidth',2); hold on;
text(D+K+xs2+0.35,D+xs2-0.5,'1','Fontname','Cambria','Fontsize',14,'Fontweight','Bold');
text(D+K+xs2+1.25,D+xs2+0.5,'1','Fontname','Cambria','Fontsize',14,'Fontweight','Bold');

axis equal tight;
set(gca,'Position',[0.01 0.01 0.980 0.98]);
set(gca,'Fontname','Cambria');
set(gca,'Fontsize',14);
set(gca,'Fontweight','Bold');
xmin = min(floor(xneg1),floor(xneg2));
set(gca,'xlim',[xmin D+K+Rv+1]);
set(gca,'xtick',[xneg1 0 ADI1 ADI2 D K ADF2 D+K]);
set(gca,'xticklabel',{'\itADI^1_t' '0' '\itADI^1_t' '\itADI^2_t' '\itD_t' '\itK' '\itADF_t' '\itK + \itD_{t}'});
text(xneg2-2,xneg2+0.5,'\itADI^2_t','Fontname','Cambria','Fontsize',14,'Fontweight','Bold');
set(gca,'ylim',[floor(xneg2) D+Rv+1]);
set(gca,'ytick',[ADI1 D D+Rv]);
set(gca,'yticklabel',{'\itADI^1_t','\itD_t','\itD_t+\itV_t'});
PlotAxisAtOrigin(0,0);
set(gca,'Fontname','Cambria');
set(gca,'Fontsize',14);
set(gca,'Fontweight','Bold');
text(-2,D-2,'Descarga R_t','Fontname','Cambria','Fontsize',14,'Fontweight','Bold','Rotation',90,'HorizontalAlignment','left');
text(K+2,-1.5,'Agua Disponible \itAD_t','Fontname','Cambria','Fontsize',14,'Fontweight','Bold');
xlabel('Agua Disponible AD_t'); 
text(D+2,D+0.4,'ROE','Fontname','Cambria','Fontsize',14,'Fontweight','Bold');
text(D+(K-D)*0.65,8.75,['RCO Tipo 1 ({\it\eta_t} ',char(60),'1)'],'Fontname','Cambria','Fontsize',14,'Fontweight','Bold','HorizontalAlignment','right','rotation',15);
text(D+(K-D)*0.50,3.75,['RCO Tipo 2 ({\it\eta_t} ',char(62),'1)'],'Fontname','Cambria','Fontsize',14,'Fontweight','Bold','HorizontalAlignment','left','rotation',30);

