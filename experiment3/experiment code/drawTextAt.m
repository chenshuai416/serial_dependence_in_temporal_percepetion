function drawTextAt(w,txt,x,y,color)
%draw text with center at x,y
%sometimes, writing in chinese will result in runtime error.
%get BoundsRect
bRect= Screen('TextBounds', w,txt);
Screen('DrawText',w,txt,x-bRect(3)/2,y-bRect(4)/2,color);
