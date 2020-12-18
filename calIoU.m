function IoU = calIoU(Pg, groundTruth, VIDEO, DATASET, k)
for video = VIDEO
    for user = DATASET
        segments = size(groundTruth{video}{1},1);
        for tran = 1:segments-k-1
            for latency=1:k
                tempPg = Pg{video}{user}{tran}(:,latency); tempPg = tempPg>0;
                %tempPg = groundTruth{video}{user}(tran,:); tempPg = tempPg/sum(tempPg);
                tempGT = groundTruth{video}{user}(tran+latency,:); tempGT = tempGT>0; % tempGT = tempGT/sum(tempGT);
                IoU{video}(user,tran,latency) = sum(tempPg.*tempGT')/sum((tempPg+tempGT')>0);
            end
        end
    end
end
end