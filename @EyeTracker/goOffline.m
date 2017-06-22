function goOffline(obj)
% goOffline
%
% Description:
% Puts the EyeLink if offline (idle) mode.  If the eye tracker is already
% offline, this function doesn't do anything.

if obj.IsOpen
	mglEyelinkGoOffline;
end
