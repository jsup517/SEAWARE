function vec = VMVgeneration(next, current, H, W, win)
tempVMV1 = reshape(next, [H W]);
tempVMV2 = reshape(current, [H W]);
minimini = 10000;
for nn=-win:1:win
    for jj=-win:1:win
        %dis = sum(sum(abs(tempVMV1-circshift(tempVMV2,[nn jj]))))+abs(nn)+abs(jj);
        dis = sum(sum(abs(tempVMV1.*circshift(tempVMV2,[nn jj])-1)))+0.1*abs(nn)+abs(jj);
        if dis<minimini
            minimini = dis;
            optnn = nn;
            optjj = jj;
        end
    end
end
vec = [optnn optjj];
end