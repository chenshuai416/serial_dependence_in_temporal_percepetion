function [ output_args ] = Fixation_cross( windowPtr,Cen_X, Cen_Y, Color,size)
%UNTITLED �˴���ʾ�йش˺�����ժҪ
% Fixation_cross( windowPtr,Cen_X, Cen_Y, Color,size)
%   �˴���ʾ��ϸ˵��


length = size;
width = size/3;
Screen('FillRect',windowPtr, Color, [Cen_X-length/2 , Cen_Y - width/2 , Cen_X + length/2 , Cen_Y + width/2]');
Screen('FillRect',windowPtr, Color, [Cen_X-width/2 , Cen_Y - length/2 , Cen_X + width/2 , Cen_Y + length/2]');


end % end of function

