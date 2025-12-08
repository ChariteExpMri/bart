
function S = loadparamFromScript(fname)
     tmp = struct();

    % Run the parameter file inside this workspace
    run(fname);

    % Collect all variables created by the script
    vars = whos;
    for k = 1:numel(vars)
        name = vars(k).name;
        S.(name) = eval(name);
    end
    try; S=rmfield(S, 'tmp'); end
    try; S=rmfield(S, 'fname'); end
