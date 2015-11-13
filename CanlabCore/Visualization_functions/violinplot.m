%__________________________________________________________________________
% violinplot.m - Simple violin plot using matlab default kernel density estimation
%
% Updates:
% v2: extended for accepting also cells of different length
% v3:
%    - changed varargin to parameter - value list
%    - specification of x-axis vals possible now
% Last update: 09/2014
%__________________________________________________________________________
% This function creates violin plots based on kernel density estimation
% using ksdensity with default settings. Please be careful when comparing pdfs
% estimated with different bandwidth!
%
% Differently to other boxplot functions, you may specify the x-position.
% This is particularly usefule when overlaying with other data / plots.
%__________________________________________________________________________
%
% Please cite this function as:
% Hoffmann H, 2013: violinplot.m - Simple violin plot using matlab default kernel
% density estimation. INRES (University of Bonn), Katzenburgweg 5, 53115 Germany.
% hhoffmann@uni-bonn.de
%
% Updated 9/2015 by Tor Wager
% - cleaned up spacing a bit, added documentation for 'x' feature
% - set x axis limits depending on x
% - added F, U outputs for point plotting later
% - added point plotting subfunction [now default to plot]
% - return point and fill handles in handles structure for later use
% - allow different colors for means, lines for different columns
%
%__________________________________________________________________________
%
% Input:
% Y:     Data to be plotted, being either
% n x m matrix. A 'violin' is plotted for each column m, OR
% 1 x m Cellarry with elements being numerical colums of nx1 length.
%
% varargin:
% xlabel:    xlabel. Set either [] or in the form {'txt1','txt2','txt3',...}
% facecolor=[1 0.5 0]%FaceColor: Specify abbrev. or m x 3 matrix (e.g. [1 0 0])
% edgecolor='k'      %LineColor: Specify abbrev. (e.g. 'k' for black); set either [],'' or 'none' if the mean should not be plotted
% facealpha=0.5     %Alpha value (transparency)
% mc='k'      %Color of the bars indicating the mean; set either [],'' or 'none' if the mean should not be plotted
% medc='r'    %Color of the bars indicating the median; set either [],'' or 'none' if the mean should not be plotted
% bw=[];      %Kernel bandwidth, prescribe if wanted.
%            %If b is a single number, b will be applied to all estimates
%            %If b is an array of 1xm or mx1, b(i) will be applied to
%            column (i).
% 'x'       followed by x position for center(s) of plots
% 'nopoints'   don't display dots
%
% Output:
% h: figure handle
% L: Legend handle
% MX: Means of groups
% MED: Medians of groups
% bw: bandwidth of kernel
%__________________________________________________________________________
% % Example1 (default):
% %
% disp('this example uses the statistical toolbox')
% Y=[rand(1000,1),gamrnd(1,2,1000,1),normrnd(10,2,1000,1),gamrnd(10,0.1,1000,1)];
% [h,L,MX,MED]=violinplot(Y);
% ylabel('\Delta [yesno^{-2}]','FontSize',14)
% %
% %Example2 (specify facecolor, edgecolor, xlabel):
% %
% disp('this example uses the statistical toolbox')
% Y=[rand(1000,1),gamrnd(1,2,1000,1),normrnd(10,2,1000,1),gamrnd(10,0.1,1000,1)];
% violinplot(Y,'xlabel',{'a','b','c','d'},'facecolor',[1 1 0;0 1 0;.3 .3 .3;0 0.3 0.1],'edgecolor','b',...
% 'bw',0.3,...
% 'mc','k',...
% 'medc','r--')
% ylabel('\Delta [yesno^{-2}]','FontSize',14)
% %
% %Example3 (specify x axis location):
% %
% disp('this example uses the statistical toolbox')
% Y=[rand(1000,1),gamrnd(1,2,1000,1),normrnd(10,2,1000,1),gamrnd(10,0.1,1000,1)];
% violinplot(Y,'x',[-1 .7 3.4 8.8],'facecolor',[1 1 0;0 1 0;.3 .3 .3;0 0.3 0.1],'edgecolor','none',...
% 'bw',0.3,'mc','k','medc','r-.')
% axis([-2 10 -0.5 20])
% ylabel('\Delta [yesno^{-2}]','FontSize',14)
% %
% %Example4 (Give data as cells with different n):
% %
% disp('this example uses the statistical toolbox')
% %
% Y{:,1}=rand(10,1);
% Y{:,2}=rand(1000,1);
% violinplot(Y,'facecolor',[1 1 0;0 1 0;.3 .3 .3;0 0.3 0.1],'edgecolor','none','bw',0.1,'mc','k','medc','r-.')
% ylabel('\Delta [yesno^{-2}]','FontSize',14)
%__________________________________________________________________________
%__________________________________________________________________________

function[h, L, MX, MED, bw, F, U] = violinplot(Y,varargin)

%defaults:
%_____________________
xL=[];
fc=[1 0.5 0];
lc='k';
alp=0.5;
mc='k';
medc='r';
b=[]; %bandwidth
plotlegend=1;
plotmean=1;
plotmedian=1;
dopoints = true;
x = [];
%_____________________

%convert single columns to cells:
if iscell(Y)==0
    Y = num2cell(Y,1);
end

%get additional parameters
if isempty(find(strcmp(varargin,'xlabel')))==0
    xL = varargin{find(strcmp(varargin,'xlabel'))+1};
end
if isempty(find(strcmp(varargin,'facecolor')))==0
    fc = varargin{find(strcmp(varargin,'facecolor'))+1};
end
if isempty(find(strcmp(varargin,'edgecolor')))==0
    lc = varargin{find(strcmp(varargin,'edgecolor'))+1};
end
if isempty(find(strcmp(varargin,'facealpha')))==0
    alp = varargin{find(strcmp(varargin,'facealpha'))+1};
end
if isempty(find(strcmp(varargin,'nopoints')))==0
    dopoints = false;
end
if isempty(find(strcmp(varargin,'mc')))==0
    if isempty(varargin{find(strcmp(varargin,'mc'))+1})==0
        mc = varargin{find(strcmp(varargin,'mc'))+1};
        plotmean = 1;
    else
        plotmean = 0;
    end
end
if isempty(find(strcmp(varargin,'medc')))==0
    if isempty(varargin{find(strcmp(varargin,'medc'))+1})==0
        medc = varargin{find(strcmp(varargin,'medc'))+1};
        plotmedian = 1;
    else
        plotmedian = 0;
    end
end
if isempty(find(strcmp(varargin,'bw')))==0
    b = varargin{find(strcmp(varargin,'bw'))+1}
    if length(b)
        disp(['same bandwidth bw = ',num2str(b),' used for all cols'])
        b=repmat(b,size(Y,2),1);
    elseif length(b)~=size(Y,2)
        warning('length(b)~=size(Y,2)')
        error('please provide only one bandwidth or an array of b with same length as columns in the data set')
    end
end
if isempty(find(strcmp(varargin,'plotlegend')))==0
    plotlegend = varargin{find(strcmp(varargin,'plotlegend'))+1};
end
if isempty(find(strcmp(varargin,'x')))==0
    x = varargin{find(strcmp(varargin,'x'))+1};
end
%-------------------------------------------------------------------------
if size(fc,1)
    fc=repmat(fc,size(Y,2),1);
end
%-------------------------------------------------------------------------
i=1;
for i=1:size(Y,2)
    
    if isempty(b)==0
        [f, u, bb]=ksdensity(Y{i},'bandwidth',b(i));
    elseif isempty(b)
        [f, u, bb]=ksdensity(Y{i});
    end
    
    f=f/max(f)*0.3; %normalize
    F(:,i)=f;
    U(:,i)=u;
    MED(:,i)=nanmedian(Y{i});
    MX(:,i)=nanmean(Y{i});
    bw(:,i)=bb;
    
end
%-------------------------------------------------------------------------
%mp = get(0, 'MonitorPositions');
%set(gcf,'Color','w','Position',[mp(end,1)+50 mp(end,2)+50 800 600])
%-------------------------------------------------------------------------

%_________________________________________________________________________
%
% Check stuff
%
%_________________________________________________________________________

if isempty(x)
    x = zeros(size(Y,2));
    setX = 0;
else
    setX = 1;
    if isempty(xL) == 0
        disp('_________________________________________________________________')
        warning('Function is not designed for x-axis specification with string label')
        warning('when providing x, xlabel can be set later anyway')
        error('please provide either x or xlabel. not both.')
    end
end

% Enforce matrices for colors, not cell arrays

if iscell(lc)
    lc = cat(1, lc{:});
end

if iscell(fc)
    fc = cat(1, fc{:});
end

if iscell(mc)
    mc = cat(1, mc{:});
end

if iscell(medc)
    medc = cat(1, medc{:});
end

% Check mean and median colors - added by Tor
if size(mc, 1) < size(Y, 2)
    
    mc = repmat(mc, size(Y, 2), 1);
    
end

if size(medc, 1) < size(Y, 2)
    
    medc = repmat(medc, size(Y, 2), 1);
    
end

if size(lc, 1) < size(Y, 2)
    
    lc = repmat(lc, size(Y, 2), 1);
    
end



%_________________________________________________________________________
%
% Main plot
%
%_________________________________________________________________________

i=1;
for i = i:size(Y,2)
    
    % FILL - violin shape
    if isempty(lc)
        
        if setX == 0
            h(i)=fill([F(:,i)+i;flipud(i-F(:,i))],[U(:,i);flipud(U(:,i))],fc(i,:),'FaceAlpha',alp,'EdgeColor','none');
        else
            h(i)=fill([F(:,i)+x(i);flipud(x(i)-F(:,i))],[U(:,i);flipud(U(:,i))],fc(i,:),'FaceAlpha',alp,'EdgeColor','none');
        end
    else
        
        if setX == 0
            h(i)=fill([F(:,i)+i;flipud(i-F(:,i))],[U(:,i);flipud(U(:,i))],fc(i,:),'FaceAlpha',alp,'EdgeColor', lc(i,:));
        else
            h(i)=fill([F(:,i)+x(i);flipud(x(i)-F(:,i))],[U(:,i);flipud(U(:,i))],fc(i,:),'FaceAlpha',alp,'EdgeColor', lc(i,:));
        end
    end
    
    hold on
    
    % Plot mean and median values
    
    if setX == 0
        if plotmean
            p(1)=plot([interp1(U(:,i),F(:,i)+i,MX(:,i)), interp1(flipud(U(:,i)),flipud(i-F(:,i)),MX(:,i)) ],[MX(:,i) MX(:,i)], 'Color',mc(i,:),'LineWidth',2);
        end
        
        if plotmedian
            p(2)=plot([interp1(U(:,i),F(:,i)+i,MED(:,i)), interp1(flipud(U(:,i)),flipud(i-F(:,i)),MED(:,i)) ],[MED(:,i) MED(:,i)], 'Color',medc(i,:),'LineWidth',2);
        end
        
    elseif setX
        
        if plotmean
            p(1)=plot([interp1(U(:,i),F(:,i)+i,MX(:,i))+x(i)-i, interp1(flipud(U(:,i)),flipud(i-F(:,i)),MX(:,i))+x(i)-i],[MX(:,i) MX(:,i)],'Color', mc(i,:), 'LineWidth',2);
        end
        
        if plotmedian
            p(2)=plot([interp1(U(:,i),F(:,i)+i,MED(:,i))+x(i)-i, interp1(flipud(U(:,i)),flipud(i-F(:,i)),MED(:,i))+x(i)-i],[MED(:,i) MED(:,i)],'Color', medc(i,:), 'LineWidth',2);
        end
    end
    
end % For each column

%-------------------------------------------------------------------------
if plotlegend && (plotmean || plotmedian)
    
    if plotmean && plotmedian
        L=legend([p(1) p(2)],'Mean','Median');
        
    elseif plotmean==0 && plotmedian
        L=legend([p(2)],'Median');
        
    elseif plotmean && plotmedian==0
        L=legend([p(1)],'Mean');
    end
    
    set(L,'box','off','FontSize',14)
else
    L=[];
end

% Set axis properties
%-------------------------------------------------------------------------
if ~setX, x = 1:size(Y, 2); end

%axis([0.5 size(Y,2)+0.5, min(U(:)) max(U(:))]);

% Set axis limits
set(gca, 'XLim', [min(x)-.5 max(x)+.5], 'XTick', x, 'YLim', [min(U(:)) max(U(:))]);


%-------------------------------------------------------------------------

xL2={''};
i=1;
for i=1:size(xL,2)
    xL2=[xL2,xL{i},{''}];
end
set(gca,'TickLength',[0 0],'FontSize',12)
box on

if isempty(xL)==0
    set(gca,'XtickLabel',xL2)
end
%-------------------------------------------------------------------------

% WANI ADDED nopoints OPTION (11/12/15)
if dopoints
    plot_violin_points(x, Y, U, F, lc, fc, varargin)
end

% SHOW MEAN/MEDIAN LINE ABOVE THE POINTS, SO DO THIS AGAIN (WANI)
i=1;
for i = i:size(Y,2)
    % Plot mean and median values
    
    if setX == 0
        if plotmean
            p(1)=plot([interp1(U(:,i),F(:,i)+i,MX(:,i)), interp1(flipud(U(:,i)),flipud(i-F(:,i)),MX(:,i)) ],[MX(:,i) MX(:,i)], 'Color',mc(i,:),'LineWidth',2);
        end
        
        if plotmedian
            p(2)=plot([interp1(U(:,i),F(:,i)+i,MED(:,i)), interp1(flipud(U(:,i)),flipud(i-F(:,i)),MED(:,i)) ],[MED(:,i) MED(:,i)], 'Color',medc(i,:),'LineWidth',2);
        end
        
    elseif setX
        
        if plotmean
            p(1)=plot([interp1(U(:,i),F(:,i)+i,MX(:,i))+x(i)-i, interp1(flipud(U(:,i)),flipud(i-F(:,i)),MX(:,i))+x(i)-i],[MX(:,i) MX(:,i)],'Color', mc(i,:), 'LineWidth',2);
        end
        
        if plotmedian
            p(2)=plot([interp1(U(:,i),F(:,i)+i,MED(:,i))+x(i)-i, interp1(flipud(U(:,i)),flipud(i-F(:,i)),MED(:,i))+x(i)-i],[MED(:,i) MED(:,i)],'Color', medc(i,:), 'LineWidth',2);
        end
    end
    
end % For each column

end %of function



function linehandles = plot_violin_points(x, Y, U, F, lc, fc, varargin)
% x = vector of x positions for each "column"
% Y = cell array of input data, one cell per "column"
% U, F = outputs from ksdensity, normalized, or [] to recalculate
% lc = len(Y) x 3 vector of point fill colors
% fc = len(Y) x 3 vector of point line colors
%
% added by Tor Wager, Sept 2015
% lc is line color, will be used as fill
% fc is fill color, will be used for lines, in a strange twist of fate
% designed to increase contrast

manual_pointsize = false;

if isempty(find(strcmp(varargin{1},'pointsize')))==0
    pointsize = varargin{1}{find(strcmp(varargin{1},'pointsize'))+1};
    manual_pointsize = true;
end

if isempty(F) || isempty(U)
    % recalculate if density values are missing
    % this adds flexibility for use in other functions without modifying code
    
    for i=1:size(Y, 2)
        
        [f, u, bb]=ksdensity(Y{i});
        
    end
    
    f=f/max(f)*0.3; %normalize
    F(:,i) = f;
    U(:,i) = u;
    
end

nbins = 10;

linehandles = [];

for i = 1:size(Y, 2)
    
    myx = x(i);     % x-value for this bar in plot
    
    myfillcolor = lc(i, :); % line color for this plot
    mylinecolor = fc(i, :); % line color for this plot
    
    myU = U(:, i);  % x-values of ksdensity output
    myF = F(:, i);  % y-values (density) of ksdensity output
    
    myY = Y{i};     % data points
    mybins = linspace(min(myY), max(myY), nbins);
    
    % starting and ending values
    st = [-Inf mybins(1:end-1)];
    en = [mybins];
    
    % set point size
    if ~manual_pointsize
        pointsize = 1000 ./ length(myY);
        pointsize(pointsize < 1) = 1;
        pointsize(pointsize > 12) = 12;
    end
    
    clear mylimit my_xvals
    
    for j = 1:nbins
        % define points within a bin or 'slab'
        
        whpoints = myY > st(j) & myY <= en(j);
        
        whu = myU > st(j) & myU <= en(j);
        
        mylimit(j) = mean(myF(whu));  % average density for this 'slab' of points
        % this will be the limit on x-values
        
        % interleave points on either side of the midline
        % make the first point the actual midline value
        
        my_xvals = linspace(myx - mylimit(j), myx + mylimit(j), sum(whpoints))';
        
        if mod(length(my_xvals), 2)
            % odd number, use the midline point
            my_xvals = [myx; my_xvals(1:end-1)];
        end
        
        % build coordinates:
        % xlocs is left to right, ylocs is y-values to plot
        
        ylocs = myY(whpoints);
        %xlocs = repmat(my_xvals, ceil(length(ylocs) ./ length(my_xvals)), 1);
        
        xlocs = my_xvals(1:length(ylocs));
        
        
        linehandles{i, j} =  plot(xlocs, ylocs, 'o', 'Color', mylinecolor, 'MarkerSize', pointsize, 'MarkerFaceColor', myfillcolor);
        
    end % slab
    
end % column

linehandles = linehandles';
for i = 1:size(linehandles, 2)
    lh2{i} = cat(1, linehandles{:, i});
end
linehandles = lh2;

end % function