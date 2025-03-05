function plan = buildfile
    plan = buildplan(localfunctions);
    
    plan("package") = matlab.buildtool.Task( ...
        Description = "Package toolbox", ...
        Actions = @packageToolbox);

    plan("benchmark").Dependencies = "compile";

    plan.DefaultTasks = ["check" "test" "package"];
end

function checkTask(~)
    issues = codeIssues("toolbox");

    errors = issues.Issues(issues.Issues.Severity=="error", ...
        ["FullFilename", "LineStart", "Description"]);
    warnings = issues.Issues(issues.Issues.Severity=="warning", ...
        ["FullFilename", "LineStart", "Description"]);

    if ~isempty(errors)
        disp("Errors");
        disp("======")
        for i = 1:height(errors)
            fprintf("%s:%d\n",errors{i,"FullFilename"}, ...
                errors{i,"LineStart"});
            fprintf("  %s\n",errors{i,"Description"});
        end
    end

    if ~isempty(warnings)
        disp("Warnings");
        disp("========")
        for i = 1:height(warnings)
            fprintf("%s:%d\n",warnings{i,"FullFilename"}, ...
                warnings{i,"LineStart"});
            fprintf("  %s\n",warnings{i,"Description"});
        end
    end

    assert(isempty(errors));
end

function testTask(~)
    oldpath = addpath(genpath("toolbox"));
    finalize = onCleanup(@()(path(oldpath)));

    results = runtests("tests","IncludeSubfolders",true);
    disp(results);
    assertSuccess(results);
end

function compileTask(~)
    %% Path to MATLAB provided cmake
    cmake = fullfile(matlabroot, 'bin', computer('arch'),'cmake','bin','cmake');
    % The windows version has a blank in the program folder name
    % (C:/Program Files), thus we use additional double quotes.
    cmake = ['"' cmake '"'];

    if system(strcat(cmake," --version")) ~= 0
        disp("CMake is not provided by MATLAB. MATLAB Coder must be installed.");
        return;
    end
    %% Run cmake
    system(strcat(cmake," -S bindings/ -B build -DCMAKE_BUILD_TYPE=Release"));
    system(strcat(cmake," --build build --config Release"));
    system(strcat(cmake," --install build --prefix toolbox/internal/mex --component Runtime"));
end

function benchmarkTask(~)
    oldpath = addpath(genpath("toolbox"));
    finalize = onCleanup(@()(path(oldpath)));

    tr = runperf("tests/testSnapshot.m");

    results = vertcat(tr.Samples);

    % Extract site and function under test
    pat = '\[dataset=(?<Site>\w*)\]\/(?<Function>\w*)';
    results = [results struct2table(cell2mat(regexp(string(results.Name),pat,'names')))];

    % Extract libtopotoolbox flag
    % Not every function has a uselibtt argument
    v = zeros(size(results,1),1,'logical');
    pat3 = '\(uselibtt=(?<UseLibTT>\w*)\)';
    s = regexp(string(results.Name),pat3,'names');
    haslibtt = cellfun(@(x) length(x) == 1, s);
    v(haslibtt) = cell2mat(arrayfun(@(x) x.UseLibTT == "true",cell2mat(s),'UniformOutput',false));
    results.UseLibTT = v;

    % Summarize samples with min, median and max.
    T = groupsummary(results, ...
        ["Site","Function","UseLibTT","RunIdentifier"], {"min","median","max"},"MeasuredTime");

    T = renamevars(T,["GroupCount","min_MeasuredTime","median_MeasuredTime","max_MeasuredTime"], ...
        ["SampleSize","Min","Median","Max"]);

    % Add information about the commit and benchmark run to the table
    runinfo = table;
    lastCommit = gitrepo().LastCommit;
    runinfo.LastCommit = lastCommit.ID;
    runinfo.CommitDate = lastCommit.CommitterDate;
    runinfo.RunDate = datetime;
    runinfo = [runinfo tr(1).Samples(1,"RunIdentifier")];
    results = join(T,runinfo);

    % Append new run to the results file
    resultsfile = "tests/results/benchmark.csv";
    if ~isfolder(fileparts(resultsfile))
        mkdir(fileparts(resultsfile))
    end
    if isfile(resultsfile)
        results = [readtable(resultsfile);results];
    end

    writetable(results,resultsfile);
end

function docTask(~)
    oldpath = addpath(genpath("toolbox"));
    rmpath(genpath("toolbox/docs/mlxfiles"));
    finalize = onCleanup(@()(path(oldpath)));

    publishtthelp2html;
end
