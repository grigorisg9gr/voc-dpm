function train_dpm_for_all_clips_in_folder
% cd /vol/atlas/homes/grigoris/external/dpm_matlab/voc-dpm/; startup; train_dpm_for_all_clips_in_folder
try 
    matlabpool open 4
catch
end
conf=voc_config(); 
% conf.paths.bboxes_dir
dir1= dir(conf.paths.bboxes_dir); 
for par_fold=3:length(dir1) %3
    if dir1(par_fold).isdir
        try
            fprintf('running for clip %s\n', dir1(par_fold).name);
            pascal(dir1(par_fold).name,1,1);
        catch
            fprintf('The clip of %s could not run successfully\n', dir1(par_fold).name);
        end
    end
end
end

