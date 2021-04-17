


% ==============================================
%%   
% ===============================================

% r1=f_test(-1);
% r2=f_test2(-1);

funs={'f_test' 'f_test2'  'f_test3' }

b={};
for i=1:length(funs)
    w=feval(funs{i},-1)
    func=strrep(w{1},'@','')
    pr=w(2:end,:);
    if i>1
        pr(:,1)=stradd(pr(:,1),[func '.'],1);
        remfuns=stradd(funs(   setdiff(1:length(funs),  [i:length(funs)])   )','@',1)
        dep={[func '.dep' ] '' 'dependency from prev. functions'  remfuns }
        pr=[dep;pr];
    end
    lin={['inf' num2str(1000+i)]     ['============[ ' func ' ]===============']                          '' ''}
    b=[b; lin; pr];
end
    
% ==============================================
%  
% ===============================================

[m z parse q2]=paramgui(b,'uiwait',1,'close',1)

%  'inf98'      '*** cut tif to slices      '                                  '' ''   %    'inf1' 


% ==============================================
%%   
% ===============================================

eval(m)