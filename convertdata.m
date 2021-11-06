% Extract data from xlsx and xls files and convert to csv files
%
% Also output one contenated tsv file for hbayesDM testing
% NB: hbayesDM model needs a different task structure with just two options
% so remember this is just for testing/learning purposes.
%
% 2019-12-21: created by DVS (david.v.smith@temple.edu)

clear;
maindir = pwd;

% grab source data
sourcedatadir = '/Users/tug87422/Downloads/Pam/all_data_final/';
sourcedata = dir([sourcedatadir '*.xls*']);
sourcedata = struct2cell(sourcedata);
sourcedata = sourcedata(1,1:end);


sublist = zeros(length(sourcedata),1); % add subs here, print later
idx = 0;
for i = 1:length(sourcedata)
    fname = sourcedata{i};
    data = xlsread(fullfile(sourcedatadir,fname));

    % get file name parts
    fname_split = split(fname,'_');
    subnum_str = fname_split{1};
    condition_str = fname_split{2};
    
    % make subject list for later
    sublist(i,1) = str2double(subnum_str);
    
    % build output file with header
    outname = [subnum_str '_' condition_str '.csv'];
    outfile = fullfile(maindir,'data',outname);
    cHeader = 'subject,trial,response,reward,trial_type,accuracy';
    fid = fopen(outfile,'w');
    fprintf(fid,'%s\n',cHeader);
    fclose(fid);
    
     % write data to end of file
     dlmwrite(outfile,data,'-append');
     

end

% % write out a sublist for later
dlmwrite('sublist.txt',unique(sublist));



