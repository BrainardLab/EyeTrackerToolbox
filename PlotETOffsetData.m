function PlotETOffsetData(fileName)

if nargin ~= 1
	error('Usage: PlotETOffsetData(fileName)');
end

if ~exist(fileName, 'file')
	error('Cannot find "%s".', fileName);
end

load(fileName);

numPos = length(data);

figure;

for i = 1:numPos
	hold on;
	
	% Plot our targets.
	plot(data(i).targetPos(1), data(i).targetPos(2), 'rx');
	
	% Plot our gaze.
	plot(data(i).gaze(1), data(i).gaze(2), 'go');
	
	% Make a line connecting the 2 points.
	x = [data(i).targetPos(1), data(i).gaze(1)];
	y = [data(i).targetPos(2), data(i).gaze(2)];
	plot(x, y);
end

axis([-20 20 -15 15]);
