function dxdt = mySystem(t, x)
% Функция, возвращающая градиент для системы:
% d2x/dt2 - (dx/dt)*x - 2*x^3 + 5*x - 1 = 0
%
% Фазовые переменные:
%   x1 = x  (положение)
%   x2 = dx/dt (скорость)

dxdt(1, :) = x(2, :);                          % dx1/dt = x2
dxdt(2, :) = x(1, :) .* x(2, :) + 2 * x(1, :) .^ 3 - 5 * x(1, :) + 1;
% dx2/dt = x1*x2 + 2*x1^3 - 5*x1 + 1
end

function [value, isterminal, direction] = outOfBounds(t, z, bound)
% Функция-событие для остановки интегрирования при выходе за границы

value = [abs(z(1)) - bound; abs(z(2)) - bound];
isterminal = [1; 1];
direction = [0; 0];
end