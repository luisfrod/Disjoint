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
ecm=k/2;%host per aggregation
posnode=0;
it=0;
variable_names_node_table = {'EndNodes';'Xpoint';'Ypoint';'Layer'};

%Compute values for plotting
differenceX=1;
%startX=0; Compute startX as the difference between total width and width of present layer divided by 2.
differenceY=1;
startY=4;
%width=aggregation*ecm*differenceX;
width=(aggregation-1)*differenceX;

%Preallocation
%TODO preallocate edges
if flagit
    it=1;
    posnode=it;
end
if ~flaghosts
    ecm=0;
end
h=aggregation*2+aggregation*ecm+core+posnode;
endnodes = cell(h, 1);
Xpoint(h,1)=1;
Ypoint(h,1)=1;
layern(h,1)=1;
edges(core*it+2*aggregation*agg_to_core+aggregation*ecm,2)=1;

%Internet layer
if flagit
    Xpoint(1,1)=width/2;
    Ypoint(1,1)=startY;
    layern(1)=0;
    endnodes{1}='IT';
end

%Ypoint=zeros(h,1)+ones(h-aggregation*host_per_aggregation,1)+ones(core+1+aggregation,1)+ones(core+1,1)+ones(1,1)

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
startY=startY-differenceY;
startX=(width-(aggregation-1)*differenceX)/2;
countpod=1;
posagg=posnode;
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
startY=startY-differenceY;
startX=(width-(aggregation-1)*differenceX)/2;
countpod=1;
for i=1:aggregation
    posnode=posnode+1;
    Ypoint(posnode,1)=startY;
    layern(posnode,1)=3;
    Xpoint(posnode,1)=startX+differenceX*(i-1);
    endnodes{posnode} = strcat('E', num2str(i));
    if i>countpod*agg_to_core
        countpod=countpod+1;
    end
    addj=posagg+(countpod-1)*agg_to_core;
    for j=1:agg_to_core
        posedge=posedge+1;
        edges(posedge,1)=posnode;
        edges(posedge,2)= j+addj;
    end
end

%Host layer
if flaghosts
    posagg=posagg+aggregation;
    differenceX=width/(ecm*aggregation-1);
    startY=startY-differenceY;
    posnode1=posnode;
    count=1;
    count2=1;
    for j=1:aggregation
        addj=posnode1+(count2-1)*ecm;
        for i=1:ecm
            posnode=posnode+1;
            Ypoint(posnode,1)=startY;
            layern(posnode,1)=4;
            Xpoint(posnode,1)=startX+differenceX*(count-1);
            endnodes{posnode} = strcat('H', num2str(count));
            posedge=posedge+1;
            edges(posedge,1)=posagg+j;
            edges(posedge,2)=i+addj;
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

