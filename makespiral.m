p = 12;
n = 1000;
m1 = 1;
m2 = 1.5;
sq1 = 3;
sq2 = 3;

% %Simple Spiral
% t = linspace(0,p*pi,n);
% x = t.*cos(t);
% y = t.*sin(t);
% plot(x,y)

%Expnding Spiral by squares
t = linspace(0,p*pi,n);
x = m1*t.^sq1.*cos(t);
y = m1*t.^sq1.*sin(t);
plot(x,y); hold on

%Expnding Spiral by 5ths
t = linspace(0,p*pi,n);
x = m2*t.^sq2.*cos(t);
y = m2*t.^sq2.*sin(t);
plot(x,y); hold off
