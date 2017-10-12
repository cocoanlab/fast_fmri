function instructions = load_instruction(varargin)

% default
get_task_inst = false;
get_survey_inst = false;

% parsing varargin
for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'task'}
                get_task_inst = true;
            case {'survey'}
                get_survey_inst = true;
        end
    end
end

if get_task_inst
    instructions{1}{1} = '���ݺ��� �ܾ� 20���� �־��� ���Դϴ�. ���� ������ �����Ͽ� ���迡 �������ֽʽÿ�.';
    instructions{1}{2} = 'ù �ܾ �� �� �ﰢ������ �������� �ܾ ���� �︰ ���� �ִ��� ���� ���մϴ�.';
    
    
elseif get_survey_inst
else
end

end