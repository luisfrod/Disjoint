function G=graphSpineLeaf(spine, leaf, hostsperleaf)
%GRAPHSPINELIEAF Creates a graph with topology spineleaf divided in layers
%           Function used by Graphtopology
%   Spine: number of spine nodes. Each node only connects to Internet in upper layer. 
%       Will be called S1,S2...
%   Leaf: number of leaf nodes. Each node connects to all nodes in spine layer.
%       Will be called L1,L2... 
%   Hostsperleaf: number of hosts per leaf node. Each node connects to only one node 
%       in leaf layer. Since taken symmetric, each node in leaf layer has
%       the same number of hosts. Will be called H1,H2...
%

variable_names_node_table = {'EndNodes';'Xpoint';'Ypoint';'Layer'};

%TODO topology and layer as categorical at the end, or in struct with number of core, aggregation and edges
%topology=categorical({'SpineLeaf'});

h=spine+leaf+hostsperleaf*leaf+1;
endnodes = cell(h, 1);
endnodes{1}='IT';
Xpoint(h,1)=1;
Ypoint(h,1)=1;
layern(h,1)=1;

edgesstart=spine*(leaf+1);
edges(edgesstart+leaf*hostsperleaf,2)=1;

%TODO think of better way to compute first difference and start plotting points

differenceX=1;
startX=0;
differenceY=1;
startY=3;
coreYpos=startY-differenceY;

Xpoint(1,1)=differenceX+(differenceX*spine-differenceX)/2;
Ypoint(1,1)=startY;
layern(1)=0;
for i=1:spine
    Ypoint(i+1,1)=coreYpos;
    Xpoint(i+1,1)=startX+differenceX*i;
    layern(i+1)=1;
    endnodes{i+1} = strcat('S', num2str(i));
    edges(i,1)= 1;
    edges(i,2)= i+1;
end

aggYpos=coreYpos-differenceY;
differenceX=(differenceX*spine+1)/leaf;
startX=differenceX/2;
count=1;
for i=1:leaf
    Ypoint(spine+i+1,1)=aggYpos;
    layern(spine+i+1,1)=2;
    Xpoint(spine+i+1,1)=startX+differenceX*(i-1);
    endnodes{i+spine+1} = strcat('L', num2str(i));
    for j=2:spine+1
    edges(spine+count,1)=spine+1+i;
    edges(spine+count,2)= j;
    count=count+1;
    end
end

edgeYpos=aggYpos-differenceY;
differenceedgX=(differenceX*leaf+1)/(hostsperleaf*leaf);
startX=(differenceX*leaf-(differenceedgX*(hostsperleaf*leaf-1)))/2;
count=1;
count2=1;
for j=1:leaf
    for i=1:hostsperleaf
        Ypoint(spine+leaf+count+1,1)=edgeYpos;
        layern(spine+leaf+count+1,1)=3;
        Xpoint(spine+leaf+count+1,1)=startX+differenceedgX*(count-1);
        endnodes{spine+leaf+count+1} = strcat('H', num2str(count));
        edges(edgesstart+count,1)=spine+1+j;
        edges(edgesstart+count,2)=spine+leaf+1+i+(count2-1)*hostsperleaf;
        count=count+1;
    end
    count2=count2+1;
end
%layer=categorical(layern,0:3,{'internet' 'core' 'aggregation' 'edge'});
layer=categorical(layern,0:3,{'internet','spine' 'leaf' 'host'});
NodeTable=table(endnodes,Xpoint,Ypoint,layer,'VariableNames',variable_names_node_table);
EdgeTable=table(edges,'VariableNames',{'EndNodes'});
G=graph(EdgeTable,NodeTable);

end