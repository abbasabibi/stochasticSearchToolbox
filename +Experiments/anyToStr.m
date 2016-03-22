function str = anyToStr(varargin)
    str = cell(1,numel(varargin));
    for idx = 1:numel(varargin)
        switch class(varargin{idx})
            case 'char'
                str{idx} = sprintf('''%s''',varargin{idx});
            case 'cell'
                str{idx} = sprintf('{ %s }',Experiments.anyToStr(varargin{idx}{:}));
            case 'function_handle'
                str{idx} = sprintf('func:%s',func2str(varargin{idx}));
            otherwise
                if(isnumeric(varargin{idx})||islogical(varargin{idx}))
                    str{idx} = sprintf('[ %s ]',num2str(varargin{idx}));
                else
                    str{idx} = class(varargin{idx});
                end
        end
    end
    str = sprintf('%s ',str{:});
    str(end) = [];
end