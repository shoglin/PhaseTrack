function plotLocus(x1, x2, dx, event_out_of_bounds, TMAX, equilibria)
% Функция построения фазового портрета

% Получаем уникальные значения из сетки
x1_vals = unique(x1(:));
x2_vals = unique(x2(:));

% Уменьшаем количество начальных условий для более чистого рисунка
step_idx = max(1, round(length(x1_vals) / 15));
x1_vals_reduced = x1_vals(1:step_idx:end);
x2_vals_reduced = x2_vals(1:step_idx:end);

total_steps = length(x1_vals_reduced) * length(x2_vals_reduced);
current_step = 0;

% Создаем фигуру
pl_fig = figure('Name', 'Phase Space', 'NumberTitle', 'off', 'Visible', 'off');
hold on;

% Настройки для численного интегрирования
options = odeset('Events', event_out_of_bounds, 'RelTol', 1e-8, 'AbsTol', 1e-10, 'MaxStep', 0.05);

% Прогресс-бар
f = waitbar(0, "Plotting locus. Please wait...", ...
    'Name', 'Plotting Locus', ...
    'WindowStyle', 'modal');

% Перебираем начальные условия
for i = 1:length(x1_vals_reduced)
    for j = 1:length(x2_vals_reduced)
        x0 = [x1_vals_reduced(i); x2_vals_reduced(j)];
        
        try
            [~, sol] = ode45(dx, [0 TMAX], x0, options);
            plot(sol(:, 1), sol(:, 2), 'c', 'LineWidth', 1);
        catch
            % Пропускаем проблемные начальные условия
        end
        
        current_step = current_step + 1;
        waitbar(current_step / total_steps, f);
    end
end

% Отображаем особые точки
if nargin >= 6 && ~isempty(equilibria)
    plot(equilibria(1, :), equilibria(2, :), 'ro', ...
         'MarkerSize', 8, ...
         'MarkerFaceColor', 'red');
    legend('Траектории', 'Особые точки', 'Location', 'best');
else
    legend('Траектории', 'Location', 'best');
end

% Настройка графика
xlabel('x_1 (position)', 'FontSize', 12);
ylabel('x_2 (velocity)', 'FontSize', 12);
title('Phase Portrait', 'FontSize', 14);
grid on;
box on;
axis equal;
xlim([min(x1_vals), max(x1_vals)]);
ylim([min(x2_vals), max(x2_vals)]);

set(pl_fig, 'Visible', 'on');
delete(f);
hold off;
end