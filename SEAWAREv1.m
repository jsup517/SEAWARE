% SFD based View Prediction
clear all; close all; clc;

% Simulation Parameters
thresold = 0; % Object and View correlation threshold (Default: 0)

resX = [3840, 3840, 3840, 2560, 2560, 2160, 2560, 2560, 2560];
resY = [2160, 2048, 2160, 1440, 1440, 1080, 1440, 1440, 1440];

% Tiles
W = 4; H = 4;
T = W*H; % number of tiles

% Dataset
datasetSize = 48; 
trainDataSet = 1:43; testDataSet = 44:48;
testData = length(testDataSet);
segmentDuration = 1; 
k = floor(10/segmentDuration); % prediction horizon

alpha = 0.1;
beta = 0.1;

wh = 3; ww = 5;

visual = 0;


% Simulation tracking
filename1 = '121620';
filename2 = 'yolo';
filename3 = ['H' num2str(H) 'xW' num2str(W) 'seg' num2str(segmentDuration)];
filename4 = ['k' num2str(k)];
filename5 = ['win' num2str(ww) num2str(wh) 'a' num2str(alpha*10) 'b' num2str(beta*10)];
filename6 = ['test' num2str(testDataSet(1)) '-' num2str(testDataSet(end))];
filenameA = [filename1 filename2 filename3 filename4 filename5 filename6];
filenameB = [filename1 filename2 filename3];
filenameC = [filename1 filename3];

if filename2 == 'anno'
    VIDEO = 1:3; % video index (0:Conan,1:Ski,2:Google,...,8)
else
    VIDEO = 1:9;
end


display('Simulation Start')
if exist(['GroundTruth_' filenameC '.mat'],'file') 
    load(['GroundTruth_' filenameC '.mat']);
    display('View data found!')
else
    display('Read View Data')
    % Generate Ground Truth - readView
    for video = VIDEO
        for user = 1:datasetSize
            [groundTruth{video}{user} pitchyaw{video}{user}] = readView(video, user, H, W, segmentDuration);
            segments = size(groundTruth{video}{user},1);
            for tran = 1:segments
                for latency=1:k
                    Pg{video}{user}{tran}(:,latency) = groundTruth{video}{user}(tran,:);
                end
            end
        end
    end
    save(['GroundTruth_' filenameC '.mat'],'groundTruth','Pg','pitchyaw');
end

% SFD generation
if exist(['SFD_' filenameB '.mat'],'file')
    load(['SFD_' filenameB '.mat']);
    display('SFD data found!');
else
    display('SFD generation');
    for video = VIDEO
        segments = size(groundTruth{video}{1},1);
        [SFD{video} VMV{video} cente{video}] = SFDgeneration(video, segments, H, W, resX(video), resY(video), filename2);
    end
    save(['SFD_' filenameB '.mat'],'SFD','VMV','cente');
end

% VOSM generation
if exist(['VOSM_' filenameA '.mat'],'file')
    load(['VOSM_' filenameA '.mat']);
    display('VOSM data found!');
else
    display('VOSM generation')
    for video = VIDEO
        % Training Dataset
        count = 0;
        for uu = trainDataSet
            count = count + 1;
            trainingSet{count} = groundTruth{video}{uu};
        end

        % Train VOSM
        threshold = 0;
        [VOSMn{video} VOSMe{video}] = VOSMgeneration(SFD{video}, VMV{video}, pitchyaw{video}, trainingSet, alpha, threshold, H, W);
    end
    save(['VOSM_' filenameA '.mat'],'VOSMn','VOSMe');
end

% Prediction
if exist(['Prediction_' filenameA '.mat'],'file')
    load(['Prediction_' filenameA '.mat']);
    display('View Prediction data found!');
else
    display('View Prediction')
    % Perform View prediction
    for video = VIDEO
        numOB = length(SFD{video});
        for user = testDataSet
            %groundTruth{video}{user} = readView(video, user, H, W, segmentDuration);
            segments = size(groundTruth{video}{1},1);
            Rn = 1; Rd = 1; M = 1; availableSet = 0; priorHex = 0;
            for tran = 1:segments-k
                currentView = groundTruth{video}{user}(tran,:);
                currentHex = binaryVectorToHex(currentView);

                [Po{video}{user}{tran}, pySFD{video}{user}{tran}] = ...
                    PredictionSEAWARE(VOSMn{video}, VOSMe{video}, SFD{video},...
                    cente{video}, pitchyaw{video}{user}, k, T, currentView,...
                    tran, numOB, H, W, beta, ww, wh, resX(video), resY(video));
            end
        end
    end
    save(['Prediction_' filenameA '.mat'],'Po');
end


display('Precision calculation')
% Measure the performance
precision = calPrecision(Po, groundTruth, VIDEO, testDataSet, k);

IoU = calIoU(Po, groundTruth, VIDEO, testDataSet, k);

HR = calHR(Po, groundTruth, VIDEO, testDataSet, k);

predictionError = calPE(Po, groundTruth, VIDEO, testDataSet, k);

figureNum = 0;
for video = VIDEO 
    figureNum = figureNum + 1;
    temp = mean(mean(precision{video}(testDataSet,:,:)));

    for kk=1:k
        p(kk) = temp(:,:,kk);
    end

    figure(figureNum); 
    %subplot(1, length(VIDEO),video); 
    hold on; grid on;
    plot(1:k,p,'LineWidth',2);
    legend('SEAWARE'); xlabel('k'); ylabel('Precision')
    
    figureNum = figureNum + 1;
    temp = mean(mean(HR{video}(testDataSet,:,:)));

    for kk=1:k
        p(kk) = temp(:,:,kk);
    end

    figure(figureNum); 
    %subplot(1, length(VIDEO),video); 
    hold on; grid on;
    plot(1:k,p,'LineWidth',2);
    legend('SEAWARE'); xlabel('k'); ylabel('Hit Rate')    

    pe = mean(mean(predictionError{video}(testDataSet,:,:)));

    for kk=1:k
        PE(kk) = pe(:,:,kk);
    end
    figureNum = figureNum + 1;
    figure(figureNum); 
    hold on; grid on;
    plot(1:k,PE,'LineWidth',2);
    legend('SEAWARE'); xlabel('k'); ylabel('Prediction Error')
    
end