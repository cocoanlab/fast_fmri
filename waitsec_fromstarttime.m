function waitsec_fromstarttime(starttime, duration)

% function waitsec_fromstarttime(starttime, duration)

while true
    if GetSecs - starttime >= duration
        break;
    end
end

end