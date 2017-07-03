function str=stringPaths(paths,varargin)
%STRINGPATHS creates a cell of strings with the paths
%   Inputs:
%       paths: cell array composed of row vectors that represent the path.
%       varargin: the graph of the network if it inclued a nodetable with
%       the names of the nodes.
%   Outputs:
%       str: cell string with the paths.
%
% Luis Félix Rodríguez Cano 2017

list_color={'cyan','red','green','black','yellow','magenta','blue'};

[sz v]=size(paths);
str1='';
count=1;
for j=1:sz
    count=count+1;
    if(count>7)
        count=1;
    end
    str2=char({[sprintf('Path %d ',j),' (',list_color{count},'): ']});
    [v sz2]=size(paths{j});
    for i=1:sz2
        if nargin<2
            if i==1
                str2=strcat(str2,num2str(paths{j}(i)));
            else
                str2=strcat(str2, ',',num2str(paths{j}(i)));
            end
        else
            str2=strcat(str2, ',',varargin{1}.Nodes.Name{paths{j}(i)});
        end
    end
    str1=char({str1,str2});
end
str{1}=char({'Paths:'; str1});
%str{1}={str{1} ; str1};

end