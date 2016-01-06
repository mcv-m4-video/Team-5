clc
close all
clearvars

%Change the gt and results folder
resultFolder = './Results Change Detection/';
gtFolder = './Highway/groundtruth/';

%200 A and 200 B
numberofEvaluatedResults = 200;

segmentationType = 'A';
f1resultsfordsynA = zeros(1,26);
for shift = 0:1:25
    f1resultsfordsynA(shift+1) = calculatemeanf1(resultFolder, gtFolder, segmentationType, numberofEvaluatedResults, shift);
end

segmentationType = 'B';
f1resultsfordsynB = zeros(1,26);
for shift = 0:1:25
    f1resultsfordsynB(shift+1) = calculatemeanf1(resultFolder, gtFolder, segmentationType, numberofEvaluatedResults, shift);
end



h1 = figure;
plot(0:25,f1resultsfordsynA)
ylim([0 1])
title('F1 Score of A with Desynchronized Frames')
xlabel('#desyncs frames')
ylabel('F1 score')
saveas(h1, 'F1 Score of A with Desynchronized Frames', 'jpg')

h2 = figure;
plot(0:25,f1resultsfordsynB)
ylim([0 1])
title('F1 Score of B with Desynchronized Frames')
xlabel('#desyncs frames')
ylabel('F1 score')
saveas(h2, 'F1 Score of B with Desynchronized Frames', 'jpg')