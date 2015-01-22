function [neg] = pascal_data(cls, year, dataid)
% Get training data from the PASCAL dataset.
%   [pos, neg, impos] = pascal_data(cls, year)
%
% Return values
%   pos     Each positive example on its own
%   neg     Each negative image on its own
%   impos   Each positive image with a list of foreground boxes
%
% Arguments
%   cls     Object class to get examples for
%   year    PASCAL dataset year

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

if nargin<3
    dataid=0;
end
conf       = voc_config('pascal.year', year);
dataset_fg = conf.training.train_set_fg;
dataset_bg = conf.training.train_set_bg;
cachedir   = conf.paths.model_dir;
VOCopts    = conf.pascal.VOCopts;

try
  load([cachedir cls '_' dataset_fg '_' year]);
catch
  % Positive examples from the foreground dataset
%   ids      = textread(sprintf([conf.paths.pascal_im VOCopts.imgsetpath], dataset_fg), '%s');

  % Negative examples from the background dataset
  ids    = textread(sprintf([conf.paths.pascal_im VOCopts.imgsetpath], dataset_bg), '%s');
  neg    = [];
  numneg = 0;
  for i = 1:length(ids);
    tic_toc_print('%s: parsing negatives (%s %s): %d/%d\n', ...
                  cls, dataset_bg, year, i, length(ids));
    rec = PASreadrecord(sprintf([conf.paths.pascal_im VOCopts.annopath], ids{i}));
    clsinds = strmatch(cls, {rec.objects(:).class}, 'exact');
    if length(clsinds) == 0
      dataid             = dataid + 1;
      numneg             = numneg+1;
      neg(numneg).im     = [conf.paths.pascal_im rec.imgname(9:end)];
      neg(numneg).flip   = false;
      neg(numneg).dataid = dataid;
    end
  end
  
  save([cachedir cls '_' dataset_fg '_' year], 'neg');
end
