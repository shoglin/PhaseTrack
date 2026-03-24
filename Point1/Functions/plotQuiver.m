function plotQuiver(x1, x2, dx)
% Функция построения стрелок (векторного поля)

hold on;

% Вычисляем градиент во всех точках сетки
z = dx(0, [reshape(x1, 1, []); reshape(x2, 1, [])]);

% Извлекаем компоненты
dx1 = reshape(z(1, :), size(x1, 1), size(x1, 2));
dx2 = reshape(z(2, :), size(x2, 1), size(x2, 2));

% Нормализуем стрелки для лучшей визуализации
magnitude = sqrt(dx1.^2 + dx2.^2);
dx1_norm = dx1 ./ magnitude;
dx2_norm = dx2 ./ magnitude;

% Рисуем векторное поле
quiver(x1, x2, dx1_norm, dx2_norm, 'k', ...
       'AutoScale', 'on', ...
       'AutoScaleFactor', 0.35, ...
       'LineWidth', 0.8);

hold off;
end