function precision = calPrecision(Pg, groundTruth, VIDEO, DATASET, k)
for video = VIDEO
    for user = DATASET
        segments = size(groundTruth{video}{1},1);
        for tran = 1:segments-k-1
            for latency=1:k
                tempPg = Pg{video}{user}{tran}(:,latency)'; 
                if sum(tempPg)>0, tempPg = tempPg/sum(tempPg); end
                %tempPg = groundTruth{video}{user}(tran,:); tempPg = tempPg/sum(tempPg);
                tempGT = groundTruth{video}{user}(tran+latency,:); 
                if sum(tempGT)>0, tempGT = tempGT/sum(tempGT); end
                precision{video}(user,tran,latency) = sum(min(tempPg,tempGT));
            end
        end
    end
end
end