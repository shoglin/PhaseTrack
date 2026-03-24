%% main.m - Главный исполнительный файл для системы Рабиновича-Фабриканта
clc;
clear all;
close all;

tic; % запуск секундомера

%% Параметры моделирования
% Параметры системы
alpha = 0.05;    % параметр α (можно менять)
gamma = 0.1;     % параметр γ (можно менять)

% Параметры визуализации
XMAX = 2;        % размер сетки по x (от -XMAX до XMAX)
YMAX = 2;        % размер сетки по y (от -YMAX до YMAX)
ZMAX = 2;        % размер сетки по z (от -ZMAX до ZMAX)
STEP = 0.2;      % шаг сетки для векторного поля
TMAX = 100;      % время моделирования

% Начальные условия для траекторий
% Вариант (a)
x0_a = 0.1;
y0_a = -0.1;
z0_a = 0.1;

% Вариант (b)
x0_b = -1;
y0_b = 0;
z0_b = 0.5;

%% Определение системы Рабиновича-Фабриканта
% Система имеет вид:
%   dx/dt = y*(z - 1 + x^2) + gamma*y
%   dy/dt = x*(3*z + 1 - x^2) + gamma*y
%   dz/dt = -2*z*(alpha + x*y)

rabinovich_system = @(t, xyz) rabinovichFabrikant(t, xyz, alpha, gamma);

% Функция-событие для остановки интегрирования при выходе за границы
event_out_of_bounds = @(t, z) outOfBounds3D(t, z, XMAX, YMAX, ZMAX);

%% Поиск и отображение особых точек
fprintf('=== Поиск особых точек для α = %.3f, γ = %.3f ===\n', alpha, gamma);
equilibria = findEquilibriaRF(alpha, gamma);
fprintf('\n');

%% Построение фазовых траекторий для варианта (a)
fprintf('Построение фазовой траектории для варианта (a)...\n');
fprintf('Начальные условия: (%.2f, %.2f, %.2f)\n', x0_a, y0_a, z0_a);

% Интегрирование для варианта (a)
options = odeset('RelTol', 1e-6, 'AbsTol', 1e-8, 'Events', event_out_of_bounds);
[t_a, traj_a] = ode45(rabinovich_system, [0 TMAX], [x0_a; y0_a; z0_a], options);

% Построение 3D траектории
figure('Name', 'Фазовая траектория (a)', 'NumberTitle', 'off', 'Position', [100, 100, 800, 600]);
plot3(traj_a(:,1), traj_a(:,2), traj_a(:,3), 'b-', 'LineWidth', 1.5);
xlabel('x', 'FontSize', 12);
ylabel('y', 'FontSize', 12);
zlabel('z', 'FontSize', 12);
title(sprintf('Фазовая траектория (a): α = %.3f, γ = %.3f\nНачальные условия: (%.2f, %.2f, %.2f)', ...
              alpha, gamma, x0_a, y0_a, z0_a), 'FontSize', 14);
grid on;
view(45, 30);
hold on;

% Отображение особых точек
plotEquilibria3D(equilibria);
legend('Траектория', 'Особые точки', 'Location', 'best');
hold off;

fprintf('Вариант (a): Длина траектории = %d точек\n', length(t_a));
fprintf('Диапазон x: [%.3f, %.3f]\n', min(traj_a(:,1)), max(traj_a(:,1)));
fprintf('Диапазон y: [%.3f, %.3f]\n', min(traj_a(:,2)), max(traj_a(:,2)));
fprintf('Диапазон z: [%.3f, %.3f]\n', min(traj_a(:,3)), max(traj_a(:,3)));
fprintf('\n');

%% Построение фазовых траекторий для варианта (b)
fprintf('Построение фазовой траектории для варианта (b)...\n');
fprintf('Начальные условия: (%.2f, %.2f, %.2f)\n', x0_b, y0_b, z0_b);

% Изменяем параметры для варианта (b)
alpha_b = 1.1;
gamma_b = 0.87;
rabinovich_system_b = @(t, xyz) rabinovichFabrikant(t, xyz, alpha_b, gamma_b);

% Интегрирование для варианта (b)
[t_b, traj_b] = ode45(rabinovich_system_b, [0 TMAX], [x0_b; y0_b; z0_b], options);

% Построение 3D траектории
figure('Name', 'Фазовая траектория (b)', 'NumberTitle', 'off', 'Position', [150, 150, 800, 600]);
plot3(traj_b(:,1), traj_b(:,2), traj_b(:,3), 'r-', 'LineWidth', 1.5);
xlabel('x', 'FontSize', 12);
ylabel('y', 'FontSize', 12);
zlabel('z', 'FontSize', 12);
title(sprintf('Фазовая траектория (b): α = %.3f, γ = %.3f\nНачальные условия: (%.2f, %.2f, %.2f)', ...
              alpha_b, gamma_b, x0_b, y0_b, z0_b), 'FontSize', 14);
grid on;
view(45, 30);
hold on;

% Находим и отображаем особые точки для варианта (b)
equilibria_b = findEquilibriaRF(alpha_b, gamma_b);
plotEquilibria3D(equilibria_b);
legend('Траектория', 'Особые точки', 'Location', 'best');
hold off;

fprintf('Вариант (b): Длина траектории = %d точек\n', length(t_b));
fprintf('Диапазон x: [%.3f, %.3f]\n', min(traj_b(:,1)), max(traj_b(:,1)));
fprintf('Диапазон y: [%.3f, %.3f]\n', min(traj_b(:,2)), max(traj_b(:,2)));
fprintf('Диапазон z: [%.3f, %.3f]\n', min(traj_b(:,3)), max(traj_b(:,3)));
fprintf('\n');

%% Построение проекций на координатные плоскости
fprintf('Построение проекций траекторий...\n');

% Проекции для варианта (a)
figure('Name', 'Проекции траектории (a)', 'NumberTitle', 'off', 'Position', [200, 200, 1000, 800]);

subplot(2,2,1);
plot(traj_a(:,1), traj_a(:,2), 'b-', 'LineWidth', 1);
xlabel('x'); ylabel('y');
title('Проекция на плоскость xy');
grid on; axis equal;

subplot(2,2,2);
plot(traj_a(:,1), traj_a(:,3), 'b-', 'LineWidth', 1);
xlabel('x'); ylabel('z');
title('Проекция на плоскость xz');
grid on; axis equal;

subplot(2,2,3);
plot(traj_a(:,2), traj_a(:,3), 'b-', 'LineWidth', 1);
xlabel('y'); ylabel('z');
title('Проекция на плоскость yz');
grid on; axis equal;

subplot(2,2,4);
plot3(traj_a(:,1), traj_a(:,2), traj_a(:,3), 'b-', 'LineWidth', 1);
xlabel('x'); ylabel('y'); zlabel('z');
title('3D вид');
grid on; view(45, 30);

sgtitle(sprintf('Проекции траектории (a): α = %.3f, γ = %.3f', alpha, gamma));

% Проекции для варианта (b)
figure('Name', 'Проекции траектории (b)', 'NumberTitle', 'off', 'Position', [250, 250, 1000, 800]);

subplot(2,2,1);
plot(traj_b(:,1), traj_b(:,2), 'r-', 'LineWidth', 1);
xlabel('x'); ylabel('y');
title('Проекция на плоскость xy');
grid on; axis equal;

subplot(2,2,2);
plot(traj_b(:,1), traj_b(:,3), 'r-', 'LineWidth', 1);
xlabel('x'); ylabel('z');
title('Проекция на плоскость xz');
grid on; axis equal;

subplot(2,2,3);
plot(traj_b(:,2), traj_b(:,3), 'r-', 'LineWidth', 1);
xlabel('y'); ylabel('z');
title('Проекция на плоскость yz');
grid on; axis equal;

subplot(2,2,4);
plot3(traj_b(:,1), traj_b(:,2), traj_b(:,3), 'r-', 'LineWidth', 1);
xlabel('x'); ylabel('y'); zlabel('z');
title('3D вид');
grid on; view(45, 30);

sgtitle(sprintf('Проекции траектории (b): α = %.3f, γ = %.3f', alpha_b, gamma_b));

%% Исследование влияния параметров солвера
fprintf('=== Исследование влияния параметров солвера ===\n');

% Различные настройки точности
tolerances = [1e-3, 1e-6, 1e-9];
colors = {'g', 'b', 'r'};

figure('Name', 'Влияние точности интегрирования (a)', 'NumberTitle', 'off', 'Position', [300, 300, 800, 600]);
hold on;

for i = 1:length(tolerances)
    opts = odeset('RelTol', tolerances(i), 'AbsTol', tolerances(i)*1e-2);
    [~, traj_temp] = ode45(rabinovich_system, [0 TMAX/2], [x0_a; y0_a; z0_a], opts);
    plot3(traj_temp(:,1), traj_temp(:,2), traj_temp(:,3), colors{i}, 'LineWidth', 1);
end

xlabel('x'); ylabel('y'); zlabel('z');
title(sprintf('Влияние точности интегрирования на траекторию (a)\nα = %.3f, γ = %.3f', alpha, gamma));
legend(sprintf('RelTol = %.0e', tolerances(1)), ...
       sprintf('RelTol = %.0e', tolerances(2)), ...
       sprintf('RelTol = %.0e', tolerances(3)));
grid on; view(45, 30);
hold off;

% Для варианта (b)
figure('Name', 'Влияние точности интегрирования (b)', 'NumberTitle', 'off', 'Position', [350, 350, 800, 600]);
hold on;

for i = 1:length(tolerances)
    opts = odeset('RelTol', tolerances(i), 'AbsTol', tolerances(i)*1e-2);
    [~, traj_temp] = ode45(rabinovich_system_b, [0 TMAX/2], [x0_b; y0_b; z0_b], opts);
    plot3(traj_temp(:,1), traj_temp(:,2), traj_temp(:,3), colors{i}, 'LineWidth', 1);
end

xlabel('x'); ylabel('y'); zlabel('z');
title(sprintf('Влияние точности интегрирования на траекторию (b)\nα = %.3f, γ = %.3f', alpha_b, gamma_b));
legend(sprintf('RelTol = %.0e', tolerances(1)), ...
       sprintf('RelTol = %.0e', tolerances(2)), ...
       sprintf('RelTol = %.0e', tolerances(3)));
grid on; view(45, 30);
hold off;

%% Построение векторного поля (сечения)
fprintf('Построение векторного поля в сечениях...\n');

% Сечение z = 0
figure('Name', 'Векторное поле в сечении z=0 (a)', 'NumberTitle', 'off', 'Position', [400, 400, 800, 600]);
[x_grid, y_grid] = meshgrid(-XMAX:STEP:XMAX, -YMAX:STEP:YMAX);
z_const = 0;

% Вычисляем векторное поле в сечении
u = zeros(size(x_grid));
v = zeros(size(x_grid));

for i = 1:size(x_grid, 1)
    for j = 1:size(x_grid, 2)
        deriv = rabinovich_system(0, [x_grid(i,j); y_grid(i,j); z_const]);
        u(i,j) = deriv(1);
        v(i,j) = deriv(2);
    end
end

% Нормализуем векторы для лучшей визуализации
magnitude = sqrt(u.^2 + v.^2);
u_norm = u ./ (magnitude + eps);
v_norm = v ./ (magnitude + eps);

quiver(x_grid, y_grid, u_norm, v_norm, 0.5);
xlabel('x'); ylabel('y');
title(sprintf('Векторное поле в сечении z = 0\nα = %.3f, γ = %.3f', alpha, gamma));
grid on; axis equal;

% Отображаем особые точки на сечении
hold on;
for i = 1:length(equilibria)
    if abs(equilibria(i,3)) < 0.01
        plot(equilibria(i,1), equilibria(i,2), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
    end
end
hold off;

%% Вывод информации о времени выполнения
toc; % остановка секундометра

fprintf('\n=== Моделирование завершено ===\n');