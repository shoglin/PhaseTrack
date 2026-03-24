function equilibria = findEquilibriaRF(alpha, gamma)
% FINDEQUILIBRIARF Находит особые точки системы Рабиновича-Фабриканта
%   equilibria = FINDEQUILIBRIARF(alpha, gamma) возвращает матрицу,
%   где каждая строка содержит координаты [x, y, z] особой точки
%
%   Аналитические выражения для особых точек:
%       1. Тривиальная точка: (0, 0, 0)
%       2. Точки на оси x: (±1, 0, 0)
%       3. Точки при γ ≤ 1: (±√(1-γ), ∓√(1-γ), 0)
%       4. Точки при γ ≤ 2: (±√(1-γ/2), ∓α/√(1-γ/2), -γ/2)

equilibria = [];

% 1. Тривиальная точка
equilibria = [equilibria; 0, 0, 0];
fprintf('Особая точка P0: (%.3f, %.3f, %.3f)\n', 0, 0, 0);

% 2. Точки на оси x
equilibria = [equilibria; 1, 0, 0];
fprintf('Особая точка P1: (%.3f, %.3f, %.3f)\n', 1, 0, 0);
equilibria = [equilibria; -1, 0, 0];
fprintf('Особая точка P2: (%.3f, %.3f, %.3f)\n', -1, 0, 0);

% 3. Точки при γ ≤ 1
if gamma <= 1
    x_val = sqrt(1 - gamma);
    equilibria = [equilibria; x_val, -x_val, 0];
    fprintf('Особая точка P3: (%.3f, %.3f, %.3f)\n', x_val, -x_val, 0);
    equilibria = [equilibria; -x_val, x_val, 0];
    fprintf('Особая точка P4: (%.3f, %.3f, %.3f)\n', -x_val, x_val, 0);
end

% 4. Точки при γ ≤ 2 и α ≠ 0
if gamma <= 2 && alpha ~= 0
    x_val = sqrt(1 - gamma/2);
    if ~isnan(x_val) && ~isinf(x_val) && imag(x_val) == 0
        y_val = -alpha / x_val;
        z_val = -gamma/2;
        equilibria = [equilibria; x_val, y_val, z_val];
        fprintf('Особая точка P5: (%.3f, %.3f, %.3f)\n', x_val, y_val, z_val);
        equilibria = [equilibria; -x_val, -y_val, z_val];
        fprintf('Особая точка P6: (%.3f, %.3f, %.3f)\n', -x_val, -y_val, z_val);
    end
end

fprintf('Всего найдено особых точек: %d\n', size(equilibria, 1));

end