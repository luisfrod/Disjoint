function paths=nodeDisjointSplittingV2(G,source,dest,matrix)
%NODEDISJOINTV2 Performs nodesplitting algorithmV2 to find a pair of
%disjoint paths with node-disjointness.
%       Inputs:
%           G: Can be the graph of the topology or the netCostMatrix.
%           Source: Can be the name of the source node or the index
%           Dest: Can be the name of the destination node or the index
%           matrix: logical. 1 to indicate G is a matrix or 0 to indicate
%           is a graph.
%       Output:
%           paths: Cell array composed of row vectors with the indices of 
%           the nodes of the path.

%Luis Félix Rodríguez Cano 2017

%Luis Félix Rodríguez Cano 2017

assert(islogical(matrix));

if matrix
    netCostMatrix=G;
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

%for j=1:N-1
    
    [sz, v]=size(U);
    netCostMatrixchanged = netCostMatrix;
    
    % Replace all edges in path with arcs towards destination
    
    for i=1:sz
        netCostMatrixchanged(U(i,2),U(i,1))= Inf;
    end
    
    
    % Division of nodes in the path
    
    %Find which nodes are the new ones
    splitting_nodes=[U(:,1)' U(:,2)'];
    splitting_nodes=unique(splitting_nodes);
    splitting_nodes=splitting_nodes(splitting_nodes~=source & splitting_nodes~=dest);
    [v szn]=size(splitting_nodes);
    
    %Preallocate new matrix with splitting nodes
    netCostMatrixchanged(rows+szn,cols+szn)=0;
    netCostMatrixchanged(netCostMatrixchanged==0) = Inf;
    
    %Translate new nodes with new position in matrix of duplicate
    splitting_nodes=[splitting_nodes' (rows+1:rows+szn)'];
    
    %Add new positions in matrix for divided nodes
    %Taking of the old one connected to previous in path and the new one to the next in path
    for i=1:szn
        %netCostMatrixchanged(splitting_nodes(i,2),:)= netCostMatrixchanged(splitting_nodes(i,1),:); %Make new subnod unidirectional to next in path
        %netCostMatrixchanged(splitting_nodes(i,1),:)= Inf; %Make one subnod with only arriving nodes
        %netCostMatrixchanged(splitting_nodes(i,1),splitting_nodes(i,2))= 0; %Do arc towards dest between them
        
        netCostMatrixchanged(splitting_nodes(i,2),:)= netCostMatrixchanged(splitting_nodes(i,1),:); %Make new subnod unidirectional to next in path
        netCostMatrixchanged(splitting_nodes(i,1),:)= Inf; %Make one subnod with only arriving nodes
        netCostMatrixchanged(splitting_nodes(i,2),splitting_nodes(i,1))= 0;
    end
    
    netCostMatrixchanged(:,source)= Inf;
    netCostMatrixchanged(dest,:)= Inf;
    
    %Do directed graph towards source in shortest path and with negative costs
    for i=1:sz
        if (U(i,1)==source)
            netCostMatrixchanged(U(i,2),U(i,1))=-netCostMatrixchanged(U(i,1),U(i,2));
        else
            [sr sc]=find(splitting_nodes==U(i,1));
            netCostMatrixchanged(U(i,2),splitting_nodes(sr,2))=-netCostMatrixchanged(splitting_nodes(sr,2),U(i,2));
            netCostMatrixchanged(splitting_nodes(sr,2),U(i,2))=Inf;
        end
        netCostMatrixchanged(U(i,1),U(i,2))= Inf;
    end

    %Do dijkstra in modified graph
    [nextpath, totalCost]=dijkstra(netCostMatrixchanged, source, dest);
    %if isempty(nextpath)
    %    break
    %end

    
    % Translate new nodes in nextpath to old nodes
    [v, sz2]=size(nextpath);
    passpath=true(sz2,1);
    for i=1:sz2
        %[x y]=find(splitting_nodes() == nextpath(i))
        %if x~=0 && y~=0
        %   nextpath()
        %end
        if ismember(nextpath(i),splitting_nodes(:,2))
            passpath(i)=false;
        end
    end
    
    nextpath=nextpath(passpath);
    
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
%end
 
    % Get matrix from paths
    [sz, v]=size(U);
    netCostMatrix=inf(rows, cols);
    for i=1:sz
        netCostMatrix(U(i,1),U(i,2))=1;%Since its a spanning tree, and is only garanted that the sum of the cost of the paths is minimum, not one path
    end

% Out of the loops, find paths out of spanning tree
paths=edgeDisjointNaiveDijkstra(netCostMatrix,source,dest,2,true);
end

