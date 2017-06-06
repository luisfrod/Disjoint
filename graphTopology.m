function G = graphTopology(topology,varargin)
%GRAPHTOPOLY Creates a graph with the atributes given 
%   depending on the topology chosen
%   topolgy: chooses the topology. Topologies implemented:
%       3Tier: Based on layers
%       Portland(not implemented)
%
%   varagin: arguments used depending on the topology chosen:
%        3Tier: core, aggregation, edgesl
%           core: number of core nodes. Each node only connects to Internet in upper layer. 
%           Will be called C1,C2...
%           aggregation: number of aggregation nodes. Each node connects to all nodes in core layer.
%           Will be called A1,A2... 
%           edgesl: number of edge nodes per aggregation node. Each node connects to only one node 
%           in aggregation layer. Since taken symmetric, each node in aggregation layer has
%           the same number of edge nodes. Will be called E1,E2...
%       Portland
%

switch topology
    case '3Tier'
        assert(nargin==4,'Error in number of inputs in 3-Tier topology. Needs three aditional inputs: core, aggregation, edgesl')
        assert(isscalar(varargin{1}) & isscalar(varargin{2}) & isscalar(varargin{3}),'All additional inputs in 3-Tier topology need to be scalars')
        G=graph3Tier(varargin{1},varargin{2},varargin{3});
    otherwise
        error('Topology not supported. First argument can only be: 3Tier')
end
end

