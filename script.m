clear all;
clc;
close all;

% Shutdown any existing ROS connections
fprintf('Shutting down any existing ROS connections...\n');
rosshutdown;

%% Start Dobot Magician Node
fprintf('Starting ROS node and connecting to Dobot Magician...\n');
rosinit("192.168.27.1");


%% Start Dobot ROS Interface
fprintf('Initializing Dobot Magician...\n');
dobot = DobotMagician();

dobot.PublishEndEffectorPose([0.15,0.0,0.10], [0,0,0]);

cam = webcam(3);  % Initialize the camera
cam.Resolution = '640x480';  % Set a supported resolution
pause(3);  % Allow the camera to initialize

%Capture and save images
A = snapshot(cam);
imwrite(A, ['ActualImage2', '.jpg']);

[matrix, image] = shapes_and_colours("ActualImage2.jpg");

%% LOCATION HANDLING
order = [
    0, 1; % RED CIRCLE
    1, 1; % RED SQUARE
    0, 2;
    1, 2;
    0, 3;
    1, 3;
];

orderedMatrix = [];

for i = 1:size(order, 1)
    val3 = order(i, 1);
    val4 = order(i, 2);
    
    % Find rows matching the current values of columns 3 and 4
    matchingRows = matrix(matrix(:, 3) == val3 & matrix(:, 4) == val4, :);
    
    % Display the matching rows
    fprintf('Rows with (Column 3 = %d, Column 4 = %d):\n', val3, val4);
    orderedMatrix = [orderedMatrix; matchingRows];
end

for i = 1:size(orderedMatrix, 1)
    pixelX = orderedMatrix(i,1);
    pixelY = orderedMatrix(i,2);

    [realX, realY] = PixelToReal(pixelX, pixelY);
    orderedMatrix(i,1) = realX;
    orderedMatrix(i,2) = realY;
end

%% Movement
x = false;
for i=1:size(orderedMatrix,1)

    x = ~x;

    EE_Pos = [orderedMatrix(i,1) , orderedMatrix(i,2), -0.053] + [0.01, 0, 0];  % In centimeters
    pause(3);

    dobot.PublishEndEffectorPose(EE_Pos, [0,0,0]);

    openClose = 1;
    pause(3)
    dobot.PublishToolState(x,openClose);


    dobot.PublishEndEffectorPose([0.15,0.0,0.10], [0,0,0]);
    pause(3)

end



