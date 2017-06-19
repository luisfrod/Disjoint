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
[paths1, totalCost] = dijkstra(netCostMatrix, source, dest);

U=[];
[sz, v]=size(U);
for i=1:sz-1
    U=[U; paths1(i) paths1(i+1)];
end
    
for j=1:N
    
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
    [v, sz2]=size(nextpath);
    indexinU=[];
    notz=[];
    for i=1:sz
        flagi=true;
        for z=1:sz2-1
           %sprintf('U-%d %d nextpath-%d %d',U(i,1), U(i,2), nextpath(z), nextpath(z+1))
            if U(i,1)==nextpath(z+1) && U(i,2)==nextpath(z)
                notz=[notz z];
                flagi=false;
                break;
            end
        end
        if flagi
            indexinU=[indexinU, i];
        end
    end
    
    U=U(indexinU,:);
    
    [v, sz2]=size(nextpath);
    for i=1:sz2-1
        if i==notz
            i=i+1;
            continue
        end
        U=[U; nextpath(i) nextpath(i+1)];
    end
end
 
    % Get matrix from paths
    [v, sz]=size(U);
    netCostMatrix=zeros(rows, cols);
    for i=1:v
        netCostMatrix(U(i,1),U(i,2))=1;%Since its a spanning tree, and is only garanted that the sum of the cost of the paths is minimum, not one path
    end

    netCostMatrix(netCostMatrix==0) = Inf;

% Out of the loops, find paths out of spanning tree
paths=edgeDisjointNaiveDijkstra(netCostMatrix,source,dest,N,true);