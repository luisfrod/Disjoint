function paths = nodeDisjointFlow(G,source,dest,N,matrix)
%NODEDISJOINTFLOW Performs node-disjoint path finding algorithm.
%It splits each node in two and performs a max flow algorithm.
%       Inputs:
%           G: Can be the graph of the topology or the netCostMatrix.
%           Source: Can be the name of the source node or the index
%           Dest: Can be the name of the destination node or the index
%           N: Number of paths to compute.
%           matrix: logical. 1 to indicate G is a matrix or 0 to indicate
%           is a graph.
%       Output:
%           paths: Cell array composed of row vectors with the indices of 
%           the nodes of the path.

%Luis Félix Rodríguez Cano 2017

assert(islogical(matrix));

if matrix
    netCostMatrix=G;
    G=graph(G);
else
    netCostMatrix=full(adjacency(G));
end

if ischar(source) && ischar(dest)
    source=findnode(G,source);
    dest=findnode(G,dest);
elseif isscalar(source) && isscalar(dest)
else
    error('Second and Third input need to be a string or an index of the matrix');
end

%netCostMatrix(netCostMatrix==0) = Inf;
[rows, cols]=size(netCostMatrix);

splitting_nodes=[1:rows];

splitting_nodes=splitting_nodes(splitting_nodes~=source & splitting_nodes~=dest);
[v szn]=size(splitting_nodes);

    %Preallocate new matrix with splitting nodes
    netCostMatrix(rows+szn,cols+szn)=0;
    
        %Translate new nodes with new position in matrix of duplicate
    splitting_nodes=[splitting_nodes' (rows+1:rows+szn)'];
    
        %Add new positions in matrix for divided nodes
    %Taking of the old one connected to previous in path and the new one to the next in path
    for i=1:szn
        netCostMatrix(splitting_nodes(i,2),:)= netCostMatrix(splitting_nodes(i,1),:); %Make new subnod unidirectional to next in path
        netCostMatrix(splitting_nodes(i,1),:)= 0; %Make one subnod with only arriving nodes
        netCostMatrix(splitting_nodes(i,1),splitting_nodes(i,2))= 0.001;
    end
    
    netCostMatrix(:,source)= 0;
    netCostMatrix(dest,:)= 0;
    
    
    G=digraph(netCostMatrix,'OmitSelfLoops');
    
    [mf, DG] = maxflow(G,source,dest);
    
    netCostMatrix=full(adjacency(DG));
    
    paths=edgeDisjointNaiveDijkstra(netCostMatrix,source,dest,N,true);
    
    % Translate new nodes in nextpath to old nodes
    
    for j=1:size(paths)
    [v, sz2]=size(paths{j});
    passpath=true(sz2,1);
    for i=1:sz2
        if ismember(paths{j}(i),splitting_nodes(:,2))
            passpath(i)=false;
        end
    end
    
    paths{j}=paths{j}(passpath);
    end

end