function [groundTruth pitchyaw] = readView(video, user, H, W, segmentDuration)

    [timeStamp occupiedTiles pitch yaw]=readHeadMotion3(['Experiment_1\' num2str(user) '\video_' num2str(video-1) '.csv'],W,H);
    
    counter = 1; 
    T = H*W;
        
    for tran = 1:floor(max(timeStamp)/segmentDuration)
        tempView = zeros(1,T);
        while timeStamp(counter) < tran*segmentDuration
            tempView = tempView | occupiedTiles(counter,:);
            counter = counter + 1;
        end
        groundTruth(tran,:) = tempView;
        pitchyaw(tran,:) = [pitch(counter) yaw(counter)];
    end
end