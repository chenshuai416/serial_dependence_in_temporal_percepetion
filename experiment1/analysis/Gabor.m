function y_fit = Gabor(x,h,w)
%compute Gabor model function
%x: previous- current
y_fit = h .* exp(-( w .* x ).^2) .* sin ( w .* x );
end