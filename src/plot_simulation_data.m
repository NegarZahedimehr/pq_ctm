
tt=linspace(0,24-1/12,288);

% Extracting link IDs
link_id = xlsread(xlsx_file, 'GP_Speed', sprintf('a%d:e%d', range(1), range(2)));
gp_id = link_id(:, 1)'; % GP link IDs
pm = pm_dir*link_id(:, 2)'; % postmiles
llen = link_id(:, 3)'; % link lengths in miles
ffspeeds = link_id(:, 5)'; % free flow speeds

figure(1);
hold on;
pcolor(pm, tt, ORQ');
colorbar;
axis([pm(1), pm(end), 0, 24]);
xlabel('Abs. Postmile');
ylabel('Time');
title('On-ramp Queues');

figure(2);
hold on;
pcolor(pm, tt, GP_F');
shading flat;
colorbar;
axis([pm(1), pm(end), 0, 24]);
xlabel('Abs. Postmile');
ylabel('Time');
title('GP Flow');

figure(3);
hold on;
pcolor(pm, tt, -GP_V');
shading flat;
colorbar;
axis([pm(1), pm(end), 0, 24]);
xlabel('Abs. Postmile');
ylabel('Time');
title('GP Speed');
grid on;


