function JND=calJND(a,b)
probability=0.25;
t25=(-1/a)*(log(1-probability)-log(probability))+b;
probability=0.75;
t75=(-1/a)*(log(1-probability)-log(probability))+b;
JND=0.5*(t75-t25);
end