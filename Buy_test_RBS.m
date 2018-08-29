clear all;
close all;
clc;

%%
init_shares = 5;
init_money = 0;
max_shares = [5 10 20 50 100];
%%
try
    load('Proc_Day.mat')
mov_mat = nchoosek(1:100,2);
mov_mat(end+1:end+length(mov_mat),[1 2]) = flipud(mov_mat(:,[2 1]));
mov_mat = sortrows(mov_mat,[1 2]);
catch
current_path = cd;
cd([cd filesep 'd_all_txt'])
folder_locs = dir(['**' filesep '* stocks']);

for n = 1:length(folder_locs)
    cd([folder_locs(n).folder filesep folder_locs(n).name])
    try
        file_locs = [dir(['**' filesep '*.txt']);file_locs];
    catch
        file_locs = [dir(['**' filesep '*.txt'])];
    end
end

cd(current_path)
mov_mat = nchoosek(1:100,2);
uniq_mov = unique(mov_mat(:));
mov_mat(end+1:end+length(mov_mat),[1 2]) = flipud(mov_mat(:,[2 1]));
mov_mat = sortrows(mov_mat,[1 2]);
qty_output = zeros(length(mov_mat(:,1)),length(file_locs),length(max_shares));
bsl = qty_output;
min_val_len = max(mov_mat(:));
mov_mat_len = length(mov_mat(:,1));
del_pos = zeros(1,length(file_locs),'logical');

for i = 1:length(file_locs)
    [Date,Val] = importfile_day([file_locs(i).folder filesep file_locs(i).name]);
    
    if length(Val) > min_val_len
        
        for m = 1:length(uniq_mov)
            mov(m).val = movmean(Val,[uniq_mov(m) 0],'Endpoints','fill');
        end
        for j = 1:length(max_shares)
            parfor m = 1:mov_mat_len
                mov_1 = mov(mov_mat(m,1)).val;
                mov_2 = mov(mov_mat(m,2)).val;
                max_val = max([mov_mat(m,1) mov_mat(m,2)]);
                buy_logic = mov_1>mov_2;
                
                qty_output(m,i,j) = mov_ave_roi(Val(max_val+1:end),buy_logic(max_val+1:end),init_shares,init_money,max_shares(j));
                bsl(m,i,j) = qty_output(m,i,j)/(Val(end)*init_shares);
            end
        end
        disp(['File ' num2str(i) ' Loaded - ' num2str(round(100*(i/length(file_locs)))) '%']);
    else
        disp(['File ' num2str(i) ' not long enough']);
%         del_pos(i) = true;
    end
    
end

%%
% qty_output(:,del_pos,:)=[];
qty_output(qty_output(:) == 0) = NaN;
save('Proc_Day.mat','-v7.3')
end
%%
qty_output(isinf(qty_output(:))) = NaN;
% bsl(isinf(qty_output(:))) = NaN;
for j = 1:length(max_shares)
    qty_output1 = squeeze(qty_output(:,:,j));
%     bsl1 = squeeze(bsl(:,:,j));
    ave_year_return = mean(qty_output1,2,'omitnan');
%     bsl_rtn = mean(bsl1,2,'omitnan');
    win_perc = 100*(sum(qty_output1>1,2,'omitnan')./length(qty_output1(1,:)));
    
    %%Plotting
    x_val = reshape(mov_mat(:,1),[],max(mov_mat(:,1)));
    y_val = reshape(mov_mat(:,2),[],max(mov_mat(:,1)));
    
    figure
    contourf(x_val,y_val,reshape(ave_year_return,[],max(mov_mat(:,1))),...
        'LineStyle','none')
    xlabel('$t_1$')
    ylabel('$t_2$')
    colormap(redgreencmap(91))
    if ceil(max(abs(ave_year_return)))>2
    set(gca,...
        'clim',[2-ceil(max(abs(ave_year_return))) ceil(max(abs(ave_year_return)))])
    else
    set(gca,'clim',[0 ceil(max(abs(ave_year_return)))])
    end
    
    h = colorbar;
    xlabel(h,'Average Yearly Return')
    figure_saving(['AveYearReturn_' num2str(init_shares) '_' num2str(max_shares(j))],'png','-r600')
    savefig(['AveYearReturn_' num2str(init_shares) '_' num2str(max_shares(j))])
    
    figure
    contourf(x_val,y_val,reshape(win_perc,[],max(mov_mat(:,1))),...
        'LineStyle','none')
    xlabel('$t_1$')
    ylabel('$t_2$')
    colormap('jet')
    h1 = colorbar;
    xlabel(h1,'Win Percentage')
    figure_saving(['WinPerc_' num2str(init_shares) '_' num2str(max_shares(j))],'png','-r600')
    savefig(['WinPerc_' num2str(init_shares) '_' num2str(max_shares(j))])
    
%     figure
%     contourf(x_val,y_val,reshape(bsl_rtn,[],max(mov_mat(:,1))),...
%         'LineStyle','none')
%     xlabel('$t_1$')
%     ylabel('$t_2$')
%     colormap(redgreencmap)
%     
%     set(gca,'xscale','log',...
%         'yscale','log',...
%         'clim',[-max(abs(bsl_rtn)) max(abs(bsl_rtn))])
%     
%     h = colorbar;
%     xlabel(h,'Relative Return')
%     figure_saving(['ReturnRel_' num2str(init_shares) '_' num2str(max_shares(j))],'png','-r600')
%     savefig(['ReturnRel_' num2str(init_shares) '_' num2str(max_shares(j))])
    close all
end