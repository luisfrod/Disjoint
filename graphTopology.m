function G = graphTopology(topology,varargin)
%GRAPHTOPOLY Creates a graph with the atributes given 
%   depending on the topology chosen
%   topolgy: chooses the topology. Topologies implemented:
%       SpineLeaf
%       Portland(not implemented)
%
%   varagin: arguments used depending on the topology chosen:
%       SpineLeaf: spine, leaf, hostperleaf
%           Spine: number of spine nodes. Each node only connects to Internet in upper layer. 
%           Will be called S1,S2...
%           Leaf: number of leaf nodes. Each node connects to all nodes in spine layer.
%           Will be called L1,L2... 
%           Hostsperleaf: number of hosts per leaf node. Each node connects to only one node 
%           in leaf layer. Since taken symmetric, each node in leaf layer has
%           the same number of hosts. Will be called H1,H2...
%       Portland
%

switch topology
    case 'SpineLeaf'
        assert(nargin==4,'Error in number of inputs in 3-Tier topology. Needs three aditional inputs: core, aggregation, edgesl')
        assert(isscalar(varargin{1}) & isscalar(varargin{2}) & isscalar(varargin{3}),'All additional inputs in 3-Tier topology need to be scalars')
        G=graphSpineLeaf(varargin{1},varargin{2},varargin{3});
    otherwise
        error('Topology not supported. First argument can only be: 3Tier')
end
end

