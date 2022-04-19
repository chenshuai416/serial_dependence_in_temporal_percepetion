function [ CircleRect_PointList ] = CircleRect_4pointList(x, y, diameter)
% x,y: center of the Circle or Rect, in pixel
% diamter: Circle or Rect size/ diameter, in pixel
% 用圆心和半径来计算四个点位置用以输入PTB函数

% =====================when using 'FillOval' or 'FrameOval' or 'FillRect' or 'FrameRect':===============================
% CircleRect_PointList = CircleRect_4pointList(x, y, diameter)
% Screen('FrameRect', wPtr, [0 0 0], CircleRect_PointList, 3);
% Screen('FillOval', wPtr, [256 256 0], CircleRect_PointList);
x = round(x);
y = round(y);
r = round(diameter/2);
pointList(1)=x-r;
pointList(2)=y-r;
pointList(3)=x+r;
pointList(4)=y+r;

for i = 1:4
    CircleRect_PointList(1,i)=pointList(i);
end

end

