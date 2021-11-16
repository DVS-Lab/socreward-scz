clear;
maindir = pwd;
allconditions = {'money', 'social'};
allsubjects = load('sublist.txt');

fid_summary = fopen(fullfile(maindir,'summary_2P_0Neutral_MLE_fixedEffects.csv'),'w');
fprintf(fid_summary,'analysiscondition,ntrials,repeat,alpha,alpha_se,beta,beta_se,psuedoR2,BIC\n');
analysisconditions = {'all','3000_money','4000_social','3000_social','4000_money'};
for t = 1:5 % tests: 1 is all, 2 is 3000-social, 3 is 4000-social, 4 is 3000 nonsocial, 5 is 4000 nonsocial
    if strcmp(analysisconditions{t},'all')
        conditions = allconditions;
        subjects = allsubjects;
    elseif strcmp(analysisconditions{t},'3000_money')
        conditions = {'money'};
        subjects = allsubjects(allsubjects < 4000);
    elseif strcmp(analysisconditions{t},'4000_money')
        conditions = {'money'};
        subjects = allsubjects(allsubjects > 4000);
    elseif strcmp(analysisconditions{t},'3000_social')
        conditions = {'social'};
        subjects = allsubjects(allsubjects < 4000);
    elseif strcmp(analysisconditions{t},'4000_social')
        conditions = {'social'};
        subjects = allsubjects(allsubjects > 4000);
    end
    
    for r = 1:10 % repeats
        [SlotChoice_all,Reward_all,TrialType_all] = deal([]);
        analysiscondition = analysisconditions{t};
        for c = 1:length(conditions)
            
            for s = 1:length(subjects)
                
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
                
                
                SlotChoice_all = [SlotChoice_all; SlotChoice];
                Reward_all = [Reward_all; Reward];
                TrialType_all = [TrialType_all; TrialType];
                
                
            end
        end
        N = length(SlotChoice_all);
        %% run RL_2P model and save results
        result = RL_2P(SlotChoice_all, Reward_all, TrialType_all);
        
        %fprintf(fid_summary,'subject,condition,alpha,alpha_se,beta,beta_se,psuedoR2,BIC\n');
        R = result.final;
        fprintf(fid_summary,'%s,%d,%d,%f,%f,%f,%f,%f,%f\n',analysiscondition,N,r,R.alpha,R.alpha_se,R.beta,R.beta_se,R.pseudoR2,R.BIC);
    end
end
fclose(fid_summary);
