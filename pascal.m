function pascal(cls, n, multi_person, note, dotrainval, testyear)
% Train and evaluate a model. 
%   pascal(cls, n, note, dotrainval, testyear)
%
%   The model will be a mixture of n star models, each of which
%   has 2 latent orientations.
%
% Arguments
%   cls           Object class to train and evaluate
%   n             Number of aspect ratio clusters to use
%                 (The final model has 2*n components)
%   note          Save a note in the model.note field that describes this model
%   dotrainval    Also evaluate on the trainval dataset
%                 This is used to collect training data for context rescoring
%   testyear      Test set year (e.g., '2007', '2011')

% AUTORIGHTS
% -------------------------------------------------------
% Copyright (C) 2011-2012 Ross Girshick
% Copyright (C) 2008, 2009, 2010 Pedro Felzenszwalb, Ross Girshick
% 
% This file is part of the voc-releaseX code
% (http://people.cs.uchicago.edu/~rbg/latent/)
% and is available under the terms of an MIT-like license
% provided in COPYING. Please retain this notice and
% COPYING if you use this file (or a portion of it) in
% your project.
% -------------------------------------------------------

startup;

conf = voc_config();
cachedir = conf.paths.model_dir;
testset = conf.eval.test_set;

% TODO: should save entire code used for this run
% Take the code, zip it into an archive named by date
% print the name of the code archive to the log file
% add the code name to the training note
timestamp = datestr(datevec(now()), 'dd.mmm.yyyy:HH.MM.SS');

% Set the note to the training time if none is given
if nargin < 4
  note = timestamp;
end

% Don't evaluate trainval by default
if nargin < 4
  dotrainval = false;
end

if nargin < 5
  % which year to test on -- a string, e.g., '2007'.
  testyear = conf.pascal.year;
end

% Record a log of the training and test procedure
diary(conf.training.log([cls '-' timestamp]));

% Train a model (and record how long it took)
th = tic;
model = pascal_train(cls, n, multi_person-1, note);
toc(th);

% Free the feature vector cache memory
fv_cache('free'); % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Lower threshold to get high recall
model.thresh = min(conf.eval.max_thresh, model.thresh);
model.interval = conf.eval.interval;


% Collect detections on the test set
suffix = testyear; 
ds = pascal_test(model, testset, testyear, suffix);
printing_detections(model.class, ds, multi_person)

% ds_neg_1 = test_on_pascal_nonperson(model,'train');
% ds_neg_2 = test_on_pascal_nonperson(model,'val');
% printing_detections(model.class, ds_neg_1, 10)
% printing_detections(model.class, ds_neg_1, 10)

% cnt=0;
% for i=1:length(ds_neg_2)
%     if ~isempty(ds_neg_2{i}), cnt=cnt+1;end
% end


% %% printing the detection images 
% figure(1), set(gcf, 'Color','white')
% set(gcf, 'nextplot','replacechildren', 'Visible','off');
% 
% cls = model.class; 
% images = [conf.paths.frames_dir cls '/'];
% img_list = dir([images,'*.png']); num_ids = length(img_list);
% path_save_img = [conf.paths.bboxes_im_out_dir '/' cls '/']; unix(['mkdir -p ' path_save_img]);
% bb_path = [conf.paths.bboxes_out_dir '/' cls '/']; unix(['mkdir -p ' bb_path]);
% for i=1:num_ids
%     im = imread([images img_list(i).name]);
%     fprintf('%s: saving image: %d/%d\n', cls, i, num_ids);
%     if ~isempty(ds{1,i})
%         max_people = min(size(ds{1,i},1),multi_person);
% %         showboxes(im,ds{1,i}(1:max_people,:));
%         for m=1:max_people
%             write_bb_to_file(bb_path, [img_list(i).name(1:end-4) '_' num2str(m-1) '.pts'], ds{1,i}(m,1:4))
%         end
% %         print(gcf, '-dpng', '-r0', [path_save_img img_list(i).name]);
%     end
% end
% 
% function write_bb_to_file(bb_path, name, bb)
% fileID = fopen([bb_path name],'w'); %sprintf('%06d',i-1)
% fprintf(fileID,'version: 1\n');
% fprintf(fileID,'n_points: 4\n');
% fprintf(fileID,'{\n');
% bb1{1} = num2str(bb(1)); bb1{2} = num2str(bb(2)); bb1{3} = num2str(bb(3)); bb1{4} = num2str(bb(4));
% fprintf(fileID,'%s %s\n',bb1{1},bb1{2});
% fprintf(fileID,'%s %s\n',bb1{1},bb1{4});
% fprintf(fileID,'%s %s\n',bb1{3},bb1{2});
% fprintf(fileID,'%s %s\n',bb1{3},bb1{4});
% 
% fprintf(fileID,'}');
% fclose(fileID); 
