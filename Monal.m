%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Program Name : Red Object Detection and Tracking and Pick and Place Action      %
% Description  : How to detect and track red, green and blue              %
%                objects in Live Video, then open the serial port and send
%                respective command to make the Robot take an action. The
%                action is either to pick and place object in Left
%                direction fo the robot or to the right side of the robot
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialization
clear all
redThresh = 0.24; % Threshold for red detection
greenThresh = 0.05; % Threshold for green detection
blueThresh = 0.15; % Threshold for blue detection
delete(instrfind);

% pause(3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s1 = serial('COM13','BaudRate',9600,'DataBits',8,'TimeOut',50);  % check port number before use
disp('welcome')
%s1.Timeout = 1000;
fopen(s1);
%b = fread(s1,1,'int8');
new_signal = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


vidDevice = imaq.VideoDevice('winvideo', 1, 'YUY2_640x480', ... % Acquire input video stream
                    'ROI', [1 1 640 480], ...
                    'ReturnedColorSpace', 'rgb');
vidInfo = imaqhwinfo(vidDevice); % Acquire input video property
hblob = vision.BlobAnalysis('AreaOutputPort', false, ... % Set blob analysis handling
                                'CentroidOutputPort', true, ... 
                                'BoundingBoxOutputPort', true', ...
                                'MinimumBlobArea', 600, ...
                                'MaximumBlobArea', 3000, ...
                                'MaximumCount', 10);
hshapeinsBox = vision.ShapeInserter('BorderColorSource', 'Input port', ... % Set box handling
                                        'Fill', true, ...
                                        'FillColorSource', 'Input port', ...
                                        'Opacity', 0.4);
htextinsRed = vision.TextInserter('Text', 'Red   : %2d', ... % Set text for number of blobs
                                    'Location',  [5 2], ...
                                    'Color', [1 0 0], ... // red color
                                    'Font', 'Courier New', ...
                                    'FontSize', 14);
%htextinsGreen = vision.TextInserter('Text', 'Green : %2d', ... % Set text for number of blobs
%                                     'Location',  [5 18], ...
%                                     'Color', [0 1 0], ... // green color
%                                     'Font', 'Courier New', ...
%                                     'FontSize', 14);
htextinsBlue = vision.TextInserter('Text', 'Blue  : %2d', ... % Set text for number of blobs
                                     'Location',  [5 34], ...
                                     'Color', [0 0 1], ... // blue color
                                     'Font', 'Courier New', ...
                                     'FontSize', 14);
htextinsCent = vision.TextInserter('Text', '+      X:%4d, Y:%4d', ... % set text for centroid
                                    'LocationSource', 'Input port', ...
                                    'Color', [1 1 0], ... // yellow color
                                    'Font', 'Courier New', ...
                                    'FontSize', 14);
hVideoIn = vision.VideoPlayer('Name', 'Final Video', ... % Output video player
                                'Position', [100 100 vidInfo.MaxWidth+20 vidInfo.MaxHeight+30]);
nFrame = 0; % Frame number initialization

%% Processing Loop
% while(1)
%     stream = fread(s1, 1)
%     while(isempty(stream))
%         stream = fread(s1, 1)
%     end
%     if(stream(1) == 'O')
%         disp(stream);
%         fprintf(s1,'N');
%     end
while(300)
    rgbFrame = step(vidDevice); % Acquire single frame
    rgbFrame = flipdim(rgbFrame,2); % obtain the mirror image for displaying
    
    diffFrameRed = imsubtract(rgbFrame(:,:,1), rgb2gray(rgbFrame)); % Get red component of the image
    diffFrameRed = medfilt2(diffFrameRed, [3 3]); % Filter out the noise by using median filter
    binFrameRed = im2bw(diffFrameRed, redThresh); % Convert the image into binary image with the red objects as white
    
 %    diffFrameGreen = imsubtract(rgbFrame(:,:,2), rgb2gray(rgbFrame)); % Get green component of the image
%     diffFrameGreen = medfilt2(diffFrameGreen, [3 3]); % Filter out the noise by using median filter
  %   binFrameGreen = im2bw(diffFrameGreen, greenThresh); % Convert the image into binary image with the green objects as white
     
     diffFrameBlue = imsubtract(rgbFrame(:,:,3), rgb2gray(rgbFrame)); % Get blue component of the image
     diffFrameBlue = medfilt2(diffFrameBlue, [3 3]); % Filter out the noise by using median filter
     binFrameBlue = im2bw(diffFrameBlue, blueThresh); % Convert the image into binary image with the blue objects as white
    
    [centroidRed, bboxRed] = step(hblob, binFrameRed); % Get the centroids and bounding boxes of the red blobs
    centroidRed = uint16(centroidRed); % Convert the centroids into Integer for further steps 
    
   %  [centroidGreen, bboxGreen] = step(hblob, binFrameGreen); % Get the centroids and bounding boxes of the green blobs
   %  centroidGreen = uint16(centroidGreen); % Convert the centroids into Integer for further steps 
     
     [centroidBlue, bboxBlue] = step(hblob, binFrameBlue); % Get the centroids and bounding boxes of the blue blobs
     centroidBlue = uint16(centroidBlue); % Convert the centroids into Integer for further steps 
    
    rgbFrame(1:50,1:90,:) = 0; % put a black region on the output stream
    vidIn = step(hshapeinsBox, rgbFrame, bboxRed, single([1 0 0])); % Instert the red box
    % vidIn = step(hshapeinsBox, vidIn, bboxGreen, single([0 1 0])); % Instert the green box
     vidIn = step(hshapeinsBox, vidIn, bboxBlue, single([0 0 1])); % Instert the blue box
    
    for object = 1:1:length(bboxRed(:,1)) % Write the corresponding centroids for red
        centXRed = centroidRed(object,1); centYRed = centroidRed(object,2);
        vidIn = step(htextinsCent, vidIn, [centXRed centYRed], [centXRed-6 centYRed-9]); 
         if(centXRed > 200)
             disp(centXRed);
             disp('Sending Red')
             fprintf(s1,'r');
             pause(1);
         end
    end
     %for object = 1:1:length(bboxGreen(:,1)) % Write the corresponding centroids for green
         %centXGreen = centroidGreen(object,1); centYGreen = centroidGreen(object,2);
         %vidIn = step(htextinsCent, vidIn, [centXGreen centYGreen], [centXGreen-6 centYGreen-9]);
         % if(centXGreen > 200)
          %   disp(centXGreen);
           %  fprintf(s1,'g');
            % pause(2);
          %end
     %end
     for object = 1:1:length(bboxBlue(:,1)) % Write the corresponding centroids for blue
         centXBlue = centroidBlue(object,1); centYBlue = centroidBlue(object,2);
         vidIn = step(htextinsCent, vidIn, [centXBlue centYBlue], [centXBlue-6 centYBlue-9]); 
         if(centXBlue > 200)
             disp(centXBlue);
             disp('Sending Blue')
             fprintf(s1,'b');
             pause(1);
         end
     end
     vidIn = step(htextinsRed, vidIn, uint8(length(bboxRed(:,1)))); % Count the number of red blobs
    
    % vidIn = step(htextinsGreen, vidIn, uint8(length(bboxGreen(:,1)))); % Count the number of green blobs
     vidIn = step(htextinsBlue, vidIn, uint8(length(bboxBlue(:,1)))); % Count the number of blue blobs
    step(hVideoIn, vidIn); % Output video stream
    nFrame = nFrame+1;
end
%fprintf(s1,'hola done');
% release(hVideoIn); % Release all memory and buffer used
% release(vidDevice);
% clear all;
% end
%% Clearing Memory
release(hVideoIn); % Release all memory and buffer used
release(vidDevice);
clear all;
clc;