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
    instructions{1}{1} = '지금부터 단어 20개가 주어질 것입니다. 다음 사항을 유의하여 실험에 참여해주십시오.';
    instructions{1}{2} = '첫 단어를 본 후 즉각적으로 떠오르는 단어를 벨이 울린 직후 최대한 빨리 말합니다.';
    
    
elseif get_survey_inst
else
end

end