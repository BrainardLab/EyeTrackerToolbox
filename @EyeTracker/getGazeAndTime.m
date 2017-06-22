function [eyePosition, time] = getGazeAndTime(obj)
% getGazeAndTime - Gets the current gaze plus its time stamp.
%
% Syntax:
% [eyePosition, time] = obj.getGazeAndTime
%
% Output:
% eyePosition (1x2) - (x,y) position of the eye in the coordinates specified by
%   the properties ScreenWidth and ScreenHeight.  Empty if the eye tracker
%   isn't open, NaN if no eye position is available.
% time (scalar) - Time stamp of the eye position from the eye tracker.
%   Empty if the eye tracker isn't open, NaN if no eye position is
%   available.

error(nargchk(1, 1, nargin));

if obj.IsOpen
	% Get the eye position in eye tracker coordinates.
	[eyePosition, time] = mglEyelinkGetCurrentEyePos(0);
	
	% Convert them to our coordinates.  Don't bother converting if we
	% didn't get a valid eye position back.
	if ~isnan(time)
		eyePosition = EyeTracker.px2cm(eyePosition, obj.ScreenPixelCoords, ...
			[obj.ScreenWidth obj.ScreenHeight]);
		
		% Subtract off the screen fixation drift.
		eyePosition = eyePosition - obj.ScreenFixationDrift;
	end
else
	eyePosition = [];
	time = [];
end
