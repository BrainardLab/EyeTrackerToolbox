function calibrate(obj)
% calibrate
%
% Description:
% Runs the calibration/setup of the eye tracker.  Must be done before
% running an experiment.

if obj.IsOpen
	mglClearScreen(obj.BackgroundColor);
	mglFlush;
	
	% Setup the calibration target parameters.
	targetParams.outerRGB = obj.TargetOuterRGB;
	targetParams.innerRGB = obj.TargetInnerRGB;
	
	mglEyelinkSetup([], targetParams);
else
	error('EyeLink connection needs to be established.');
end
