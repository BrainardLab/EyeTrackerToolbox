classdef EyeTracker < handle
    % EyeLink eye tracker class.
    %
    % EyeTracker Properties:
    % CalibrationType - Type of calibration to run.
	% EDFFileName - The name of the output EDF file.
	% Gaze - The gaze of the eye in centimeter screen coordinates.
    % TargetScreenID - The MGL ID of the target screen.
    % BackgroundColor - RGB value of the calibration background.
    % RecordingState - The recording state of the eye tracker.
    %
    % EyeTracker Methods:
	% EyeTracker - Constructor
    % abort - Shuts down all connections with the eye tracker.
    % getEDFFile - Gets the EDF file from the eye tracker.
	% 
	% EyeTracker Static Methods:
	% px2cm - Converts eye coordinates in pixels to centimeters.
    
	properties
		EyeLinkIPAddress = '100.1.1.1';
		CalibrationType = 'HV9';
		EnableAutomaticCalibration = 'NO';
		AutomaticCalibrationPacing = 1000;
		DriftCorrectCRDisable = 'OFF';
		LinkEventFilter = 'RIGHT,FIXATION,SACCADE,BLINK';
		LinkSampleData = 'RIGHT,GAZE,STATUS';
		SampleRate = 1000;
		
		% Background color used during the calibration.
		BackgroundColor = [0 0 0];
		
		% Screen resolution.
		ScreenPixelCoords;
		
		% Correction for fixation drift. (x,y)
		ScreenFixationDrift = [0 0];
		
		% The display ID of the stimulus computer.
		TargetScreenID = 2;
		
		% Calibration target colors.
		TargetOuterRGB = [0.8 0.8 0.8];
		TargetInnerRGB = [1 0 0];
	end
	
	properties (Dependent = true)
		% EDF filename.
		EDFFileName;
	end
	
	properties (SetAccess = protected)
		IsOpen;
		
		% Current gaze position of the observer.
		Gaze = [0 0];
		
		% Screen dimensions in centimeters.
		ScreenWidth;
		ScreenHeight;
		
		% Indicates if an EDF file will be used.
		UseEDFFile = false;
		
		% The recording state of the eye tracker.
		RecordingState;
	end
	
	% Private properties that are used to store the value for dependent
	% properties.
	properties (Access = protected)
		P_EDFFileName;
	end
	
	methods
		function obj = EyeTracker(screenWidth, screenHeight, EDFFileName)
            % obj = EyeTracker(screenWidth, screenHeight, [EDFFileName])
            %
            % Description:
            % Creates an EyeTracker object.
            
			if nargin < 2 || nargin > 3
				error('Usage: EyeTracker(screenWidth, screenHeight, [EDFFileName]');
			end
			
			obj.ScreenWidth = screenWidth;
			obj.ScreenHeight = screenHeight;
			
			% Set the EDF filename if it was passed.  Otherwise, we'll
			% toggle that no EDF file is to be used.
			if nargin == 3
				obj.EDFFileName = EDFFileName;
			end
		end
		
		% This functions shuts down all connection to the EyeTracker.
		% Useful for error situations.
		abort(obj)
		
		% Connects to the eye tracker and runs the basic setup/calibration.
		initialize(obj)
		
		% Connects to the EyeLink computer.
		connect(obj)
		
		% Disconnects from the EyeLink computer.
		disconnect(obj)
		
		% Runs the calibration/setup routine for the eye tracker.
		calibrate(obj)
		
		% Starts the EyeLink recording.
		startRecording(obj)
		
		% Stops the EyeLink recording.
		stopRecording(obj)
		
		% Puts the EyeLink if offline (idle) mode.
		goOffline(obj)
		
		% Gets the EDF file from the eye tracker.
		getEDFFile(obj, fileDestination)
		
		[gaze, time] = getGazeAndTime(obj)
		
		% Closes any open EDF files.
		closeEDFFile(obj)
		
		% Sends a command to the eye tracker computer.
		print(obj, command)
        
        % Writes a message into the EDF file while recording.
        writeEDFMessage(obj, msg)
	end
	
	methods (Static = true)
		% Returns the connection status of the eye tracker.
		connectionStatus = isConnected
	end
	
	% Property set/get overrides.
	methods
		% EDFFileName
		function set.EDFFileName(obj, fileName)
			% Make sure we're not recording when we set the filename.
			assert(obj.RecordingState ~= 1, 'EyeTracker:EDFFileName:RecordingState', ...
				'Cannot set the file name while recording.');
			
			obj.P_EDFFileName = fileName;
			obj.UseEDFFile = true;
			
			% Make sure there's a .edf suffix on the filename.
			[~, ~, ext] = fileparts(obj.EDFFileName);
			if isempty(ext)
				obj.P_EDFFileName = strcat(obj.EDFFileName, '.edf');
			end
		end
		function fileName = get.EDFFileName(obj)
			fileName = obj.P_EDFFileName;
		end
		
		% Returns the location of the subject's gaze.
		function eyePosition = get.Gaze(obj)
			if obj.IsOpen
				% Get the eye position in eye tracker coordinates.
				eyePosition = mglEyelinkGetCurrentEyePos(0);
				
				% Convert them to our coordinates.
				eyePosition = EyeTracker.px2cm(eyePosition, obj.ScreenPixelCoords, ...
					[obj.ScreenWidth obj.ScreenHeight]);
				
				% Subtract off the screen fixation drift.
				eyePosition = eyePosition - obj.ScreenFixationDrift;
			else
				eyePosition = [];
			end
		end
		
		% Returns whether there is an open eye tracker connection.
		function isOpen = get.IsOpen(obj) %#ok<MANU>
			if EyeTracker.isConnected ~= 0
				isOpen = true;
			else
				isOpen = false;
			end
		end
		
		function rState = get.RecordingState(obj)
			if obj.IsOpen
				if mglEyelinkRecordingCheck == 0
					rState = 1;
				else
					rState = 0;
				end
			else
				rState = -1;
			end
		end
    end
    
    methods (Static = true)
        function data = readEDFFile(dataFile)
			% readEDFFile - Returns the data from within an EDF file.
			%
			% Syntax:
			% data = readEDFFile(dataFile)
			%
			% Input:
			% dataFile (string) - Name of the EDF file to load.
			%
			% Output:
			% data (struct) - Data structure containing EDF file data.
			
			data = mglEyelinkEDFRead(dataFile);
		end
		
		function cmCoords = px2cm(pxCoords, screenDimsPx, screenDimsCm)
			% px2cm - Converts gaze in pixels to centimeters.
			%
			% Syntax:
			% cmCoords = px2cm(pxCoords, screenDimsPx, screenDimsCm)
			%
			% Input:
			% pxCoords (Mx2) - Eye pixel coordinates from the eye tracker.
			% screenDimsPx (1x2) - Screen dimensions in pixels.
			% screenDimsCm (1x2) - Screen dimensions in centimeters.
			%
			% Output:
			% cmCoords (Mx2) - Eye coordinates in centimeters.
			
			if nargin ~= 3
				error('Usage: EyeTracker.px2cm(pxCoords, screenDimsPx, screenDimsCm)');
			end
			
			cmCoords = zeros(size(pxCoords));
			cmCoords(:,1) = pxCoords(:,1) * screenDimsCm(1) / screenDimsPx(1) - screenDimsCm(1)/2;
			cmCoords(:,2) = screenDimsCm(2)/2 - pxCoords(:,2) * screenDimsCm(2) / screenDimsPx(2);
		end
    end
end
