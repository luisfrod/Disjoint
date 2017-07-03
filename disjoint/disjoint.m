function paths = disjoint(topology,type,source,dest,N,varargin)
%DISJOINT Computes disjoint paths between source and dest in network
%specified. 
%   paths = disjoint(topology,type,source,dest,N,varargin)
%
% Inputs:
%       topology:  type of topology of the network. Can be 'SpineLeaf',
%           'VL2' or 'other'. Known topology is only valid for computations
%           from TOR to TOR (or leaf to leaf) and if the costs of all edges
%           are equal.
%       type: 'nodes' or 'edges'.
%       source: index in matrix of source node. If topology is 'other' and
%           is used with the graph, it can be the name of the node. If
%           topology is different than 'other' and mininet is true 
%           (explained later), is the ID of the switches.
%       dest: index in matrix of destination node. If topology is 'other' 
%           and is used with the graph, it can be the name of the node.If
%           topology is different than 'other' and mininet is true 
%           (explained later), is the ID of the switches.
%       N: number of disjoint paths to compute. If wanted the total
%           number of paths simply put a big number, like 99, and when 
%           there are no more paths the program will stop and will only 
%           return a list with the paths that exist.
%       varargin: varies depending on topology:
%
%           -If topology is 'SpineLeaf':
%               varargin{1}: mininet, flag that is true if used from
%                   mininet and false if used from matlab. This has an 
%                   effect on the ID of the switches of the path. If it's 
%                   true it will return the ID of the swithces in the path 
%                   as used in layers in mininet.
%               varargin{2}: number of spines in topology.
%               varargin{3}: number of leafs in topology.
%               varargin{4}: (optional) not_in_path, row vector array with 
%                   the ID, if mininet is true, or the index, if mininet is
%                   false, of the nodes that can't be part of the path.
%           Synthesis for 'SpineLeaf' topology:
%               disjoint( topology, type, source, dest, N, mininet, spines, leafs)
%               disjoint( topology, type, source, dest, N, mininet, spines, leafs, not_in_path)
%
%           -If topology is 'VL2':
%               varargin{1}: mininet, flag that is true if used from
%                   mininet and false if used from matlab. This has an 
%                   effect on the ID of the switches of the path. If it's 
%                   true it will return the ID of the swithces in the path 
%                   as used in layers in mininet.
%               varargin{2}: if varargin{3} and varargin{4} are not used,
%                   is k, the number of ports of each node in topology. If 
%                   atleast varargin{3} is used, it's dc, number of ports 
%                   of nodes in the core layer.
%               varargin{3}: (optional) da, number of ports of the nodes
%                   in the aggregation layer.
%               varargin{4}: (optional) not_in_path, row vector array with 
%                   the ID, if mininet is true, or the index, if mininet is
%                   false, of the nodes that can't be part of the path.
%           Synthesis for 'VL2' topology:
%               disjoint( topology, type, source, dest, N, mininet, k)
%               disjoint( topology, type, source, dest, N, mininet, dc,da)
%               disjoint(topology,type,source,dest,N,mininet,dc,da,not_in_path)
%
%           -If topology is 'other':
%               varargin{1}: G, matlab graph or adjacency matrix.
%               varargin{2}: matrix, true or false. It indicates if G is 
%                   the graph with false or the adjacency matrix with true.
%               varargin{3}: max, true or false. If true it will
%                   find maximum number of paths, which is slower, if it's 
%                   false, it will use a faster algorithm, but may not find 
%                   all disjoint paths.
%           Synthesis for 'other' topology:
%               disjoint( topology, type, source, dest, N, G, matrix, max)
%
%  Output:
%       paths: cell array composed of row vectors with the indices of 
%           the nodes of the path. If there is no path it will be an empty
%           1x1 cell.
%
%Luis Félix Rodríguez Cano 2017

if isequal(source,dest)
    error('Source and destination are the same.')
end

switch topology
    
    case 'SpineLeaf'
        
        if nargin==8 || nargin==9
            Spines=varargin{2};
            Leafs=varargin{3};
            mininet=varargin{1};
            exclude=false;
            if nargin==9
                not_in_path = varargin{4};
                [a sz]=size(not_in_path);
                exclude=true;
            end
        else
            error('Wrong number of input arguments for SpineLeaf topology. Use\ndisjoint( topology, type, source, dest, N, mininet, spines, leafs)\nor\ndisjoint( topology, type, source, dest, N, mininet, spines, leafs, not_in_path)');
        end
        
        if mininet
            if dest > Leafs || dest > 153 || source > 153 || source<0 || dest<0 || source > Leafs
                error('Origin or dest is not in Leaf layer.');
            end
        else
            if dest > Spines+Leafs || source<=Spines || dest<=Spines || source > Spines+Leafs
                error('Origin or dest is not in Leaf layer.');
            end
        end
        
        if N>Spines
            nloop=Spines;
        else
            nloop=N;
        end
        
        if exclude
            for i=1:sz
                if not_in_path(i)==source || not_in_path(i)==dest
                    paths=cell(1,1);
                    return;
                end
            end
            
            [can_be_used, nloop]=corescanbeused(mininet, sz, not_in_path, 4095,0,Spines);
            
            if nloop>N
                nloop=N;
            elseif nloop==0
                paths=cell(1,1);%There is no path to destination since no Spine is allowed to be used
                return;
            end
        else
            if mininet
                can_be_used=4095;
            else
                can_be_used=0;
            end
        end
        
        paths=cell(nloop,1);
        
        if exclude
            for i=1:nloop
                paths{i}(3)=dest;
                paths{i}(1)=source;
                paths{i}(2)=can_be_used(i);
            end
        else
            for i=1:nloop
                paths{i}(3)=dest;
                paths{i}(1)=source;
                paths{i}(2)=can_be_used+i;
            end
        end
        
    case 'VL2'
        
        if nargin>6 && nargin<10
            mininet=varargin{1};
            exclude=false;
            if nargin==7
                %k=varargin{2};
                core=varargin{2}/2;
                aggregation=varargin{2};
                TOR=varargin{2}^2/4;%edges
                TOR_per_pod=2;

            else
                %dc=varargin{2};
                %da=varargin{3};
                assert(mod(varargin{3},2)==0,'Error, da must be an even number.')
                core=varargin{3}/2;
                aggregation=varargin{2};
                TOR=varargin{3}*varargin{2}/4;%edges
                TOR_per_pod=TOR/(aggregation/2);
            end
            
            if nargin==9
                not_in_path = varargin{4};
                [a sz]=size(not_in_path);
                exclude=true;
            end
        else
            error('Wrong number of input arguments for VL2 topology. Use\ndisjoint( topology, type, source, dest, N, mininet, k)\nor\ndisjoint( topology, type, source, dest, N, mininet, dc,da)\nor\ndisjoint(topology,type,source,dest,N,mininet,dc,da,not_in_path)');
        end
        
        assert(mod(varargin{2},2)==0,'Error, dc or k must be an even number.')
        
        if mininet
            if dest > TOR || dest > 153 || source > 153 || source<0 || dest<0 || source > TOR
            	error('Origin or dest is not in TOR layer.');
            end
        else
            if dest > core+aggregation+TOR || source<=core+aggregation || dest<=core+aggregation || source > core+aggregation+TOR
            	error('Origin or dest is not in TOR layer.');
            end
        end
        
        %Check if source and dest are in the same pod or not - first pod is
        %0
        if mininet
            npodsource=floor(source/TOR_per_pod);
            npoddest=floor(dest/TOR_per_pod);
            aggsource=256+npodsource*2;
            aggdest=256+npoddest*2;
        else
            npodsource=floor((source-core-aggregation-1)/TOR_per_pod);
            npoddest=floor((dest-core-aggregation-1)/TOR_per_pod);
            aggsource=core+1+npodsource*2;
            aggdest=core+1+npoddest*2;
            %sprintf('core=%d, npodsource=%d, npoddest=%d, aggsoure=%d, aggdest=%d',core, npodsource,npoddest,aggsource,aggdest)
        end

        
        nloop=2;
        
        if exclude
            for i=1:sz
                if not_in_path(i)==source || not_in_path(i)==dest
                    paths=cell(1,1);%No path to dest
                    return;
                end
            end
            
            if ismember(aggsource, not_in_path) && ismember(aggsource+1, not_in_path)
                paths=cell(1,1);%No path to dest
                return;
            elseif ismember(aggsource, not_in_path) || ismember(aggsource+1, not_in_path)
                 nloop=1;
                 if ismember(aggsource, not_in_path)
                    aggsource=aggsource+1;
                 end
            end
            
            if npodsource~=npoddest
                if ismember(aggdest, not_in_path) && ismember(aggdest+1, not_in_path)
                    paths=cell(1,1);%No path to dest
                    return;
                elseif ismember(aggdest, not_in_path) || ismember(aggdest+1, not_in_path)
                    nloop=1;
                    if ismember(aggdest, not_in_path)
                        aggdest=aggdest+1;
                    end
                end
                
                [can_be_used, can_core]=corescanbeused(mininet, sz, not_in_path, 4095,0,core);
            
                if can_core==0
                    paths=cell(1,1);%There is no path to destination since no Spine is allowed to be used
                    return;
                elseif can_core==1 & type=='nodes'
                    nloop=1;
                end
            end
        else
            if  npodsource~=npoddest
                if mininet
                    can_be_used=[4096 4097];
                else
                    can_be_used=[1 2];
                end
            end
        end
        
        paths=cell(nloop,1);
        
        if npodsource==npoddest
            for i=1:nloop
                paths{i}(3)=dest;
                paths{i}(1)=source;
                paths{i}(2)=aggsource+i-1;
            end
        else
            for i=1:nloop
                paths{i}(5)=dest;
                paths{i}(1)=source;
                switch type
                    case 'edges'
                        paths{i}(3)=can_be_used(1);
                    case 'nodes'
                        paths{i}(3)=can_be_used(i);
                    otherwise
                        error('Input argument type must be "edges" or "nodes".');
                end
                paths{i}(2)=aggsource+i-1;
                paths{i}(4)=aggdest+i-1;
            end
        end
    
    case 'other'
        if nargin==8
        G=varargin{1};
        matrix=varargin{2};
        max=varargin{3};
        else
            error('Wrong number of input arguments for "other" topology. Use disjoint( topology, type, source, dest, N, G, matrix, max)');
        end
        
        switch type
            case 'edges'
                if max
                    paths= edgeDisjointPair(G,source,dest,N,matrix);
                else
                    paths = edgeDisjointNaiveDijkstra(G,source,dest,N,matrix);
                end
            case 'nodes'
                if max
                    paths = nodeDisjointFlow(G,source,dest,N,matrix);
                else
                    paths= nodeDisjointNaiveDijkstra(G,source,dest,N,matrix);
                end
            otherwise
                error('Input argument type must be "edges" or "nodes".');
        end
    otherwise
            error('Topology specified is not supported, enter "other" if it''s not VL2 or SpineLeaf.');
end

end

function [can_be_used, nloop]=corescanbeused(mininet, sz, not_in_path, tempmininet,tempmatlab,cores)
            
     nloop=0;
     can_be_used=[];
     if mininet
        for i=1:cores
            flag=true;
            tempmininet=tempmininet+1;
            for j=1:sz
                if not_in_path(j)==tempmininet
                    flag=false;
                    break;
                end
             end
             if flag
                nloop=nloop+1;
                can_be_used=[can_be_used tempmininet];
             end
         end
     else
        for i=1:cores
            flag=true;
            tempmatlab=tempmatlab+1;
            for j=1:sz
                if not_in_path(j)==tempmatlab
                flag=false;
                break;
                end
            end
            if flag
                nloop=nloop+1;
                can_be_used=[can_be_used tempmatlab];
            end
        end
     end
end

