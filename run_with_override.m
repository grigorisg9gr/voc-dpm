function conf = run_with_override(path1)
% grigoris, 3/2/2015
% this functions works as a wrapper function and can be called from the
% terminal in order to overwrite the default value/path of the voc_config()
    global VOC_CONFIG_OVERRIDE;
    VOC_CONFIG_OVERRIDE = @override_voc;
    global path_new; path_new = path1 ; conf=voc_config();
    startup; 
    train_dpm_for_all_clips_in_folder()