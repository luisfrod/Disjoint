function Drawgraphlayered(core, aggregation, edgesl)

endnodes = cell(core+1, 1);
endnodes{1}='IT';
for i=1:core
    endnodes{i+1} = strcat('C', num2str(i));
end
NodeTable=table(endnodes,'VariableNames',{'EndNodes'});

edges=[];
for i=1:core
    edges=[edges; 1 i+1];
end

EdgeTable=table(edges,'VariableNames',{'EndNodes'});
G=graph(EdgeTable,NodeTable);

p = plot(G,'NodeLabel',table2cell(G.Nodes));
p.Marker = 'x';
p.NodeColor = 'r';
p.MarkerSize = 10;
XDatacore = p.XData;
YDatacore = p.YData;

for i=1:aggregation
    endnodes{i+core+1} = strcat('A', num2str(i));
end
NodeTable=table(endnodes,'VariableNames',{'EndNodes'});

for i=1:aggregation
    for j=2:core+1
    edges=[edges; core+1+i j];
    end
end
EdgeTable=table(edges,'VariableNames',{'EndNodes'});
%G=addedge(G,EdgeTable);
G=graph(EdgeTable,NodeTable);

p = plot(G,'NodeLabel',table2cell(G.Nodes));
p.Marker = 'x';
p.NodeColor = 'r';
p.MarkerSize = 10;

XDataaggr = XDatacore;
YDataaggr = YDatacore;

start=YDatacore(1,2);
difference=YDatacore(1,2)-YDatacore(1,1);
for i=1:aggregation
    YDataaggr=[YDataaggr, start+difference];
end

differenceag=(XDatacore(1,end)+1)/aggregation;
start=differenceag/2;
for i=0:aggregation-1
    XDataaggr=[XDataaggr, start+differenceag*i];
end

p.XData = XDataaggr;
p.YData = YDataaggr;


count=1;
for i=1:edgesl
    for j=1:aggregation
    endnodes{core+aggregation+count+1} = strcat('E', num2str(count));
    count=count+1;
    end
end
NodeTable=table(endnodes,'VariableNames',{'EndNodes'});
count=1;
for j=1:aggregation
    for i=1:edgesl
        edges=[edges; core+1+j core+aggregation+1+i+(count-1)*edgesl];
    end
    count=count+1;
end
EdgeTable=table(edges,'VariableNames',{'EndNodes'});
G=graph(EdgeTable,NodeTable);

p = plot(G,'NodeLabel',table2cell(G.Nodes));
p.Marker = 'x';
p.NodeColor = 'r';
p.MarkerSize = 10;

XDatedge = XDataaggr;
YDatedge = YDataaggr;

start=YDatedge(1,end);
difference=YDatedge(1,end)-YDatedge(1,end-aggregation);
for i=1:edgesl*aggregation
    YDatedge=[YDatedge, start+difference];
end

difference=(XDatedge(1,end)+1)/(edgesl*aggregation);
start=(differenceag*aggregation-(difference*(edgesl*aggregation-1)))/2;
for i=0:edgesl*aggregation-1
    XDatedge=[XDatedge, start+difference*i];
end

p.XData = XDatedge;
p.YData = YDatedge;

end