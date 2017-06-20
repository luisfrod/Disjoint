function paths=edgeDisjointPair(G,source,dest,N,matrix)
%EDGEDISJOINTPAIR Obtains N edge-disjoint paths in G for the 
%source and dest nodes using LBA algorithm.
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
[rows, cols]=size(netCostMatrix);

%Iterative Pair Edge Disjoint

%Do first dijkstra
[nextpath, totalCost] = dijkstra(netCostMatrix, source, dest);

U=[];
[v, sz]=size(nextpath);
for i=1:sz-1
    U=[U; nextpath(i) nextpath(i+1)];
end

for j=1:N-1
    
    [sz, v]=size(U);
    netCostMatrixchanged = netCostMatrix;
    % Do directed graph towards source in shortest path and with negative costs
    for i=1:1:sz
        netCostMatrixchanged(U(i,1),U(i,2))= Inf;
        netCostMatrixchanged(U(i,2),U(i,1))= -netCostMatrixchanged(U(i,2),U(i,1));
    end

    %Do dijkstra in modified graph
    [nextpath, totalCost]=dijkstra(netCostMatrixchanged, source, dest);
    if isempty(nextpath)
        break
    end
     
    %Find Union of both removing interlacing edges
    
        %Find interlacing edges
    [v, sz2]=size(nextpath);
    flagU=true(1,sz);
    notz=false(v,sz2);
    for i=1:sz
        for z=1:sz2-1
           %sprintf('U-%d %d nextpath-%d %d',U(i,1), U(i,2), nextpath(z), nextpath(z+1))
            if U(i,1)==nextpath(z+1) && U(i,2)==nextpath(z)
                notz(z)=true;
                flagU(i)=false;
                break;
            end
        end
    end
    
        %Do the union without interlacing edges
        
    U=U(flagU,:);
    
    [v, sz2]=size(nextpath);
    for i=1:sz2-1
        if notz(i)
            continue
        end
        U=[U; nextpath(i) nextpath(i+1)];
    end
end
 
    % Get matrix from paths
    [sz, v]=size(U);
    netCostMatrix=inf(rows, cols);
    for i=1:sz
        netCostMatrix(U(i,1),U(i,2))=1;%Since its a spanning tree, and is only garanted that the sum of the cost of the paths is minimum, not one path
    end

% Out of the loops, find paths out of spanning tree
paths=edgeDisjointNaiveDijkstra(netCostMatrix,source,dest,N,true);