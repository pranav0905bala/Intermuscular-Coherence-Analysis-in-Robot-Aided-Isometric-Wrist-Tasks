function EMG = extractTrignoEMG(filename)
% Robust extractor for Trigno Discover EMG CSV files
    
    raw = readcell(filename, 'Delimiter', ',');
    
    % Row 4 has muscle names: "1 (FDS) (81029)", "2 (FDS) (81029)", etc.
    headerRow = 4;
    
    % Row 6 has "EMG 1 Time Series (s)" and "EMG 1 (mV)" labels
    emgHeaderRow = 6;
    
    % Row 8 is where data starts
    dataRow = 8;
    
    fprintf('Reading muscle data from row %d\n', headerRow);
    
    muscleNames = {};
    emgCols = [];
    nCols = size(raw, 2);
    
    % ---- Extract muscle names and EMG columns
    % Column 1 is shared time, muscles start from column 2
    for c = 1:nCols
        if c > size(raw, 2) || headerRow > size(raw, 1)
            continue;
        end
        
        val = raw{headerRow, c};
        
        if ischar(val) || isstring(val)
            % Extract muscle name from pattern like "1 (FDS) (81029)"
            tok = regexp(char(val), '\(([A-Z]+)\)', 'tokens', 'once');
            
            if ~isempty(tok)
                muscleName = upper(tok{1});
                
                % For column 1, it's the time column (skip for muscles)
                if c == 1
                    fprintf('Column %d: Time column\n', c);
                else
                    % All other columns are EMG data
                    muscleNames{end+1} = muscleName;
                    emgCols(end+1) = c;
                    fprintf('Column %d: %s\n', c, muscleName);
                end
            end
        end
    end
    
    if isempty(muscleNames)
        error('No muscles found. Check file format.');
    end
    
    fprintf('\nFound %d muscles\n', length(muscleNames));
    
    % ---- Extract time (column 1)
    timeData = raw(dataRow:end, 1);
    
    % Handle missing data markers
    for i = 1:length(timeData)
        if ~isnumeric(timeData{i})
            timeData{i} = NaN;
        end
    end
    
    EMG.time = cell2mat(timeData);
    EMG.time = EMG.time(~isnan(EMG.time));
    
    fprintf('Extracted %d time points\n', length(EMG.time));
    
    % ---- Extract each muscle's EMG signal
    for k = 1:length(muscleNames)
        x = raw(dataRow:end, emgCols(k));
        
        % Handle missing data markers
        for i = 1:length(x)
            if ~isnumeric(x{i})
                x{i} = NaN;
            end
        end
        
        x = cell2mat(x);
        x = x(~isnan(x));
        
        % Trim to match time length
        minLen = min(length(EMG.time), length(x));
        EMG.time = EMG.time(1:minLen);
        x = x(1:minLen);
        
        % Create valid field name
        name = matlab.lang.makeValidName(muscleNames{k});
        EMG.(name) = x;
        
        fprintf('Extracted %s: %d samples\n', name, length(x));
    end
    
    fprintf('\n=== Extraction Complete ===\n');
    fprintf('Available fields: %s\n', strjoin(fieldnames(EMG)', ', '));
end