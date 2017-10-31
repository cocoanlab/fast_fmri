function ts = fast_fmri_generate_ts

% function ts = fast_fmri_generate_ts

% ts{j} = {{'w1', 'w2'}, [6], [0]} -> no rating
% ts{j} = {{'w1', 'w2'}, [6], [6]} -> rating

ts = cell(40,1);

SID = input('Subject ID (number)? ', 's');
SessID = input('Session number? ', 's');

dat_file = fullfile(savedir, ['b_responsedata_sub' SID '_sess' SessID '.mat']);

load(dat_file); 

intervals = repmat([3 4 6 9]', 1, 13);
for i = 1:size(intervals,2)
    intervals(:,i) = intervals(randperm(4),i);
    wh_rating(i) = randi(3);
end

isi_iti = zeros(40,2);

for i = 1:13
    idx = (3*(i-1)+1):(3*(i-1)+3);
    isi_iti(idx,1) = intervals(1:3,i);
    isi_iti(idx(wh_rating(i)),2) = intervals(4,i);
end

isi_iti(40,1) = 15;

for i = 1:(numel(response)-1)
    ts{i} = {{response{i}, response{i+1}}, isi_iti(i,1), isi_iti(i,2)};
end

end