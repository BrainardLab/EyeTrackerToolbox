function startRecording(obj)
% startRecording
%
% Description:
% Starts the recording process on the EyeLink computer.

if obj.IsOpen
	% Open up the EDF file on the EyeLink computer if specified.
	if obj.UseEDFFile
		mglPrivateEyelinkEDFOpen('data.edf');
	end
	
	mglEyelinkRecordingStart('file-sample', 'link-sample', 'file-event', 'link-event');
else
	error('Can''t start recording until connected the EyeLink computer.');
end
