
% pcreateDB(pax)
% pcreateDB('C:\Users\skoch\Desktop\deeplearning\DeNeRD\datset4')


function pcreateDB(pax)




% tot_brain_sects=1;
% for k=1:tot_brain_sects
    disp('first loop')
    %    tb=string(ls('dataset')); %get tb of images in training folder
    %     tb=string(ls('dataset')); %get tb of images in training folder
    
    
    
    %     tb(1:2)=[]; % delete first two entries because they are . and .. (???)
    %tb = sort_nat(tb);
    %tb(:,1)=strcat('dataset/', tb(:,1));
    %     tb(:,1)=fullfile(pwd, 'dataset/', tb(:,1));%#paul
    %     tb(:,1)=stradd(tb,[fullfile(pwd,'dataset') filesep],1)
    
    % pax=pwd;
    kk=dir(fullfile(pax,'sec*.png'));
    dum={kk(:).name}';
    tb(:,1)=cellfun(@(a) {[  pax filesep regexprep(a,'\s+','') ]} ,dum);
    %   tb(:,1)=stradd(regexprep(tb(:,1),'\s+',''),[pwd filesep],1)
    
    trainingdata=tb;
    trainingdata=array2table(trainingdata);
    trainingdata=table2cell(trainingdata);
    
    for j=1:size(tb,1)
        %disp('second loop')
        %         [num, location]=count_localmax(char(tb(j,1)));
        
        %         bounds = zeros(num,4);
        %         stats = regionprops('table',BW,'BoundingBox','MajorAxisLength','MinorAxisLength');
        
        %         for i=1:num
        %             close
        % %            bounds(i,:) = [location(i,1)-9,location(i,2)-9,18,18];
        % %             bounds(i,:) = [location(i,1)-4,location(i,2)-4,8,8]; %6,6,12,12
        % %             bounds(i,:)=stats.BoundingBox(i,:);
        %             %disp('end of second loop')
        %         end
        bounds = [ ]; % here a bouinding box is drawn in the top left corner of your image
        bounds3{j,1}=bounds;
        
        %disp('end of first loop')
    end
    
    s1 = horzcat(trainingdata,bounds3);
    s2{1,1}=s1;
    clear bounds3
    %     s1 = horzcat(trainingdata,bounds3);
    %     s2{k,1}=trainingdata;
    %     clear bounds3
 
training = vertcat(s2{1,1});
training = cell2table(training);
training.training1=char(training.training1);
training = table2cell(training);
training(:,1)=regexprep(training(:,1),'\s+$','');%regexprep(training(:,1),'\s+','');

%training = vertcat(s2{1:1,1});
% training = vertcat(s2{1:k,1});
% training = cell2table(training);
% training.training=char(training.training);
% training = table2cell(training);

save(fullfile(pax,'training.mat'), 'training');