%% Скрипт для построения фазовых траекторий (с отладкой)
clear all
close all
clc

%% Настройки модели
model_name = 'my_system';

% Загружаем модель
if ~bdIsLoaded(model_name)
    load_system(model_name);
end

%% НАСТРОЙКИ СОЛВЕРА
set_param(model_name, 'Solver', 'ode23t');
set_param(model_name, 'MaxStep', '0.001');
set_param(model_name, 'MinStep', '1e-15');
set_param(model_name, 'InitialStep', '1e-8');
set_param(model_name, 'RelTol', '1e-3');
set_param(model_name, 'AbsTol', '1e-5');
set_param(model_name, 'MaxConsecutiveMinStep', '1000');
set_param(model_name, 'StopTime', '2');
set_param(model_name, 'SaveTime', 'on');
set_param(model_name, 'SaveOutput', 'on');

%% Задаем начальные условия
initial_conditions = [
    0,    0.01;
    0,    0.02;
    0.01, 0;
    -0.01, 0.01;
    0,    -0.01;
    0.02, 0.005;
    -0.02, -0.005
];

% Цвета
colors = {'b', 'r', 'g', 'm', 'c', 'k', 'y'};

% Создаем фигуру
figure('Name', 'Фазовый портрет', 'Position', [100, 100, 900, 700])
hold on
grid on

success_count = 0;
trajectories_x = {};
trajectories_y = {};
trajectories_ic = {};

%% Цикл по начальным условиям
for i = 1:size(initial_conditions, 1)
    x0 = initial_conditions(i, 1);
    v0 = initial_conditions(i, 2);
    
    fprintf('\n========================================\n');
    fprintf('Симуляция %d/%d: x0 = %.3f, v0 = %.3f\n', i, size(initial_conditions, 1), x0, v0);
    
    try
        % Устанавливаем начальные условия
        set_param([model_name '/Integrator'], 'InitialCondition', num2str(x0));
        set_param([model_name '/Integrator1'], 'InitialCondition', num2str(v0));
        
        % Запускаем симуляцию
        simOut = sim(model_name);
        
        fprintf('  simOut тип: %s\n', class(simOut));
        
        % Пытаемся извлечь данные - ПРОВЕРЯЕМ ВСЕ ВОЗМОЖНЫЕ ВАРИАНТЫ
        x_data = [];
        y_data = [];
        
        % Вариант 1: Прямые поля
        if isfield(simOut, 'x')
            x_data = simOut.x;
            fprintf('  Найдено поле x\n');
        end
        if isfield(simOut, 'y')
            y_data = simOut.y;
            fprintf('  Найдено поле y\n');
        end
        
        % Вариант 2: yout
        if isempty(x_data) && isfield(simOut, 'yout')
            if size(simOut.yout, 2) >= 2
                x_data = simOut.yout(:, 1);
                y_data = simOut.yout(:, 2);
                fprintf('  Данные из yout\n');
            end
        end
        
        % Вариант 3: DataSet
        if isempty(x_data) && isa(simOut, 'Simulink.SimulationOutput')
            % Ищем сигналы по имени
            try
                x_data = get(simOut, 'x');
                y_data = get(simOut, 'y');
                fprintf('  Данные через get\n');
            catch
            end
        end
        
        % Вариант 4: Из workspace (если данные сохранились отдельно)
        if isempty(x_data) && evalin('base', 'exist(''x'', ''var'')')
            x_data = evalin('base', 'x');
            y_data = evalin('base', 'y');
            fprintf('  Данные из workspace\n');
        end
        
        % Проверяем полученные данные
        fprintf('  x_data size: ');
        if isempty(x_data)
            fprintf('ПУСТО\n');
        else
            fprintf('%dx%d\n', size(x_data, 1), size(x_data, 2));
        end
        
        fprintf('  y_data size: ');
        if isempty(y_data)
            fprintf('ПУСТО\n');
        else
            fprintf('%dx%d\n', size(y_data, 1), size(y_data, 2));
        end
        
        % Проверяем качество данных
        if isempty(x_data) || isempty(y_data)
            fprintf('  -> НЕТ ДАННЫХ!\n');
            fprintf('  Проверьте блоки To Workspace в модели.\n');
            fprintf('  Они должны иметь имена переменных: x и y\n');
            continue;
        end
        
        if length(x_data) < 2
            fprintf('  -> МАЛО ДАННЫХ (всего %d точек)\n', length(x_data));
            continue;
        end
        
        if any(~isfinite(x_data)) || any(~isfinite(y_data))
            fprintf('  -> ЕСТЬ БЕСКОНЕЧНОСТИ\n');
            continue;
        end
        
        % Успешно!
        success_count = success_count + 1;
        trajectories_x{success_count} = x_data;
        trajectories_y{success_count} = y_data;
        trajectories_ic{success_count} = [x0, v0];
        
        % Строим траекторию
        color_idx = mod(success_count-1, length(colors)) + 1;
        plot(x_data, y_data, colors{color_idx}, 'LineWidth', 1.5)
        plot(x_data(1), y_data(1), [colors{color_idx}, 'o'], 'MarkerSize', 8, 'MarkerFaceColor', colors{color_idx})
        
        fprintf('  -> УСПЕШНО! Траектория %d построена\n', success_count);
        
    catch ME
        fprintf('  -> ОШИБКА: %s\n', ME.message);
        continue;
    end
end

%% Оформление
hold off
xlabel('Положение (x)', 'FontSize', 12)
ylabel('Скорость (v)', 'FontSize', 12)
title(sprintf('Фазовый портрет (%d траекторий)', success_count), 'FontSize', 14)
grid on

if success_count > 0
    legend_str = cell(success_count, 1);
    for i = 1:success_count
        legend_str{i} = sprintf('x_0=%.3f, v_0=%.3f', trajectories_ic{i}(1), trajectories_ic{i}(2));
    end
    legend(legend_str, 'Location', 'best')
end

fprintf('\n========================================\n');
fprintf('=== РЕЗУЛЬТАТ ===\n');
fprintf('Успешно построено: %d из %d\n', success_count, size(initial_conditions, 1));

if success_count == 0
    fprintf('\n=== ПРОБЛЕМА: НЕТ ДАННЫХ ===\n');
    fprintf('Возможные причины:\n');
    fprintf('1. В модели нет блоков To Workspace\n');
    fprintf('2. Блоки To Workspace имеют другие имена переменных\n');
    fprintf('3. Блоки To Workspace настроены на сохранение в формате Structure\n');
    fprintf('\nРешение:\n');
    fprintf('1. Откройте модель my_system\n');
    fprintf('2. Найдите блоки To Workspace\n');
    fprintf('3. Установите им имена: x и y\n');
    fprintf('4. Формат сохранения: Array\n');
    fprintf('5. Сохраните модель и запустите скрипт снова\n');
end