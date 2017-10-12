function waitsec_fromstarttime(starttime, duration)

% function waitsec_usingwhile(starttime, duration)

while true
    if GetSecs - starttime >= duration
        break;
    end
end

end