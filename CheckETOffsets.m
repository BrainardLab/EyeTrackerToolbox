function CheckETOffsets
% CheckETOffsets
%
% Description:
% Displays a set of targets on the screen for the purpose of seeing what
% sort of offset the eye tracker produces for different areas of the
% display.  When the experimenter feels the subject is fixating on a given
% target, they should press the 't' key to record the current eye gaze and
% target location.  This data is saved into a file called 'ETOffsets.mat'
% in the current working directory.

try
	UseClassesDev; 
	ClockRandSeed;
	
	screenDims = [38.8 30];
	edfFile = 'oc.edf';
	bgRGB = [1 1 1] * 0;

	% Create the EyeTracker object.
	et = EyeTracker(screenDims(1), screenDims(2), edfFile);
	
	et.CalibrationType = 'HV13';
	
	% Create our GLWindow object.
	win = GLWindow('SceneDimensions', screenDims, 'BackgroundColor', bgRGB);
	
	% Add our target and eye cursor.
	win.addCross([0 0], [1 1], [1 1 1], 'Name', 'target');
	%win.addOval([0 0], [0.25 0.25], [1 0 0], 'Name', 'eye');
	
	% Open our window and then run the calibration.
	win.open;
	et.connect;
	et.initialize;

	% List of positions we'll test.
	targetPos = [0 0
				 0 10
				 0 -10
				 -10 0
				 10 0
				 -10 10
				 10 10
				 -10 -10
				 10 -10
				 0 5
				 0 -5
				 -5 0
				 5 0
				 -5 5
				 5 5
				 -5 -5
				 5 -5];
	numPos = size(targetPos, 1);
	
	% Start recording the eye positions.
	et.startRecording;
	
	% Clear our character queue.
	mglGetKeyEvent;
	
	% Loop over the list of target positions randomly.
	randomI = Shuffle(1:numPos);
	for i = randomI
		% Update our target's position.
		win.setObjectProperty('target', 'Center', targetPos(i,:));
		
		everForward = true;
		while everForward
			% Grab the current gaze.
			gaze = et.Gaze;
			
			% Check our character queue.
			key = mglGetKeyEvent;
			if ~isempty(key)
				switch key.charCode
					case 'q'
						error('Abort');
						
					case 't'
						data(i).gaze = gaze; %#ok<*AGROW>
						data(i).targetPos = targetPos(i,:);
						everForward = false;
				end
			end
			
			% Update the eye cursor's position.
		%	win.setObjectProperty('eye', 'Center', gaze);
			
			win.draw;
		end
	end
	
	% Stop recording and grab the EDF file.
	et.stopRecording;
	et.goOffline;
	et.getEDFFile;
	et.disconnect;
	
	% Close the window.
	win.close;
	
	% Save the data file.
	save('ETOffsets.mat', 'data');
catch e
	if exist('et', 'var');
		et.abort;
	end
	
	if exist('win', 'var');
		win.close;
	end
	
	switch e.message
		case 'Abort'
			fprintf('*** Aborting program ***\n');
			
		otherwise
			rethrow(e);
	end
end
