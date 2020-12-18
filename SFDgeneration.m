% Media Server - SFD
function [SFD VMV cente] = SFDgeneration(video, segments, H, W, resX, resY, filename2)
T = H*W;
if filename2 == 'yolo'
    bndBox_Yolo2;
else
    bndBox;
end
numObjects = length(objects{video});

for oo=1:numObjects
    for tran=1:segments
        if sum(objects{video}{oo}(:,5)==tran)
            bndInd = find(objects{video}{oo}(:,5)==tran);
            boundingBox = objects{video}{oo}(bndInd(1),1:4);
            cente{oo}(tran,:) = [(boundingBox(4)+boundingBox(2))/2, (boundingBox(3)+boundingBox(1))/2];
            objectTiles = boxMap(boundingBox,W,H,resX,resY);
            SFD{oo}(tran,:) = objectTiles;
        else
            SFD{oo}(tran,:) = zeros(1,T);
            cente{oo}(tran,:) = [0 0];
        end
        % VMV
        if tran>1
            %VMV{oo}(tran,:) = VMVgeneration(SFD{oo}(tran,:), SFD{oo}(tran-1,:), H, W, 10);
            VMV{oo}(tran,:) = cente{oo}(tran,:)-cente{oo}(tran-1,:);
        else
            VMV{oo}(tran,:) = [0 0];
        end
    end
    
    % interpolation
    findSFD = find(sum(SFD{oo},2));
    bir = min(findSFD); dea = max(findSFD);
  
    tran = bir;
    while tran<dea
        if sum(SFD{oo}(tran,:))>0
            tempSFD1 = reshape(SFD{oo}(tran,:),[H W]);
            tran = tran + 1;
        else
            len = 0;
            while sum(SFD{oo}(tran,:))==0
                tran = tran + 1;
                len = len + 1;
            end
            tempSFD2 = reshape(SFD{oo}(tran,:),[H W]);
            inteSFD1 = VMVgeneration(tempSFD2, tempSFD1, H, W, 10);
            for inte = 1:len
                inteSFD2 = floor(inteSFD1/len*inte);
                SFD{oo}(tran-len+inte-1,:) = reshape(circshift(tempSFD1,[inteSFD2(1) inteSFD2(2)]),[1 T]);
            end
        end

    end
end

end