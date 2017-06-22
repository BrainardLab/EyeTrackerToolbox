% EyeTrackingTest.m
%

% make an eye tracking object, with the current screen dimensions
screenDimensions = [51.88085 32.42553];  
et = EyeTracker(screenDimensions(1), screenDimensions(2));

% the info that is picked in the tracking
% has to be defined. 
et.LinkEventFilter = 'RIGHT,FIXATION,SACCADE,BLINK';
et.LinkSampleData = 'RIGHT,GAZE,STATUS';

% Set the calibration target colors.
et.TargetOuterRGB = [1 1 1];
et.TargetInnerRGB = [1 0 0];

% Set the background color of the calibration.
% need to change the background in the calibration to be
% equiluminant to standard background.
et.BackgroundColor = [0 0 0];

% Use the 13 point calibration.
et.CalibrationType = 'HV9';

% Connect to the eye tracker.
et.connect;

% Initialize the eye tracker, i.e. run the setup and send over
% some basic parameters.
et.initialize;

% when you're done disconnect. 
et.disconnect; 

clear all; 