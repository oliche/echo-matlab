function package_function(strfcn, outputpath)
% ExportFunction(strfcn,outputpath)
% Export one or several m-file function (s) and its non built-in dependencies in the
% specified directory
%
% ExportFunction('foo.m')
% ExportFunction({'foo.m','bar.m'},'C:\DATA\foobar')
%
if ischar(strfcn), strfcn={strfcn}; end

if nargin==1, outputpath = fullfile(pwd,strrep(strfcn{1},'.','_')); end

if ~isfolder(outputpath), mkdir(outputpath);end

% Magouille : on se place temporairement dans le repertoire du fichier avant de chercher les dependances
% Probleme mal compris: quand on ne le fait pas, matlab.codetools.requiredFilesAndProducts est instable
originDir=pwd;

reqFiles=cell(1,0);

for n = 1:length(strfcn)
    fileDir = fileparts(which(strfcn{n}));
    [prevDir,lastDir] = fileparts(fileDir);
    while startsWith(lastDir, {'+', '@'})
        fileDir = fileparts(prevDir);
        [prevDir, lastDir] = fileparts(fileDir);
    end
    cd(fileDir);
    disp(['Looking for required files for : ' strfcn{n} 10 'in directory : ' fileDir]);
    reqFiles = [reqFiles,matlab.codetools.requiredFilesAndProducts(strfcn{n})];
end
disp('Exporting')
cd(originDir);

reqFiles = unique(reqFiles);

for m = 1:length(reqFiles)
    [chem, ~] = fileparts(reqFiles{m});
    
    chemparts = textscanlim(chem, filesep);
    packInd = find(cellfun(@(X) startsWith(X, {'+', '@'}), chemparts), 1, 'first');
    if isempty(packInd)  % Ce n'est pas un package ni une classe
        spack = '';
    else  % C'est un package, il faut creer les repertoires
        spack = mkPackPath(outputpath, chemparts(packInd:end));
    end
    
    [st1,mess1] = copyfile(reqFiles{m},[outputpath spack],'f');
    if ~st1, disp(['Error copying ' reqFiles{m} ':' mess1]);end
end

function spack = mkPackPath(outputpath,pathCell)
spack = [filesep fullfile(pathCell{:})];

for n = 1:length(pathCell)
    if ~exist(fullfile(outputpath, pathCell{1:n}),'dir')
        mkdir(fullfile(outputpath, pathCell{1:n}))
    end
end
