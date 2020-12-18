function Pout = VOSMprediction(Node, Edge, obTile, k, currentView, tran, numOB, H, W)
% Derive Prediction Matrix
P = zeros(k,numOB);

currentNode = zeros(1,numOB);
for tt=1:numOB
    if sum(obTile{tt}(tran,:).*currentView)>0
        currentNode(tt) = 1;
    end
end
if find(Node{tran}==bi2de(currentNode))
    currentNodeIndex = find(Node{tran}==bi2de(currentNode));
else
    currentNodeIndex = 0;
end

for ii=1:k
    if ii==1
        if ii+tran-1>length(Edge)
            Ri{1} = Edge{end};
        else
            Ri{1} = Edge{ii+tran-1};
        end
        sumRi = sum(Ri{ii});
        for ri = 1:length(sumRi)
            Ri{ii}(:,ri) = Ri{ii}(:,ri)/sumRi(ri);
        end
    else
        if ii+tran-1>length(Edge)
            Ri{ii} = Edge{end}*Ri{ii-1};
        else
            Ri{ii} = Edge{ii+tran-1}*Ri{ii-1};
        end
        sumRi = sum(Ri{ii});
        for ri = 1:length(sumRi)
            Ri{ii}(:,ri) = Ri{ii}(:,ri)/sumRi(ri);
        end
    end
end

allNode = de2bi(Node{tran},numOB);
if size(allNode,1)==1
    biNode = allNode;
else
    biNode = allNode(1:end-1,:);
end
hdistance = zeros(size(biNode,1),1);
for tt=1:size(biNode,1)
    hdistance(tt) = sum(biNode(tt,:).*currentNode);
end
[val, tempNodes]=sort(hdistance,'descend');
ra = max([1 floor(0.2*length(tempNodes))]);
ra = min([k ra]);

for ii=1:k    
    if currentNodeIndex>0
        D = Ri{ii}(:,currentNodeIndex);
    else
        D = sum(Ri{ii}(:,tempNodes(1:ra)),2);
    end
    
    if ii+tran>length(Node)
        allNode = de2bi(Node{end},numOB);
    else
        allNode = de2bi(Node{ii+tran},numOB);
    end
    
    for tt=1:numOB
        for mm=1:length(D)
            if allNode(mm,tt) == 1
                P(ii,tt) = P(ii,tt) + D(mm);
            end
        end
    end
    
    if sum(P(ii,:))>0
        P(ii,:) = P(ii,:)/sum(P(ii,:));
    else
        P(ii,:) = zeros(1,numOB);
    end
end

Pout = P;
end