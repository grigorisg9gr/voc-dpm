function ds = test_on_pascal_nonperson(model, dataset_bg)
% Based on the original pascal_test function. However, it is set to test
% the model on the PASCAL dataset (only the images that do not contain
% faces). 
% Compute bounding boxes in a test set.
%   ds = pascal_test(model, testset, year, suffix)
%
% Return value
%   ds      Detection clipped to the image boundary. Cells are index by image
%           in the order of the PASCAL ImageSet file for the testset.
%           Each cell contains a matrix who's rows are detections. Each
%           detection specifies a clipped subpixel bounding box and its score.
% Arguments
%   model   Model to test

if nargin<2, dataset_bg='train'; end
conf = voc_config();
cachedir = conf.paths.model_dir;
VOCopts    = conf.pascal.VOCopts;
cls = model.class; 


% run detector in each image
try
  load([cachedir cls '_boxes_pascal_not_person_on_' dataset_bg]);
catch
    ids    = textread(sprintf([conf.paths.pascal_im VOCopts.imgsetpath], dataset_bg), '%s');  
    num_ids = length(ids);
    ds_out = cell(1, num_ids);
    bs_out = cell(1, num_ids);
    non_face = zeros([1 num_ids]); 
    th = tic();
    for i = 1:num_ids;
        rec = PASreadrecord(sprintf([conf.paths.pascal_im VOCopts.annopath], ids{i}));
        clsinds = strmatch('person', {rec.objects(:).class}, 'exact');
        if isempty(clsinds)
            fprintf('%s: testing (pascal nonface): %d/%d\n', cls, i, num_ids); 
            non_face(i) = 1; 
            im = imread([conf.paths.pascal_im rec.imgname(9:end)]);
            [ds, bs] = imgdetect(im, model, model.thresh);
            if ~isempty(bs)
              unclipped_ds = ds(:,1:4);
              [ds, bs, rm] = clipboxes(im, ds, bs);
              unclipped_ds(rm,:) = [];

              % NMS
              I = nms(ds, 0.3);
              ds = ds(I,:);
              bs = bs(I,:);
              unclipped_ds = unclipped_ds(I,:);

              % Save detection windows in boxes
              ds_out{i} = ds(:,[1:4 end]);

              % Save filter boxes in parts
              if model.type == model_types.MixStar
                % Use the structure of a mixture of star models 
                % (with a fixed number of parts) to reduce the 
                % size of the bounding box matrix
                bs = reduceboxes(model, bs);
                bs_out{i} = bs;
              else
                % We cannot apply reduceboxes to a general grammar model
                % Record unclipped detection window and all filter boxes
                bs_out{i} = cat(2, unclipped_ds, bs);
              end
            else
              ds_out{i} = [];
              bs_out{i} = [];
            end
        end
    end
  
  th = toc(th);
  ds = ds_out;
  bs = bs_out;
  save([cachedir cls '_boxes_pascal_not_person_on_' dataset_bg], ...
       'ds', 'bs', 'th', 'non_face');
  fprintf('Testing took %.4f seconds\n', th);
end
