function UseMyKeypress(hFig, myKeypressFun, customModes)
% UseMyKeypress(hFig, myKeypressFun, customModes)
% 
% In certain plot modes (rotate, pan, zoom), MATLAB overwrites keypress
% callbacks. This function sets and maintains a custom keypress callback
% (with options to ignore/append the custom callback in certain modes).
% 
% NOTE
%   Uses undocumented features to overwrite/append MATLAB exploration mode keypress
%   callbacks with custom keypress function.
%   See: https://undocumentedmatlab.com/articles/enabling-user-callbacks-during-zoom-pan
% 
% Inputs
%   hFig 
%       The figure handle
% 
%   myKeypressFun
%       Keypress function handle (e.g. @MyCustomKeypressFunction)
% 
%   customModes (optional, default: {'Exploration.Datacursor', 'ignore'})
%       [n x 2] Cell matrix of Exploration modes to 'ignore' or 'append'.
%
%       First column should be the exploration mode name
%       Second column should be 'ignore' or 'append'
%       If 'ignore', you get default matlab behavior for that mode.
%       If 'append', you get default matlab behavior followed by your
%       function. Note, you may want to ignore conflicting parsing in your
%       custom function.
% 
% 
% Example:
% 
% % This example prints key presses except when in datacursor mode (where
% % left, right keys will move the selected data point).
% % In rotate mode, left, right key presses will both update the plot and
% % also call the custom function (print the pressed key).
% figure()
% customFun = @(~,evnt) fprintf('Custom keypress callback for key %s\n', evnt.Key);
% UseMyKeypress(gcf,customFun, ...
%     {'Exploration.Datacursor', 'ignore'
%      'Exploration.Rotate3d', 'append'});
% x = linspace(-pi,pi,40);
% plot3(cos(x),sin(x),x);
% view(3)
% 
% 
% Tested on Matlab 2019b
%
%
%--------------------------------------------------------------------------
% History:
%   2022.01   Copyright Tommy Hosman, All Rights Reserved
%--------------------------------------------------------------------------


    if nargin < 3
        customModes = {'Exploration.Datacursor', 'ignore'};
    end


%% Get Mode manager and current mode property
    hFig = handle(hFig);
    hManager = uigetmodemanager(hFig);
    prop = hManager.findprop('CurrentMode');
    
%% Set listener for changes to CurrentMode
    
% Commented addlistener. Multiple call will add multiple listeners. Uncertain of behavior.
%     addlistener( hManager, prop, ...
%             'PostSet', @(obj,event) HandleModeUpdate(obj,event,hFig,myKeypressFun,customModes));


    % More control of the listener's lifetime
    % Calling this function twice will overwrite the previous listener.
    hListener = event.proplistener( hManager, prop, ...
            'PostSet', @(obj,evnt) HandleModeUpdate(obj,evnt,hFig,myKeypressFun,customModes));

    % Save so the listener persists
    mkl = getappdata(0,'mykeypress_listeners');
    mkl.(sprintf('fig%d', hFig.Number)) = hListener;
    setappdata(0,'mykeypress_listeners',mkl); 


%% Disable Mode listeners and set my keypress function
    evnt.AffectedObject = hManager;
    HandleModeUpdate([],evnt, hFig, myKeypressFun, customModes)
    

end
 


function HandleModeUpdate(obj,evnt, hFig, myKeypressFun, customModes)
% When mode changes, the listners and callbacks are re-enabled.
% This function will disable and set the custom keypress function
%
% Also handles specified customModes
    
    
    % Get hManager and figure objects
    hManager = evnt.AffectedObject;
    
    % Just passing in hFig to handle when CurrentMode is empty
%     hFig = hManager.CurrentMode.FigureHandle;
    
    
    
    
    
    % Is this a custom mode?
    if isempty(hManager.CurrentMode)
        isCustom = [];
    else
        isCustom = find(ismember(customModes(:,1), {hManager.CurrentMode.Name}),1);
        
        % Uncomment to see current mode name
        % fprintf('Updating after %s was used!\n', hManager.CurrentMode.Name)
    end
    
    
    if isempty(isCustom)
        % Default behavior
        
        % disable mode listeners and callbacks
        LocalUseMyKeypress(hManager,hFig,myKeypressFun); 
        
        
    else
        % Custom modes
        customMode = customModes{isCustom,2};
        switch customMode
            case 'ignore'
                return
                
            case 'append'
                isAppend = 1;
                LocalUseMyKeypress(hManager,hFig,myKeypressFun, isAppend)
                
            otherwise
                error('Unrecognized custom mode %s', customMode);
        end
    end
end



function LocalUseMyKeypress(hManager,hFig,myKeypressFun, isAppend)
% General procedure from: 
% https://undocumentedmatlab.com/articles/enabling-user-callbacks-during-zoom-pan

    if nargin < 4
        isAppend = false;
    end

    % Allow us to change key press callback functions
    try
        [hManager.WindowListenerHandles.Enabled] = deal(false);  % HG2
    catch
        set(hManager.WindowListenerHandles, 'Enable', 'off');  % HG1
    end
    
    
    % Update callback
    if ~isAppend
        % Default
        set(hFig, 'WindowKeyPressFcn', [], 'KeyPressFcn', myKeypressFun);    
        
    else
        % Append
        windowCB = get(hFig, 'WindowKeyPressFcn');
        if iscell( windowCB )
            % Assuming the last cell is the custom function
            % Normally, this is empty. But if previously set by this
            % function, that will no longer be true.
            windowCB{end} = myKeypressFun;
        else
            windowCB = {windowCB, myKeypressFun};
        end
        set(hFig, 'WindowKeyPressFcn', windowCB);
    end
end
