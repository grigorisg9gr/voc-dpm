function [pos,impos, dataid] = read_faces(clip_name, multi_person, dataid)
if nargin<2, multi_person=0; end
if nargin<3, dataid=1; end
conf=voc_config(); 
cachedir   = conf.paths.model_dir;

try 
    load([cachedir clip_name '_pos_faces']);
catch
    images = [conf.paths.frames_dir clip_name '/'];
    bboxes = [conf.paths.bboxes_dir clip_name '/'];
    img_list = dir([images,'*.png']); tot_img = length(img_list); 
    thres_add = round(max(tot_img/400,3)); % "step" for reading images
    cnt = 1 ; 
    numpos = 1;
    pos(1).im='dd'; pos(1).x1=1; pos(1).y1=1; pos(1).x2=1; pos(1).y2=1; pos(1).boxes=[1 1 1 1]; pos(1).flip=false; pos(1).dataids=1; pos(1).sizes=1; %dummy values to create the struct
    if ~multi_person
        while cnt<= tot_img
            [f_e, bbox] = read_pts_file(bboxes, [img_list(cnt).name(1:end-4) '.pts']);
            if ~f_e, cnt =cnt + 1; continue; end
            pos(numpos) = parse_pos(images, img_list(cnt).name, bbox, dataid);

            numpos = numpos + 1;
            dataid = dataid + 1;
            cnt =cnt + thres_add;
        end
        impos=pos; % in this case, there is one person per image, so the two structs are the same

    else
        numimpos = 1; 
        while cnt<= tot_img
            pts_l = dir([bboxes, [img_list(cnt).name(1:end-4) '*.pts']]); % if multiple people, then it's in the format [name]_kk.pts, otherwise [name].pts. We need to recognise both
            if isempty(pts_l), cnt =cnt + 1; continue; end
            impos(numimpos).im = [images img_list(cnt).name]; impos(numimpos).flip = false; 
            for k=1:length(pts_l)
                [~, bbox] = read_pts_file(bboxes, pts_l(k).name);
                pos(numpos) = parse_pos(images, img_list(cnt).name, bbox, dataid);
                impos(numimpos).boxes(k,:) = pos(numpos).boxes; impos(numimpos).sizes(k) = pos(numpos).sizes; 
                numpos = numpos + 1;
                dataid = dataid + 1;
            end
            impos(numimpos).dataids = dataid; dataid = dataid + 1; numimpos = numimpos + 1; 
            cnt =cnt + thres_add;
        end
    end
    save([cachedir clip_name '_pos_faces'],'pos','impos','dataid');
end
end

function pos_1 = parse_pos(path, name, bbox, dataid)
pos_1.im      = [path name];  
pos_1.x1      = bbox(1);
pos_1.y1      = bbox(2);
pos_1.x2      = bbox(3);
pos_1.y2      = bbox(4);
pos_1.boxes   = bbox;
pos_1.flip    = false;
pos_1.dataids = dataid;
pos_1.sizes   = (bbox(3)-bbox(1)+1)*(bbox(4)-bbox(2)+1);
end

function [f_e, box_dist] = read_pts_file(path_n, file)
try
    d=fopen([path_n '/' file],'r'); A = fscanf(d, '%c',21); % get rid of the dummy chars in the beginning
    n_points = fscanf(d, '%i'); A = fscanf(d, '%c',2); 
    tr = fscanf(d, '%f');
    box_dist = [tr(1), tr(2), tr(5), tr(4)];
    fclose(d); f_e = 1;
catch
    box_dist = []; f_e = 0; % file_exists
end
end


% function [pos,dataid] = read_faces(clip_name)
% 
% conf=voc_config(); 
% images = [conf.paths.frames_dir clip_name '/'];
% bboxes = [conf.paths.bboxes_dir clip_name '/'];
% img_list = dir([images,'*.png']); tot_img = length(img_list); 
% thres_add = round(max(tot_img/400,5)); % "step" for reading images
% cnt = 1 ; 
% numpos = 1; dataid=1 ; pos=[];
% while cnt<= tot_img
%     [f_e, bbox] = read_pts_file(bboxes, [img_list(cnt).name(1:end-4) '.pts']);
%     if ~f_e, cnt =cnt + 1; continue; end
%     pos(numpos).im = [images img_list(cnt).name];  
%     pos(numpos).x1      = bbox(1);
%     pos(numpos).y1      = bbox(2);
%     pos(numpos).x2      = bbox(3);
%     pos(numpos).y2      = bbox(4);
%     pos(numpos).boxes   = bbox;
%     pos(numpos).flip    = false;
%     pos(numpos).dataids = dataid;
%     pos(numpos).sizes   = (bbox(3)-bbox(1)+1)*(bbox(4)-bbox(2)+1);
%     
%     numpos = numpos + 1;
%     dataid = dataid + 1;
%     cnt =cnt + thres_add;
% end
% 
% end