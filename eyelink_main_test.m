function eyelink_main(savefilename, varargin)

% eyelink_main(savefilename, varargin)
% 
% varargin: 'Init', 'Shutdown'

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            
            case 'Init'
                
                commandwindow;
                dummymode=0;
                
                try
                    
                    edfFile = sprintf('%s.EDF', savefilename);
                    
                    if ~EyelinkInit(dummymode)
                        fprintf('Eyelink Init aborted. Cannot connect to Eyelink\n');
                        Eyelink('Shutdown');
                        Screen('CloseAll');
                        commandwindow;
                        return;
                    end
                    
                    [v, vs]=Eyelink('GetTrackerVersion');
                    
                    % open file to record data to
                    eye = Eyelink('Openfile', edfFile);
                    
                    if eye~=0
                        fprintf('Cannot create EDF file ''%s'' ', edffilename);
                        Eyelink('Shutdown');
                        Screen('CloseAll');
                        commandwindow;
                        return;
                    end
                    
                    Eyelink('command', 'add_file_preamble_text ''Recorded by EyelinkToolbox demo-experiment''');
                    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
                    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
                    
                    % check the software version
                    % add "HTARGET" to record possible target data for EyeLink Remote
                    if v>=4
                        Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,HTARGET,GAZERES,STATUS,INPUT');
                        Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,STATUS,INPUT');
                    else
                        Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT');
                        Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
                    end
                    
                    % make sure we're still connected.
                    if Eyelink('IsConnected')~=1 && dummymode == 0
                        fprintf('not connected at step 5, clean up\n');
                        % cleanup;
                        % function cleanup
                        Eyelink('Shutdown');
                        Screen('CloseAll');
                        commandwindow;
                        return;
                    end
                    
                catch exc
                    %this "catch" section executes in case of an error in the "try" section
                    %above.  Importantly, it closes the onscreen window if its open.
                    % cleanup;
                    % function cleanup
                    getReport(exc,'extended')
                    disp('EYELINK CAUGHT')
                    Eyelink('Shutdown');
                    Screen('CloseAll');
                    commandwindow;
                end
                
            case 'Shutdown'
                
                Eyelink('Command', 'set_idle_mode');
                WaitSecs(0.5);
                Eyelink('CloseFile');
                % download data file
                try
                    fprintf('Receiving data file ''%s''\n', edfFile );
                    status=Eyelink('ReceiveFile');
                    if status > 0
                        fprintf('ReceiveFile status %d\n', status);
                    end
                    if 2==exist(edfFile, 'file')
                        fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
                    end
                catch
                    fprintf('Problem receiving data file ''%s''\n', edfFile );
                end
                % STEP 9
                % cleanup;
                % function cleanup
                Eyelink('Shutdown');
                
            otherwise, warning(['Unknown input string option:' varargin{i}]);
        end
    end
end


