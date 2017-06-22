function initialize(obj)
% initialize
%
% Description:
% Initializes the eye tracker by sending over calibration, screen, and
% recording parameters, and then runs the calibration routine.

% Get the screen dimensions in pixels.
mglSwitchDisplay(obj.TargetScreenID);
mglOpen;
mglScreenCoordinates;
mglClearScreen([0 0 0]);
obj.ScreenPixelCoords = [mglGetParam('screenWidth'), mglGetParam('screenHeight')];

% Set up some variables.
obj.print(sprintf('screen_pixel_coords = 0 0 %d %d', obj.ScreenPixelCoords(1), obj.ScreenPixelCoords(2)));

% Calibration: change to HV9 for better calibration, HV3 for faster;
% Automatic calibration is generally desirable, and the pacing is probably best at 1500,
% though 1000 might work if that's too slow.
obj.print(sprintf('calibration_type = %s', obj.CalibrationType));
obj.print(sprintf('enable_automatic_calibration %s', obj.EnableAutomaticCalibration));
obj.print(sprintf('automatic_calibration_pacing = %d', obj.AutomaticCalibrationPacing));
obj.print(sprintf('driftcorrect_cr_disable = %s', obj.DriftCorrectCRDisable));

% What gets sent through the link...
obj.print(sprintf('link_event_filter = %s', obj.LinkEventFilter));
obj.print(sprintf('link_sample_data = %s', obj.LinkSampleData));
obj.print(sprintf('sample_rate = %d', obj.SampleRate));

% Run the calibration.
obj.calibrate;
