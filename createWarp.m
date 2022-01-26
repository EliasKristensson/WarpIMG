function createWarpData

clc
close all
clear all

global h info data

getInfo
setMainWindow

function getInfo(varargin)
global h info

info.IMG{1}    = [];
info.IMG{2}    = [];
info.warped{1} = [];
info.warped{2} = [];
info.s1        = 2;
info.s2        = 3;
info.gauss     = fspecial('gaussian', 10, 4);
info.gaussVal  = 5;
info.minDiam   = 17;
info.cut       = 0;
info.mask      = [];
info.center    = [1 1];
info.threshold = [1 1];
info.trans     = 'linear conformal';
info.tform     = [];
info.fig_color = [0.3 0.3 0.3];
info.strings.imStr  = '2';
info.strings.numbs  = '1';
info.strings.cut    = '1';
info.strings.transform = ['linear conformal|affine|projective|polynomial|piecewise linear|lwm'];
info.colors     = 'ybgrbygrbygrbygrb';
info.patterns   = '.o*sd.o*sd.o*sd.o*sd';

function reset(varargin)
global h info data

close all
getInfo
setMainWindow

function setMainWindow
global h info

h.main_figure = figure('Color', info.fig_color, 'Units' , 'Normalized', 'Position', [0, 0, 1, 0.97]);%, 'menubar','none');

for i = 10:10:500
    info.strings.cut = [info.strings.cut,'|',num2str(i)];
end

h.reset = uicontrol('Units', 'Normalized', 'Style', 'pushbutton', 'String', 'Reset', 'Position', [0.9 0.1 0.05 0.05], 'Callback', @reset);

h.selTra =  uicontrol('Units', 'Normalized', 'Style', 'popup', 'String', info.strings.transform, 'Position', [0.02 0.9 0.10 0.025], 'Value', 3, 'Callback', @selectTransform);

h.selShape =  uicontrol('Units', 'Normalized', 'Style', 'popup', 'String', 'Square|Circle', 'Position', [0.02 0.87 0.10 0.025], 'Value', 1);

h.slidTh1 = uicontrol('Units', 'Normalized', 'Style', 'slider', 'Min', 0, 'Max', 1,'Value', info.threshold(1), 'Position', [0.18 0.49 0.2 0.05],'Callback', @setThreshMain);

h.slidTh2 = uicontrol('Units', 'Normalized', 'Style', 'slider', 'Min',0,'Max',1,'Value',info.threshold(2), 'Position', [0.18 0.02 0.2 0.05],'Callback', @setThreshSub);

h.valTh1 = uicontrol('Units', 'Normalized', 'Style', 'edit', 'String', [num2str(get(h.slidTh1,'Value'))],'Position', [0.33 0.545 0.05 0.025],'Callback', @setThreshFromText);

h.valTh2 = uicontrol('Units', 'Normalized', 'Style', 'edit', 'String', [num2str(get(h.slidTh2,'Value'))],'Position', [0.33 0.075 0.05 0.025],'Callback', @setThreshFromText);

h.matVar1 = uicontrol('Units', 'Normalized', 'Style', 'edit', 'String', 'F{1}','Position', [0.23 0.545 0.075 0.025]);

h.matVar2 = uicontrol('Units', 'Normalized', 'Style', 'edit', 'String', 'F{2}','Position', [0.23 0.075 0.075 0.025]);

h.mask   = uicontrol('Units', 'Normalized', 'Style', 'pushbutton', 'String', 'Select AOI', 'Position', [0.02 0.81 0.1 0.05], 'Callback', @selAOI);

h.slidDi = uicontrol('Units', 'Normalized', 'Style', 'slider', 'Min',1,'Max',31,'Value',info.minDiam,'Position', [0.02 0.69 0.1 0.05],'Callback', @setDiam);

h.valDi  = uicontrol('Units', 'Normalized', 'Style', 'edit', 'String', ['Min diameter = ', num2str(get(h.slidDi,'Value'))], 'Position', [0.02 0.745 0.1 0.025]);

h.slidGa = uicontrol('Units', 'Normalized', 'Style', 'slider', 'Min',1,'Max',20,'Value',info.gaussVal, 'Position', [0.02 0.59 0.1 0.05],'Callback', @setGauss);

h.dispGa = uicontrol('Units', 'Normalized', 'Style', 'edit', 'String', ['Gaussian kernel = ', num2str(get(h.slidGa,'Value'))], 'Position', [0.02 0.645 0.1 0.025]);

% h.valRep = uicontrol('Units', 'Normalized', 'Style', 'popup', 'String', '1|2|3|4|5|6|7|8|9','Position', [0.81 0.02 0.05 0.05], 'Value', 5);

% h.valZom = uicontrol('Units', 'Normalized', 'Style', 'popup', 'String', '2x|3x|4x|5x|6x|7x', 'Position', [0.75 0.02 0.05 0.05], 'Value', 1);

h.saveTf = uicontrol('Units', 'Normalized', 'Style', 'pushbutton', 'String', 'Save', 'Position', [0.02 0.045 0.05 0.05], 'Callback', @saveTransform);

h.close  = uicontrol('Units', 'Normalized', 'Style', 'pushbutton', 'String', 'Close', 'Position', [0.93 0.92 0.05 0.025], 'Callback', @closeFig);

h.browse1 = uicontrol('Units', 'Normalized', 'Style', 'pushbutton', 'String', 'Browse Main', 'Position', [0.1 0.53 0.05 0.025], 'Callback', @loadMainImage);

h.selIMG1 = uicontrol('Units', 'Normalized', 'Style', 'popup', 'String', 'Raw|Masked|Filtered|Smoothed|Corrected|Mask', 'Position', [0.1 0.49 0.05 0.025], 'Value', 1, 'Callback', @update);

h.browse2 = uicontrol('Units', 'Normalized', 'Style', 'pushbutton', 'String', 'Browse', 'Position', [0.1 0.07 0.05 0.025], 'Callback', @loadImages);

h.selIMG2 = uicontrol('Units', 'Normalized', 'Style', 'popup', 'String', 'Raw|Masked|Filtered|Smoothed|Corrected|Mask', 'Position', [0.1 0.03 0.05 0.025], 'Value', 1, 'Callback', @update);

h.think   = uicontrol('Units', 'Normalized', 'Style', 'edit', 'String', 'Ready', 'Position', [0.02 0.4 0.05 0.025]);

h.selIMG3 = uicontrol('Units', 'Normalized', 'Style', 'popup', 'String', 'Both - Not warped|Both - Warped|Dots - Not warped|Dots - Warped', 'Position', [0.75 0.2 0.1 0.025], 'Value', 1, 'Callback', @checkWarp);

h.check  = uicontrol('Units', 'Normalized', 'Style', 'pushbutton', 'String', 'Update/recalculate', 'Position', [0.75 0.15 0.1 0.025], 'Callback', @checkWarp);


h.sub(5)   = subplot(2,3,[3 6]);
set(gca, 'Position', [0.68 0.3 0.29 0.5])
h.sub(4)   = subplot(2,3,5);
set(gca, 'Position', [0.43 0.12 0.20 0.35])
h.sub(3)   = subplot(2,3,4);
set(gca, 'Position', [0.18 0.12 0.20 0.35])
h.sub(2)   = subplot(2,3,2);
set(gca, 'Position', [0.43 0.58 0.20 0.35])
h.sub(1)   = subplot(2,3,1);
set(gca, 'Position', [0.18 0.58 0.20 0.35])

function selectCurrIm(hObj,event,ax)
global info h
info.currIm = get(hObj,'Value')+1;

function setThreshMain(hObj,event,ax)
global info h

info.threshold(1) = get(hObj,'Value');
set(h.valTh1, 'String', num2str(info.threshold(1)));

update

function setThreshSub(hObj,event,ax)
global info h

info.threshold(2) = get(hObj,'Value');
set(h.valTh2, 'String', num2str(info.threshold(2)));

update

function setDiam(hObj,event,ax)
global info h

info.minDiam = round(get(hObj,'Value'));
if ~mod(info.minDiam,2)
    info.minDiam = info.minDiam + 1;
end
set(h.valDi, 'String', ['Min diameter = ', num2str(info.minDiam)]);

update

function setGauss(hObj,event,ax)
global info h

info.gaussVal = get(hObj,'Value');
set(h.dispGa, 'String', ['Gaussian kernel = ', num2str(info.gaussVal)]);

update

function selectTransform(hObj,event,ax)
global info h
vals         = {'linear conformal','affine','projective','polynomial','piecewise linear','lwm'};
info.trans = vals{get(hObj,'Value')};

update

function saveTransform(hObj,event,ax)
global info h

names = info.files;
tform = info.tform;

if ~isempty(tform)
    saveName = ['Warpdata ', datestr(now, 'dd-mm-yyyy HH MM')];
    uisave({'tform','names'}, saveName)
    
    set(h.think, 'String', 'Saving transform')
    pause(1)
    set(h.think, 'String', 'Ready for warp')
end

function checkItOut(hObj,event,ax)
global info h
disp('checkItOut')

update

set(h.think, 'String', 'Thinking')

R  = get(h.valRep, 'Value');
Z  = get(h.valZom, 'Value');
zV = [1/4 1/3 3/8 2/5 5/12 3/7];
tX = round(info.sX*zV(Z)):round((1-zV(Z))*info.sX);
tY = round(info.sY*zV(Z)):round((1-zV(Z))*info.sY);

if ~isempty(info.tform)
    for i = 1:2%numel(IMG)
        info.warped{i} = imtransform(info.IMG{i},info.tform{i},...
            'XData',[1 size(info.IMG{1},2)],'YData',[1 size(info.IMG{1},1)],'XYScale',[1 1]);
    end
    
    subplot(info.s1,info.s2,[3 6]);
    try
        for i = 1:R
            for k = 1:2
                imagesc(mat2gray(info.warped{k}(tY,tX)), [0, 1])
                daspect([1 1 1])
                colormap gray
                drawnow
            end
        end
    end

    
    
%     for j = 1:R
%         for i = 1:2%numel(IMG)
%             figure(1)
%             colormap gray
%             subplot(s1,s2,s2);
%             imagesc(fixed(:,:,i))
%             hold on
%             line([tX(1) tX(end)], [tY(1) tY(1)], 'Color', 'k','LineStyle','--')
%             line([tX(1) tX(end)], [tY(end) tY(end)], 'Color', 'k','LineStyle','--')
%             line([tX(1) tX(1)], [tY(1) tY(end)], 'Color', 'k','LineStyle','--')
%             line([tX(end) tX(end)], [tY(1) tY(end)], 'Color', 'k','LineStyle','--')
%             daspect([1 1 1])
%             title(['CCD: ', num2str(i)],'FontSize',14,'FontWeight','bold')
%             
%             subplot(s1,s2,s1*s2)
%             imagesc(fixed(tY,tX,i))
%             daspect([1 1 1])
%             title(['CCD: ', num2str(i)],'FontSize',14,'FontWeight','bold')
%             drawnow
%             pause(0.1)
%         end
%     end
else
%     for j = 1:R
%         for i = 1:2%numel(IMG)
%             figure(1)
%             colormap gray
%             subplot(s1,s2,s2);
%             imagesc(IMG{i})
%             hold on
%             line([tX(1) tX(end)], [tY(1) tY(1)], 'Color', 'k','LineStyle','--')
%             line([tX(1) tX(end)], [tY(end) tY(end)], 'Color', 'k','LineStyle','--')
%             line([tX(1) tX(1)], [tY(1) tY(end)], 'Color', 'k','LineStyle','--')
%             line([tX(end) tX(end)], [tY(1) tY(end)], 'Color', 'k','LineStyle','--')
%             daspect([1 1 1])
%             title(['CCD: ', num2str(i)],'FontSize',14,'FontWeight','bold')
%             
%             subplot(s1,s2,s1*s2)
%             imagesc(IMG{i}(tY,tX))
%             daspect([1 1 1])
%             title(['CCD: ', num2str(i)],'FontSize',14,'FontWeight','bold')
%             drawnow
%             pause(0.1)
%         end
%     end
end
% update

function rotImage(hObj, event, ax)
global info h

function closeFig(hObj, event, ax)
uiresume
close(gcf)

function loadMainImage(hObj, event, ax)
global info h

[filename, pathname] = uigetfile({'*.*',  'All Files (*.*)'},'Select the reference image.');

set(h.think, 'String', 'Thinking')

if isstr(filename)
    curr_path = cd;
    
    cd(pathname)
    filetype = filename(strfind(filename, '.')+1:end);
    
    switch filetype
        case 'tif'
            info.IMG{1}   = double(imread(filename));
        case 'sif'
            try
                info.IMG{1}   = readSIF(filename, 41, 1000, 1000);
            end
        case 'mat'
            load(filename)            
            try
                eval(['info.IMG{1} = ', get(h.matVar1, 'String'), ';'])
            catch
                info.IMG{1}   = F{1};
            end

        case 'txt'
            info.IMG{1}   = double(load(filename));
        otherwise
            info.IMG{1}   = double(imread(filename));
    end
    
    H             = fspecial('gaussian',10,5);
    info.IMG{1}   = imfilter(info.IMG{1},H); %Initial filtering
    info.files{1} = filename;
    info.sX       = size(info.IMG{1},2);
    info.sY       = size(info.IMG{1},1);
    info.fullGaus = imresize(mat2gray(fspecial('gaussian', 1000, info.gaussVal)), [info.sY, info.sX]);
    
    subplot(info.s1,info.s2,1);
    imagesc(info.IMG{1})
    colormap gray
    daspect([1 1 1])
    titel = [info.files{1},' (CCD 1)'];
    titel(strfind(titel, '_')) = ' ';
    title(titel,'FontSize',14,'FontWeight','bold')
    
    update
end

function loadImages(hObj, event, ax)
global info h

[filename, pathname] = uigetfile({'*.*',  'All Files (*.*)'},'Select image to warp.');

set(h.think, 'String', 'Thinking')

if isstr(filename)
    curr_path = cd;
    
    cd(pathname)
    filetype = filename(strfind(filename, '.')+1:end);
    
    switch filetype
        case 'tif'
            info.IMG{2}   = double(imread(filename));
        case 'sif'
            try
                info.IMG{2}   = readSIF(filename, 41, 1000, 1000);
            end
        case 'mat'
            load(filename)
            try
                eval(['info.IMG{2} = ', get(h.matVar2, 'String'), ';'])
            catch
                info.IMG{2}   = F{2};
            end
        case 'txt'
            info.IMG{2}   = double(load(filename));
        otherwise
            info.IMG{2}   = double(imread(filename));
    end
    
%     H             = fspecial('gaussian',10,5);
%     H             = fspecial('gaussian',40,20);
%     info.IMG{2}   = imfilter(info.IMG{2},H);
    info.files{2} = filename;
    info.sX       = size(info.IMG{2},2);
    info.sY       = size(info.IMG{2},1);
    info.fullGaus = imresize(mat2gray(fspecial('gaussian', 1000, info.gaussVal)), [info.sY, info.sX]);
    
    subplot(info.s1,info.s2,info.s2+1);
    imagesc(info.IMG{2})
    colormap gray
    daspect([1 1 1])
    titel = [info.files{2},' (CCD 2)'];
    titel(strfind(titel, '_')) = ' ';
    title(titel,'FontSize',14,'FontWeight','bold')
    
    update
end

function printImages(nr)
global h info

if nr == 1
    val = get(h.selIMG1, 'Value');
else 
    val = get(h.selIMG2, 'Value');
end
sp = [1 4];
cut = info.cut;
gV  = info.gaussVal;
s1  = info.s1;
s2  = info.s2;
sX  = info.sX;
sY  = info.sY;
th  = info.threshold;

subplot(s1,s2,sp(nr));
hold off
if val == 1
    imagesc(info.IMG{nr})
elseif val == 2
    if isempty(info.mask)
        imagesc(info.IMG{nr})
    else 
        imagesc(info.IMG{nr}.*info.mask)
    end
elseif val == 3
    imagesc(info.filt{nr})
elseif val == 4
    imagesc(info.smooth{nr})
elseif val == 5
    imagesc(info.corr{nr})
elseif val == 6
    imagesc(info.mask)
else
    imagesc(info.IMG{nr})
end
% hold on
% if ~isempty(info.mask)
%     if get(h.selShape, 'Value') == 1
%         line([1 sX], [cut(2) cut(2)], 'Color', 'k','LineStyle','--')
%         line([1 sX], [cut(4) cut(4)], 'Color', 'k','LineStyle','--')
%         line([cut(1) cut(1)], [1 sY], 'Color', 'k','LineStyle','--')
%         line([cut(3) cut(3)], [1 sY], 'Color', 'k','LineStyle','--')
%     else 
%         
%     end
% end
colormap gray
daspect([1 1 1])
titel = [info.files{nr},' (CCD ', num2str(nr), ')'];
titel(strfind(titel, '_')) = ' ';
title(titel,'FontSize',14,'FontWeight','bold')

subplot(s1,s2,sp(nr)+1);
imagesc(info.corr{nr}, [0, 1])
daspect([1 1 1])
colormap gray

% checkWarp

function extractImages(nr)
global h info

gV  = info.gaussVal;
s1  = info.s1;
s2  = info.s2;
sX  = info.sX;
sY  = info.sY;
th  = info.threshold(nr);

if length(info.cut) == 1
    info.cut = [1 1 sX sY];
end

tmp1 = 'ygrbygrbygrbygrb';
tmp2 = '.o*sd.o*sd.o*sd.o*sd';

tform     = [];
if nr == 1
    th = get(h.slidTh1, 'Value');
else
    th = get(h.slidTh2, 'Value');
end
fullGaus  = imresize(mat2gray(fspecial('gaussian', 1000, gV)), [sY, sX]);

info.smooth{nr}  = double(imfilter(info.IMG{nr}, info.gauss));
fourier          = fftshift(fft2(info.IMG{nr}));
info.filt{nr}    = double(abs(ifft2(fftshift(fourier.*fullGaus))));

info.corr{nr} = 1 - mat2gray(info.smooth{nr}./info.filt{nr});
if ~isempty(info.mask)
    info.corr{nr} = info.corr{nr}.*info.mask;
end

function getRoughPos(nr)
global h info

sp  = [1 4];

cut = info.cut;
gV  = info.gaussVal;
s1  = info.s1;
s2  = info.s2;
sX  = info.sX;
sY  = info.sY;
th  = info.threshold(nr);

tmp1 = 'ybgrbygrbygrbygrb';
tmp2 = '.o*sd.o*sd.o*sd.o*sd';

tempPos = pkfnd(info.corr{nr}, info.threshold(nr), info.minDiam)';
MaxPos  = sortOutFalseDots(tempPos, info.minDiam, info.threshold(nr), info.corr{nr});

info.Peaks{nr} = MaxPos;

subplot(s1,s2,sp(nr));
if ~isempty(MaxPos)
    hold on
    plot(MaxPos(1,:), MaxPos(2,:), '.y')
    title(['Number of found points: ', num2str(size(MaxPos,2))],'FontSize',14,'FontWeight','bold')
else
    title(['No points found'])
end

subplot(s1,s2,sp(nr)+1);
imagesc(info.corr{nr}, [0, 1])
daspect([1 1 1])
colormap gray
if ~isempty(MaxPos)
    hold on
    plot(MaxPos(1,:), MaxPos(2,:),[tmp1(nr), tmp2(nr)])
    title(['Number of found points: ', num2str(size(MaxPos,2))],'FontSize',14,'FontWeight','bold')
else
    title(['No points found'])
end

function findPeakBuddy
global info
disp("findPeakBuddy")

Peaks = info.Peaks;
if numel(Peaks) == 2
    if ~isempty(Peaks{1}) && ~isempty(Peaks{2})
        for i = 1:numel(Peaks)
            pos = [];
            if size(Peaks{1},2) < size(Peaks{2},2)
                m = 1;
            else
                m = 2;
            end
            for j = 1:size(Peaks{m},2)
                ii = 1;
                bF = [];
                for k = 1:size(Peaks{i},2)
                    bF(ii) = sum(abs(Peaks{1}(:,j) - Peaks{i}(:,k)));
                    ii     = ii + 1;
                end
                [~,tmp] = min(bF);
                pos(j)  = tmp;
            end
            info.Peaks{i} = Peaks{i}(:,pos);
            info.order{i} = pos;
        end
        info.order{1} = 1:size(info.Peaks{1},2);
    end
end

function update(varargin)
global info h
disp('update')

set(h.think, 'String', 'Thinking', 'Backgroundcolor', 'r')

if ~isempty(info.mask)
    set(h.mask, 'String', 'Clear AOI')
else 
    set(h.mask, 'String', 'Select AOI')
end

try
    extractImages(1)
    printImages(1)
    getRoughPos(1)
catch
    disp('Problem Ref image')
    pause(1)
end
try
    extractImages(2)
    printImages(2)
    getRoughPos(2)
    if numel(info.Peaks{1}) < 1000
        findPeakBuddy
        calcTform   %H?r uppst?r n?got fel...
    end
catch
    disp('Problem Warpimage')
end

if isempty(info.tform)
    set(h.think, 'String', 'Ready', 'Backgroundcolor', 'w')
else
    set(h.think, 'String', 'Ready for warp')
end

function calcTform
global info h
disp('calcTform')

%PROBLEM CALCULATING CENTER POINT, SKIPPING THIS FOR NOW

assignin('base', 'info', info)

info.tform    = [];
info.tform{1} = cp2tform(info.Peaks{1}', info.Peaks{1}', info.trans);
info.tform{2} = cp2tform(info.Peaks{2}', info.Peaks{1}', info.trans);
for i = 1:2
    tform(i) = cp2tform(info.Peaks{2}', info.Peaks{1}', info.trans)
end
info.tform = tform;

if numel(info.IMG) > 1
    
    tmp = 1;
    for i = 2:numel(info.Peaks)
        if size(info.Peaks{i},2) == size(info.Peaks{1},2)
            tmp = tmp + 1;
        end
    end
    
    wrn = 0;
    if tmp == numel(info.Peaks)
        
        for i = 1:numel(info.Peaks)
            if size(info.Peaks{i},2) < 2
                wrn = 1;
            end
        end
        
        if ~wrn
            clear tform
            for i = 1:2 %Only two images
                %Moving points, Fixed points, trans type 
                tform(i) = cp2tform(info.Peaks{i}', info.Peaks{1}', info.trans);
            end
            info.tform = tform;
        end
    end
    
%     checkWarp
end

function IMG = readSIF(name, header, sX, sY)

fid = fopen(name);
for k = 1:header
    fgetl(fid);
end
IMG = reshape(fread(fid, sX*sY, 'single=>single'), [sX sY]);
fclose(fid);

function selAOI(varargin)
global info h

if isempty(info.mask)
    if ~isempty(info.IMG{1})
        info.mask = NaN(size(info.IMG{1}));
        if get(h.selShape, 'Value') == 1
            [x,y] = ginput(2);
            x     = sort(round(x));
            y     = sort(round(y));
            
            info.mask = NaN(size(info.IMG{1}));
            info.mask(y(1):y(2),x(1):x(2))     = 1;

        else
            [x,y] = ginput(2);
            
            info.center(1) = round(y(1));
            info.center(2) = round(x(1));
            info.dist(1)   = sqrt( (x(1)-x(2)).^2 + (y(1)-y(2)).^2);
            
            [X, Y]      = meshgrid(1:size(info.IMG{1},2), 1:size(info.IMG{1},1));
            dist        = sqrt((X-info.center(2)).^2 + (Y-info.center(1)).^2);
            info.mask(dist>info.dist)  = 0;
            info.mask(dist<=info.dist) = 1;
            
        end
    end
else
    info.mask = [];
end
    
update

if ~isempty(info.mask)
    set(h.mask, 'String', 'Clear AOI')
else 
    set(h.mask, 'String', 'Select AOI')
end

function out=pkfnd(im,th,sz)

%find all the pixels above threshold
%im=im./max(max(im)); 
ind=find(im > th);
[nr,nc]=size(im);
tst=zeros(nr,nc);
n=length(ind);
if n==0
    out=[];
    disp('nothing above threshold');
    return;
end
mx=[];
%convert index from find to row and column
rc=[mod(ind,nr),floor(ind/nr)+1];
for i=1:n
    r=rc(i,1);c=rc(i,2);
    %check each pixel above threshold to see if it's brighter than it's neighbors
    %  THERE'S GOT TO BE A FASTER WAY OF DOING THIS.  I'M CHECKING SOME MULTIPLE TIMES,
    %  BUT THIS DOESN'T SEEM THAT SLOW COMPARED TO THE OTHER ROUTINES, ANYWAY.
    if r>1 && r<nr && c>1 && c<nc
        if im(r,c)>=im(r-1,c-1) && im(r,c)>=im(r,c-1) && im(r,c)>=im(r+1,c-1) && ...
         im(r,c)>=im(r-1,c)  && im(r,c)>=im(r+1,c) &&   ...
         im(r,c)>=im(r-1,c+1) && im(r,c)>=im(r,c+1) && im(r,c)>=im(r+1,c+1)
        mx=[mx,[r,c]']; 
        %tst(ind(i))=im(ind(i));
        end
    end
end
%out=tst;
mx=mx';

[npks,~]=size(mx);

%if size is specified, then get ride of pks within size of boundary
if nargin==3 && npks>0
   %throw out all pks within sz of boundary;
    ind=find(mx(:,1)>sz & mx(:,1)<(nr-sz) & mx(:,2)>sz & mx(:,2)<(nc-sz));
    mx=mx(ind,:); 
end

%prevent from finding peaks within size of each other
[npks,~]=size(mx);
if npks > 1 
    %CREATE AN IMAGE WITH ONLY PEAKS
    nmx=npks;
    tmp=0.*im;
    for i=1:nmx
        tmp(mx(i,1),mx(i,2))=im(mx(i,1),mx(i,2));
    end
    %LOOK IN NEIGHBORHOOD AROUND EACH PEAK, PICK THE BRIGHTEST
    for i=1:nmx
        roi=tmp( (mx(i,1)-floor(sz/2)):(mx(i,1)+(floor(sz/2)+1)),(mx(i,2)-floor(sz/2)):(mx(i,2)+(floor(sz/2)+1))) ;
        [mv,indi]=max(roi);
        [mv,indj]=max(mv);
        tmp( (mx(i,1)-floor(sz/2)):(mx(i,1)+(floor(sz/2)+1)),(mx(i,2)-floor(sz/2)):(mx(i,2)+(floor(sz/2)+1)))=0;
        tmp(mx(i,1)-floor(sz/2)+indi(indj)-1,mx(i,2)-floor(sz/2)+indj-1)=mv;
    end
    ind=find(tmp>0);
    mx=[mod(ind,nr),floor(ind/nr)+1];
end

if size(mx)==[0,0]
    out=[];
else
    out(:,2)=mx(:,1);
    out(:,1)=mx(:,2);
end

function MaxPos = sortOutFalseDots(MaxPos, MinDiam, Thresh, im)
global info

radius  = round(MinDiam/2);
minArea = pi*(MinDiam/2)^2;

Pos = [];
for i = 1:size(MaxPos,2)
    x = MaxPos(1,i) - radius : MaxPos(1,i) + radius;
    y = MaxPos(2,i) - radius : MaxPos(2,i) + radius;
    
    %Just make sure to avoid index outside frame
    x(x<=0) = 1; 
    y(y<=0) = 1;
    x(x > info.sX) = info.sX;
    y(y > info.sY) = info.sY;
    
    %If dot -> area above threshold = minArea
    numbOnes = sum(sum(im(y,x) > Thresh));
    if numbOnes > minArea
        Pos = [Pos, MaxPos(:,i)];
    end
end

MaxPos = Pos;

function out = cntrd(im,mx,sz)

% if isempty(mx)
%     warning('there were no positions inputted into cntrd. check your pkfnd theshold')
%     out=[];
%     return;
% end

%create mask - window around trial location over which to calculate the centroid
r       = (sz+1)/2;
m       = 2*r;
x       = 0:(m-1);
cent    = (m-1)/2;
x2      = (x-cent).^2;
dst     = zeros(m,m);   %distances from center
for i = 1:m
    dst(i,:) = sqrt((i-1-cent)^2+x2);
end

ind         = find(dst < r);    %find distances within circle radius r
msk         = zeros([2*r,2*r]); %make empty mask
msk(ind)    = 1.0;              %fill mask pixels that are within radius r

dst2        = msk.*(dst.^2);
ndst2       = sum(sum(dst2));

[nr,nc]     = size(im);
%remove all potential locations within distance sz from edges of image
ind         = find(mx(:,2) > 1.5*sz & mx(:,2) < nr-1.5*sz);
mx          = mx(ind,:);
ind         = find(mx(:,1) > 1.5*sz & mx(:,1) < nc-1.5*sz);
mx          = mx(ind,:);

[nmx,~]     = size(mx);

%inside of the window, assign an x and y coordinate for each pixel
xl          = zeros(2*r,2*r);
for i=1:2*r
    xl(i,:) = (1:2*r);
end
yl = xl';

pts = [];
%loop through all of the candidate positions
for i = 1:nmx
    %create a small working array around each candidate location, and apply the window function
    tmp=msk.*im((mx(i,2)-r+1:mx(i,2)+r),(mx(i,1)-r+1:mx(i,1)+r));
    %calculate the total brightness
    norm=sum(sum(tmp));
    %calculate the weigthed average x location
    xavg=sum(sum(tmp.*xl))./norm;
    %calculate the weighted average y location
    yavg=sum(sum(tmp.*yl))./norm;
    %calculate the radius of gyration^2
    rg=(sum(sum(tmp.*dst2))/ndst2);
    
    %concatenate it up
    pts = [pts,[mx(i,1)+xavg-r,mx(i,2)+yavg-r,norm,rg]'];
    
%     %OPTIONAL plot things up if you're in interactive mode
%     if interactive==1
%      imagesc(tmp)
%      axis image
%      hold on;
%      plot(xavg,yavg,'x')
%      plot(xavg,yavg,'o')
%      plot(r,r,'.')
%      hold off
%      pause
%     end

    
end
out = pts';

function setThreshFromText(varargin)
global info h

string = get(h.valTh1, 'String');
try
    info.threshold(1) = str2num(string);
    set(h.slidTh1, 'Value', info.threshold(1));
end
string = get(h.valTh2, 'String');
try
    info.threshold(2) = str2num(string);
    set(h.slidTh2, 'Value', info.threshold(2));
end

update

function checkWarp(varargin)
global info h
clc
disp('checkWarp')

if strcmp(varargin{2}.Source.Style, 'pushbutton')
    update
end

val = get(h.selIMG3, 'Value');
subplot(info.s1,info.s2,[3 6]);

if val == 1
    imagesc(mat2gray(info.IMG{1})+mat2gray(info.IMG{2}), [0, 2])
    daspect([1 1 1])
    colormap gray
    drawnow
    
elseif val == 2
    
    if ~isempty(info.tform)
        info.warped{1} = imtransform(info.IMG{1},info.tform(1), 'XData',[1 size(info.IMG{1},2)],'YData',[1 size(info.IMG{1},1)],'XYScale',[1 1]);
        info.warped{2} = imtransform(info.IMG{2},info.tform(2), 'XData',[1 size(info.IMG{1},2)],'YData',[1 size(info.IMG{1},1)],'XYScale',[1 1]);
    end

    imagesc(mat2gray(info.warped{1})+mat2gray(info.warped{2}), [0, 2])
    daspect([1 1 1])
    colormap gray
    drawnow
    
elseif val == 3
    
    imagesc(zeros(info.sY,info.sX), [0, 1])
    daspect([1 1 1])
    colormap gray
    hold on
    try
        plot(info.Peaks{1}(1,:), info.Peaks{1}(2,:),[info.colors(1),info.patterns(1)])
    end
    try
        plot(info.Peaks{2}(1,:), info.Peaks{2}(2,:),[info.colors(2),info.patterns(2)])
    end
    hold off
    
elseif val == 4
    
    getWarpedDots

    imagesc(zeros(info.sY,info.sX), [0, 1])
    daspect([1 1 1])
    colormap gray
    hold on
    try
        plot(info.Peaks_w{1}(1,:), info.Peaks_w{1}(2,:),[info.colors(1),info.patterns(1)])
    end
    try
        plot(info.Peaks_w{2}(1,:), info.Peaks_w{2}(2,:),[info.colors(2),info.patterns(2)])
    end
    hold off  
end

function getWarpedDots(varargin)
global info h
% clc
disp('getWarpedDots')

if ~isempty(info.tform)
    info.warped{1} = imtransform(info.IMG{1}, info.tform{1}, 'XData',[1 size(info.IMG{1},2)],'YData',[1 size(info.IMG{1},1)],'XYScale',[1 1]);
    info.warped{2} = imtransform(info.IMG{2}, info.tform{2}, 'XData',[1 size(info.IMG{1},2)],'YData',[1 size(info.IMG{1},1)],'XYScale',[1 1]);
    
    fullGaus  = imresize(mat2gray(fspecial('gaussian', 1000, info.gaussVal)), [info.sY, info.sX]);
        
    for nr = 1:2
        if nr == 1
            th = get(h.slidTh1, 'Value');
        else
            th = get(h.slidTh2, 'Value');
        end
        
        info.smooth_w{nr}  = double(imfilter(info.warped{nr}, info.gauss));
        fourier            = fftshift(fft2(info.warped{nr}));
        info.filt_w{nr}    = double(abs(ifft2(fftshift(fourier.*fullGaus))));
        
        info.corr_w{nr} = 1 - mat2gray(info.smooth_w{nr}./info.filt_w{nr});
        if ~isempty(info.mask)
            info.corr_w{nr} = info.corr_w{nr}.*info.mask;
        end
    end
    
    for nr = 1:2
        tempPos = pkfnd(info.corr_w{nr}, th, info.minDiam)';
        MaxPos  = sortOutFalseDots(tempPos, info.minDiam, th, info.corr_w{nr});
        
        info.Peaks_w{nr} = MaxPos;
    end
    
    
end

function weightedCenter(IMG, peaks, minDiam)
% clc

[X,Y]           = meshgrid(linspace(-minDiam,minDiam,2*minDiam+1), linspace(-minDiam,minDiam,2*minDiam+1)); %Coordinate system
R               = sqrt(X.^2 + Y.^2);
R(R < minDiam)  = 1;
R(R >= minDiam) = 0;

for i = 1:length(peaks)
    x       = peaks(1,i)
    y       = peaks(2,i)
    ROI     = IMG(y-minDiam:y+minDiam, x-minDiam:x+minDiam);
    ROI_c   = ROI.*R;
    
    [X2,Y2] = meshgrid(linspace(x-minDiam, x+minDiam, 2*minDiam+1), linspace(y-minDiam,y+minDiam,2*minDiam+1)); %Coordinate system
    x_c     = sum(sum(ROI_c.*X2))./sum(sum(ROI_c))
    y_c     = sum(sum(ROI_c.*Y2))./sum(sum(ROI_c))
end
