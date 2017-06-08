function G = graphPortland(k)
%GRAPHPORTLAND Creates a graph with topology Portland divided in layers
%           Function used by Graphtopology
%   Number of nodes is computed by input argument k in layers:
%   Core layer: (k/2)^2 nodes. Each node only connects to Internet in upper layer. 
%       Will be called C1,C2...
%   Aggregation layer: 2*core nodes. This nodes are divided in pods. Each
%       pode has two aggregation nodes, each connecting to half the core 
%       nodes. Will be called A1,A2... 
%   Edge layer: same number as aggregation nodes. Each node connects to all
%       aggregation nodes in its pod. Will be called E1,E2...
%   Host layer: (k^3/4) nodes. Each node connects to only one node in edge 
%       layer. Since taken symmetric, each node in edge layer has the same
%       number of hosts. Will be called H1,H2...
%

%Compute values for topology
assert(mod(k,2)==0,'Error, k must be an even number.')
core=(k/2)^2;
%pods=core/2;
aggregation=core*2;
%pods=k;
ecm=k/2;%host per aggregation
variable_names_node_table = {'EndNodes';'Xpoint';'Ypoint';'Layer'};

%Compute values for plotting
differenceX=1;
%startX=0; Compute startX as the difference between total width and width of present layer divided by 2.
differenceY=1;
startY=4;
width=aggregation*ecm*differenceX;

%Preallocation
h=aggregation*2+aggregation*ecm+core+1;
endnodes = cell(h, 1);
Xpoint(h,1)=1;
Ypoint(h,1)=1;
layern(h,1)=1;
edges(core+3*aggregation*ecm,2)=1;

%Internet layer
Xpoint(1,1)=width/2;
Ypoint(1,1)=startY;
layern(1)=0;
endnodes{1}='IT';

%Ypoint=zeros(h,1)+ones(h-aggregation*host_per_aggregation,1)+ones(core+1+aggregation,1)+ones(core+1,1)+ones(1,1)

%Core layer
startX=(width-(core-1)*differenceX)/2;
startY=startY-differenceY;
for i=1:core
    Ypoint(i+1,1)=startY;
    Xpoint(i+1,1)=startX+differenceX*(i-1);
    layern(i+1)=1;
    endnodes{i+1} = strcat('C', num2str(i));
    edges(i,1)= 1;
    edges(i,2)= i+1;
end

%Aggregation layer
posedge=i;
posnode=i+1;
startY=startY-differenceY;
startX=(width-(aggregation-1)*differenceX)/2;
count=1;
countpod=1;
for i=1:aggregation
    Ypoint(posnode+i,1)=startY;
    layern(posnode+i,1)=2;
    Xpoint(posnode+i,1)=startX+differenceX*(i-1);
    endnodes{posnode+i} = strcat('A', num2str(i));
    if i>countpod*ecm
        countpod=countpod+1;
    end
    addj=((i-(countpod-1)*ecm)-1)*ecm;
    for j=2:ecm+1
        edges(posedge+count,1)=posnode+i;
        edges(posedge+count,2)= j+addj;
        count=count+1;
    end
end

%Edge layer
posedge=posedge+count-1;
posagg=posnode;
posnode=posnode+i;
startY=startY-differenceY;
startX=(width-(aggregation-1)*differenceX)/2;
count=1;
countpod=1;
for i=1:aggregation
    Ypoint(posnode+i,1)=startY;
    layern(posnode+i,1)=3;
    Xpoint(posnode+i,1)=startX+differenceX*(i-1);
    endnodes{posnode+i} = strcat('E', num2str(i));
    %extra=int32(i/ecm)-1;
    if i>countpod*ecm
        countpod=countpod+1;
    end
    addj=posagg+(countpod-1)*ecm;
    for j=1:ecm
        edges(posedge+count,1)=posnode+i;
        edges(posedge+count,2)= j+addj;
        count=count+1;
    end
end

%Host layer
posedge=posedge+count-1;
posnode=posnode+i;
posagg=posagg+aggregation;
startY=startY-differenceY;
startX=0;
count=1;
count2=1;
for j=1:aggregation
    addj=posnode+(count2-1)*ecm;
    for i=1:ecm
        Ypoint(posnode+count,1)=startY;
        layern(posnode+count,1)=4;
        Xpoint(posnode+count,1)=startX+differenceX*(count-1);
        endnodes{posnode+count} = strcat('H', num2str(count));
        edges(posedge+count,1)=posagg+j;
        edges(posedge+count,2)=i+addj;
        count=count+1;
    end
    count2=count2+1;
end

layer=categorical(layern,0:4,{'internet' 'core' 'aggregation' 'edge' 'host'});
NodeTable=table(endnodes,Xpoint,Ypoint,layer,'VariableNames',variable_names_node_table);
EdgeTable=table(edges,'VariableNames',{'EndNodes'});
G=graph(EdgeTable,NodeTable);

end

