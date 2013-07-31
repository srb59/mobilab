function generateBatch_Callback(~,~,obj)
try
    index = obj.container.findItem(obj.uuid);
    [~,gObj] = viewLogicalStructure(obj.container,'',false);
    backTraceList = [gObj.getAncestors(index+1)-1 index];
    backTraceList(backTraceList==0) = [];
    
    M = length(backTraceList);
    cmdList{1} = 'clear all;close all;clc;';
    %     fcount = 1;
    for it=1:M
        tmp = obj.container.item{backTraceList(it)}.history;
        if it == 2
            tmp = ['tmpObj = ' tmp];%#ok
        elseif it > 2
            ind = strfind(tmp(1,:),'}');
            if ~isempty(ind)
                tmp(1:ind) = [];
                tmp = ['tmpObj = tmpObj' tmp];%#ok
            end
        end
        if size(tmp,1) > 1
            for jt=1:size(tmp,1)
                cmdList{end+1} = tmp(jt,:);%#ok
            end
        else
            cmdList{end+1} = tmp;%#ok
        end
    end
    
    outFile = [obj.container.mobiDataDirectory filesep 'batchScript.m'];
    if exist(outFile,'file')
        choice = questdlg2(...
            sprintf(['The file ' outFile ' already exist.\nDo you want to replace it?']),...
            'Warning!!!','Yes','No','No');
        if strcmp(choice,'No')
            [filename, pathname] = uiputfile2('*.m', 'Save the script as',[obj.container.mobiDataDirectory filesep 'batchScript.m']);
            if isnumeric(filename), return;end
            outFile = fullfile(pathname,filename);
        end
    end
    
    fid = fopen(outFile,'w');
    for it=1:length(cmdList);
        fprintf(fid,'%s\n',cmdList{it});
    end
    fclose(fid);
    fprintf('\nSaved in:\n');
    fprintf([' ' outFile '\n\n']);
catch ME
    sendEmailReport(ME);
end