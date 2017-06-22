function writeEDFMessage(obj, msg)
% writeEDFMessage(msg)
%
% Description:
% Writes a message into the EDF file during recording.  Messages are
% timestamped by the EyeLink computer.
%
% Input:
% msg (string) - The message to write.

if nargin ~= 2
    error('Usage: writeEDFMessage(msg)');
end

% Make sure we're connected to the eye tracker.
if ~obj.IsOpen
    error('Please connect to the eye tracker.');
end

% Make sure we're actually recording.
if obj.RecordingState ~= 1
    error('Recording must be started before sending EDF messages.');
end

mglEyelinkEDFPrintF(msg);
