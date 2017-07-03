function p=plotGraphtopology(G,varargin)
%PLOTGRAPHTOPOLOGY plots graphs done by graphTopology function using X and 
%Y coordinates computed when it was created.
%
%   p=plotGraphtopology(G,varargin)
%
%   Inputs:
%       G: graph.
%       varargin: can specificy additional format in which to plot the graph
%       except for X and Y coordenates and name of nodes. If wanted to
%       change those better to use the plot function provided by Matlab.
%
%   Outputs:
%       p: graph plot.
%   
%
%Luis Félix Rodríguez Cano 2017

table=G.Nodes;
if(nargin>1)
    p=plot(G,'XData',table.Xpoint','YData',table.Ypoint','NodeLabel',table.Name,varargin{:});
else
    p=plot(G,'XData',table.Xpoint','YData',table.Ypoint','NodeLabel',table.Name,'Marker','x','NodeColor','r','MarkerSize',10);

end
end

