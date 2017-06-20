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

