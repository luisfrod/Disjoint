function G = graphTopology(topology,varargin)
%GRAPHTOPOLY Creates a graph with the atributes given 
%   depending on the topology chosen
%   topolgy: chooses the topology. Topologies implemented:
%       SpineLeaf
%       Portland
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
%       Portland: k
%           Number of nodes is computed by input argument k in layers:
%           Core layer: (k/2)^2 nodes. Each node only connects to Internet in upper layer. 
%               Will be called C1,C2...
%           Aggregation layer: 2*core nodes. This nodes are divided in pods. Each
%               pode has two aggregation nodes, each connecting to half the core 
%               nodes. Will be called A1,A2... 
%           Edge layer: same number as aggregation nodes. Each node connects to all
%               aggregation nodes in its pod. Will be called E1,E2...
%           Host layer: (k^3/4) nodes. Each node connects to only one node in edge 
%               layer. Since taken symmetric, each node in edge layer has the same
%               number of hosts. Will be called H1,H2...
%

switch topology
    case 'SpineLeaf'
        assert(nargin==4,'Error in number of inputs in SpineLeaf topology. Needs three aditional inputs: spine, leaf, hostperleaf')
        assert(isscalar(varargin{1}) & isscalar(varargin{2}) & isscalar(varargin{3}),'All additional inputs in SpineLeaf topology need to be scalars')
        G=graphSpineLeaf(varargin{1},varargin{2},varargin{3});
    case 'Portland'
        assert(nargin==2,'Error in number of inputs in Portland topology. Needs one aditional input: k')
        assert(isscalar(varargin{1}),'All additional inputs in Portland topology need to be scalars')
        G=graphPortland(varargin{1});
    otherwise
        error('Topology not supported. First argument can only be: SpineLeaf Portland')
end
end

