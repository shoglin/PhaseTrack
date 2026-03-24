%% local_portraits_simple.m - Простое построение локальных фазовых портретов
clear all;
close all;
clc;

%% Определение системы
% dx1/dt = x2
% dx2/dt = x1*x2 + 2*x1^3 - 5*x1 + 1
dx = @(x) [x(2); x(1)*x(2) + 2*x(1)^3 - 5*x(1) + 1];

%% Находим особые точки (x2=0, 2*x1^3 - 5*x1 + 1=0)
coeff = [2, 0, -5, 1];
x1_roots = roots(coeff);
x1_roots = x1_roots(abs(imag(x1_roots)) < 1e-10);
x1_roots = sort(real(x1_roots));

fprintf('Найдено %d особых точек:\n', length(x1_roots));
for i = 1:length(x1_roots)
    fprintf('  Точка %d: (%.4f, 0)\n', i, x1_roots(i));
end

%% Параметры локальных портретов
local_radius = 0.6;     % Радиус окрестности
step = 0.03;             % Шаг сетки

% Создаем фигуру
figure('Name', 'Локальные фазовые портреты', 'Position', [100, 100, 1200, 400]);

%% Для каждой особой точки строим локальный портрет
for i = 1:length(x1_roots)
    subplot(1, length(x1_roots), i);
    hold on;
    grid on;
    axis equal;
    
    x1_eq = x1_roots(i);
    x2_eq = 0;
    
    % Создаем локальную сетку
    x1_grid = x1_eq - local_radius : step : x1_eq + local_radius;
    x2_grid = x2_eq - local_radius : step : x2_eq + local_radius;
    [X1, X2] = meshgrid(x1_grid, x2_grid);
    
    % Рисуем векторное поле (только направление, без интеграции)
    for j = 1:numel(X1)
        x1 = X1(j);
        x2 = X2(j);
        f = dx([x1; x2]);
        
        % Нормализуем для красоты
        norm_f = sqrt(f(1)^2 + f(2)^2);
        if norm_f > 0.01
            f = f / norm_f * 0.12;
            quiver(x1, x2, f(1), f(2), 'Color', [0.4 0.4 0.4], ...
                   'AutoScale', 'off', 'LineWidth', 0.6, 'MaxHeadSize', 0.5);
        end
    end
    
    % Рисуем сепаратрисы для седловых точек (аналитически)
    J = [0, 1; x2_eq + 6*x1_eq^2 - 5, x1_eq];
    [V, D] = eig(J);
    eig_vals = diag(D);
    
    % Определяем тип точки
    if real(eig_vals(1)) * real(eig_vals(2)) < 0
        % Седло - рисуем сепаратрисы
        type_text = 'Седло';
        color_point = 'r';
        
        % Находим направления сепаратрис
        for k = 1:2
            dir_vec = V(:, k);
            dir_vec = dir_vec / norm(dir_vec);
            
            % Рисуем в обе стороны
            t_vals = linspace(0, local_radius * 0.8, 50);
            for sign_dir = [-1, 1]
                x_sep = x1_eq + sign_dir * t_vals * dir_vec(1);
                y_sep = x2_eq + sign_dir * t_vals * dir_vec(2);
                
                % Проверяем, что точки в пределах графика
                mask = abs(x_sep - x1_eq) <= local_radius & ...
                       abs(y_sep - x2_eq) <= local_radius;
                x_sep = x_sep(mask);
                y_sep = y_sep(mask);
                
                if length(x_sep) > 1
                    plot(x_sep, y_sep, 'r-', 'LineWidth', 1.5);
                end
            end
        end
        
    elseif isreal(eig_vals) && eig_vals(1) > 0 && eig_vals(2) > 0
        type_text = 'Неуст. узел';
        color_point = 'm';
    elseif isreal(eig_vals) && eig_vals(1) < 0 && eig_vals(2) < 0
        type_text = 'Уст. узел';
        color_point = 'g';
    elseif ~isreal(eig_vals) && real(eig_vals(1)) > 0
        type_text = 'Неуст. фокус';
        color_point = 'm';
    elseif ~isreal(eig_vals) && real(eig_vals(1)) < 0
        type_text = 'Уст. фокус';
        color_point = 'g';
    elseif abs(real(eig_vals(1))) < 1e-10 && ~isreal(eig_vals)
        type_text = 'Центр';
        color_point = 'b';
    else
        type_text = 'Особая точка';
        color_point = 'k';
    end
    
    % Рисуем особую точку
    plot(x1_eq, x2_eq, 'o', 'MarkerSize', 12, ...
         'MarkerFaceColor', color_point, 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
    
    % Рисуем круговые траектории для центра (аналитически)
    if strcmp(type_text, 'Центр')
        theta = linspace(0, 2*pi, 100);
        for r = [0.2, 0.35, 0.5]
            x_circ = x1_eq + r * cos(theta);
            y_circ = x2_eq + r * sin(theta);
            plot(x_circ, y_circ, 'b--', 'LineWidth', 1);
        end
    end
    
    % Рисуем примерные траектории для узлов и фокусов (несколько линий)
    if contains(type_text, 'узел') || contains(type_text, 'фокус')
        angles = linspace(0, 2*pi, 12);
        for angle = angles
            % Маленькое смещение
            eps = 0.08;
            x0 = x1_eq + eps * cos(angle);
            v0 = x2_eq + eps * sin(angle);
            
            % Короткая интеграция
            try
                opts = odeset('MaxStep', 0.05, 'RelTol', 1e-6);
                [t, z] = ode45(@(t,x) dx(x), [0, 0.5], [x0; v0], opts);
                if size(z, 1) > 1
                    plot(z(:,1), z(:,2), color_point, 'LineWidth', 1);
                end
                
                [t, z] = ode45(@(t,x) dx(x), [0, -0.5], [x0; v0], opts);
                if size(z, 1) > 1
                    plot(z(:,1), z(:,2), color_point, 'LineWidth', 1);
                end
            catch
                % Пропускаем если не получается
            end
        end
    end
    
    % Оформление
    xlim([x1_eq - local_radius, x1_eq + local_radius]);
    ylim([x2_eq - local_radius, x2_eq + local_radius]);
    xlabel('x_1', 'FontSize', 11);
    ylabel('x_2', 'FontSize', 11);
    title(sprintf('Точка (%.3f, 0)\n%s', x1_eq, type_text), 'FontSize', 11);
    grid on;
    
    % Добавляем линии осей
    plot([x1_eq - local_radius, x1_eq + local_radius], [x2_eq, x2_eq], 'k--', 'LineWidth', 0.5);
    plot([x1_eq, x1_eq], [x2_eq - local_radius, x2_eq + local_radius], 'k--', 'LineWidth', 0.5);
end

%% Добавляем информацию о собственных значениях
fprintf('\n=== Детальный анализ ===\n');
for i = 1:length(x1_roots)
    x1_eq = x1_roots(i);
    J = [0, 1; 6*x1_eq^2 - 5, x1_eq];
    eig_vals = eig(J);
    
    fprintf('\nТочка (%.4f, 0):\n', x1_eq);
    fprintf('  Матрица Якоби:\n');
    fprintf('  [%8.4f, %8.4f\n', J(1,1), J(1,2));
    fprintf('   %8.4f, %8.4f]\n', J(2,1), J(2,2));
    fprintf('  Собственные значения: λ1 = %8.4f, λ2 = %8.4f\n', eig_vals(1), eig_vals(2));
    
    % Определяем тип
    det_J = det(J);
    trace_J = trace(J);
    fprintf('  След = %.4f, Определитель = %.4f\n', trace_J, det_J);
    
    if det_J < 0
        fprintf('  → Седло (неустойчивая)\n');
    elseif det_J > 0 && trace_J < 0
        fprintf('  → Устойчивый узел или фокус\n');
    elseif det_J > 0 && trace_J > 0
        fprintf('  → Неустойчивый узел или фокус\n');
    elseif abs(trace_J) < 1e-10 && det_J > 0
        fprintf('  → Центр (нейтральная)\n');
    end
end

%% Сохранение
saveas(gcf, 'local_phase_portraits.png');
fprintf('\nГрафик сохранен: local_phase_portraits.png\n');