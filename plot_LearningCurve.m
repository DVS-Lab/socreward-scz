clear; close all;
maindir = pwd;
conditions = {'money', 'social'};
subjects = load('sublist.txt');

for c = 1:length(conditions)
    condition = conditions{c};
    
    nbins = 20;
    lc = zeros(length(subjects),nbins);
    
    count = 0;
    for s = 1:length(subjects)
        subject = subjects(s);
        count = count + 1;
        
        filename = fullfile(maindir,'data',[num2str(subject) '_' condition '.csv']);
        delimiter = ',';
        startRow = 2;
        formatSpec = '%f%f%f%f%f%f%[^\n\r]';
        fileID = fopen(filename,'r');
        dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
        fclose(fileID);
        
        %% Allocate imported array to column variable names
        Subject = dataArray{:, 1};
        Trial = dataArray{:, 2};
        SlotChoice = dataArray{:, 3};
        Reward = dataArray{:, 4};
        TrialType = dataArray{:, 5};
        Accuracy = dataArray{:, 6};
        
        Accuracy(Accuracy == -99,:) = NaN;
        
        start = 1;
        stop = 5;
        
        for b = 1:nbins
            lc(count,b) = nanmean(Accuracy(start:stop));
            start = start + 5;
            stop = stop + 5;
        end
        
        
    end
    
    
    x = 1:nbins;
    y = mean(lc);
    e = std(lc) / sqrt(size(lc,1)); %across sessions
    figure,errorbar(x,y,e)
    title([ condition ' Learning Curve'])
    xlabel('Time (bins of 5 trials)')
    ylabel('accuracy')
    
end