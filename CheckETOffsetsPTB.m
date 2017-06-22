function CheckETOffsetsPTB

try
	InitializeMatlabOpenGL;
	UseClassesDev; 
	ClockRandSeed;
	
	screenDims = [38.8 30];
	edfFile = 'oc.edf';
	bgRGB = [1 1 1] * 0;
	
	% Open the display.
	screenNumber = max(Screen('Screens'));
    window = Screen('OpenWindow', screenNumber);
	
	% Provide Eyelink with details about the graphics environment
    % and perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).
    el=EyelinkInitDefaults(window);
	
	% Initialization of the connection with the Eyelink Gazetracker.
	% exit program if this fails.
	if ~EyelinkInit(0, 1)
		error('Eyelink Init aborted.\n');
	end
	
	[~, vs]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );
    
    % make sure that we get gaze data from the Eyelink
    Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
    
    % open file to record data to
    %Eyelink('Openfile', edfFile);
	
	% Calibrate the eye tracker
    EyelinkDoTrackerSetup(el);

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
	
	% start recording eye position
    Eyelink('StartRecording');
	
	eye_used = Eyelink('EyeAvailable');
	
	Screen('ColorRange', el.window, 1);
	
	[px, py] = Screen('WindowSize', el.window);
	
	Screen('BeginOpenGL', el.window, 1);
	HDRInitOpenGL(screenDims(1), screenDims(2));
	glClearColor(bgRGB(1), bgRGB(2), bgRGB(3), 0);
	glClear;
	Screen('EndOpenGL', el.window);
	
	ListenChar(2);
	FlushEvents;
	
	% Loop over the list of target positions randomly.
	randomI = Shuffle(1:numPos);
	for i = randomI
		everForward = true;
		while everForward
			% Get the sample in the form of an event structure
			evt = Eyelink( 'NewestFloatSample');
			
			% If we do, get current gaze position from sample
			x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
			y = evt.gy(eye_used+1);
			
			% Do we have valid data and is the pupil visible?
			if x ~= el.MISSING_DATA && y ~= el.MISSING_DATA && evt.pa(eye_used+1) > 0
				gaze = [x y];
				gaze(1) = gaze(1) * screenDims(1) / px - screenDims(1)/2;
				gaze(2) = screenDims(2)/2 - gaze(2) * screenDims(2) / py;
			end
			
			% Check our character queue.
			if CharAvail
				switch GetChar;
					case 'q'
						error('Abort');
						
					case 't'
						data(i).gaze = gaze; %#ok<*AGROW>
						data(i).targetPos = targetPos(i,:);
						everForward = false;
				end
			end
			
			% Draw the fixation target.
			Screen('glPoint', el.window, [1 1 1], targetPos(i,1), targetPos(i,2), 5);
			
			Screen('Flip', el.window);
		end
	end
	
	% finish up: stop recording eye-movements,
    % close graphics window, close data file and shut down tracker
    Eyelink('StopRecording');
    Eyelink('CloseFile');
	
	% Shutdown Eyelink:
	Eyelink('Shutdown');
	
	sca;
	
	ListenChar(0);
	
	% Save the data file.
	save('ETOffsets.mat', 'data');
catch e
	% Shutdown Eyelink:
	Eyelink('Shutdown');
	
	sca;
	
	ListenChar(0);
	
	switch e.message
		case 'Abort'
			fprintf('*** Aborting program ***\n');
			
		otherwise
			rethrow(e);
	end
end
