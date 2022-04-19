function [beta] = plot_DoG(inputData)
%inputData with the format of (:,5) previous (:,7)deviation
    x = unique(round(inputData(:,5)*100)/100);
    y = grpstats(inputData(:,7),round(inputData(:,5)*100)/100);
    scatter(x,y,'filled');
    beta = fit_DoG(inputData(:,5),inputData(:,7));
    theta = -1:0.001:1;
    DoG_y = dog(theta,beta(1),beta(2));
    ax = gca;
    hold on
    plot(ax.XLim,[0 0],'--g','linewidth',1);
    plot(theta,DoG_y,'-k','linewidth',2);
    strings={"a="+num2str(beta(1))+'w='+num2str(beta(2))};
    text(0,.1,strings,'FontSize',20)
    ylim([-0.1 0.1]);
end