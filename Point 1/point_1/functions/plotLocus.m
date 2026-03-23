function plotLocus(x1, x2, dx, event_out_of_bounds, TMAX)
% Функция построения фазовых траекторий (locus) с плавными кривыми
%
% Входные параметры:
%   x1, x2 - матрицы сетки (от meshgrid)
%   dx - функция градиента @(t, x)
%   event_out_of_bounds - функция-событие для остановки
%   TMAX - максимальное время интегрирования

% Создаем окно ожидания
f = waitbar(0, "Plotting locus. Please wait...", ...
    'Name', 'Plotting Locus', ...
    'WindowStyle', 'modal');

% Получаем уникальные значения из сетки
x1_vals = unique(x1(:));
x2_vals = unique(x2(:));

% Уменьшаем количество начальных условий для более чистого рисунка
% (берем каждую 2-ю точку, чтобы траектории не перекрывались)
step_idx = max(1, round(length(x1_vals) / 15));
x1_vals_reduced = x1_vals(1:step_idx:end);
x2_vals_reduced = x2_vals(1:step_idx:end);

total_steps = length(x1_vals_reduced) * length(x2_vals_reduced);
current_step = 0;

% Создаем фигуру для фазового портрета (изначально скрытую)
pl_fig = figure('Name', 'Phase Portrait', ...
                'NumberTitle', 'off', ...
                'Visible', 'off', ...
                'Position', [100, 100, 800, 600]);
hold on;

% Настройки для более точного интегрирования (плавные кривые)
options = odeset(...
    'Events', event_out_of_bounds, ...
    'RelTol', 1e-8, ...      % высокая относительная точность
    'AbsTol', 1e-10, ...     % высокая абсолютная точность
    'MaxStep', 0.05);        % ограничение максимального шага

% Цвет для траекторий (светло-синий, полупрозрачный)
trajectory_color = [0.4, 0.6, 0.9];

% Перебираем все начальные условия
for i = 1:length(x1_vals_reduced)
    for j = 1:length(x2_vals_reduced)
        x0 = [x1_vals_reduced(i); x2_vals_reduced(j)];
        
        try
            % Численное интегрирование с высоким разрешением
            [~, sol] = ode45(dx, [0 TMAX], x0, options);
            
            % Строим фазовую траекторию с плавной линией
            plot(sol(:, 1), sol(:, 2), ...
                 'LineWidth', 1.2, ...
                 'Color', trajectory_color);
        catch
            % Пропускаем проблемные начальные условия (например, особые точки)
        end
        
        % Обновляем шкалу прогресса
        current_step = current_step + 1;
        waitbar(current_step / total_steps, f);
    end
end

% Настройка внешнего вида графика
xlabel('x_1 (position)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('x_2 (velocity)', 'FontSize', 12, 'FontWeight', 'bold');
title('Phase Portrait', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
box on;
axis equal;
xlim([min(x1_vals), max(x1_vals)]);
ylim([min(x2_vals), max(x2_vals)]);

% Добавляем особые точки (равновесия) если нужно
hold on;
% Находим и отмечаем точки равновесия (опционально)
% Для данной системы: x2 = 0, и x1*x2 + 2*x1^3 - 5*x1 + 1 = 0 => 2*x1^3 - 5*x1 + 1 = 0
% Можно решить численно и отметить
try
    % Находим корни уравнения 2*x^3 - 5*x + 1 = 0
    equilibrium_x1 = roots([2, 0, -5, 1]);
    equilibrium_x1 = equilibrium_x1(abs(equilibrium_x1) <= max(x1_vals));
    for eq = equilibrium_x1'
        plot(eq, 0, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'red');
    end
catch
    % Если не удалось найти точки равновесия, пропускаем
end

% Показываем фигуру
set(pl_fig, 'Visible', 'on');

% Закрываем окно прогресса
delete(f);
hold off;
end