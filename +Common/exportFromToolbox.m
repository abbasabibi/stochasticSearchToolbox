function exportFromToolbox (destDir,filesToExport)

cDir = pwd;

dependFiles = {};
for i=1:length(filesToExport)
    %[fList,~] = matlab.codetools.requiredFilesAndProducts( filesToExport(i) );
    if (isdir(filesToExport{i}))
        filesToExport_dir = getFilesForDirector(filesToExport{i});
        for i = 1:length(filesToExport_dir)
            [fList,~] = depfun( filesToExport_dir{i} );        
            dependFiles = [dependFiles, fList];
        end
    else
        [fList,~] = depfun( filesToExport{i} );        
        dependFiles = [dependFiles, fList];     %#ok<AGROW>
    end
    
end

dependFiles = unique(dependFiles);

mkdir(destDir)
for i=1:length(dependFiles)
    srcFile  = dependFiles(i);
    if (~strcmp(srcFile{1}(1:5), '/usr/'))
        pathstr = fileparts(srcFile{:});
        pathstr = strrep(pathstr, cDir, destDir);
        mkdir(pathstr)
        destFile = strrep(dependFiles(i), cDir, destDir);
        copyfile(srcFile{:},destFile{:})
    end
end

end

function [fileList] = getFilesForDirector(directory)
    fileList = {};
    files = Common.strsplit(ls(fullfile(directory)));
    for i = 1:length(files)
        if (strcmp(files{i}(end-1:end), '.m') || strcmp(files{i}(end-1:end), '.c') || strcmp(files{i}(end-3:end), '.cpp'))
            fileList = [fileList, fullfile(directory, files{i})];
        else
            if (isdir(fullfile(directory, files{i})))
                fileList = [fileList, getFilesForDirector(fullfile(directory, files{i}))];            
            end
        end
    end
end