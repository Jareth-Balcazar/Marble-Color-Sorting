  % This requires Image Acquistion toolbox , MATLab Support Package for
  % USB Webcams, & MATLAB Support Package for Arduino Hardware

  % if videoinput is wrong, it is most likely the Default format or even the
  % adaptername
  % use imaqhwinfo in the command line to find the installed Adapters 
  % To get the  device number and default format, run 
  % imaqhwinfo(adaptername), this will output the device IDs under winvideo
  % I'm sure you can pick any of the three IDs - imaqhwinfo(adapatername,ID)
  % This line will give you the Default format to use for videoinput
  % So, videoinput (adaptername, ID, format)

%Color Detection and Separation using arduino and Matlab interfaced with a
%Webcam.
% To clear the Workspace
clear all; close all;
clear a;                  
a = arduino('COM8', 'Mega2560', 'Libraries', 'Servo'); %Initialize arduino at COM PORT 3
Red= servo(a, 'D4');                %Initialize Red Door servo @ Digitial pin 4
Blue= servo(a, 'D3');                %Initialize Blue Door servo @ Digitial pin 3
Green= servo(a, 'D2');                %Initialize Green Door servo @ Digitial pin 2
writePosition(Red,0);             %writePosition(servo_name,angle)   0<=angle<=1; this initializes starting pos
writePosition(Blue,0.1);             %writePosition(servo_name,angle)   0<=angle<=1; this initializes starting pos
writePosition(Green,0);             %writePosition(servo_name,angle)   0<=angle<=1; this initializes starting pos

%Initially we are initialzing the Live video stream
  imaqreset          %delete and resets image aquisition toolbox functions
  info= imaqhwinfo;  %Information regarding the Adaptors 
  vid= videoinput('winvideo','1', 'MJPG_1280x720');  %videoinput('apaptername','device_ID','format')
  set(vid, 'FramesPerTrigger', Inf);   %Specify number of frames to acquire per trigger using selected video source
  set(vid, 'ReturnedColorspace', 'rgb') %Set the video input as RGB or grayscale.
  vid.FrameGrabInterval = 4;      %An interval between frames, Here 5 frame interval between two frames
  start(vid);                     % start
  preview(vid);                   %see the video
  
% Set loop from the value of slider
  while(vid.FramesAcquired<=900)    % Its a loop which runs for 300 frames, It can be varied as required.
% current snapshot
  im = getsnapshot(vid);            %To convert the live stream video into a screenshot 

  r=im(:,:,1); g=im(:,:,2); b=im(:,:,3); % r= red object g= green and b= blue objects;respective layer
  
  % Red color detection
  diff_red=imsubtract(r,rgb2gray(im));   % To separate RED objects from a gray image
  diff_r=medfilt2(diff_red,[3 3]);       % Applting median filter
  bw_r=imbinarize(diff_r,0.2);           % To convert grayscale image to Black and white with a threshold value of 0.2
  area_r=bwareaopen(bw_r,300);           % To remove objects less than 300 pixels
  R = sum(area_r(:));                      % Records the Value of Red
  rm=immultiply(area_r,r);  gm=g.*0;  bm=b.*0; %Multiplies the red detected object with red to visualize.
  image_r=cat(3,rm,gm,bm);                     %combines all RGB image
  subplot(2,2,2);
  imshow(image_r);                             % Displays the image
  title('RED');                               
    
% Green color detection 
  diff_green=imsubtract(g,rgb2gray(im));
  diff_g=medfilt2(diff_green,[3 3]);
  bw_g=imbinarize(diff_g,0.071);
  area_g=bwareaopen(bw_g,300);
  G = sum(area_g(:));                    % Records the Value of Green
  gm=immultiply(area_g,g);  
  image_g=cat(3,rm,gm,bm);
  subplot(2,2,3);
  imshow(image_g);
  title('GREEN');
     
% Blue color detection
  diff_blue=imsubtract(b,rgb2gray(im));
  diff_b=medfilt2(diff_blue,[3 3]);
  bw_b=imbinarize(diff_b,0.2);
  area_b=bwareaopen(bw_b,300);
  B = sum(area_b(:));                    % Records the Value of Green
  bm=immultiply(area_b,b);  
  image_b=cat(3,rm,gm,bm);
  subplot(2,2,4);
  imshow(image_b);    
  title('BLUE');
 
 % For servo control and display the color. 
 
if((R>G) && (R>B))                         %if the area of Red is greater than Green and Blue then its Red
    fprintf('The color is red ');
    fprintf('\n');
    writePosition(Red,.60);                  %Writes servo position as 0.6*180= 108 degrees
    pause(4);
    writePosition(Red,0); 
 elseif((G>R) && (G>B))                    %if the area of Green is greater than Red and Blue then its Green
    fprintf('The color is green ');
    fprintf('\n');
    writePosition(Green,.60);                  %Writes servo position as 0.6*180= 108 degrees
    pause(4);
    writePosition(Green,0); 
 elseif((B>R) && (B>G))                    %if the area of Blue is greater than red and Green then its Blue
    fprintf('The color is blue ');
    fprintf('\n');
    writePosition(Blue,.60);                  %Writes servo position as 0.6*180= 108 degrees
    pause(4);
    writePosition(Blue,0.1); 
  else
    fprintf('Cannot find a color ');       %if none of the colors are discovered during snapshot
    fprintf('\n');
    writePosition(Red,0);                  
    writePosition(Blue,0.1); 
    writePosition(Green,0); 
end  
  
  end
  
 
%Once the program has run, the data's are cleared. I have it capped at
%900 frames with 5 frame interval, this can be changed above
  stop(vid);                              
  delete(vid);
  clear all,close all;