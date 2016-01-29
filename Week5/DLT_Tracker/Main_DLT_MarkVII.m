function Main_DLT_MarkVII

% Final code

%% p = [px, py, sx, sy, theta]; The location of the target in the first
% frame.
% px and py are th coordinates of the centre of the box
% sx and sy are the size of the box in the x (width) and y (height)
%   dimensions, before rotation
% theta is the rotation angle of the box
%
% 'numsample',1000,   The number of samples used in the condensation
% algorithm/particle filter.  Increasing this will likely improve the
% results, but make the tracker slower.
%
% 'condenssig',0.01,  The standard deviation of the observation likelihood.
%
% 'affsig',[4,4,.02,.02,.005,.001]  These are the standard deviations of
% the dynamics distribution, that is how much we expect the target
% object might move from one frame to the next.  The meaning of each
% number is as follows:
%    affsig(1) = x translation (pixels, mean is 0)
%    affsig(2) = y translation (pixels, mean is 0)
%    affsig(3) = x & y scaling
%    affsig(4) = rotation angle
%    affsig(5) = aspect ratio
%    affsig(6) = skew angle
% clear all

%% Parameters
dbstop if error
% dbstop at 266
addpath('affineUtility');
addpath('drawUtility');
addpath('imageUtility');
addpath('NN');

dataPath = '../Datasets/';
titleName = 'Highway_Results';

p = [122 142 38 100 0.0];
opt = struct('numsample',1000, 'affsig',[4, 4, 0.05, 0.0, 0.01, 0.000]);

% The number of previous frames used as positive samples.
opt.maxbasis = 10;
opt.updateThres = 0.8;
% Indicate whether to use GPU in computation.
global useGpu;
useGpu = false;
opt.condenssig = 0.01;
opt.tmplsize = [32, 32];
opt.normalWidth = 320;
opt.normalHeight = 240;
seq.init_rect = [p(1) - p(3) / 2, p(2) - p(4) / 2, p(3), p(4), p(5)];

%% Load data
disp('Loading data...');
fullPath = [dataPath, titleName, '/img_04_13_FullMarkV/'];
fullPathRGB = '../../../../Datasets/highway/input/';
fid = fopen('Data_img_04_13_FullMarkV.txt', 'a+');

d = dir([fullPath, '*.jpg']);
if size(d, 1) == 0
    d = dir([fullPath, '*.png']);
end
if size(d, 1) == 0
    d = dir([fullPath, '*.bmp']);
end

im = imread([fullPath, d(1).name]);
data = zeros(size(im, 1), size(im, 2), size(d, 1));
scaleHeight = size(im, 1) / opt.normalHeight;
scaleWidth = size(im, 2) / opt.normalWidth;

seq.s_frames = cell(100, 1);
seq.Tracks = cell(100, 1);

RoI = zeros(size(im));
RoI([1:20,end-20:end],:) = 1;
TracksData = [];
TracksData.reportRes = [];
TracksData.CentriodX = [];
TracksData.CentriodY = [];
TracksData.ConfidFramewise = [];
TCount = 0;


TracksList = [];
TracksListN = [];
for i = 1:150 %1 : size(d, 1)
    seq.s_frames{i} = imread([fullPath, d(i).name]) > 127;
    seq.s_framesOrig{i} = seq.s_frames{i};
    seq.RGB_frames{i} = imread([fullPathRGB, 'in' sprintf('%0.6d', i+850) '.jpg']);
    CCD = bwconncomp(seq.s_frames{i});
    seq.Tracks{i} = CCD;
    
    if(i == 5)
        qq = 1;
    end
    
    % remove small objects
    for j = 1:CCD.NumObjects
        if(length(CCD.PixelIdxList{j}) < 80)
            qq =1;
            seq.s_frames{i}(CCD.PixelIdxList{j}) = 0;
        end
    end
    
    
    %     Centriods = [seq.Objs.Centroid;];
    %     CentriodsX = Centriods(1:2:end);
    %     CentriodsY = Centriods(2:2:end);
    %
    frame = double(rgb2gray(seq.RGB_frames{i}));
    
    figure(1);imshow(frame./255); hold on
    text(5, 18, num2str(i), 'Color','y', 'FontWeight','bold', 'FontSize',18);
    
    % check only in the RoI
    [r, c] = find(RoI == 0);
    seq.s_frames{i} = bwselect(seq.s_frames{i},c,r,4);
    seq.Objs = regionprops(seq.s_frames{i});
    
    fprintf(fid, '\n\nFrame Number : %d \n', i);
    fprintf(fid, 'Tracking car index: ');
    fprintf('\n\nFrame Number : %d \n', i);
    fprintf('Tracking car index: ');
    
    
    %% check whether there is any new object
    if(i ~= 1)
        % check whether objcts are same as previous one or not
        [r, c] = find(seq.s_frames{i-1} == 1);
        BW21 = bwselect(seq.s_frames{i},c,r,4);
        BW22 = seq.s_frames{i} - BW21 > 0;
        
        % if any new object add this object into track and run the code
        CCDN.Objs = regionprops(BW22);
        
        if(~isempty(CCDN))
            for j = 1:length(CCDN.Objs)
                CCDN = NewTrackDataExtraction(CCDN, frame, j, opt, fid);
                CCDN.Objs(j).ConfidFramewise = [];
                CCDN.Objs(j).CentriodX = [];
                CCDN.Objs(j).CentriodY = [];
                CCDN.Objs(j).neg = [];
                
                TracksData(TCount).ConfidFramewise = [];
                TracksData(TCount).CentriodX = [];
                TracksData(TCount).CentriodY = [];
                TracksData(TCount).neg = [];
                TracksData(TCount).tmpl.mean = [];
                TracksData(TCount).tmpl.basis = [];
                TracksData(TCount).param.est = [];
                TracksData(TCount).param.lastUpdate = [];
                
                TracksData(TCount).Area = CCDN.Objs(j).Area;
                TracksData(TCount).BoundingBox = CCDN.Objs(j).BoundingBox;
                TracksData(TCount).CentriodX = CCDN.Objs(j).CentriodX;
                TracksData(TCount).CentriodY = CCDN.Objs(j).CentriodY;
                TracksData(TCount).Centroid = CCDN.Objs(j).Centroid;
                TracksData(TCount).ConfidFramewise = CCDN.Objs(j).ConfidFramewise;
                TracksData(TCount).Continue = CCDN.Objs(j).Continue;
                TracksData(TCount).neg = CCDN.Objs(j).neg;
                TracksData(TCount).nn = CCDN.Objs(j).nn;
                TracksData(TCount).param = CCDN.Objs(j).param;
                TracksData(TCount).param0 = CCDN.Objs(j).param0;
                TracksData(TCount).paramOld = CCDN.Objs(j).paramOld;
                TracksData(TCount).pos = CCDN.Objs(j).pos;
                TracksData(TCount).reportRes = CCDN.Objs(j).reportRes;
                TracksData(TCount).tmpl = CCDN.Objs(j).tmpl;                
                % TracksData(TCount) = CCDN.Objs(j);
                TCount = TCount + 1;
            end
        end
        
        %         figure;imshow(RoI); hold on; title('RoI'); hold off
        %         figure;imshow(seq.s_frames{i-1}); hold on; title('Previous frame after removing noise'); hold off
        %         figure;imshow(seq.s_frames{i}); hold on;  title('Present frame after removing noise'); hold off
        %         figure;imshow(BW2);  hold on; title('Objects which are in present frame'); hold off
        %
    end
    
    %% update track list
    
    for j = 1:TCount-1
        if(TracksData(j).Continue)
            TracksListN(j) = j;
        else
            TracksListN(j) = 0;
        end
    end
    TracksListN(TracksListN == 0) = [];
    TracksList = TracksListN;
    if(i == 1 )
        for j = 1:length(seq.Objs)
            seq.Objs(j).paramOld = [seq.Objs(j).Centroid(1), seq.Objs(j).Centroid(2),...
                seq.Objs(j).BoundingBox(3)/opt.tmplsize(2), 0, seq.Objs(j).BoundingBox(4) ...
                /seq.Objs(j).BoundingBox(3) / (opt.tmplsize(1) / opt.tmplsize(2)), 0];
            
            seq.Objs(j).param0 = affparam2mat(seq.Objs(j).paramOld);
            
            reportRes = [];
            seq.Objs(j).tmpl.mean = warpimg(frame, seq.Objs(j).param0, opt.tmplsize);
            seq.Objs(j).tmpl.basis = [];
            
            % Sample 10 positive templates for initialization
            for k = 1 : opt.maxbasis / 10
                seq.Objs(j).tmpl.basis(:, (k - 1) * 10 + 1 : k * 10) = ...
                    samplePos_DLT(frame, seq.Objs(j).param0, opt.tmplsize);
            end
            
            % Sample 100 negative templates for initialization
            p0 = seq.Objs(j).paramOld(5);
            seq.Objs(j).tmpl.basis(:, opt.maxbasis + 1 : 100 + opt.maxbasis) = ...
                sampleNeg(frame, seq.Objs(j).param0, opt.tmplsize, 100, opt, 8);
            
            seq.Objs(j).param.est = seq.Objs(j).param0;
            seq.Objs(j).param.lastUpdate = 1;
            
            duration = 0;
            if (exist('dispstr','var'))  dispstr='';  end
            L = [ones(opt.maxbasis, 1); (-1) * ones(100, 1)];
            
            seq.Objs(j).nn = initDLT(seq.Objs(j).tmpl, L);
            L = [];
            
            seq.Objs(j).pos = seq.Objs(j).tmpl.basis(:, 1 : opt.maxbasis);
            seq.Objs(j).pos(:, opt.maxbasis + 1) = seq.Objs(j).tmpl.basis(:, 1);
            seq.Objs(j).reportRes = [];
            opts.numepochs = 5;
            drawbox(j, [], opt.tmplsize, seq.Objs(j).param.est, 'Color','r', 'LineWidth',2.5);
            fprintf(fid, '%d\t', j);
            fprintf('%d\t', j);
            pause(0.1);
            seq.Objs(j).Continue = 1;
        end
        TracksData = seq.Objs;
        TracksList = 1:length(TracksData);
        TCount = length(TracksData) + 1;
    else
        for j = TracksList
            
            % do tracking
            TracksData(j).param = estwarp_condens_DLT(frame, TracksData(j).tmpl, TracksData(j).param, opt, TracksData(j).nn, i);
            
            % do update
            temp = warpimg(frame, TracksData(j).param.est', opt.tmplsize);
            TracksData(j).pos(:, mod(i - 1, opt.maxbasis) + 1) = temp(:);
            if  TracksData(j).param.update
                opts.batchsize = 10;
                % Sample two set of negative samples at different range.
                TracksData(j).neg = sampleNeg(frame, TracksData(j).param.est', opt.tmplsize, 49, opt, 8);
                TracksData(j).neg = [TracksData(j).neg sampleNeg(frame, ...
                    TracksData(j).param.est', opt.tmplsize, 50, opt, 4)];
                TracksData(j).nn = nntrain(TracksData(j).nn, [TracksData(j).pos TracksData(j).neg]',...
                    [ones(opt.maxbasis + 1, 1); zeros(99, 1)], opts);
            end
            
            duration = duration + toc;
            
            res = affparam2geom(TracksData(j).param.est);
            p(1) = round(res(1));
            p(2) = round(res(2));
            p(3) = round(res(3) * opt.tmplsize(2));
            p(4) = round(res(5) * (opt.tmplsize(1) / opt.tmplsize(2)) * p(3));
            p(5) = res(4);
            p(1) = p(1) * scaleWidth;
            p(3) = p(3) * scaleWidth;
            p(2) = p(2) * scaleHeight;
            p(4) = p(4) * scaleHeight;
            paramOld = [p(1), p(2), p(3)/opt.tmplsize(2), p(5), p(4) /p(3) / (opt.tmplsize(1) / opt.tmplsize(2)), 0];
            
            TracksData(j).reportRes = [TracksData(j).reportRes;  affparam2mat(paramOld)];
            
            TracksData(j).tmpl.basis = [TracksData(j).pos];
            
            if(TracksData(j).param.confidence < 0.3)
                qq = 1;
            end
            
            TracksData(j).ConfidFramewise(i) = max(TracksData(j).param.confidence);
            
            TracksData(j).CentriodX(i) = TracksData(j).param.est(1);
            TracksData(j).CentriodY(i) = TracksData(j).param.est(2);
            
            if(abs(TracksData(j).param.est(2) - size(frame,1)) < 40) % || ...
                %                     abs(TracksData(j).param.est(1) - size(frame,1)) < 20)
                TracksData(j).Continue = 0;
                qq = 1;
                fprintf(fid, '\nJARVIS: Boss we lost one car, Car Index : %d\n', j);
                fprintf(fid, 'Tracking car index: ');
                fprintf('\nJARVIS: Boss we lost one car, Car Index : %d\n', j);
                fprintf('Tracking car index: ');
            end
            
            drawbox(j, [], opt.tmplsize, TracksData(j).param.est, 'Color','r', 'LineWidth',2.5);
            fprintf(fid, '%d\t', j);
            fprintf('%d\t', j);
            pause(0.1);
            
            
            
            if(i == 10)
                qq = 1;
            end
            
        end
    end
    saveas(gcf, ['Results\img_04_13_FullMarkV\Output_' sprintf('%0.6d', i) '.jpg']);
    clf;
end

fclose(fid);
end

function UpdateNewTrack
detectionToTrackAssignment
end

function [assignments, unassignedTracks, unassignedDetections] = ...
    detectionToTrackAssignment()

nTracks = length(tracks);
nDetections = size(centroids, 1);

% Compute the cost of assigning each detection to each track.
cost = zeros(nTracks, nDetections);
for i = 1:nTracks
    cost(i, :) = distance(tracks(i).kalmanFilter, centroids);
end

% Solve the assignment problem.
costOfNonAssignment = 20;
[assignments, unassignedTracks, unassignedDetections] = ...
    assignDetectionsToTracks(cost, costOfNonAssignment);
end

function seq = NewTrackDataExtraction(seq, frame, j, opt, fid)

seq.Objs(j).paramOld = [seq.Objs(j).Centroid(1), seq.Objs(j).Centroid(2),...
    seq.Objs(j).BoundingBox(3)/opt.tmplsize(2), 0, seq.Objs(j).BoundingBox(4) ...
    /seq.Objs(j).BoundingBox(3) / (opt.tmplsize(1) / opt.tmplsize(2)), 0];

seq.Objs(j).param0 = affparam2mat(seq.Objs(j).paramOld);

reportRes = [];
seq.Objs(j).tmpl.mean = warpimg(frame, seq.Objs(j).param0, opt.tmplsize);
seq.Objs(j).tmpl.basis = [];

% Sample 10 positive templates for initialization
for k = 1 : opt.maxbasis / 10
    seq.Objs(j).tmpl.basis(:, (k - 1) * 10 + 1 : k * 10) = ...
        samplePos_DLT(frame, seq.Objs(j).param0, opt.tmplsize);
end

% Sample 100 negative templates for initialization
p0 = seq.Objs(j).paramOld(5);
seq.Objs(j).tmpl.basis(:, opt.maxbasis + 1 : 100 + opt.maxbasis) = ...
    sampleNeg(frame, seq.Objs(j).param0, opt.tmplsize, 100, opt, 8);

seq.Objs(j).param.est = seq.Objs(j).param0;
seq.Objs(j).param.lastUpdate = 1;

duration = 0;
if (exist('dispstr','var'))  dispstr='';  end
L = [ones(opt.maxbasis, 1); (-1) * ones(100, 1)];

seq.Objs(j).nn = initDLT(seq.Objs(j).tmpl, L);
L = [];

seq.Objs(j).pos = seq.Objs(j).tmpl.basis(:, 1 : opt.maxbasis);
seq.Objs(j).pos(:, opt.maxbasis + 1) = seq.Objs(j).tmpl.basis(:, 1);
seq.Objs(j).reportRes = [];
opts.numepochs = 5;
drawbox(j, 'New object', opt.tmplsize, seq.Objs(j).param.est, 'Color','g', 'LineWidth',2.5);
fprintf(fid, 'JARVIS : Boss I found one new carrrrrr, Car Index : %d', j);
fprintf(fid, '\nTracking car index: ');
fprintf('JARVIS : Boss I found one new carrrrrr, Car Index : %d', j);
fprintf('\nTracking car index: ');
pause(0.1);
seq.Objs(j).Continue = 1;
end