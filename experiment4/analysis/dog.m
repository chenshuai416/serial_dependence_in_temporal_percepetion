function fit = dog(x, a, w)
    c = sqrt(2) / exp(-0.5);
    fit =  x .* a .* w .* c .* exp(-(w .* x).^ 2);
end