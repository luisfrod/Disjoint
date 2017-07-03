function plotPaths(p, paths)
%PLOTPATHS plots the paths in the plot of a graph
%   Inputs:
%       p: plot of a graph
%       paths: cell array composed of row vectors that represent the path.
%
% Luis Félix Rodríguez Cano 2017

list_color={'c','r','g','k','y','m','b'};

count=1;
[sz v]=size(paths);
for j=1:sz
    count=count+1;
    if(count>7)
        count=1;
    end
    highlight(p,paths{j},'EdgeColor',list_color{count},'LineWidth',3);
end

end