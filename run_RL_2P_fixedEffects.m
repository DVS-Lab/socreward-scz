clear;
maindir = pwd;
conditions = {'money', 'social'};
subjects = load('sublist.txt');
outdir = fullfile(maindir,'modelRegressors','TrialData_2Pmodel');
if ~exist(outdir,'dir')
    mkdir(outdir);
end

fid_summary = fopen(fullfile(maindir,'summary_2P_0Neutral_MLE_fixedEffects.csv'),'w');
fprintf(fid_summary,'subject,condition,alpha,alpha_se,beta,beta_se,psuedoR2,BIC\n');
for c = 1:length(conditions)
    
    [SlotChoice_all,Reward_all,TrialType_all] = deal([]);
    
    for s = 1:length(subjects)
        subject = subjects(s);
        condition = conditions{c};
        msg = sprintf('running subject %d on the %s condition',subject,condition);
        disp(msg);
        
        if strcmp(condition,'social')
            filename = fullfile(maindir,'data',[num2str(subject) '_' condition '.csv']);
        else
            filename = fullfile(maindir,'data',[num2str(subject) '_' condition '.csv']);
        end
        delimiter = ',';
        startRow = 2;
        
        %% Format string for each line of text:
        %   column1: double (%f)
        %	column2: double (%f)
        %   column3: double (%f)
        %	column4: double (%f)
        %   column5: double (%f)
        %	column6: double (%f)
        % For more information, see the TEXTSCAN documentation.
        formatSpec = '%f%f%f%f%f%f%[^\n\r]';
        
        %% Open the text file and read in data
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
        
        SlotChoice_all = [SlotChoice_all; SlotChoice];
        Reward_all = [Reward_all; Reward];
        TrialType_all = [TrialType_all; TrialType];
        
    end
    
    %% run RL_2P model and save results
    result = RL_2P(SlotChoice_all, Reward_all, TrialType_all);
    
    %fprintf(fid_summary,'subject,condition,alpha,alpha_se,beta,beta_se,psuedoR2,BIC\n');
    R = result.final;
    fprintf(fid_summary,'%s,%f,%f,%f,%f,%f,%f\n',condition,R.alpha,R.alpha_se,R.beta,R.beta_se,R.pseudoR2,R.BIC);
    
    
end
fclose(fid_summary);
