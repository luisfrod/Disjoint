function G = graphVL2(flagit,flaghosts,varargin)
%GRAPHVL2 Creates a graph with topology graphVL2 divided in layers
%           Function used by Graphtopology
%   Inputs:
%       flagit:flag to have an internet node or not
%       flaghosts:flag to have node hosts or not
%       varargin can be:
%           k (dc=da=k)
%           dc, da
%           dc, da, agg_per_pod(number of aggregation nodes per pod)
%
%   Number of nodes is computed by input arguments in layers:
%   Core layer: da/2 nodes. Each node only connects to Internet in upper layer. 
%       Will be called C1,C2...
%   Aggregation layer: dc nodes. This nodes are divided in pods. Each
%       pode has two aggregation nodes, each connecting to all the core 
%       nodes. Will be called A1,A2... 
%   Edge layer: same number as aggregation nodes. Each node connects to all
%       aggregation nodes in its pod. Will be called E1,E2...
%   Host layer: 2*dc nodes. Each node connects to only one node in edge 
%       layer. Since taken symmetric, each node in edge layer has the same
%       number of hosts. Will be called H1,H2...
%

%Compute values for topology
if nargin==3
    k=varargin{1};
    core=k/2;
    aggregation=k;
    TOR=k^2/4;%edges
    agg_per_pod=2;
    ecm=2*k;%O 20 o 40
else
    if nargin==4
        dc=varargin{1};
        da=varargin{2};
        agg_per_pod=2;
    elseif nargin==5
        dc=varargin{1};
        da=varargin{2};
        agg_per_pod=varargin{3};
    else
        error('Incorrect input arguments: has to be ');
    end
    
    core=da/2;
    aggregation=dc;
    TOR=da*dc/4;%edges
    ecm=2*dc;%O 20 o 40
    
end
assert(mod(varargin{1},2)==0,'Error, dc or k must be an even number.')
posnode=0;
it=0;
variable_names_node_table = {'EndNodes';'Xpoint';'Ypoint';'Layer'};

%Compute values for plotting
differenceX=1;
startX=0; %Compute startX as the difference between total width and width of present layer divided by 2.
differenceY=1;
startY=4;
width=(TOR-1)*differenceX;
%if flaghosts
%    width=(ecm*TOR-1)*differenceX;
%else
%    width=(TOR-1)*differenceX;
%end

%Preallocation
if flagit
    it=1;
    posnode=it;
end
if ~flaghosts
    ecm=0;
end
h=aggregation+TOR+TOR*ecm+core+posnode;
endnodes = cell(h, 1);
Xpoint(h,1)=1;
Ypoint(h,1)=1;
layern(h,1)=1;
edges(it*core+aggregation*core+TOR*agg_per_pod+aggregation*ecm,2)=1;

%Internet layer
if flagit
    Xpoint(1,1)=width/2;
    Ypoint(1,1)=startY;
    layern(1)=0;
    endnodes{1}='IT';
end

%Core layer
startX=(width-(core-1)*differenceX)/2;
startY=startY-differenceY;
for i=1:core
    posnode=posnode+1;
    Ypoint(posnode,1)=startY;
    Xpoint(posnode,1)=startX+differenceX*(i-1);
    layern(posnode)=1;
    endnodes{posnode} = strcat('C', num2str(i));
    if flagit
    edges(i,1)= 1;
    edges(i,2)= i+1;
    end
end

%Aggregation layer
if flagit
    posedge=i;
else
    posedge=0;
end
posagg=posnode;
startY=startY-1;
startX=(width-(aggregation-1)*differenceX)/2;
for i=1:aggregation
    posnode=posnode+1;
    Ypoint(posnode,1)=startY;
    layern(posnode,1)=2;
    Xpoint(posnode,1)=startX+differenceX*(i-1);
    endnodes{posnode} = strcat('A', num2str(i));
    for j=it+1:core+it
        posedge=posedge+1;
        edges(posedge,1)=posnode;
        edges(posedge,2)= j;
    end
end

%Edge layer
startY=startY-1;
startX=(width-(TOR-1)*differenceX)/2;
countpod=1;
edge_per_pod=TOR/(aggregation/agg_per_pod);
for i=1:TOR
    posnode=posnode+1;
    Ypoint(posnode,1)=startY;
    layern(posnode,1)=3;
    Xpoint(posnode,1)=startX+differenceX*(i-1);
    endnodes{posnode} = strcat('E', num2str(i));
    if i>countpod*edge_per_pod
        countpod=countpod+1;
    end
    for j=1:agg_per_pod
        posedge=posedge+1;
        edges(posedge,1)=posnode;
        edges(posedge,2)= posagg+j+(countpod-1)*agg_per_pod;
    end
end
%Host layer
if flaghosts
    posagg=posagg+aggregation;
    differenceX=width/(ecm*TOR-1);
    startY=startY-1;
    posnode1=posnode;
    count=1;
    count2=1;
    for j=1:TOR
        addj=posnode1+(count2-1)*ecm;
        for i=1:ecm
            posnode=posnode+1;
            Ypoint(posnode,1)=startY;
            layern(posnode,1)=4;
            Xpoint(posnode,1)=startX+differenceX*(count-1);
            endnodes{posnode} = strcat('H', num2str(count));
            posedge=posedge+1;
            edges(posedge,1)=posagg+j;
            edges(posedge,2)=addj+i;
            count=count+1;
        end
        count2=count2+1;
    end
end

layer=categorical(layern,0:4,{'internet' 'core' 'aggregation' 'edge' 'host'});
NodeTable=table(endnodes,Xpoint,Ypoint,layer,'VariableNames',variable_names_node_table);
EdgeTable=table(edges,'VariableNames',{'EndNodes'});
G=graph(EdgeTable,NodeTable);

end

