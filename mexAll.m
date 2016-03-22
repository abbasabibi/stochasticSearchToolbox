[status,list]=system('find . | egrep ''(Mex\.cpp)$''');
list1 = Common.strsplit(list,'./');
[status,list]=system('find . | egrep ''(Mex\.c)$''');
list2 = Common.strsplit(list,'./');


list = {list1{2:end}, list2{2:end}};

for i = 1:length(list)
   indexDir = find(list{i} == '/', 1, 'last');
   eval(['mex  ', ' -outdir ',  list{i}(1:indexDir), '  ', list{i}]);
   % eval(['mex ', list(i)]);
end
