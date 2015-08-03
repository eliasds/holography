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


%% Make a Square Sprial of Size N x N
size = 128;
mask = ones(size);

for L = 1:2:size-1
    mask(L,1+L:size-L) = 0; % Create top horizontal lines
    mask(L:1+size-L,L) = 0; % Create left verticle lines
    mask(L,2+size-L:L) = 0; % Create bottom horizontal lines
    mask(size-L:L,L) = 0; % Create right verticle lines
end
mask = fliplr(rot90(mask,3));
mask(size/2+1,size/2+1) = 1;
mask(size/2,size/2) = 0;
figure;imagesc(mask)
