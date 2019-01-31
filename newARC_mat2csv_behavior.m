%% This script converts .mat files to .csv

subjs={'test001'}

for i = 1 : length(subjs)
sub=(subjs{i});
disp(sub);
x=struct2table(TrialStruct.Trials)
writetable(x,[sub '.csv'])
end
