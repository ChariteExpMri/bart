function stop = surrogateoptplot(~,optimValues,state)
% SURROGATEOPTPLOT Plot value of the objective function after each function
% evaluation.
%
%   STOP = SURROGATEOPTPLOT(X,OPTIMVALUES,STATE) plots current, incumbent
%   and best fval.

%   Copyright 2018-2020 The MathWorks, Inc.

persistent plotBest plotIncumbent plotRandom plotAdaptive plotInitial ...
    plotBestInfeas plotIncumbentInfeas plotRandomInfeas plotAdaptiveInfeas ...
    plotInitialInfeas legendHndl legendStr legendHndlInfeas legendStrInfeas ...
    nFeas

stop = false;

if strcmpi(state,'init')
    plotBest = []; plotIncumbent = []; plotRandom = [];
    plotAdaptive = []; plotInitial = [];
    plotBestInfeas = []; plotIncumbentInfeas = []; plotRandomInfeas = [];
    plotAdaptiveInfeas = []; plotInitialInfeas = [];
    
    legendHndl = []; legendStr = {};
    legendHndlInfeas = []; legendStrInfeas = {};
    nFeas = 0;
end

if optimValues.funccount == 0 || (isempty(optimValues.fval) && isempty(optimValues.ineq))
    % no function evals or none of the trials are successfully evaluated; no plots.
    return;
end
updateLegend = false;

if isempty(optimValues.fval)
    % feasibility problem
    best = optimValues.constrviolation;
    incumbent = optimValues.incumbentConstrviolation;
    current = optimValues.currentConstrviolation;
else
    best = optimValues.fval;
    incumbent = optimValues.incumbentFval;
    current = optimValues.currentFval;
end

if isempty(plotBest)
    xlabel('Number of Function Evaluations','interp','none');
    
    if isempty(optimValues.fval)
        ylabel('Infeasibility','interp','none');
        title('Number of feasible points: 0','interp','none')
    else
        ylabel('Objective Function','interp','none');
        title(['Best: ',' Incumbent: ',' Current: '],'interp','none')
    end
    hold on; grid on;
end

fname = getString(message('MATLAB:optimfun:funfun:optimplots:WindowTitle'));
fig = findobj(0,'Type','figure','name',fname);
if ~isempty(fig)
    options = get(fig,'UserData');
    tolCon = options.ConstraintTolerance;
else
    tolCon = 1e-3;
end
                        
if optimValues.constrviolation <= tolCon
    if isempty(plotBest)
        plotBest = plot(optimValues.funccount,best,'go');
        set(plotBest,'Tag','surrplotbestf','MarkerSize',6);
        legendHndl(end+1) = plotBest;
        legendStr{end+1} = 'Best';
        updateLegend = true;
    else
        newX = [get(plotBest,'Xdata') optimValues.funccount];
        newY = [get(plotBest,'Ydata') best];
        set(plotBest,'Xdata',newX, 'Ydata',newY);
    end
else
    if isempty(plotBestInfeas)
        plotBestInfeas = plot(optimValues.funccount,best,'ro');
        set(plotBestInfeas,'Tag','surrplotbestfinfeas','MarkerSize',5);
        legendHndlInfeas(end+1) = plotBestInfeas;
        legendStrInfeas{end+1} = 'Best (Infeas)';
        updateLegend = true;
    else
        newX = [get(plotBestInfeas,'Xdata') optimValues.funccount];
        newY = [get(plotBestInfeas,'Ydata') best];
        set(plotBestInfeas,'Xdata',newX, 'Ydata',newY);
    end
end

if optimValues.incumbentConstrviolation <= tolCon
    if isempty(plotIncumbent)
        plotIncumbent = plot(optimValues.funccount,incumbent,'bx');
        set(plotIncumbent,'Tag','surrplotincumbent','MarkerSize',4);
        legendHndl(end+1) = plotIncumbent;
        legendStr{end+1} = 'Incumbent';
        updateLegend = true;
    else
        newX = [get(plotIncumbent,'Xdata') optimValues.funccount];
        newY = [get(plotIncumbent,'Ydata') incumbent];
        set(plotIncumbent,'Xdata',newX, 'Ydata',newY);
    end
else
    if isempty(plotIncumbentInfeas)
        plotIncumbentInfeas = plot(optimValues.funccount,incumbent,'rx');
        set(plotIncumbentInfeas,'Tag','surrplotincumbentinfeas','MarkerSize',3);
        legendHndlInfeas(end+1) = plotIncumbentInfeas;
        legendStrInfeas{end+1} = 'Incumbent (Infeas)';
        updateLegend = true;
    else
        newX = [get(plotIncumbentInfeas,'Xdata') optimValues.funccount];
        newY = [get(plotIncumbentInfeas,'Ydata') incumbent];
        set(plotIncumbentInfeas,'Xdata',newX, 'Ydata',newY);
    end
end

if strcmpi('adaptive',optimValues.currentFlag)
    if optimValues.currentConstrviolation <= tolCon
        nFeas = nFeas + 1;
        if isempty(plotAdaptive)
            plotAdaptive = plot(optimValues.funccount,current,'k.');
            set(plotAdaptive,'Tag','surrplotadaptive','MarkerSize',8);
            legendHndl(end+1) = plotAdaptive;
            legendStr{end+1} = 'Adaptive Samples';
            updateLegend = true;
        else
            newX = [get(plotAdaptive,'Xdata') optimValues.funccount];
            newY = [get(plotAdaptive,'Ydata') current];
            set(plotAdaptive,'Xdata',newX, 'Ydata',newY);
        end
    else
        if isempty(plotAdaptiveInfeas)
            plotAdaptiveInfeas = plot(optimValues.funccount,current,'r.');
            set(plotAdaptiveInfeas,'Tag','surrplotadaptiveinfeas','MarkerSize',6);
            legendHndlInfeas(end+1) = plotAdaptiveInfeas;
            legendStrInfeas{end+1} = 'Adaptive Samples (Infeas)';
            updateLegend = true;
        else
            newX = [get(plotAdaptiveInfeas,'Xdata') optimValues.funccount];
            newY = [get(plotAdaptiveInfeas,'Ydata') current];
            set(plotAdaptiveInfeas,'Xdata',newX, 'Ydata',newY);
        end
    end
end

if strcmpi('random',optimValues.currentFlag)
    if optimValues.currentConstrviolation <= tolCon
        nFeas = nFeas + 1;
        if isempty(plotRandom)
            plotRandom = plot(optimValues.funccount,current,'kv');
            set(plotRandom,'Tag','surrplotrandom','MarkerSize',4);
            legendHndl(end+1) = plotRandom;
            legendStr{end+1} = 'Random Samples';
            updateLegend = true;
        else
            newX = [get(plotRandom,'Xdata') optimValues.funccount];
            newY = [get(plotRandom,'Ydata') current];
            set(plotRandom,'Xdata',newX, 'Ydata',newY);
        end
    else
        if isempty(plotRandomInfeas)
            plotRandomInfeas = plot(optimValues.funccount,current,'rv');
            set(plotRandomInfeas,'Tag','surrplotrandominfeas','MarkerSize',3);
            legendHndlInfeas(end+1) = plotRandomInfeas;
            legendStrInfeas{end+1} = 'Random Samples (Infeas)';
            updateLegend = true;
        else
            newX = [get(plotRandomInfeas,'Xdata') optimValues.funccount];
            newY = [get(plotRandomInfeas,'Ydata') current];
            set(plotRandomInfeas,'Xdata',newX, 'Ydata',newY);
        end
    end
end

if strcmp(optimValues.currentFlag,'initial')
    if optimValues.currentConstrviolation <= tolCon
        if isempty(plotInitial)
            plotInitial = plot(optimValues.funccount,current,'md');
            set(plotInitial,'Tag','surrplotinitial','MarkerSize',4);
            legendHndl(end+1) = plotInitial;
            legendStr{end+1} = 'Initial Samples';
            nFeas = nFeas + 1;
            updateLegend = true;
        else
            newX = [get(plotInitial,'Xdata') optimValues.funccount];
            newY = [get(plotInitial,'Ydata') current];
            set(plotInitial,'Xdata',newX, 'Ydata',newY);
            nFeas = nFeas + numel(newY);
        end
    else
        if isempty(plotInitialInfeas)
            plotInitialInfeas = plot(optimValues.funccount,current,'rd');
            set(plotInitialInfeas,'Tag','surrplotinitialinfeas','MarkerSize',3);
            legendHndlInfeas(end+1) = plotInitialInfeas;
            legendStrInfeas{end+1} = 'Initial Samples (Infeas)';
            updateLegend = true;
        else
            newX = [get(plotInitialInfeas,'Xdata') optimValues.funccount];
            newY = [get(plotInitialInfeas,'Ydata') current];
            set(plotInitialInfeas,'Xdata',newX, 'Ydata',newY);
        end
    end
end

if optimValues.surrogateReset == 1 && optimValues.funccount > 1
    y = get(gca,'Ylim');
    x = optimValues.funccount;
    ll = line([x, x],y);
    updateLegend = true;
    if optimValues.surrogateResetCount < 2
        legendHndlInfeas(end+1) = ll;
        legendStrInfeas{end+1} = 'Surrogate Reset';        
    end
end

if optimValues.checkpointResume && optimValues.funccount > 1
    y = get(gca,'Ylim');
    x = optimValues.funccount;
    ll = line([x, x],y,'Color','red','LineWidth',0.75);
    updateLegend = true;
    if optimValues.checkpointResumeCount < 2
        legendHndlInfeas(end+1) = ll;
        legendStrInfeas{end+1} = 'Checkpoint Resume';
    end
end

if isempty(optimValues.fval)
    set(get(gca,'Title'),'String', ...
        sprintf('Number of feasible points: %g', nFeas),'interp','none')
else
    set(get(gca,'Title'),'String', ...
        sprintf('Best: %g Incumbent: %g Current: %g',optimValues.fval, ...
        incumbent, current));
    '#'
end


if updateLegend && optimValues.constrviolation <= tolCon    
    legend([legendHndlInfeas legendHndl], [legendStrInfeas legendStr], ...
        'FontSize',8);
elseif updateLegend
    legend(legendHndlInfeas, legendStrInfeas,'FontSize',8);
end

if strcmp(state, 'done')
    hold off;
end
end

