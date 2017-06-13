function p=plotGraphtopology(G,varargin)
%PLOTGRAPHTOPOLOGY plots graphs done by graphTopology function using X and
%                   Y coordinates computed when it was created
%       varargin can specificy additional format in which to plot the graph
%       except for X and Y coordenates and name of nodes. If wanted to
%       change those better to use the plot function provided by Matlab.
%
%Luis F�lix Rodr�guez Cano 2017

table=G.Nodes;
if(nargin>1)
    p=plot(G,'XData',table.Xpoint','YData',table.Ypoint','NodeLabel',G.Nodes.Name,varargin{:});
else
    p=plot(G,'XData',table.Xpoint','YData',table.Ypoint','NodeLabel',G.Nodes.Name,'Marker','x','NodeColor','r','MarkerSize',10);

end
end

