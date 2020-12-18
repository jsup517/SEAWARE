function [timeStamp occupiedTiles pitch yaw]=readHeadMotion3(fileName, W, H)

%% Head movement read
M = csvread(fileName,6,1);

timeStamp = M(:,1);
qx = M(:,2); qy = M(:,3); qz = M(:,4); qw = M(:,5); xf = M(:,6); yf = M(:,7); zf = M(:,8);

q = [qw qx qy qz];
[r1 r2 r3]=quat2angle(q);

x = 2*qx.*qz+2*qy.*qw;
y = 2*qy.*qz-2*qx.*qw;
z = 1-2*qx.*qx-2*qy.*qy;

pitch = real(asin(y));
yaw = zeros(1,length(x));
elements = real(z./sqrt(1-y.^2));
for ii=1:length(elements)
    if elements(ii) > 1
        elements(ii) = 1;
    end
    if elements(ii) < -1
        elements(ii) = -1;
    end
end

for ii=1:length(x)
    if x(ii) > 0
        if z(ii) >= 0
            yaw(ii) = asin(elements(ii));
        else
            yaw(ii) = asin(elements(ii)) + 2 * pi;
        end
    else
        yaw(ii) = pi - asin(elements(ii));
    end
end
yaw = yaw/(2*pi);
yaw = 1-yaw;
pitch = 1 - (pitch + pi/2)/pi;
        

% %pitch = (z>0).*(abs(acos(sqrt(x.^2+y.^2)./sqrt(x.^2+y.^2+z.^2))))+(z<=0).*(-abs(acos(sqrt(x.^2+y.^2)./sqrt(x.^2+y.^2+z.^2))));
% r = sqrt(x.^2+y.^2+z.^2);
% pitch = asin(y./r);
% cosPitch = r.*cos(pitch);
% yaw = (x<0).*(pi-asin(-z./cosPitch))+(x>=0).*(asin(-z./cosPitch));
% %yaw = yaw + pi/2;
% yaw = (yaw>0).*(yaw)+(yaw<=0).*(yaw+2*pi);
% 
% pitch = pitch/pi+0.5;
% yaw = yaw/(2*pi);

% tile maps
for ff = 1:length(pitch)
    occupiedTiles(ff,:) = tileMap(pitch(ff), yaw(ff), W, H);
%     image(100*reshape(occupiedTiles(ff,:),[H W]));
%     drawnow;    
end


end