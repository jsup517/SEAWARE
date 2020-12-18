function [Pout2, pySFD] = PredictionSEAWARE(VOSMn, VOSMe, SFD, cente, pitchyaw, k, T, currentView, tran, numOB, H, W, beta, ww, wh, resX, resY)

viewport = reshape(currentView, [H W]);

Po = VOSMprediction(VOSMn, VOSMe, SFD, k, currentView, tran, numOB, H, W);

% Derive Prediction Matrix
P2 = zeros(k,T);

for ii=1:k    
    if sum(Po(ii,:))==0
        P2(ii,:) = currentView;
        pySFD(ii,:) = pitchyaw(tran,:);
    else
        for oo=1:numOB
            if Po(ii,oo)>0
                pre = SFD{oo}(tran+ii,:);
                ori = SFD{oo}(tran,:);
                tempOMV1 = reshape(pre, [H W]);
                tempOMV2 = reshape(ori, [H W]);
                minimini = 10000;
                for nn=-wh:1:wh
                    for jj=-ww:1:ww
                        dis = sum(sum((tempOMV1.*circshift(tempOMV2,[nn jj]))==0))+beta*(abs(nn)+abs(jj));
                        if dis<minimini
                            minimini = dis;
                            optnn = nn;
                            optjj = jj;
                        end
                    end
                end
                P2(ii,:) = P2(ii,:) + Po(ii,oo)*reshape(circshift(viewport, [optnn optjj]),[1 T]);
                
              
                if sum(find(reshape(SFD{oo}(tran+ii,:),[H, W])))>0 && sum(find(reshape(SFD{oo}(tran,:),[H, W])))>0
                    [a1 b1]=find(reshape(SFD{oo}(tran+ii,:),[H, W]));
                    [a2 b2]=find(reshape(SFD{oo}(tran,:),[H, W]));
                else
                    [a1 b1]=find(reshape(currentView,[H, W]));
                    [a2 b2]=find(reshape(currentView,[H, W]));
                end

                VMV2 = [mean(b1)-mean(b2), mean(a1)-mean(a2)]./[W, H];
                newpitchyaw2 = pitchyaw(tran,:)+VMV2;
                pySFD(ii,:) = newpitchyaw2;
                
                newviewport2 = tileMap(newpitchyaw2(1), newpitchyaw2(2), W, H);
                
                %P2(ii,:) = P2(ii,:) + Po(ii,oo)*newviewport2;
            end
        end
    end
    
   
    if sum(P2(ii,:))>0
        P2(ii,:) = P2(ii,:)/sum(P2(ii,:));
    end

end
Pout2 = P2';
end