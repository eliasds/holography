p = 8;
n = 60000;
a1 = (2*pi)/(2*pi);
b1 = 3.5;
% p = 7;n = 800;a1 = 1/(2*pi);a2 = a1;b1 = 3.1;b2 = b1;
% p = 7;n = 800;a1 = 1/(2*pi);a2 = a1;b1 = 3.3;b2 = b1;
theta = linspace(0,p*pi,n);
R1 = a1*theta.^b1;
% R2 = a2*theta.^b2;
% theta = theta.*linspace(1,.8,n);

%Expanding Double Spiral (New Code)
x1 = R1.*cos(theta);
y1 = R1.*sin(theta);
x2 = -x1;
y2 = -y1;
figure
plot(x1,y1); hold on
plot(x2,y2); hold off
min1 = min(abs(max(x1)),abs(max(y1)));
max1 = 2*ceil(max(abs([x1 y1]))+1);
axisval = 0.98*min1;
axis image
axis([-axisval axisval -axisval axisval])

spiralmat = ones(max1);
for L = 1:n
    spiralmat(round(y1(L)+(max1)/2),round(x1(L)+(max1)/2)) = 0;
    spiralmat(round(y2(L)+(max1)/2),round(x2(L)+(max1)/2)) = 0;
end
figure
imagesc(spiralmat);axis image;axis xy
% spiralmat = imcropcenter(spiralmat,[size(spiralmat)/2 4000 4000]);
% figure
% imagesc(spiralmat);axis image;axis xy

    

mfname = [mfilename('fullpath'),'.m'];
mfile = fun2var(mfname);


% %Simple Spiral
% x1 = a1*theta.*cos(theta1);
% y1 = a1*theta.*sin(theta1);
% figure
% plot(x1,y1);
% hold on
% hold off
% axis image


% %Double Spiral
% x1 = a1*theta.*cos(theta);
% y1 = a1*theta.*sin(theta);
% x2 = a2*theta.*cos(theta+pi);
% y2 = a2*theta.*sin(theta+pi);
% figure
% plot(x1,y1); hold on
% plot(x2,y2); hold off
% axisval = 0.99*min(max(x1),max(x2));
% axis image
% axis([-axisval axisval -axisval axisval])


% %Expanding Double Spiral
% x1 = a1*theta.^b1.*cos(theta);
% y1 = a1*theta.^b1.*sin(theta);
% x2 = a2*theta.^b2.*cos(theta+pi);
% y2 = a2*theta.^b2.*sin(theta+pi);
% figure
% plot(x1,y1); hold on
% plot(x2,y2); hold off
% axisval = 0.99*min(max(x1),max(x2));
% axis image
% axis([-axisval axisval -axisval axisval])


%% Make a Square Sprial of Size N x N
%{
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
%}




