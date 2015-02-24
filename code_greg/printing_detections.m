function printing_detections(cls, ds, multi_person)
% Printing the detections overlaid on images and saving their detected bounding boxes. 
% There is the option of multi_person, which dictates how many bounding
% boxes we will save at most in each image. 

figure(1), set(gcf, 'Color','white')
set(gcf, 'nextplot','replacechildren', 'Visible','off');

conf=voc_config(); 
images = [conf.paths.frames_dir cls '/'];
img_list = dir([images,'*.png']); num_ids = length(img_list);
path_save_img = [conf.paths.bboxes_im_out_dir '/' cls '/']; unix(['mkdir -p ' path_save_img]);
bb_path = [conf.paths.bboxes_out_dir '/' cls '/']; unix(['mkdir -p ' bb_path]);
parfor i=1:num_ids
%     im = imread([images img_list(i).name]);
    tic_toc_print('%s: saving image: %d/%d\n', cls, i, num_ids);
    if ~isempty(ds{1,i})
        max_people = min(size(ds{1,i},1),multi_person);
%         showboxes(im,ds{1,i}(1:max_people,:));
        for m=1:max_people
            write_bb_to_file(bb_path, [img_list(i).name(1:end-4) '_' num2str(m-1) '.pts'], ds{1,i}(m,1:4))
        end
%         print(gcf, '-dpng', '-r0', [path_save_img img_list(i).name]);
    end
end
end


function write_bb_to_file(bb_path, name, bb)
fileID = fopen([bb_path name],'w'); %sprintf('%06d',i-1)
fprintf(fileID,'version: 1\n');
fprintf(fileID,'n_points: 4\n');
fprintf(fileID,'{\n');
bb1{1} = num2str(bb(1)); bb1{2} = num2str(bb(2)); bb1{3} = num2str(bb(3)); bb1{4} = num2str(bb(4));
fprintf(fileID,'%s %s\n',bb1{1},bb1{2});
fprintf(fileID,'%s %s\n',bb1{1},bb1{4});
fprintf(fileID,'%s %s\n',bb1{3},bb1{2});
fprintf(fileID,'%s %s\n',bb1{3},bb1{4});

fprintf(fileID,'}');
fclose(fileID); 
end