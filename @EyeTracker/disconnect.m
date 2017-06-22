function disconnect(obj)
% disconnect
%
% Description:
% Disconnects from the EyeTracker PC.  Does nothing if we're not connected.

if obj.IsOpen
	mglEyelinkClose;
end
