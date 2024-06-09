
% transform atlas-image to pseuDOIDs 
% Reason:--> issue with exlastx and very large numbers such as (182305696 and 182305712)
%  [v pid     ]=recodeIDS('forward', w2 );
%  [w2back pid]=recodeIDS('back', v, pid );

function [v pid]=recodeIDS(task, w2,pid )

%% ===============================================
if strcmp(task,'forward')
    wx=w2(:);
    uni=unique(wx);
    uni(uni==0)=[];
    pid=[uni [1:length(uni)]'];
    
    v=zeros(size(wx));
    for j=1:size(pid,1)
        v( find(wx==pid(j,1))) =pid(j,2);
    end
    v=reshape(v,size(w2));
end
if strcmp(task,'back')
     wx=w2(:);
    v=zeros(size(wx));
    for j=1:size(pid,1)
        v( find(wx==pid(j,2))) =pid(j,1);
    end
    v=reshape(v,size(w2));
end


%% ===============================================



if 0
     [v pid     ]=recodeIDS('forward', w2 );
     [w2back pid2]=recodeIDS('back', v, pid );
     
end