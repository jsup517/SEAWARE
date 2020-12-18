function [VOSMn VOSMe] = VOSMgeneration(SFD, VMV, pitchyaw, groundTruth, alpha, threshold, H, W)

% VSM generation
numObjects = length(SFD);
segments = size(SFD{1},1);
users = length(groundTruth);

for user = 1:users
    for oo=1:numObjects
        for tran=1:segments
            Ob{user}(oo,tran) = sum(SFD{oo}(tran,:).*groundTruth{user}(tran,:))>alpha*sum(SFD{oo}(tran,:));
        end
    end
end

for uu=1:users
    for seg=1:segments
        currentStatus=bi2de(Ob{uu}(:,seg)');
        if uu==1 
            VOSMn{seg} = currentStatus;
            Vn2(seg) = 1;
            VOSMe{seg} = 1;
        else
            %currentNode = find(sum((VOSMn{seg}==currentStatus),2)==length(currentStatus));
            currentNode = find(VOSMn{seg}==currentStatus);
            if seg==1
                if currentNode
                    priorNode = currentNode;
                else
                    Vn2(seg) = Vn2(seg)+1;
                    VOSMn{seg} = [VOSMn{seg}; currentStatus];
                    priorNode = Vn2(seg);
                end            
            else
                if currentNode
                    if size(VOSMe{seg-1},2)<Vn2(seg-1)
                        VOSMe{seg-1}(currentNode,Vn2(seg-1)) = 1;
                    else
                        VOSMe{seg-1}(currentNode,priorNode) = VOSMe{seg-1}(currentNode,priorNode)+1;
                    end
                    priorNode = currentNode;
                else
                    Vn2(seg) = Vn2(seg)+1;
                    VOSMn{seg} = [VOSMn{seg}; currentStatus];
                    if size(VOSMe{seg-1},2)<Vn2(seg-1)
                        VOSMe{seg-1}(Vn2(seg),Vn2(seg-1)) = 1;
                    else
                        VOSMe{seg-1}(Vn2(seg),priorNode) = 1;
                    end
                    priorNode = Vn2(seg);
                end
            end
        end
    end
end

end