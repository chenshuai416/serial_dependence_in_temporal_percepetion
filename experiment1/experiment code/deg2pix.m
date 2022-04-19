function pix = deg2pix(deg,Distance)
if exist('Distance','var')==0
    Distance=560;%单位为毫米
end
[w_pix]=Screen('WindowSize',0);
w_size=600;%Screen('DisplaySize',0);
pix_pre_size=w_pix/w_size;
pix=round(Distance*tand(deg/2)*pix_pre_size*2);
%677,381
%60,35.5