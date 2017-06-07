function p=plotGraphtopology(G,varargin)
%PLOTGRAPHTOPOLOGY plots graphs done by graphTopology function using X and
%                   Y coordinates computed when it was created
%       varargin can specificy additional format in which to plot the graph
%       except for X and Y coordenates and name of nodes. If wanted to
%       change those better to use the plot function provided by Matlab.

table=G.Nodes;
X=table.Xpoint';
Y=table.Ypoint';
if(nargin>1)
    p=plot(G,'XData',X,'YData',Y,'NodeLabel',G.Nodes.EndNodes,varargin{:});
else
    p=plot(G,'XData',X,'YData',Y,'NodeLabel',G.Nodes.EndNodes,'Marker','x','NodeColor','r','MarkerSize',10);

end
end

