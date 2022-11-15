function [percent, se] = compareOverlap(targDir,nSamples,sampleSize)

    % warning, the listing may need to be modified for non-windows machines
    listing = ls([targDir, '*.txt']);

    overlap = [];

    for i=1:nSamples
        f1 = [targDir, listing(i,:)];
        s1 = sample(sampleSize,'isHeader',true,'isFormatting',true, ...
            'name','s1','fileName', f1);

        for j=1:nSamples
           if j > i
                f2 = [targDir, listing(j,:)];   
                s2 = sample(sampleSize,'isHeader',true,'isFormatting',true, ...
                    'name','s2','fileName', f2);           
                   overlap = [overlap ; dataFrame.overlap(s1,s2)]; %#ok<AGROW>
                   %for more for frequent progress reports...
                   %disp(i);
                   %disp(j);
           end
        end
    end

    percent = sum(overlap)/length(overlap);
    se = std(overlap)/sqrt(length(overlap));

    disp('Average/SE percent overlap across all samples');
    disp(percent);
    disp(se);
    
end