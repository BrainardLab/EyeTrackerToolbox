function connectionStatus = isConnected
% connectionStatus = isConnected
%
% Description:
% Returns the connection status of the eye tracker.
%
% Output:
% connectionStatus (scalar) - Make take any of the following values
%   0 if link closed.
%   -1 if simulating connection.
%   1 for normal connection. 
%   2 for broadcast connection (NEW for v2.1 and later).

% Make sure the output is getting used.
if nargout ~= 1
	error('Output must be assigned to a variable.');
end

connectionStatus = mglEyelinkIsConnected;
