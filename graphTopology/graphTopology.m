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
%       Altoona Facebook
%
%   varagin: arguments used depending on the topology chosen:
%       SpineLeaf: spine, leaf and if flaghosts is true: hostperleaf
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
%               Number of nodes is computed by input arguments in layers:
%           Core layer: da/2 nodes. Each node only connects to Internet in upper layer. 
%               Will be called C1,C2...
%           Aggregation layer: dc nodes. This nodes are divided in pods. There are
%           2 aggregation nodes per pod, each aggregation node connects to all 
%           the core nodes. Will be called A1,A2... 
%           Edge layer: same number as aggregation nodes. Each node connects to all
%               aggregation nodes in its pod. Will be called E1,E2...
%           Host layer: 2*dc nodes. Each node connects to only one node in edge 
%               layer. Since taken symmetric, each node in edge layer has the same
%               number of hosts. Will be called H1,H2...
%       Altoona Facebook:
%               m: number of pods of edges
%               n: number of pods of TOR
%               if flaghosts is true: one additional for the number of hosts per TOR
%               Number of nodes is computed by input arguments m and n in layers:
%           Edge/Core layer: 4*m nodes. Each node only connects to Internet in upper layer. 
%               Will be called E1,E2...
%           Spine layer: 48*4 nodes. This nodes are divided in 4 pods. Each
%               pod ha 48 aggregation nodes, all nodes in a pod connect to one node
%               in each pod in the upper layer, the one with the same index of the pod
%               in this layer. Will be called S1,S2... 
%           Fabric layer: 4*n nodes. Each pod has 4 nodes. Each node in a pod connects to all nodes in an
%               upper layer pod. The upper layer pod with the same index of the respective index
%               of the node inside the current layer pod. Will be called F1,F2...
%           TOR layer: 48*n nodes. Each node connects to all fabric nodes in its pod.
%               Will be called T1,T2...
%           Host layer: hostperTOR*n nodes. Each node connects to only one node in TOR 
%               layer. Since taken symmetric, each node in edge layer has the same
%               number of hosts. Will be called H1,H2...
%
%Luis Félix Rodríguez Cano 2017

assert(islogical(flagit) & islogical(flaghosts),'First two inputs must be logical')

switch topology
    case 'SpineLeaf'
        if flaghosts
            assert(nargin==6,'Error in number of inputs in SpineLeaf topology. Needs three aditional inputs: spine, leaf, hostperleaf')
            assert(isscalar(varargin{1}) & isscalar(varargin{2}) & isscalar(varargin{3}),'All additional inputs in SpineLeaf topology need to be scalars')
            G=graphSpineLeaf(flagit,flaghosts,varargin{1},varargin{2},varargin{3});
        else
            assert(nargin==5 || nargin==6,'Error in number of inputs in SpineLeaf topology. Needs two aditional inputs: spine, leaf')
            assert(isscalar(varargin{1}) & isscalar(varargin{2}),'All additional inputs in SpineLeaf topology need to be scalars')
            G=graphSpineLeaf(flagit,flaghosts,varargin{1},varargin{2});
        end
    case 'Portland'
        assert(nargin==4,'Error in number of inputs in Portland topology. Needs one aditional input: k')
        assert(isscalar(varargin{1}),'All additional inputs in Portland topology need to be scalars')
        G=graphPortland(flagit,flaghosts, varargin{1});
    case 'VL2'
        G=graphVL2(flagit,flaghosts,varargin{:});
    case 'AltoonaFacebook'
        assert(nargin==5 || nargin==6,'Error in number of inputs in AltoonaFacebook topology. Needs two or three aditional inputs: m pods of edges, n pods of TOR and if flaghosts is true the number of hosts per TOR')
        assert(isscalar(varargin{1}) & isscalar(varargin{2}),'All additional inputs in AltoonaFacebook topology need to be scalars')
        G=graphAltoonaFacebook(flagit,flaghosts,varargin{:});
    otherwise
        error('Topology not supported. Topology can only be: SpineLeaf Portland VL2 AltoonaFacebook')
end
end

function G=graphSpineLeaf(flagit,flaghosts, spine, leaf, varargin)
%GRAPHSPINELIEAF Creates a graph with topology spineleaf divided in layers
%           Function used by Graphtopology
%   Inputs:
%       flagit: flag to have an internet node or not
%       flaghosts: flag to have node hosts or not
%       Spine: number of spine nodes. Each node only connects to Internet in upper layer. 
%           Will be called S1,S2...
%       Leaf: number of leaf nodes. Each node connects to all nodes in spine layer.
%           Will be called L1,L2... 
%       Hostsperleaf: number of hosts per leaf node. Each node connects to only one node 
%           in leaf layer. Since taken symmetric, each node in leaf layer has
%           the same number of hosts. Will be called H1,H2...
%
%Luis Félix Rodríguez Cano 2017

if nargin==5
    hostsperleaf=varargin{1};
end

if flagit
    it=1;
    posnode=it;
else
    posnode=0;
    it=0;
end

if ~flaghosts
    hostsperleaf=0;
end

%Preallocation
[endnodes,layern,Xpoint,Ypoint]=preallocate_nodetablevariables(spine+leaf+hostsperleaf*leaf+it);
edges(it*spine+spine*leaf+leaf*hostsperleaf,2)=1;

%TODO think of better way to compute first difference and start plotting points

%Compute values for plotting
differenceX=1;
startX=0; %Compute startX as the difference between total width and width of present layer divided by 2.
differenceY=1;
startY=3;
if spine>leaf
    big=spine;
else
    big=leaf;
end
width=(big-1)*differenceX;

%Internet layer
[endnodes,layern,Xpoint,Ypoint]=internet_layer(flagit,endnodes,layern,Xpoint,Ypoint,width,startY);

%Spine layer
[endnodes,edges,layern,Xpoint,Ypoint,posnode,startY]=core_layer(flagit,'S',endnodes,edges,layern,Xpoint,Ypoint,posnode,startY,differenceY,differenceX,width,spine);

%Leaf layer
if flagit
    posedge=spine;
else
    posedge=0;
end
posnode_leaflayer=posnode;
[endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startY]=Toall_layer_before('L',endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startY,differenceY,differenceX,width,leaf,it,spine,2);

%Host layer
[endnodes,edges,layern,Xpoint,Ypoint]=host_per_node(flaghosts,endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startX,startY,differenceY,width,hostsperleaf,leaf,posnode_leaflayer,3);

%variable_names_node_table = {'EndNodes';'Xpoint';'Ypoint';'Layer'};
%layer=categorical(layern,0:3,{'internet' 'spine' 'leaf' 'host'});
%NodeTable=table(endnodes,Xpoint,Ypoint,layer,'VariableNames',variable_names_node_table);
%EdgeTable=table(edges,'VariableNames',{'EndNodes'});
G=graph(table(edges,'VariableNames',{'EndNodes'}),table(endnodes,Xpoint,Ypoint,categorical(layern,0:3,{'internet' 'spine' 'leaf' 'host'}),'VariableNames',{'Name';'Xpoint';'Ypoint';'Layer'}));

end

function G = graphVL2(flagit,flaghosts,varargin)
%GRAPHVL2 Creates a graph with topology graphVL2 divided in layers
%           Function used by Graphtopology
%   Inputs:
%       flagit:flag to have an internet node or not
%       flaghosts:flag to have node hosts or not
%       varargin can be:
%           k (dc=da=k)
%           dc, da
%
%   Number of nodes is computed by input arguments in layers:
%   Core layer: da/2 nodes. Each node only connects to Internet in upper layer. 
%       Will be called C1,C2...
%   Aggregation layer: dc nodes. This nodes are divided in pods. There are
%       2 aggregation nodes per pod, each aggregation node connects to all 
%       the core nodes. Will be called A1,A2... 
%   Edge layer: same number as aggregation nodes. Each node connects to all
%       aggregation nodes in its pod. Will be called E1,E2...
%   Host layer: 2*dc nodes. Each node connects to only one node in edge 
%       layer. Since taken symmetric, each node in edge layer has the same
%       number of hosts. Will be called H1,H2...
%
%Luis Félix Rodríguez Cano 2017

%Compute values for topology
if nargin==3
    k=varargin{1};
    core=k/2;
    aggregation=k;
    TOR=k^2/4;%edges
    ecm=2*k;%O 20 o 40
else
    if nargin==4
        dc=varargin{1};
        assert(mod(varargin{2},2)==0,'Error, da must be an even number.')
        da=varargin{2};
    else
        error('Incorrect input arguments: has to be ');
    end
    
    core=da/2;
    aggregation=dc;
    TOR=da*dc/4;%edges
    ecm=2*dc;%O 20 o 40
    
end
agg_per_pod=2;
assert(mod(varargin{1},2)==0,'Error, dc or k must be an even number.')

%Compute values for plotting
differenceX=1;
startX=0; %Compute startX as the difference between total width and width of present layer divided by 2.
differenceY=1;
startY=4;
width=(TOR-1)*differenceX;

%Preallocation
if flagit
    it=1;
    posnode=it;
else
    posnode=0;
    it=0;
end

if ~flaghosts
    ecm=0;
end
[endnodes,layern,Xpoint,Ypoint]=preallocate_nodetablevariables(aggregation+TOR+TOR*ecm+core+posnode);
edges(it*core+aggregation*core+TOR*agg_per_pod+aggregation*ecm,2)=1;

%Internet layer
[endnodes,layern,Xpoint,Ypoint]=internet_layer(flagit,endnodes,layern,Xpoint,Ypoint,width,startY);

%Core layer
[endnodes,edges,layern,Xpoint,Ypoint,posnode,startY]=core_layer(flagit,'C',endnodes,edges,layern,Xpoint,Ypoint,posnode,startY,differenceY,differenceX,width,core);

%Aggregation layer
if flagit
    posedge=core;
else
    posedge=0;
end
posnode_agglayer=posnode;
[endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startY]=Toall_layer_before('A',endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startY,differenceY,differenceX,width,aggregation,it,core,2);

%Edge layer
posnode_edgelayer=posnode;
edge_per_pod=TOR/(aggregation/agg_per_pod);
[endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startY]=Toall_inpod_layerbefore('E',endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startY,differenceY,differenceX,width,TOR,edge_per_pod,agg_per_pod,posnode_agglayer,3);

%Host layer
[endnodes,edges,layern,Xpoint,Ypoint]=host_per_node(flaghosts,endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startX,startY,differenceY,width,ecm,TOR,posnode_edgelayer,4);

G=graph(table(edges,'VariableNames',{'EndNodes'}),table(endnodes,Xpoint,Ypoint,categorical(layern,0:4,{'internet' 'core' 'aggregation' 'edge' 'host'}),'VariableNames',{'Name';'Xpoint';'Ypoint';'Layer'}));

end

function G = graphPortland(flagit,flaghosts,k)
%GRAPHPORTLAND Creates a graph with topology Portland divided in layers
%           Function used by Graphtopology
%   Inputs:
%       flagit:flag to have an internet node or not
%       flaghosts:flag to have node hosts or not
%       k: number of ports of each node
%   Number of nodes is computed by input argument k in layers:
%   Core layer: (k/2)^2 nodes. Each node only connects to Internet in upper layer. 
%       Will be called C1,C2...
%   Aggregation layer: 2*core nodes. This nodes are divided in pods. Each
%       pode has k/2 aggregation nodes, each connecting to half the core 
%       nodes. Will be called A1,A2... 
%   Edge layer: same number as aggregation nodes. Each node connects to all
%       aggregation nodes in its pod. Will be called E1,E2...
%   Host layer: (k^3/4) nodes. Each node connects to only one node in edge 
%       layer. Since taken symmetric, each node in edge layer has the same
%       number of hosts. Will be called H1,H2...
%
%Luis Félix Rodríguez Cano 2017

%Compute values for topology
assert(mod(k,2)==0,'Error, k must be an even number.')
core=(k/2)^2;
%pods=core/2;
aggregation=core*2;
%pods=k;
agg_to_core=k/2;%number of cores that an aggregation node connects to

if flaghosts
    ecm=k/2;%host per aggregation
else
    ecm=0;
end

%Compute values for plotting
differenceX=1;
%startX=0; Compute startX as the difference between total width and width of present layer divided by 2.
differenceY=1;
startY=4;
%width=aggregation*ecm*differenceX;
width=(aggregation-1)*differenceX;

if flagit
    it=1;
    posnode=it;
else
    posnode=0;
    it=0;
end

%Preallocation
[endnodes,layern,Xpoint,Ypoint]=preallocate_nodetablevariables(aggregation*2+aggregation*ecm+core+posnode);
edges(core*it+2*aggregation*agg_to_core+aggregation*ecm,2)=1;

%Internet layer
[endnodes,layern,Xpoint,Ypoint]=internet_layer(flagit,endnodes,layern,Xpoint,Ypoint,width,startY);

%Ypoint=zeros(h,1)+ones(h-aggregation*host_per_aggregation,1)+ones(core+1+aggregation,1)+ones(core+1,1)+ones(1,1)

%Core layer
[endnodes,edges,layern,Xpoint,Ypoint,posnode,startY]=core_layer(flagit,'C',endnodes,edges,layern,Xpoint,Ypoint,posnode,startY,differenceY,differenceX,width,core);

%Aggregation layer
if flagit
    posedge=core;
else
    posedge=0;
end
posnode_agglayer=posnode;
startY=startY-differenceY;
startX=(width-(aggregation-1)*differenceX)/2;
countpod=1;
for i=1:aggregation
    posnode=posnode+1;
    Ypoint(posnode,1)=startY;
    layern(posnode,1)=2;
    Xpoint(posnode,1)=startX+differenceX*(i-1);
    endnodes{posnode} = strcat('A', num2str(i));
    if i>countpod*agg_to_core
        countpod=countpod+1;
    end
    addj=((i-(countpod-1)*agg_to_core)-1)*agg_to_core;
    for j=it+1:agg_to_core+it
        posedge=posedge+1;
        edges(posedge,1)=posnode;
        edges(posedge,2)= j+addj;
    end
end

%Edge layer
posnode_edgelayer=posnode;
[endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startY]=Toall_inpod_layerbefore('E',endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startY,differenceY,differenceX,width,aggregation,agg_to_core,agg_to_core,posnode_agglayer,3);

%Host layer
[endnodes,edges,layern,Xpoint,Ypoint]=host_per_node(flaghosts,endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startX,startY,differenceY,width,ecm,aggregation,posnode_edgelayer,4);

G=graph(table(edges,'VariableNames',{'EndNodes'}),table(endnodes,Xpoint,Ypoint,categorical(layern,0:4,{'internet' 'core' 'aggregation' 'edge' 'host'}),'VariableNames',{'Name';'Xpoint';'Ypoint';'Layer'}));

end

function G = graphAltoonaFacebook(flagit,flaghosts,m,n,varargin)
%GRAPHALTOONAFACEBOOK Creates a graph with the topology Facebook divided in layers
%           Function used by Graphtopology
%   Inputs:
%       flagit:flag to have an internet node or not
%       flaghosts:flag to have node hosts or not
%       m: number of pods of edges
%       n: number of pods of TOR
%      if flaghosts is true:
%       varargin{1} is the number of hosts per TOR
%   Number of nodes is computed by input arguments m and n in layers:
%   Edge/Core layer: 4*m nodes. Each node only connects to Internet in upper layer. 
%       Will be called E1,E2...
%   Spine layer: 48*4 nodes. This nodes are divided in 4 pods. Each
%       pod ha 48 aggregation nodes, all nodes in a pod connect to one node
%       in each pod in the upper layer, the one with the same index of the pod
%       in this layer. Will be called S1,S2... 
%   Fabric layer: 4*n nodes. Each pod has 4 nodes. Each node in a pod connects to all nodes in an
%       upper layer pod. The upper layer pod with the same index of the respective index
%       of the node inside the current layer pod. Will be called F1,F2...
%   TOR layer: 48*n nodes. Each node connects to all fabric nodes in its pod.
%       Will be called T1,T2...
%   Host layer: hostperTOR*n nodes. Each node connects to only one node in TOR 
%       layer. Since taken symmetric, each node in edge layer has the same
%       number of hosts. Will be called H1,H2...
%
%Luis Félix Rodríguez Cano 2017

%Compute values for topology
core=4*m;
Spines=48*4;
Fabric=4*n;
TOR=n*48;

if flaghosts
    if nargin~=5
        error('If flaghosts is true the number of hosts per TOR must be specified.');
    else
    ecm=varargin{1};%host per TOR
    end
else
    ecm=0;
end

%Compute values for plotting
differenceX=1;
startX=0;% Compute startX as the difference between total width and width of present layer divided by 2.
differenceY=1;
startY=5;
%width=aggregation*ecm*differenceX;
if m>n
    width=(core-1)*differenceX;
else
    width=(Fabric-1)*differenceX;
end

if flagit
    it=1;
    posnode=it;
else
    posnode=0;
    it=0;
end

%Preallocation
[endnodes,layern,Xpoint,Ypoint]=preallocate_nodetablevariables(core+Spines+Fabric+TOR+it+ecm*TOR);
edges(4*m*48+it*n*4+2*n*48*4+ecm,2)=1;

%Internet layer
[endnodes,layern,Xpoint,Ypoint]=internet_layer(flagit,endnodes,layern,Xpoint,Ypoint,width,startY);

posnode_corelayer=posnode;

%Edge layer
[endnodes,edges,layern,Xpoint,Ypoint,posnode,startY]=core_layer(flagit,'E',endnodes,edges,layern,Xpoint,Ypoint,posnode,startY,differenceY,differenceX,width,core);

%Spine layer
if flagit
    posedge=core;
else
    posedge=0;
end
posnode_spinelayer=posnode;
[endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startY]=Toindexnodepod_inindexpod_layerbefore('S',endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startY,differenceY,width/Spines,width,Spines,48,4,m,posnode_corelayer,2);

%Fabric layer
posnode_fabriclayer=posnode;
[endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startY]=Topod_eachinpod_layerbefore('F',endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startY,differenceY,differenceX,width,Fabric,4,48,posnode_spinelayer,3);

%TOR layer
posnode_torlayer=posnode;
[endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startY]=Toall_inpod_layerbefore('T',endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startY,differenceY,width/TOR,width,TOR,48,4,posnode_fabriclayer,4);

%Host layer

[endnodes,edges,layern,Xpoint,Ypoint]=host_per_node(flaghosts,endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startX,startY,differenceY,width,ecm,TOR,posnode_torlayer,5);

G=graph(table(edges,'VariableNames',{'EndNodes'}),table(endnodes,Xpoint,Ypoint,categorical(layern,0:5,{'internet' 'edge' 'spine' 'fabric' 'tor' 'host'}),'VariableNames',{'Name';'Xpoint';'Ypoint';'Layer'}));

end



function [endnodes,layern,Xpoint,Ypoint]=preallocate_nodetablevariables(nnodes)
    %Preallocates the node table variables taking the total number of nodes
    %of the topology
    %Luis Félix Rodríguez Cano 2017
    
    endnodes = cell(nnodes, 1);
    Xpoint(nnodes,1)=1;
    Ypoint(nnodes,1)=1;
    layern(nnodes,1)=1;
end

function [endnodes,layern,Xpoint,Ypoint]=internet_layer(flagit,endnodes,layern,Xpoint,Ypoint,width,startY)
    %Puts values for the internet node
    %Luis Félix Rodríguez Cano 2017
    if flagit
        Xpoint(1,1)=width/2;
        Ypoint(1,1)=startY;
        layern(1)=0;
        endnodes{1}='IT';
    end
end

function [endnodes,edges,layern,Xpoint,Ypoint,posnode,startY]=core_layer(flagit,char,endnodes,edges,layern,Xpoint,Ypoint,posnode,startY,differenceY,differenceX,width,core)
    %Creates core layer
    %Luis Félix Rodríguez Cano 2017
    startX=(width-(core-1)*differenceX)/2;
    startY=startY-differenceY;
    for i=1:core
        posnode=posnode+1;
        Ypoint(posnode,1)=startY;
        Xpoint(posnode,1)=startX+differenceX*(i-1);
        layern(posnode)=1;
        endnodes{posnode} = strcat(char, num2str(i));
        if flagit
        edges(i,1)= 1;
        edges(i,2)= i+1;
        end
    end
end

function [endnodes,edges,layern,Xpoint,Ypoint]=host_per_node(flaghosts,endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startX,startY,differenceY,width,hostspernode,nnodesupperlayer,posnode_upperlayer,nlayer)
    %Creates host layer, creating the same number of hosts per node in
    %upper layer
    %Luis Félix Rodríguez Cano 2017
    if flaghosts
        differenceX=width/(hostspernode*nnodesupperlayer-1);
        startY=startY-differenceY;
        posnode1=posnode;
        count=1;
        count2=1;
        for j=1:nnodesupperlayer
            addj=posnode1+(count2-1)*hostspernode;
            for i=1:hostspernode
                posnode=posnode+1;
                Ypoint(posnode,1)=startY;
                layern(posnode,1)=nlayer;
                Xpoint(posnode,1)=startX+differenceX*(count-1);
                endnodes{posnode} = strcat('H', num2str(count));
                posedge=posedge+1;
                edges(posedge,1)=posnode_upperlayer+j;
                edges(posedge,2)=addj+i;
                count=count+1;
            end
            count2=count2+1;
        end
    end
end

function [endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startY]=Toall_layer_before(char,endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startY,differenceY,differenceX,width,nnodescurrentlayer,posnode_upperlayer,nnodesupperlayer,nlayer)
    %Crates a layer in which each node connects to all nodes in upper layer
    %Luis Félix Rodríguez Cano 2017
    startY=startY-differenceY;
    startX=(width-(nnodescurrentlayer-1)*differenceX)/2;
    for i=1:nnodescurrentlayer
        posnode=posnode+1;
        Ypoint(posnode,1)=startY;
        layern(posnode,1)=nlayer;
        Xpoint(posnode,1)=startX+differenceX*(i-1);
        endnodes{posnode} = strcat(char, num2str(i));
        for j=1:nnodesupperlayer
            posedge=posedge+1;
            edges(posedge,1)=posnode;
            edges(posedge,2)= j+posnode_upperlayer;
        end
    end
end


function [endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startY]=Toall_inpod_layerbefore(char,endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startY,differenceY,differenceX,width,nnodescurrentlayer,current_per_pod,upper_per_pode,posnode_upperlayer,nlayer)
    %Creates a layer in which each node connects only to all nodes of upper
    %layer in its pod.
    %Luis Félix Rodríguez Cano 2017
    
    startY=startY-differenceY;
    startX=(width-(nnodescurrentlayer-1)*differenceX)/2;
    %countpod=1;
    addj=posnode_upperlayer;
    limit=current_per_pod;
    for i=1:nnodescurrentlayer
        posnode=posnode+1;
        Ypoint(posnode,1)=startY;
        layern(posnode,1)=nlayer;
        Xpoint(posnode,1)=startX+differenceX*(i-1);
        endnodes{posnode} = strcat(char, num2str(i));
        if i>limit
            %countpod=countpod+1;
            addj=addj+upper_per_pode;
            limit=limit+current_per_pod;
        end
        for j=1:upper_per_pode
            posedge=posedge+1;
            edges(posedge,1)=posnode;
            edges(posedge,2)= j+addj;
        end
    end
end

function [endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startY]=Toindexnodepod_inindexpod_layerbefore(char,endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startY,differenceY,differenceX,width,nnodescurrentlayer,current_per_pod,upper_in_pod,npods_upper,posnode_upperlayer,nlayer)
    %Creates a layer in which all nodes in a pod connect to one node
    %in each pod in the upper layer, the one with the same index of the pod
    %in this layer.
    %Luis Félix Rodríguez Cano 2017
    
    startY=startY-differenceY;
    startX=(width-(nnodescurrentlayer-1)*differenceX)/2;
    limit=current_per_pod;
    addj=posnode_upperlayer+1;
    for i=1:nnodescurrentlayer
        posnode=posnode+1;
        Ypoint(posnode,1)=startY;
        layern(posnode,1)=nlayer;
        Xpoint(posnode,1)=startX+differenceX*(i-1);
        endnodes{posnode} = strcat(char, num2str(i));
        if i>limit
            addj=addj+1;
            limit=limit+current_per_pod;
        end
        for j=0:npods_upper-1
            posedge=posedge+1;
            edges(posedge,1)=posnode;
            edges(posedge,2)= j*upper_in_pod+addj;
        end
    end
end

function [endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startY]=Topod_eachinpod_layerbefore(char,endnodes,edges,layern,Xpoint,Ypoint,posnode,posedge,startY,differenceY,differenceX,width,nnodescurrentlayer,current_per_pod,upper_per_pode,posnode_upperlayer,nlayer)
    %Creates a layer in which each node in a pod connects to all nodes in an
    %upper layer pod. The upper layer pod with the same index of the respective index
    %of the node inside the current layer pod.
    %Luis Félix Rodríguez Cano 2017
    
    startY=startY-differenceY;
    startX=(width-(nnodescurrentlayer-1)*differenceX)/2;
    limit=current_per_pod;
    count_in_pod=0;
    for i=1:nnodescurrentlayer
        posnode=posnode+1;
        Ypoint(posnode,1)=startY;
        layern(posnode,1)=nlayer;
        Xpoint(posnode,1)=startX+differenceX*(i-1);
        endnodes{posnode} = strcat(char, num2str(i));
        if i>limit
            limit=limit+current_per_pod;
            count_in_pod=0;
        end
        plusupper=count_in_pod*upper_per_pode;
        for j=1:upper_per_pode
            posedge=posedge+1;
            edges(posedge,1)=posnode;
            edges(posedge,2)= j+plusupper+posnode_upperlayer;
        end
        count_in_pod=count_in_pod+1;
    end
end


