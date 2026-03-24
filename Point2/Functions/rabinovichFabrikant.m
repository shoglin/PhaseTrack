function dxyz = rabinovichFabrikant(t, xyz, alpha, gamma)
% RABINOVICHFABRIKANT Система уравнений Рабиновича-Фабриканта
%   dxyz = RABINOVICHFABRIKANT(t, xyz, alpha, gamma) возвращает производные
%   для системы:
%       dx/dt = y*(z - 1 + x^2) + gamma*y
%       dy/dt = x*(3*z + 1 - x^2) + gamma*y
%       dz/dt = -2*z*(alpha + x*y)
%
%   Входные параметры:
%       t     - время (не используется, но требуется для ode45)
%       xyz   - вектор состояния [x; y; z]
%       alpha - параметр α системы
%       gamma - параметр γ системы
%
%   Выходные параметры:
%       dxyz  - вектор производных [dx/dt; dy/dt; dz/dt]

x = xyz(1);
y = xyz(2);
z = xyz(3);

% Вычисляем производные
dx = y * (z - 1 + x^2) + gamma * y;
dy = x * (3*z + 1 - x^2) + gamma * y;
dz = -2 * z * (alpha + x * y);

dxyz = [dx; dy; dz];

end