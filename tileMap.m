function occupiedTiles = tileMap(pitch, yaw, width, height)

% tile matching
%height = sqrt(T); width = sqrt(T);
occuTiles = zeros(height,width);

viewportH = 0.14;
viewportW = 0.14;
tileH = pitch-viewportH:0.01:pitch+viewportH;
tileW = yaw-viewportW:0.01:yaw+viewportW;
t1 = tileH*height;
t2 = tileW*width;

if height==1
    tileHmin = 0; tileHmax = 0;
else
    tileHmin = floor(min(t1)); tileHmax = ceil(max(t1));
end
tileWmin = floor(min(t2)); tileWmax = ceil(max(t2));

occuH = tileHmin:1:tileHmax;
occuW = tileWmin:1:tileWmax;

occuH = (occuH>=0& occuH<height).*occuH + (occuH<0).*(occuH+height) + (occuH>=height).*(occuH-height);
occuW = (occuW>=0 & occuW<width).*occuW + (occuW<0).*(occuW+width) + (occuW>=width).*(occuW-width);

for hh=1:length(occuH)
    for ww=1:length(occuW)
        occuTiles(occuH(hh)+1,occuW(ww)+1) = 1;
    end
end

% left to the right
occuRevTiles = occuTiles;
for ww=1:width
    occuRevTiles(:,ww) = occuTiles(:,width-ww+1);
end
occuRevReveTiles = occuRevTiles;
for hh=1:height
    occuRevRevTiles(hh,:) = occuRevTiles(height-hh+1,:);
end

occupiedTiles = reshape(occuTiles,[1 width*height]);

end