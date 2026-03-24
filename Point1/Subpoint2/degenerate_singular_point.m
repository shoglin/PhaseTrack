%% main.m - Анализ системы с вырожденной особой точкой
% Система: d^2x/dt^2 - sin(x)*dx/dt - ln(1+x^2) = 0
% В нормальной форме:
%   x1' = x2
%   x2' = sin(x1)*x2 + ln(1+x1^2)

clear all;
close all;
clc;

tic;

%% ==================== 1. ОПРЕДЕЛЕНИЕ СИСТЕМЫ ====================
fprintf('\n========================================\n');
fprintf('СИСТЕМА: d^2x/dt^2 - sin(x)*dx/dt - ln(1+x^2) = 0\n');
fprintf('========================================\n\n');

% Правая часть системы
dx = @(t, x) [x(2); sin(x(1))*x(2) + log(1 + x(1)^2)];

%% ==================== 2. ПОИСК ОСОБЫХ ТОЧЕК ====================
fprintf('>>> 1. ПОИСК ОСОБЫХ ТОЧЕК\n');
fprintf('----------------------------------------\n');

% Условия равновесия: x2 = 0, ln(1+x1^2) = 0
% ln(1+x1^2) = 0 => 1+x1^2 = 1 => x1^2 = 0 => x1 = 0

x1_eq = 0;
x2_eq = 0;

fprintf('Найдена особая точка: (%.4f, %.4f)\n', x1_eq, x2_eq);
fprintf('Это вырожденная точка (собственные значения матрицы линеаризации равны нулю).\n\n');

%% ==================== 3. ЛИНЕАРИЗАЦИЯ ====================
fprintf('>>> 2. ЛИНЕАРИЗАЦИЯ В ОКРЕСТНОСТИ ОСОБОЙ ТОЧКИ\n');
fprintf('----------------------------------------\n');

% Матрица Якоби
% J = [df1/dx1, df1/dx2; df2/dx1, df2/dx2]
% где:
% f1 = x2
% f2 = sin(x1)*x2 + ln(1+x1^2)

% df1/dx1 = 0
% df1/dx2 = 1
% df2/dx1 = cos(x1)*x2 + (2*x1)/(1+x1^2)
% df2/dx2 = sin(x1)

% В точке (0,0):
% df2/dx1 = cos(0)*0 + 0 = 0
% df2/dx2 = sin(0) = 0

J = [0, 1; 0, 0];

fprintf('Матрица Якоби в точке (0,0):\n');
disp(J);

eig_vals = eig(J);
fprintf('Собственные значения: λ1 = %.2f, λ2 = %.2f\n', eig_vals(1), eig_vals(2));

fprintf('\n*** ВЫВОД ***\n');
fprintf('Оба собственных значения равны нулю.\n');
fprintf('Это вырожденная особая точка.\n');
fprintf('Для определения типа требуется анализ нелинейных членов.\n\n');

%% ==================== 4. НЕЛИНЕЙНЫЙ АНАЛИЗ ====================
fprintf('>>> 3. АНАЛИЗ НЕЛИНЕЙНЫХ ЧЛЕНОВ\n');
fprintf('----------------------------------------\n');

% Разложение в ряд Тейлора
fprintf('Разложение в ряд Тейлора в окрестности (0,0):\n');
fprintf('  ln(1+x^2) = x^2 - x^4/2 + x^6/3 - ...\n');
fprintf('  sin(x) = x - x^3/6 + x^5/120 - ...\n\n');

fprintf('Подставляем в уравнение:\n');
fprintf('  x2'' = (x1 - x1^3/6 + ...)*x2 + (x1^2 - x1^4/2 + ...)\n\n');

fprintf('Главные члены в окрестности нуля:\n');
fprintf('  x2'' ≈ x1*x2 + x1^2\n\n');

fprintf('*** АНАЛИЗ ГЛАВНЫХ ЧЛЕНОВ ***\n');
fprintf('Упрощенная система:\n');
fprintf('  x1'' = x2\n');
fprintf('  x2'' = x1*x2 + x1^2\n\n');

fprintf('Найдем инвариантные многообразия (сепаратрисы):\n');
fprintf('  Предположим x2 = k*x1^p\n');
fprintf('  Подставляем: k*p*x1^(p-1)*x2 = k*x1^(p+1) + x1^2\n');
fprintf('  При p=1: x2 = k*x1, тогда: k^2*x1^2 = k*x1^2 + x1^2 => k^2 - k - 1 = 0\n');
fprintf('  k = (1 ± √5)/2 ≈ 1.618 и -0.618\n\n');

%% ==================== 5. ПОСТРОЕНИЕ ФАЗОВОГО ПОРТРЕТА ====================
fprintf('>>> 4. ПОСТРОЕНИЕ ФАЗОВОГО ПОРТРЕТА\n');
fprintf('----------------------------------------\n');

% Параметры построения
XMAX = 3.5;         % Граница по осям
STEP = 0.2;          % Шаг сетки для векторного поля
TMAX = 12;           % Время интегрирования

%% 5.1 Основной фазовый портрет
figure('Name', 'Фазовый портрет системы с вырожденной точкой', ...
       'Position', [50, 50, 1100, 900], ...
       'ToolBar', 'none', 'MenuBar', 'none', ...
       'Color', 'w');

hold on;
grid on;
axis equal;
set(gca, 'FontSize', 11);

%% Векторное поле
fprintf('  Построение векторного поля...\n');

x1_grid = -XMAX:STEP:XMAX;
x2_grid = -XMAX:STEP:XMAX;
[X1, X2] = meshgrid(x1_grid, x2_grid);

for i = 1:numel(X1)
    f = dx(0, [X1(i); X2(i)]);
    len = sqrt(f(1)^2 + f(2)^2);
    if len > 0.1
        f_norm = f / len * 0.22;
        quiver(X1(i), X2(i), f_norm(1), f_norm(2), ...
               'Color', [0.5 0.5 0.5], 'AutoScale', 'off', ...
               'LineWidth', 0.7, 'MaxHeadSize', 0.4);
    end
end

%% Фазовые траектории
fprintf('  Построение фазовых траекторий...\n');

% Начальные условия - сетка по всей плоскости
x0_vals = [-3, -2.5, -2, -1.5, -1, -0.5, 0.5, 1, 1.5, 2, 2.5, 3];
v0_vals = [-3, -2, -1.5, -1, -0.5, 0.5, 1, 1.5, 2, 3];

% Цветовая карта для траекторий
color_map = jet(length(x0_vals) * length(v0_vals));
idx_color = 1;

for x0 = x0_vals
    for v0 = v0_vals
        % Пропускаем точку равновесия
        if abs(x0) < 0.05 && abs(v0) < 0.05
            continue;
        end
        
        try
            opts = odeset('MaxStep', 0.05, 'RelTol', 1e-6);
            
            % Интегрируем вперед
            [t_fwd, z_fwd] = ode45(dx, [0, TMAX], [x0; v0], opts);
            
            % Интегрируем назад
            [t_bwd, z_bwd] = ode45(dx, [0, -TMAX/2], [x0; v0], opts);
            
            % Объединяем траектории
            z_total = [flipud(z_bwd); z_fwd];
            
            % Ограничиваем область
            mask = abs(z_total(:,1)) <= XMAX & abs(z_total(:,2)) <= XMAX;
            z_total = z_total(mask, :);
            
            if size(z_total, 1) > 5
                plot(z_total(:,1), z_total(:,2), 'Color', color_map(idx_color,:), ...
                     'LineWidth', 1);
            end
        catch
            % Пропускаем проблемные траектории
        end
        idx_color = idx_color + 1;
    end
end

%% Вырожденная особая точка
plot(0, 0, 'ro', 'MarkerSize', 16, ...
     'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 2);

text(0.2, 0.25, 'Вырожденная\nособая точка', ...
     'FontSize', 11, 'FontWeight', 'bold', 'Color', 'r', ...
     'HorizontalAlignment', 'left');

%% Приближенные сепаратрисы
fprintf('  Построение сепаратрис...\n');

% Теоретические направления сепаратрис
k1 = (1 + sqrt(5))/2;  % ≈ 1.618
k2 = (1 - sqrt(5))/2;  % ≈ -0.618

% Строим приближенные сепаратрисы
x_sep = linspace(-2, 2, 100);
y_sep1 = k1 * x_sep;
y_sep2 = k2 * x_sep;

% Ограничиваем область
mask1 = abs(y_sep1) <= XMAX;
mask2 = abs(y_sep2) <= XMAX;

plot(x_sep(mask1), y_sep1(mask1), 'g-', 'LineWidth', 2, 'Color', [0 0.7 0]);
plot(x_sep(mask2), y_sep2(mask2), 'm-', 'LineWidth', 2, 'Color', [0.7 0 0.7]);

% Добавляем численные сепаратрисы для подтверждения
x0_sep = [-1.5, -1, -0.5, 0.5, 1, 1.5];
for x0 = x0_sep
    try
        % Верхняя сепаратриса
        [~, z] = ode45(dx, [0, 4], [x0; k1*x0]);
        mask = abs(z(:,1)) <= XMAX & abs(z(:,2)) <= XMAX;
        z = z(mask, :);
        if size(z, 1) > 1
            plot(z(:,1), z(:,2), 'g-', 'LineWidth', 1.5);
        end
        
        % Нижняя сепаратриса
        [~, z] = ode45(dx, [0, 4], [x0; k2*x0]);
        mask = abs(z(:,1)) <= XMAX & abs(z(:,2)) <= XMAX;
        z = z(mask, :);
        if size(z, 1) > 1
            plot(z(:,1), z(:,2), 'm-', 'LineWidth', 1.5);
        end
    catch
    end
end

%% Оформление основного графика
xlabel('x (положение)', 'FontSize', 13, 'FontWeight', 'bold');
ylabel('v = dx/dt (скорость)', 'FontSize', 13, 'FontWeight', 'bold');
title('Фазовый портрет системы: \ddot{x} - sin(x)\dot{x} - ln(1+x^2) = 0', ...
      'FontSize', 14, 'FontWeight', 'bold');

xlim([-XMAX, XMAX]);
ylim([-XMAX, XMAX]);
grid on;

% Линии осей
plot([-XMAX, XMAX], [0, 0], 'k-', 'LineWidth', 1);
plot([0, 0], [-XMAX, XMAX], 'k-', 'LineWidth', 1);

% Легенда
legend('Векторное поле', 'Фазовые траектории', 'Вырожденная точка', ...
       'Сепаратриса (k≈1.618)', 'Сепаратриса (k≈-0.618)', ...
       'Location', 'best', 'FontSize', 10);

%% ==================== 6. ЛОКАЛЬНЫЙ ПОРТРЕТ ====================
fprintf('>>> 5. ПОСТРОЕНИЕ ЛОКАЛЬНОГО ПОРТРЕТА\n');
fprintf('----------------------------------------\n');

figure('Name', 'Локальный портрет в окрестности вырожденной точки', ...
       'Position', [150, 150, 700, 700], ...
       'ToolBar', 'none', 'MenuBar', 'none', ...
       'Color', 'w');

hold on;
grid on;
axis equal;

local_r = 1.2;
step_local = 0.04;

x1_local = -local_r:step_local:local_r;
x2_local = -local_r:step_local:local_r;
[X1l, X2l] = meshgrid(x1_local, x2_local);

% Векторное поле в локальной области
for i = 1:numel(X1l)
    f = dx(0, [X1l(i); X2l(i)]);
    len = sqrt(f(1)^2 + f(2)^2);
    if len > 0.03
        f_norm = f / len * 0.1;
        quiver(X1l(i), X2l(i), f_norm(1), f_norm(2), ...
               'Color', [0.4 0.4 0.4], 'AutoScale', 'off', ...
               'LineWidth', 0.6, 'MaxHeadSize', 0.4);
    end
end

% Траектории в локальной области
x0_local = [-1, -0.8, -0.6, -0.4, -0.2, 0.2, 0.4, 0.6, 0.8, 1];
for x0 = x0_local
    for v0 = [-0.8, -0.5, -0.3, -0.1, 0.1, 0.3, 0.5, 0.8]
        if abs(x0) < 0.05 && abs(v0) < 0.05
            continue;
        end
        try
            opts = odeset('MaxStep', 0.02, 'RelTol', 1e-6);
            [~, z] = ode45(dx, [0, 3], [x0; v0], opts);
            mask = abs(z(:,1)) <= local_r & abs(z(:,2)) <= local_r;
            z = z(mask, :);
            if size(z, 1) > 3
                plot(z(:,1), z(:,2), 'b-', 'LineWidth', 0.8);
            end
            
            [~, z] = ode45(dx, [0, -1.5], [x0; v0], opts);
            mask = abs(z(:,1)) <= local_r & abs(z(:,2)) <= local_r;
            z = z(mask, :);
            if size(z, 1) > 3
                plot(z(:,1), z(:,2), 'b-', 'LineWidth', 0.8);
            end
        catch
        end
    end
end

% Сепаратрисы в локальной области
x_sep_local = linspace(-local_r, local_r, 50);
y_sep1_local = k1 * x_sep_local;
y_sep2_local = k2 * x_sep_local;

mask1_local = abs(y_sep1_local) <= local_r;
mask2_local = abs(y_sep2_local) <= local_r;

plot(x_sep_local(mask1_local), y_sep1_local(mask1_local), 'g-', 'LineWidth', 2);
plot(x_sep_local(mask2_local), y_sep2_local(mask2_local), 'm-', 'LineWidth', 2);

% Особая точка
plot(0, 0, 'ro', 'MarkerSize', 14, 'MarkerFaceColor', 'r');

% Оформление
xlabel('x (положение)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('v = dx/dt (скорость)', 'FontSize', 12, 'FontWeight', 'bold');
title('Локальный портрет в окрестности вырожденной точки', 'FontSize', 13, 'FontWeight', 'bold');
xlim([-local_r, local_r]);
ylim([-local_r, local_r]);
grid on;

plot([-local_r, local_r], [0, 0], 'k--', 'LineWidth', 0.5);
plot([0, 0], [-local_r, local_r], 'k--', 'LineWidth', 0.5);

%% ==================== 7. ВЫВОДЫ ====================
fprintf('\n========================================\n');
fprintf('>>> 6. ВЫВОДЫ И АНАЛИЗ\n');
fprintf('========================================\n\n');

fprintf('1. ОСОБАЯ ТОЧКА:\n');
fprintf('   - Координаты: (0, 0)\n');
fprintf('   - Матрица линеаризации: J = [0 1; 0 0]\n');
fprintf('   - Собственные значения: λ1 = λ2 = 0\n');
fprintf('   - Тип: ВЫРОЖДЕННАЯ ОСОБАЯ ТОЧКА\n\n');

fprintf('2. ТИП ВЫРОЖДЕННОЙ ТОЧКИ:\n');
fprintf('   - Это точка бифуркации типа "седло-узел" (saddle-node)\n');
fprintf('   - Нелинейный анализ дает два направления сепаратрис:\n');
fprintf('     * Направление 1: v = %.3f * x  (устойчивое многообразие)\n', k1);
fprintf('     * Направление 2: v = %.3f * x  (неустойчивое многообразие)\n', k2);
fprintf('   - Точка является ПОЛУУСТОЙЧИВОЙ (притягивает с одной стороны,\n');
fprintf('     отталкивает с другой)\n\n');

fprintf('3. ПОВЕДЕНИЕ СИСТЕМЫ:\n');
fprintf('   - В области x > 0, v > k1*x: траектории уходят на бесконечность\n');
fprintf('   - В области x > 0, v < k2*x: траектории уходят на бесконечность\n');
fprintf('   - В области между сепаратрисами: траектории притягиваются к точке\n');
fprintf('   - Для x < 0 поведение симметрично\n\n');

fprintf('4. ФИЗИЧЕСКАЯ ИНТЕРПРЕТАЦИЯ:\n');
fprintf('   - При малых отклонениях система может возвращаться в равновесие\n');
fprintf('   - При превышении критической скорости происходит "срыв"\n');
fprintf('   - Это характерно для систем с трением и нелинейной восстанавливающей силой\n');

%% ==================== 8. СОХРАНЕНИЕ ====================
fprintf('\n>>> 7. СОХРАНЕНИЕ ГРАФИКОВ\n');
fprintf('----------------------------------------\n');

print(1, 'phase_portrait_degenerate_system', '-dpng', '-r300');
print(2, 'local_portrait_degenerate_point', '-dpng', '-r300');

fprintf('Графики сохранены:\n');
fprintf('  - phase_portrait_degenerate_system.png\n');
fprintf('  - local_portrait_degenerate_point.png\n');

toc;
fprintf('\n========================================\n');
fprintf('АНАЛИЗ ЗАВЕРШЕН\n');
fprintf('========================================\n');