%GRAPH3TIER Creates a graph with topology Three-Tier divided in layers
%           Function used by Graphtopology
%   core: number of core nodes. Each node only connects to Internet in upper layer. 
%       Will be called C1,C2...
%   aggregation: number of aggregation nodes. Each node connects to all nodes in core layer.
%       Will be called A1,A2... 
%   edgesl: number of edge nodes per aggregation node. Each node connects to only one node 
%       in aggregation layer. Since taken symmetric, each node in aggregation layer has
%       the same number of edge nodes. Will be called E1,E2...
%