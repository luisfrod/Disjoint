function [paths, cost] = kshortestpathsx(network, stnodes, k, varargin)
%KSHORTESTPATHS Obtains the K-shortespaths in NETWORK for the source and
%target nodes contained in STNODES. STNODES can be a cell array of
%character vectors or a numeric array. STNODES has two columns and as many
%rows as source-target pairs.
%   For each source and target pair, it returns a PATHS cell-array element
%   with the k-paths. Each path is defined as a set of node indexes. COST
%   is a cell-array such that each element stores the cost of a k-shortest
%   path.

% Miguel Ángel López Carmona, UAH
% This function is based on Yen's k-Shortest Path algorithm (1971)
% This function calls a slightly modified function dijkstra() 
% by Xiaodong Wang 2004.

    flag=true;
    if nargin>3
        if(strcmp(varargin{1},'unweight'))
        A=full(adjacency(network));
        flag=false;
        end
        %if(strcmp(varargin{1},'weight'))
        %flag=true;
        %end
    end
    if flag
        [s,t] = findedge(network);
        nnodes = numnodes(network);
        A = full(sparse(s,t,network.Edges.Weight,nnodes,nnodes));
    end
    st = reshape(findnode(network, stnodes), [], 2);
    % In kShortestPath edges==0 must be equal to Inf
    A(A==0) = Inf;
    nflows = size(stnodes,1);
    paths = cell(nflows,1);
    cost = cell(nflows,1);
    for i=1:nflows
        [paths{i}, cost{i}] = kShortestPath(A, st(i,1), st(i,2), k);
    end
end

