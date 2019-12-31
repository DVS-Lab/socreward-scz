clear;
maindir = pwd;
conditions = {'money', 'social'};
subjects = load('sublist.txt');
outdir = fullfile(maindir,'modelRegressors','TrialData_3Pmodel_repeat');
if ~exist(outdir,'dir')
    mkdir(outdir);
end

fid_summary = fopen(fullfile(maindir,'summary_3P_0Neutral_MLE_repeat.csv'),'w');
fprintf(fid_summary,'subject,condition,palpha,palpha_se,nalpha,nalpha_se,beta,beta_se,psuedoR2,BIC\n');
for s = 1:length(subjects)
    subject = subjects(s);
    for c = 1:length(conditions)
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
        
        % scale rewards between 1 and 3 
        Reward = (Reward.*2) + 1;
        Reward = Reward - 2;
        
        %% run RL_2P model and save results
        result = RL_3P(SlotChoice, Reward, TrialType);
        
        %fprintf(fid_summary,'subject,condition,alpha,alpha_se,beta,beta_se,psuedoR2,BIC\n');
        R = result.final;
        fprintf(fid_summary,'%d,%s,%f,%f,%f,%f,%f,%f,%f,%f\n',subject,condition,R.palpha,R.palpha_se,R.nalpha,R.nalpha_se,R.beta,R.beta_se,R.pseudoR2,R.BIC);
        
        fid_subj = fopen(fullfile(outdir,['rpe_' num2str(subject) '_' condition '_3P.csv']),'w');
        fprintf(fid_subj,'subject,trial,slotchoice,reward,ExpectedValue,RPE\n');
        for t = 1:length(Reward)
            fprintf(fid_subj,'%d,%d,%d,%d,%f,%f\n',subject,t,SlotChoice(t),Reward(t),R.cV(t),R.rpe(t));
        end
        fclose(fid_subj);
    end
end
fclose(fid_summary);
