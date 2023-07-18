% Parameters
pointsNr = 6; % Vertical points (different heights) for STDs
framesPerStretch = 437; % Divide STDs in stretches this size for better visualization
halfLineWidth = 0; % Copy 2*halfLineWidth+1 lines on the STD
firstHeight = 5; % First (minimal) height of the nozzle

% Open video
videoPath  = strcat(rootDir, '/', videoFileName);
myVideo = VideoReader(videoPath);
clear rootDir videoFileName

% Preliminar calculations
totalFrames = myVideo.numberOfFrames;
if totalFrames > framesPerStretch
    framesPerStretch = framesPerStretch + floor(rem(totalFrames,framesPerStretch)/floor(totalFrames/framesPerStretch));
else
    framesPerStretch = totalFrames;
end
totalStretches = floor(totalFrames/framesPerStretch);
clear totalFrames

% User interaction
imgOrig = read(myVideo,1);
imshow(imadjust(imgOrig))
clear imgOrig

myText = text(5,10,'Click on the tip of the nozzle:','color','g');
[x, y, ~] = ginput(1);
set(myText,'visible','off')
yMin = ceil(y);
xNozzle = x;

text(5,10,'Choose horizontal and vertical limits:','color','g');
[x, y, ~] = ginput(2);
xNozzle = round(xNozzle-min(x)+1);
xMin = ceil(min(x));
xMax = floor(max(x));
x = [xMin xMax];
yMax = floor(max(y));
y = round(linspace(yMin+firstHeight*pixelPerMm,yMax,pointsNr));
clear myText xMin xMax button yMax pointsNr firstHeight

close()
disp(['About to generate ',num2str(totalStretches*length(y)),' Space-Time Diagrams...'])
disp(' ')

% Construction of STDs
for l = 1:length(y)
    for i = 1:totalStretches
        instanceSTD = uint8(zeros(framesPerStretch*(2*halfLineWidth+1),x(2)-x(1)+1));
        for j = 1:framesPerStretch
            thisFrame = read(myVideo,(i-1)*framesPerStretch+j);
            for k = -halfLineWidth:halfLineWidth
                index = (j-1)*(2*halfLineWidth+1) + k + halfLineWidth + 1;
                instanceSTD(index,1:end) = thisFrame(y(l)+k,x(1):x(2));
            end
        end
        disp(['Saving STD for point ',num2str(l),', stretch ',num2str(i),'...'])
        imwrite(imadjust(instanceSTD),strcat(videoPath(1:end-4),'_',num2str((y(l)-yMin)/pixelPerMm,'%.1f'),'mm','_',num2str(i),'.bmp'))
    end
end
clear i j k l index thisFrame instanceSTD
disp(' ')

% Save parameters
disp('Saving parameters to text file...')
fid = fopen(strcat(videoPath(1:end-4),'_params.txt'),'wt');
fprintf(fid,'pixelPerMm: %f\nhalfLineWidth: %d\ntotalStretches: %d\nxNozzle: %d\n',pixelPerMm,halfLineWidth,totalStretches,xNozzle);
fclose(fid);
clear fid
%system(['cat ',videoPath(1:end-3),'cih | grep fps >> ',videoPath(1:end-4),'_params.txt']);

% Exit
disp(' ')
disp('Done')
exit
