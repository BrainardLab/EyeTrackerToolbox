function getEDFFile(obj, fileDestination)
% getEDFFile([fileDestination])
%
% Description:
% Gets the EDF file stored on the EyeLink PC and stores it on the local
% computer.  This function doesn't do anything unless and EDF file was
% specified in the constructor.
%
% Optional Input:
% fileDestination (string) - The folder where the EDF file should be saved.
%   Defaults to the current directory.

if nargin < 1 || nargin > 2
	error('Usage: getEDFFile([fileDestination])');
end

% Don't do anything unless an EDF file was specified.
if obj.UseEDFFile
	if nargin ~= 2
		fileDestination = sprintf('.%s', filesep);
	else
		% Make sure there's a file separator and the end of
		% the file destination.
		if fileDestination(end) ~= filesep
			fileDestination(end+1) = filesep;
		end
	end
	
	% Put the file in a temporary location, then we'll move it
	% with the requested name to its final location.  We do this
	% because of name size limitations on the EyeLink computer
	% end.
	mglEyelinkEDFGetFile('data.edf', '/tmp/');
	
	outputFileName = sprintf('%s%s', fileDestination, obj.EDFFileName);
	system(sprintf('mv /tmp/data.edf %s', outputFileName));
end
