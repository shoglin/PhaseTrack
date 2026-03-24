%% main_continuum.m - Главный скрипт для системы с континуумом особых точек
clc;
clear all;
close all;

tic;

%% Параметры моделирования
XMAX = 3;      % размер области (от -3 до 3)
STEP = 0.25;   % шаг сетки
TMAX = 10;     % время моделирования

%% Создание сетки
[x1, x2] = meshgrid(-XMAX: STEP: XMAX);

%% Определение системы
% Система: dx1/dt = x2, dx2/dt = x1*x2^4 + x2
dx = @(t, x) [x(2); x(1)*x(2)^4 + x(2)];

% Функция остановки
event_out_of_bounds = @(t, z) max(abs(z)) - (XMAX + 0.5);

%% Вывод информации о системе
fprintf('\n========================================\n');
fprintf('СИСТЕМА С КОНТИНУУМОМ ОСОБЫХ ТОЧЕК\n');
fprintf('========================================\n');
fprintf('Уравнение: d²x/dt² - (dx/dt)^4·x - dx/dt = 0\n');
fprintf('Нормальная форма:\n');
fprintf('  x₁'' = x₂\n');
fprintf('  x₂'' = x₁·x₂⁴ + x₂\n\n');

%% Анализ особых точек
fprintf('АНАЛИЗ ОСОБЫХ ТОЧЕК:\n');
fprintf('----------------------------------------\n');
fprintf('Условия: x₂ = 0, x₁·0⁴ + 0 = 0\n');
fprintf('РЕЗУЛЬТАТ: ВСЯ ОСЬ x₂ = 0 - множество особых точек!\n');
fprintf('Это КОНТИНУУМ, а не изолированные точки.\n\n');

fprintf('МАТРИЦА ЯКОБИ:\n');
fprintf('J = [0, 1; x₂⁴, 4x₁x₂³ + 1]\n');
fprintf('На оси x₂ = 0: J = [0, 1; 0, 1]\n');
fprintf('Собственные значения: λ₁ = 0, λ₂ = 1\n\n');

fprintf('ВЫВОД ПО УСТОЙЧИВОСТИ:\n');
fprintf('• λ₂ = 1 > 0 → ВСЕ точки континуума НЕУСТОЙЧИВЫ\n');
fprintf('• λ₁ = 0 → наличие центрального многообразия\n');
fprintf('• Любое отклонение от оси приводит к росту\n\n');

%% Построение фазового портрета
fprintf('ПОСТРОЕНИЕ ФАЗОВОГО ПОРТРЕТА...\n');
figure(1);
set(gcf, 'Name', 'Фазовый портрет (континуум)', 'Position', [50, 50, 900, 700]);
hold on;
grid on;
axis equal;
xlim([-XMAX, XMAX]);
ylim([-XMAX, XMAX]);

% Начальные условия
ic = [];

% Разные области фазовой плоскости
for x = -2.5:0.5:2.5
    for y = [-2, -1.5, -1, -0.5, 0.5, 1, 1.5, 2]
        ic = [ic; x, y];
    end
end

% Вблизи оси
for x = -2.5:0.4:2.5
    for eps = [-0.2, -0.1, 0.1, 0.2]
        ic = [ic; x, eps];
    end
end

% По границам
for x = -2.8:0.5:2.8
    ic = [ic; x, 2.8; x, -2.8];
end

fprintf('Интегрирование %d траекторий...\n', size(ic,1));

% Интегрирование
for i = 1:size(ic,1)
    if mod(i, 30) == 0
        fprintf('  %d/%d\n', i, size(ic,1));
    end
    
    try
        opts = odeset('Events', event_out_of_bounds, 'RelTol', 1e-6);
        
        % Выбор цвета в зависимости от знака x2
        if ic(i,2) > 0
            clr = [0, 0.7, 0];  % зеленый - выше оси
        elseif ic(i,2) < 0
            clr = [0.8, 0.4, 0]; % оранжевый - ниже оси
        else
            clr = [0.5, 0.5, 0.5];
        end
        
        % Вперед по времени
        [~, z] = ode45(dx, [0, TMAX], ic(i,:), opts);
        if ~isempty(z)
            plot(z(:,1), z(:,2), 'Color', clr, 'LineWidth', 1.2);
        end
        
        % Назад по времени
        [~, z] = ode45(dx, [0, -TMAX/2], ic(i,:), opts);
        if ~isempty(z)
            plot(z(:,1), z(:,2), 'Color', clr, 'LineWidth', 0.8, 'LineStyle', '--');
        end
    catch
    end
end

% Континуум особых точек - ВСЯ ОСЬ X2=0
x_axis = linspace(-XMAX, XMAX, 200);
plot(x_axis, zeros(size(x_axis)), 'r-', 'LineWidth', 3);
plot(x_axis, zeros(size(x_axis)), 'r.', 'MarkerSize', 2);

% Оформление
xlabel('x_1 = x', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('x_2 = dx/dt', 'FontSize', 12, 'FontWeight', 'bold');
title('Фазовый портрет: \ddot{x} - \dot{x}^4 x - \dot{x} = 0', ...
      'FontSize', 14, 'FontWeight', 'bold');
text(-2.8, 2.6, 'КОНТИНУУМ ОСОБЫХ ТОЧЕК (x_2 = 0)', ...
     'FontSize', 11, 'Color', 'red', 'FontWeight', 'bold', ...
     'BackgroundColor', 'white');
text(-2.8, 2.2, 'Все точки неустойчивы: λ = 0, 1', ...
     'FontSize', 10, 'BackgroundColor', 'white');
legend('Траектории (x_2 > 0)', 'Траектории (x_2 < 0)', ...
       'Континуум особых точек', 'Location', 'best');
hold off;

%% Векторное поле
figure(2);
set(gcf, 'Name', 'Векторное поле', 'Position', [100, 100, 900, 700]);
clf;

% Вычисляем поле
u = zeros(size(x1));
v = zeros(size(x2));
for i = 1:numel(x1)
    d = dx(0, [x1(i); x2(i)]);
    u(i) = d(1);
    v(i) = d(2);
end

% Визуализация
quiver(x1, x2, u, v, 0.4, 'Color', [0, 0.4, 0.8], 'LineWidth', 1);
hold on;

% Континуум
plot(x_axis, zeros(size(x_axis)), 'r-', 'LineWidth', 2.5);

% Добавляем контур скорости
[X, Y] = meshgrid(linspace(-XMAX, XMAX, 50), linspace(-XMAX, XMAX, 50));
U = zeros(size(X));
V = zeros(size(Y));
for i = 1:numel(X)
    d = dx(0, [X(i); Y(i)]);
    U(i) = d(1);
    V(i) = d(2);
end
speed = sqrt(U.^2 + V.^2);
contour(X, Y, speed, 15, 'LineColor', [0.6, 0.6, 0.6], 'LineStyle', '--');

xlabel('x_1 = x', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('x_2 = dx/dt', 'FontSize', 12, 'FontWeight', 'bold');
title('Векторное поле', 'FontSize', 14, 'FontWeight', 'bold');
colorbar;
grid on;
axis equal;
hold off;

%% Аналитический график с пояснениями
figure(3);
set(gcf, 'Name', 'Анализ устойчивости', 'Position', [150, 150, 900, 700]);
clf;
hold on;
grid on;
axis equal;
xlim([-XMAX, XMAX]);
ylim([-XMAX, XMAX]);

% Ключевые траектории для демонстрации
key_points = [
    -2, 0.2; -2, -0.2;
    -1, 0.2; -1, -0.2;
    0, 0.2; 0, -0.2;
    1, 0.2; 1, -0.2;
    2, 0.2; 2, -0.2;
    -2, 1; -2, -1;
    0, 1.5; 0, -1.5;
    2, 1; 2, -1
];

for i = 1:size(key_points,1)
    try
        opts = odeset('Events', event_out_of_bounds, 'RelTol', 1e-6);
        
        if key_points(i,2) > 0
            clr = [0, 0.6, 0];
        else
            clr = [0.8, 0.3, 0];
        end
        
        [~, z] = ode45(dx, [0, TMAX], key_points(i,:), opts);
        if ~isempty(z)
            plot(z(:,1), z(:,2), 'Color', clr, 'LineWidth', 2);
        end
        
        plot(key_points(i,1), key_points(i,2), 'ko', 'MarkerSize', 6, ...
             'MarkerFaceColor', clr);
    catch
    end
end

% Континуум
plot(x_axis, zeros(size(x_axis)), 'r-', 'LineWidth', 3);

% Пояснения
text(-2.8, 2.5, 'АНАЛИЗ УСТОЙЧИВОСТИ:', ...
     'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', 'white');
text(-2.8, 2.1, '• λ₁ = 0 (центральное многообразие)', ...
     'FontSize', 10, 'BackgroundColor', 'white');
text(-2.8, 1.7, '• λ₂ = 1 > 0 (неустойчивость)', ...
     'FontSize', 10, 'BackgroundColor', 'white');
text(-2.8, 1.3, '• ВСЕ точки оси НЕУСТОЙЧИВЫ', ...
     'FontSize', 10, 'Color', 'red', 'FontWeight', 'bold', ...
     'BackgroundColor', 'white');
text(-2.8, 0.9, '• Любое отклонение → экспоненциальный рост', ...
     'FontSize', 10, 'BackgroundColor', 'white');
text(-2.8, 0.5, '• x₂ > 0 → уход вверх', ...
     'FontSize', 10, 'Color', [0, 0.6, 0], 'BackgroundColor', 'white');
text(-2.8, 0.1, '• x₂ < 0 → уход вниз', ...
     'FontSize', 10, 'Color', [0.8, 0.3, 0], 'BackgroundColor', 'white');

xlabel('x_1 = x', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('x_2 = dx/dt', 'FontSize', 12, 'FontWeight', 'bold');
title('Анализ устойчивости континуума особых точек', ...
      'FontSize', 14, 'FontWeight', 'bold');
hold off;

toc;
fprintf('\nГОТОВО! Построено 3 графика.\n');