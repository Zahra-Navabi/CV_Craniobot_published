function latestfile = find_latestfile(Path)
% Find the latest made folder and use it as file path
dirc = dir(Path);
dirc = dirc(~cellfun(@isfolder,{dirc(:).name}));
[~,I] = max([dirc(:).datenum]);
if ~isempty(I)
    %Find the latest driectory name
    latestfile = dirc(I).name;
end
end

