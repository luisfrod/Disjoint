function G=graphSpineLeaf(flagit,flaghosts, spine, leaf, hostsperleaf)
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

variable_names_node_table = {'EndNodes';'Xpoint';'Ypoint';'Layer'};
posnode=0;
it=0;

%TODO topology and layer as categorical at the end, or in struct with number of core, aggregation and edges
%topology=categorical({'SpineLeaf'});

%Preallocation
if flagit
    it=1;
    posnode=it;
end
if ~flaghosts
    hostsperleaf=0;
end
h=spine+leaf+hostsperleaf*leaf+it;
endnodes = cell(h, 1);
Xpoint(h,1)=1;
Ypoint(h,1)=1;
layern(h,1)=1;
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
if flagit
    Xpoint(1,1)=width/2;
    Ypoint(1,1)=startY;
    layern(1)=0;
    endnodes{1}='IT';
end

%Spine layer
startX=(width-(spine-1)*differenceX)/2;
startY=startY-differenceY;
for i=1:spine
    posnode=posnode+1;
    Ypoint(posnode,1)=startY;
    Xpoint(posnode,1)=startX+differenceX*(i-1);
    layern(posnode)=1;
    endnodes{posnode} = strcat('S', num2str(i));
    if flagit
    edges(i,1)= 1;
    edges(i,2)= i+1;
    end
end

%Leaf layer
if flagit
    posedge=i;
else
    posedge=0;
end
posagg=posnode;
startY=startY-differenceY;
startX=(width-(leaf-1)*differenceX)/2;
for i=1:leaf
    posnode=posnode+1;
    Ypoint(posnode,1)=startY;
    layern(posnode,1)=2;
    Xpoint(posnode,1)=startX+differenceX*(i-1);
    endnodes{posnode} = strcat('L', num2str(i));
    for j=it+1:spine+it
        posedge=posedge+1;
        edges(posedge,1)=posnode;
        edges(posedge,2)= j;
    end
end

%Host layer
if flaghosts
    differenceX=width/(hostsperleaf*leaf-1);
    startY=startY-differenceY;
    posnode1=posnode;
    count=1;
    count2=1;
    for j=1:leaf
        addj=posnode1+(count2-1)*hostsperleaf;
        for i=1:hostsperleaf
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

layer=categorical(layern,0:3,{'internet' 'spine' 'leaf' 'host'});
NodeTable=table(endnodes,Xpoint,Ypoint,layer,'VariableNames',variable_names_node_table);
EdgeTable=table(edges,'VariableNames',{'EndNodes'});
G=graph(EdgeTable,NodeTable);

end
