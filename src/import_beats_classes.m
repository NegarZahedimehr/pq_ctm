function import_beats_classes( beats_path )
% pull in the BeATS java classes
javaaddpath(fullfile( beats_path, 'target', 'classes') );
% Pull in BeATS lib jars
lib_jars = dir(fullfile(beats_path,'target','lib','*.jar'));
[prefix{1:numel(lib_jars)}] = deal(fullfile(beats_path,'target','lib'));
javaaddpath( cellfun(@fullfile, prefix, {lib_jars.name},'UniformOutput',false) );