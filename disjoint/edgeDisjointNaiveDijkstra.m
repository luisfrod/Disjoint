function paths=edgeDisjointNaiveDijkstra(G,source,dest,N,matrix)
%EDGEDISJOINTNAIVEDIJKSTRA Obtains N edge-disjoint paths in G for the 
%source and dest nodes.
%       Inputs:
%           G: Can be the graph of the topology or the netCostMatrix.
%           Source: Can be the name of the source node or the index
%           Dest: Can be the name of the destination node or the index
%           N: Number of paths to compute
%           matrix: logical. 1 to indicate G is a matrix or 0 to indicate
%           is a graph.
%       Output:
%           paths: Cell array composed of row vectors with the indices of 
%           the nodes of the path.

% Luis Félix Rodríguez Cano, 2017

assert(islogical(matrix));

if matrix
    netCostMatrix=G;
else
    netCostMatrix=full(adjacency(G));
end

%if ismatrix(G)
%    netCostMatrix=G;
%else
%    netCostMatrix=full(adjacency(G));
%else
    %error('First input needs to be a matrix or a graph');
%end

if ischar(source) && ischar(dest)
    source=findnode(G,source);
    dest=findnode(G,dest);
elseif isscalar(source) && isscalar(dest)
else
    error('Second and Third input need to be a string or an index of the matrix');
end

netCostMatrix(netCostMatrix==0) = Inf;

%Iterative Dijkstra

paths = cell(N,1);

for j=1:N
    paths{j}= dijkstra(netCostMatrix, source, dest);
    [v, sz]=size(paths{j});
    for i=1:sz-1
        netCostMatrix(paths{j}(i),paths{j}(i+1))= Inf;
    end
end
end