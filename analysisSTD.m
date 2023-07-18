% Calculate pixelPerSec
pixelPerSec = frameRate*(2*halfLineWidth+1);
clear frameRate halfLineWidth

% List files
tempPath = pwd;
cd(rootDir)
listFiles = dir;
cd(tempPath)
clear tempPath
listSTD = [];
for i = 1:length(listFiles)
    if ~isempty(strfind(listFiles(i).name,'.bmp'))
        listSTD = [listSTD; cellstr(listFiles(i).name)];
    end
end
clear listFiles

% Read heights and pressures
numberSTDs = length(listSTD);
listHeights = zeros(1,numberSTDs);
listPressures = zeros(1,numberSTDs);
for i = 1:numberSTDs
    endPosition = cell2mat(strfind(listSTD(i),'mm_')) - 1;
    beginPosition = endPosition - 1;
    thisSTD = char(listSTD(i));
    while beginPosition > 1 && thisSTD(beginPosition-1) ~= '_'
        beginPosition = beginPosition-1;
    end
    listHeights(i) = str2num(thisSTD(beginPosition:endPosition));
    endPosition = cell2mat(strfind(listSTD(i),'mbar_')) - 1;
    beginPosition = endPosition - 1;
    thisSTD = char(listSTD(i));
    while beginPosition > 1 && thisSTD(beginPosition-1) ~= '_'
        beginPosition = beginPosition-1;
    end
    listPressures(i) = str2num(thisSTD(beginPosition:endPosition));
end
clear thisSTD beginPosition endPosition i

% Analyse STDs
disp(['About to analyze ',num2str(numberSTDs),' Space-Time Diagrams...'])
disp(' ')
for i = 1:numberSTDs
    % User iteration
    imshow(imread(strcat(rootDir,'/',strjoin(listSTD(i)))))
    thisIndex = rem(i,totalStretches);
    if thisIndex==0
        thisIndex = totalStretches;
    end
    title([num2str(listHeights(i)),' mm #',num2str(thisIndex)])
    pixX=[];
    pixT=[];
    markers=[];
    j = 0;
    while true
        [x, y, button] = ginput(1);
        switch button
            case 1 % primary button: add point
                j = j + 1;
                pixX(j) = x;
                pixT(j) = y;
                hold on
                markers(j) = plot(x,y,'ro');
            case 3 % secondary button: delete last point
                if j>0
                    set(markers(j),'visible','off')
                    j = j-1;                 
                end
            case 2 % mid button: exit
                break;
        end
    end
    clear markers
    % Estimation of frequency and amplitude
    ptsNr = floor(0.5*(length(pixX)-1));
    frequencies = zeros(1,ptsNr);
    diameters = zeros(1,ptsNr);
    for j = 1:ptsNr
        halfT = 0.5*(abs(pixT(2*j)-pixT(2*j-1))+abs(pixT(2*j)-pixT(2*j+1)));
        diameters(j) = 0.5*(abs(pixX(2*j)-pixX(2*j-1))+abs(pixX(2*j)-pixX(2*j+1)))/pixelPerMm;
        frequencies(j) = pixelPerSec/(abs(pixT(2*j)-pixT(2*j-1))+abs(pixT(2*j)-pixT(2*j+1)));
    end
    frequencies = frequencies(frequencies~=Inf);
    fileName = strjoin(listSTD(i));
    fid = fopen([rootDir,'/',fileName(1:end-3),'csv'],'wt');
    fprintf(fid,'%s,%f,%f,%f,%f,%f,%f\n',fileName,listPressures(i),listHeights(i),mean(frequencies),std(frequencies),mean(diameters),std(diameters));
    fclose(fid);
	% hgexport(gcf, [rootDir,'/',fileName(1:end-4),'_analyzed.bmp'], hgexport('factorystyle'), 'Format', 'bmp');
    fid = fopen([rootDir,'/',fileName(1:end-4),'_analyzed.txt'],'wt');
    for j=1:length(pixX)
        fprintf(fid,'%.0f,%.0f\n',pixX(j),pixT(j));
    end
    fclose(fid);
end
clear i j x y button thisIndex totalStretches numberSTDs ptsNr fid fileName
close
disp('Done')
disp(' ')
exit
