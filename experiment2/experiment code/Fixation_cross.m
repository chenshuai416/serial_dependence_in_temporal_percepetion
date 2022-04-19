function [ output_args ] = Fixation_cross( windowPtr,Cen_X, Cen_Y, Color,size)
%UNTITLED 此处显示有关此函数的摘要
% Fixation_cross( windowPtr,Cen_X, Cen_Y, Color,size)
%   此处显示详细说明


length = size;
width = size/3;
Screen('FillRect',windowPtr, Color, [Cen_X-length/2 , Cen_Y - width/2 , Cen_X + length/2 , Cen_Y + width/2]');
Screen('FillRect',windowPtr, Color, [Cen_X-width/2 , Cen_Y - length/2 , Cen_X + width/2 , Cen_Y + length/2]');


end % end of function

