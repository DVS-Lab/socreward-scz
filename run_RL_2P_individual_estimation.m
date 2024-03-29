clear;
maindir = pwd;
conditions = {'money', 'social'};
subjects = load('sublist.txt');

fid_summary = fopen(fullfile(maindir,'summary_2P_0Neutral_MLE_individual.csv'),'w');
fprintf(fid_summary,'subject,condition,repeat,alpha,alpha_se,beta,beta_se,psuedoR2,BIC\n');
for c = 1:length(conditions)
    for s = 1:length(subjects)
        for r = 1:10 % repeats
            
            subject = subjects(s);
            condition = conditions{c};
            
            filename = fullfile(maindir,'data',[num2str(subject) '_' condition '.csv']);
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
            
            
            %% run RL_2P model and save results
            result = RL_2P(SlotChoice, Reward, TrialType);
            
            %fprintf(fid_summary,'subject,condition,alpha,alpha_se,beta,beta_se,psuedoR2,BIC\n');
            R = result.final;
            fprintf(fid_summary,'%s,%d,%d,%f,%f,%f,%f,%f,%f\n',condition,subject,r,R.alpha,R.alpha_se,R.beta,R.beta_se,R.pseudoR2,R.BIC);
            
        end
        
        
    end
    
end
fclose(fid_summary);
