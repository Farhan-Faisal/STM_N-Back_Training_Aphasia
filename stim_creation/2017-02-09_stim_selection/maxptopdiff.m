%% CVR Brain average

function val = maxptopdiff(temp,type,ss)     
    temp1=temp-mean(temp); 
    lw=1.5;
    plot(temp1); hold on
    xlim([0 180]);
    if strcmp(type, 'hv')
        [xx,idx]=max(temp1) ;
        plot(repmat(xx, size(temp1)), 'r', 'LineWidth', lw)
        plot(repmat(min(temp1), size(temp1)), 'r', 'LineWidth', lw)
        title(ss)        
    elseif strcmp(type, 'bh')
        [xx,idx]=min(temp1);
        plot(repmat(xx, size(temp1)), 'r', 'LineWidth', lw)
        plot(repmat(max(temp1), size(temp1)), 'r', 'LineWidth', lw)
        title(ss)
    else error('please make appropriate selection for type: bh or hv')
    end
    val = ((max(temp1) - min(temp1))/abs(temp(idx)))*100;
    
    
    
    
end