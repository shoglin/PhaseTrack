function plotTrajectories(x1, x2, dx, TMAX)
% Построение фазовых траекторий

% Получаем уникальные значения из сетки
x1_vals = unique(x1(:));
x2_vals = unique(x2(:));

% Уменьшаем количество начальных условий для чистоты рисунка
step = max(1, round(length(x1_vals)/15));
x1_reduced = x1_vals(1:step:end);
x2_reduced = x2_vals(1:step:end);

% Настройки интегрирования для плавных кривых
options = odeset('RelTol', 1e-8, 'AbsTol', 1e-10, 'MaxStep', 0.05);

% Прогресс-бар
h = waitbar(0, 'Построение фазовых траекторий...');

total = length(x1_reduced) * length(x2_reduced);
current = 0;

% Перебираем все начальные условия
for i = 1:length(x1_reduced)
    for j = 1:length(x2_reduced)
        x0 = [x1_reduced(i); x2_reduced(j)];
        
        try
            % Численное интегрирование
            [~, sol] = ode45(dx, [0 TMAX], x0, options);
            % Строим траекторию
            plot(sol(:, 1), sol(:, 2), 'c', 'LineWidth', 0.8);
        catch
            % Пропускаем проблемные начальные условия
        end
        
        % Обновляем прогресс-бар
        current = current + 1;
        waitbar(current/total, h);
    end
end

% Закрываем прогресс-бар
close(h);
end