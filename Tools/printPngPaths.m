function printPngPaths(N,source,dest,tit,G,paths, extra_title, nodename,varargin)
%PRINTPNGPATHS Extracts to a png file a drawing of the topology with paths
%in it and with name and title stablished.
%   Inputs:
%       N: number of paths asked to compute.
%       source: index or name of source node to compute the paths.
%       dest: index or name of dest node to compute the paths.
%       tit: title of the topology.
%       G: Matlab graph of the topology.
%       paths: cell array composed of row vectors that represent the path.
%       extra_title: indicates which type of algorithm has been used to
%       find the paths.
%       nodename: true if source and dest are strings or false if they are
%       numbers. Also if the graph contains a graph with the names.
%       varargin: extra optional inputs to plot the graph of the topology.
%
% Luis Félix Rodríguez Cano 2017

switch extra_title
    case 1
        tit1=[tit,'-edge-normal'];
        tit2='Edge Normal';
    case 2
        tit1=[tit,'-edge-max'];
        tit2='Edge Max';
    case 3
        tit1=[tit,'-node-normal'];
        tit2='Node Normal';
    case 4
        tit1=[tit,'-node-max'];
        tit2='Node Max';
    otherwise
        error('Extra_title hasn''t a value within range.');
end

if nodename
    ordest=sprintf('N=%d, source=%s, dest=%s',N,source,dest);
else
    ordest=sprintf('N=%d, source=%d, dest=%d',N,source,dest);
end

fig=figure('Name',tit1,'NumberTitle','off');
clf(fig);

if nargin<9
    p=plotGraphtopology(G);
else
    p=plot(G,varargin{:});
end

plotPaths(p, paths);
title({tit;tit2;ordest});

if nodename
    xlabel(stringPaths(paths,G));
else
    xlabel(stringPaths(paths));
end

print(fig,[tit1 '.png'],'-dpng');

end

