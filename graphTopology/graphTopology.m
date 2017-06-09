function G = graphTopology(flagit,flaghosts,topology,varargin)
%GRAPHTOPOLY Creates a graph with the atributes given 
%   depending on the topology chosen
%Inputs:
%   flagit: flag to have an internet node or not
%   flaghosts: flag to have node hosts or not
%   topolgy: chooses the topology. Topologies implemented:
%       SpineLeaf
%       Portland
%       VL2
%   IT: flag to select if the internet node is added or not. True-adds it,
%       false-doesn't add it.
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
%       VL2: varargin can be:
%               k (dc=da=k)
%               dc, da
%               dc, da, agg_per_pod(number of aggregation nodes per pod)
%               Number of nodes is computed by input arguments in layers:
%           Core layer: da/2 nodes. Each node only connects to Internet in upper layer. 
%               Will be called C1,C2...
%           Aggregation layer: dc nodes. This nodes are divided in pods. Each
%               pode has two aggregation nodes, each connecting to all the core 
%               nodes. Will be called A1,A2... 
%           Edge layer: same number as aggregation nodes. Each node connects to all
%               aggregation nodes in its pod. Will be called E1,E2...
%           Host layer: 2*dc nodes. Each node connects to only one node in edge 
%               layer. Since taken symmetric, each node in edge layer has the same
%               number of hosts. Will be called H1,H2...
%
assert(islogical(flagit) & islogical(flaghosts),'First two inputs must be booleans')

switch topology
    case 'SpineLeaf'
        assert(nargin==6,'Error in number of inputs in SpineLeaf topology. Needs three aditional inputs: spine, leaf, hostperleaf')
        assert(isscalar(varargin{1}) & isscalar(varargin{2}) & isscalar(varargin{3}),'All additional inputs in SpineLeaf topology need to be scalars')
        G=graphSpineLeaf(flagit,flaghosts,varargin{1},varargin{2},varargin{3});
    case 'Portland'
        assert(nargin==4,'Error in number of inputs in Portland topology. Needs one aditional input: k')
        assert(isscalar(varargin{1}),'All additional inputs in Portland topology need to be scalars')
        G=graphPortland(flagit,flaghosts, varargin{1});
    case 'VL2'
        G=graphVL2(flagit,flaghosts,varargin{:});
    otherwise
        error('Topology not supported. First argument can only be: SpineLeaf Portland VL2')
end
end

