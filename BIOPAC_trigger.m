function BIOPAC_trigger(ljHandle, biopac_channel, biopac_onoff)

% This function trigger biopac in specific channel and duration.
% biopac_channel : BIOPAC channel. It starts from 0, 1, 2...
% biopac_onoff : 'on' / 'off'

BIOPAC_ON = 1;
BIOPAC_OFF = 0;
LJ_ioPUT_DIGITAL_BIT = 40; % UE9 + U3

if strcmp(biopac_onoff, 'on')
    Error = ljud_ePut(ljHandle, LJ_ioPUT_DIGITAL_BIT, biopac_channel, BIOPAC_ON, 0);
    Error_Message(Error)
elseif strcmp(biopac_onoff, 'off')
    Error = ljud_ePut(ljHandle, LJ_ioPUT_DIGITAL_BIT, biopac_channel, BIOPAC_OFF, 0);
    Error_Message(Error)
end

end