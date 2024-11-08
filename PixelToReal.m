function [realX, realY] = PixelToReal(pixelX, pixelY)

    % Define the camera offset relative to the end effector (in centimeters as needed)
    cameraOffset = [0.21, 0.025, 0.15];  % Camera is offset by 5 cm in the X direction
    
    % Initialize camera
    focalLength = [589.37716, 592.20768];
    principalPoint = [405.84131, 271.85548];
    
    % Define Z offset in meters and convert to centimeters (assuming robot expects cm)
    zOffset = 0.2 ;  % 6.2 cm downward, in meters
    
    % Calculate normalized coordinates for the red point
    normCoordinates_Red = [(pixelX - principalPoint(1)) / focalLength(1), ...
                           (pixelY - principalPoint(2)) / focalLength(2)];
    
    % Display normalized coordinates for red
    % fprintf('Normalized Red Coordinates: (%.4f, %.4f)\n', normCoordinates_Red(1), normCoordinates_Red(2));
    
    % Convert to real-world coordinates in meters
    realXworld = zOffset * normCoordinates_Red(2);
    realYworld = zOffset * -normCoordinates_Red(1);
    
    % Print and store real-world coordinates for red in centimeters
    % fprintf('Red Real-World Coordinates (cm): (%.2f, %.2f)\n', realXworld, realYworld);
    
    % Account for the camera offset in the X direction
    realX = -realXworld + cameraOffset(1);  % Add the camera offset in X
    realY = realYworld ;  % Add the camera offset in X
end
