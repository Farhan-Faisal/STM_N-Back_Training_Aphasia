%manually insert the patient data into bh1 and hv
fname = 'Hyperventilation';
type= 'hv'; %or'bh' or 'hv'
input = hv; %bh1 or hv
ptid = {'P1', 'P2a', 'P2b', 'P2c', 'P5', 'P6a', 'P6b', 'P6c', 'P9', 'P10', 'P11'};
%figure setup
hf = figure('Color', 'white', 'Name', fname);
set(gcf, 'Position', [531         106        1287         883]);

for subj=1:11
    temp = input(:,subj);    
    set(gca, 'FontSize', 11, 'LineWidth', 0.75)
    subplot(4,3,subj)
    disp('=======================================')
    fprintf('\n%s for %s max percent change: %1.2f: \n', type, ptid{subj}, ...
        maxptopdiff(temp, type, ptid{subj})) 
    pause
end

%print(fname,'-dpng','-r600');