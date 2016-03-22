classdef DocGen
    
    methods(Static)
        
        function clean
            
            rmdir(MatlabDocMaker.getOutputDirectory, 's')
            
        end
        
        function change_html_file(html_files, names)
            
            for i = 1:size(html_files)
                
                a1 = sprintf('<a href="%s">Go to the documentation of this file.</a>',[html_files{i}(1:end-11) '.html']);
                
                m = fileread([names{i} '.html']);
                
                mindex1 = regexp(m, '<pre');
                
                mindex2 = regexp(m, '</pre>');
                
                a2 = m(mindex1:mindex2+5);
                
                try
                    s = fileread(html_files{i});

                    hindex = regexp(s, '</head>');

                    h1 = '<link href="matlab.css" rel="stylesheet" type="text/css"/>';

                    new = [s(1:hindex-1) sprintf('%s\n', h1) s(hindex:end)];

                    content_index1 = regexp(new, '<div class="contents">');

                    content_index2 = regexp(new, '<!-- contents -->');

                    snew = [new(1:content_index1+22) a1 a2 new(content_index2-6:end)];

                    fid = fopen(html_files{i}, 'w+');
                    fprintf(fid, '%s\n', snew);
                    fclose(fid);
                catch E
                end
                
            end
        end
        
        function change_doxy_file
            
            d = fileread([MatlabDocMaker.getConfigDirectory '/Doxyfile.template']);
            
            dindex1 = regexp(d, 'SYMBOL_CACHE_SIZE');
            
            new = [d(1:dindex1(1)-7) d(dindex1(3)+27:end)];

            dindex2 = regexp(new, 'DOT_FONTNAME');
            
            new = [new(1:dindex2(2)+24) new(dindex2(2)+33:end)];
            
            dindex3 = regexp(new, 'EXCLUDE                =');
            
            new = [new(1:dindex3+23) ' DocGen' new(dindex3+24:end)];
            
            dindex4 = regexp(new, 'EXCLUDE_PATTERNS       =');
            
            new = [new(1:dindex4+23) ' */+test/* */+tests/*' new(dindex4+24:end)];

            fid = fopen([MatlabDocMaker.getConfigDirectory '/Doxyfile.template'], 'w+');
            
            fprintf(fid, '%s\n', new);
            
            fclose(fid);
            
            
        end
        function html_files = get_html_files(mfiles)
            
            
            for j = 1:size(mfiles)
                str = mfiles{j};
                index = regexp(str,'[A-Z]');
                for i = 1:length(index)
                    str = [str(1:(index(i)-1)) '_' lower(str(index(i))) str(index(i)+1:end)];
                    index = index+1;
                end
                index = regexp(str, '/');
                
                html_files{j,1} = [MatlabDocMaker.getOutputDirectory str(index(end):end-2) '_8m_source.html'];
            end
            
        end
        
        function names = get_names(mfiles)
            
            
            for i = 1:size(mfiles)
                str = mfiles{i};
                index = regexp(str, '/');
                names{i} = str(index(end)+1:end-2);
            end
            
            names = names';
        end
        
        function mfiles = get_m_files(dir)
            
            nm = 1;
            list = what(dir);
            
            mfiles = list.m;
            
            for i = 1:length(list.packages)
                if ~strcmp(list.packages{i},'test') && ~strcmp(list.packages{i},'tests')
                    mfiles = [mfiles; DocGen.get_m_files(strcat(dir,strcat('/+', list.packages{i})))];
                end
            end
            for i = 1:length(list.m)
                mfiles(nm) = {strcat(dir,strcat('/', list.m{i}))};
                nm = nm +1;
            end
            
        end
        
        function publish_matlab_files(mfiles)
            
            
            for i = 1:size(mfiles)
                publish(mfiles{i}, 'outputDir', '.', 'evalCode', false);
            end
            
        end
        
        function remove_published_files(names)
            
            for i = 1:size(names)
                delete([names{i} '.html']);
            end
            
        end
        
        function run
            
            MatlabDocMaker.setup
            
            MatlabDocMaker.create
            
            copyfile([MatlabDocMaker.getConfigDirectory '/matlab.css'],MatlabDocMaker.getOutputDirectory)
            
            mfiles = DocGen.get_m_files(MatlabDocMaker.getSourceDirectory);
            
            html_files = DocGen.get_html_files(mfiles);
            
            names = DocGen.get_names(mfiles);
            
            DocGen.publish_matlab_files(mfiles);
            
            DocGen.change_html_file(html_files, names);
            
            DocGen.remove_published_files(names)
            
            
        end
    end
end