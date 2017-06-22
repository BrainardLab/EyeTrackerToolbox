function abort(obj)
% abort
%
% Description:
% Shuts down all connections with the EyeLink PC.  Useful for error
% situations where you want to call just a single line of code to terminate
% everything.

obj.stopRecording;
obj.goOffline;
obj.disconnect;
