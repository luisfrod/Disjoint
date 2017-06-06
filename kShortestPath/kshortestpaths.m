function [paths, cost] = kshortestpaths(network, stnodes, k)
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

    st = reshape(findnode(network, stnodes), [], 2);
    [s,t] = findedge(network);
    nnodes = numnodes(network);
    nflows = size(stnodes,1);
    A = full(sparse(s,t,network.Edges.Weight,nnodes,nnodes));
    % In kShortestPath edges==0 must be equal to Inf
    A(A==0) = Inf; 
    paths = cell(nflows,1);
    cost = cell(nflows,1);
    for i=1:nflows
        [paths{i}, cost{i}] = kShortestPath(A, st(i,1), st(i,2), k);
    end
end

