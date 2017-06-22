function print(obj, command)
% print(command)
%
% Description:
% Sends a command to the EyeLink computer.
%
% Input:
% command (string) - Command string to send to the EyeLink computer.

if nargin ~= 2
	error('Usage: print(command)');
end

% Make sure the input is a string.
if ~ischar(command)
	error('"command" must be a string.');
end	

if ~obj.IsOpen
	error('No connection to the EyeLink PC.');
end

fprintf('- Sending: %s\n', command);

mglEyelinkCMDPrintF(command);
