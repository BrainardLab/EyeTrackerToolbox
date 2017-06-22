function connect(obj)
% connect
%
% Description:
% Opens a connection the EyeLink computer.  Errors if a connection cannot
% be established.

% Don't do anything if already connected.
if ~obj.IsOpen
	mglEyelinkOpen(obj.EyeLinkIPAddress, 0);
	
	if ~obj.IsOpen
		error('Failed to connect to the EyeLink system.');
	end
end
