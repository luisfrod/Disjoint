function G=graph3Tier(core, aggregation, edgesl)
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

variable_names_node_table = {'EndNodes';'Xpoint';'Ypoint';'Layer'};

%TODO topology and layer as categorical at the end, or in struct with number of core, aggregation and edges
%topology=categorical({'3Tier'});

endnodes = cell(core+aggregation+edgesl+1, 1);
endnodes{1}='IT';

h=core+aggregation+edgesl*aggregation+1;

Xpoint(h,1)=1;
Ypoint(h,1)=1;
layern(h,1)=1;

edgesstart=core*(aggregation+1);
edges(edgesstart+aggregation*edgesl,2)=1;

%TODO think of better way to compute first difference and start plotting points

differenceX=1;
startX=0;
differenceY=1;
startY=3;
coreYpos=startY-differenceY;

Xpoint(1,1)=differenceX+(differenceX*core-differenceX)/2;
Ypoint(1,1)=startY;
layern(1)=0;
for i=1:core
    Ypoint(i+1,1)=coreYpos;
    Xpoint(i+1,1)=startX+differenceX*i;
    layern(i+1)=1;
    endnodes{i+1} = strcat('C', num2str(i));
    edges(i,1)= 1;
    edges(i,2)= i+1;
end

%endnodes = cell(aggregation, 1);
aggYpos=coreYpos-differenceY;
differenceX=(differenceX*core+1)/aggregation;
startX=differenceX/2;
count=1;
for i=1:aggregation
    Ypoint(core+i+1,1)=aggYpos;
    layern(core+i+1,1)=2;
    Xpoint(core+i+1,1)=startX+differenceX*(i-1);
    endnodes{i+core+1} = strcat('A', num2str(i));
    for j=2:core+1
    edges(core+count,1)=core+1+i;
    edges(core+count,2)= j;
    count=count+1;
    end
end

%endnodes = cell(aggregation, 1);
edgeYpos=aggYpos-differenceY;
differenceedgX=(differenceX*aggregation+1)/(edgesl*aggregation);
startX=(differenceX*aggregation-(differenceedgX*(edgesl*aggregation-1)))/2;
count=1;
count2=1;
for j=1:aggregation
    for i=1:edgesl
        Ypoint(core+aggregation+count+1,1)=edgeYpos;
        layern(core+aggregation+count+1,1)=3;
        Xpoint(core+aggregation+count+1,1)=startX+differenceedgX*(count-1);
        endnodes{core+aggregation+count+1} = strcat('E', num2str(count));
        edges(edgesstart+count,1)=core+1+j;
        edges(edgesstart+count,2)=core+aggregation+1+i+(count2-1)*edgesl;
        count=count+1;
    end
    count2=count2+1;
end
layer=categorical(layern,0:3,{'internet' 'core' 'aggregation' 'edge'});
NodeTable=table(endnodes,Xpoint,Ypoint,layer,'VariableNames',variable_names_node_table);
EdgeTable=table(edges,'VariableNames',{'EndNodes'});
G=graph(EdgeTable,NodeTable);

end