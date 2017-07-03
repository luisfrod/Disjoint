function [G]=erdosRenyi(nv,p,Kreg)
%Funciton [G]=edosRenyi(nv,p,Kreg) generates a random graph based on
%the Erdos and Renyi algoritm where all possible pairs of 'nv' nodes are
%connected with probability 'p'. 
%
% Inputs:
%   nv - number of nodes 
%   p  - rewiring probability
%   Kreg - initial node degree of for regular graph (use 1 or even numbers)
%
% Output:
%   (Original)
%   G is a structure inplemented as data structure in this as well as other
%   graph theory algorithms.
%   G.Adj   - is the adjacency matrix (1 for connected nodes, 0 otherwise).
%   G.x and G.y -   are row vectors of size nv wiht the (x,y) coordinates of
%                   each node of G.
%   G.nv    - number of vertices in G
%   G.ne    - number of edges in G
%   (Modified Luis Rodríguez 29-Jun-17)
%   G is a Matlab Graph.
%   G.Nodes.Xpoint and G.Nodes.Ypoint are tables with the nodes coordenates.
%   Can be a good idea to plot with:
%   plot(G,'XData',G.Nodes.Xpoint,'YData',G.Nodes.Ypoint);
%
%Created by Pablo Blinder. blinderp@bgu.ac.il
%
%Last update 25/01/2005
%
% Modified by Luis Rodríguez 29-Jun-17 to return a Matlab Graph

%(Modified Luis Rodríguez 29-Jun-17)
if Kreg>=nv
    error('Kreg parameter, indicative of node degree, must be smaller than the number of nodes.');
end

%build regular lattice 
A=sparse(nv,nv);
Kreg=fix(abs(Kreg)/2);Kreg=(Kreg<1)+Kreg;

for k=1:Kreg
    A=sparse(A+diag(ones(1,length(diag(A,k))),k)+diag(ones(1,length(diag(A,nv-k))),nv-k));
end
ne0=nnz(A);
%find connected pairs
[v1,v2]=find(A);
% P=permPairs(nv);%my version is faster
Dis=(rand(length(v1),1)<=p);%pairs to disconnect
A(v1(Dis),v2(Dis))=0;
vDis=unique([v1(Dis),v2(Dis)]);%disconnected vertices
nDis=ne0-nnz(A);sum(Dis);

%cycle trough disconnected pairs
disconPairs=[v1(Dis),v2(Dis)];
for n=1:nDis
    %choose one of the vertices from the disconnected pair
    i=ceil(rand*size(disconPairs,1));
    j=logical(1+rand>0.5);
    vDisToRec=disconPairs(i,j);
    %find non adjacent vertices and reconnect
    adj=[find(A(:,vDisToRec)) ; find(A(vDisToRec,:))'];
    nonAdj=setdiff(1:nv,adj);
    vToRec=nonAdj(ceil(rand*length(nonAdj)));
    S=sort([vDisToRec vToRec]);
    A(S(1),S(2))=1;
end
[x,y]=getNodeCoordinates(nv);
%make adjacency matrix symetric
A=A+fliplr((flipud(triu(A))));
%G=struct('Adj',A,'x',x','y',y','nv',nv,'ne',nnz(A));

%(Modified Luis Rodríguez 29-Jun-17)
i=num2str((1:nv)');
j=cellstr(i);
nodestable=table(j,x,y,'VariableNames',{'Name';'Xpoint';'Ypoint'});
edgetable=edgeTableCostMatrix(A);
G=graph(edgetable,nodestable,'OmitSelfLoops');
end

function edgetable = edgeTableCostMatrix( NetCostMatrix )
%EDGETABLECOSTMATRIX Crates an edgetable with costs for a graph. The matrix
%   should be symmetric.
%   Input: 
%       NetCostMatrix: symmetric matrix.
%   Outpus:
%       Table with two columns: one for edges named 'EndNodes' and one for 
%       costs of each edge named 'Weight'.
%
%
%Luis Félix Rodríguez Cano 2017


edges=[];
costs=[];
count=1;
n=1;

[sz, sz2]=size(NetCostMatrix);
    for i=1:sz
        for j=count:sz
            if(NetCostMatrix(i,j)~=0 && NetCostMatrix(i,j)~=Inf)
                edges=[edges; i j];
                costs(n,1)=NetCostMatrix(i,j);
                n=n+1;
            end
        end
        count=count+1;
    end

edgetable = table(edges,costs,'VariableNames',{'EndNodes';'Weight'});

end


