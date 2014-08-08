
ORQ(2, :) = zeros(1, 288);

fprintf('Computing performance measures...\n');
GP_VMT = compute_vmt(GP_D, GP_V, llen');
HOV_VMT = compute_vmt(HOV_D, HOV_V, llen');
GP_VHT = compute_vht(GP_D, llen');
HOV_VHT = compute_vht(HOV_D, llen');
GP_Delay = compute_delay(GP_VMT, GP_VHT, ffspeeds');
HOV_Delay = compute_delay(HOV_VMT, HOV_VHT, ffspeeds');
OR_VHT = (1/12)*ORQ;
Total_VHT = GP_VHT + HOV_VHT + OR_VHT;
Total_Delay = GP_Delay + HOV_Delay + OR_VHT;


if 1
fprintf('Writing performance measures to spreadsheet...\n');
xlswrite(xlsx_file, [GP_VMT; sum(GP_VMT)], 'GP_VMT', sprintf('h%d:ki%d', range(1), range(2)+1));
xlswrite(xlsx_file, [GP_VHT; sum(GP_VHT)], 'GP_VHT', sprintf('h%d:ki%d', range(1), range(2)+1));
xlswrite(xlsx_file, [GP_Delay; sum(GP_Delay)], 'GP_Delay', sprintf('h%d:ki%d', range(1), range(2)+1));
xlswrite(xlsx_file, [HOV_VMT; sum(HOV_VMT)], 'HOV_VMT', sprintf('h%d:ki%d', range(1), range(2)+1));
xlswrite(xlsx_file, [HOV_VHT; sum(HOV_VHT)], 'HOV_VHT', sprintf('h%d:ki%d', range(1), range(2)+1));
xlswrite(xlsx_file, [HOV_Delay; sum(HOV_Delay)], 'HOV_Delay', sprintf('h%d:ki%d', range(1), range(2)+1));
xlswrite(xlsx_file, [Total_VHT; sum(Total_VHT)], 'Total_VHT', sprintf('j%d:kk%d', range(1), range(2)+1));
xlswrite(xlsx_file, [Total_Delay; sum(Total_Delay)], 'Total_Delay', sprintf('j%d:kk%d', range(1), range(2)+1));
end
