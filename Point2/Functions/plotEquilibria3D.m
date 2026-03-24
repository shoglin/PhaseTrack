function plotEquilibria3D(equilibria)
% PLOTEQUILIBRIA3D Отображает особые точки на 3D графике
%   PLOTEQUILIBRIA3D(equilibria) отображает точки из матрицы equilibria
%   красными кружками на текущем 3D графике

if isempty(equilibria)
    return;
end

% Отображаем все особые точки
plot3(equilibria(:,1), equilibria(:,2), equilibria(:,3), 'ro', ...
      'MarkerSize', 8, 'MarkerFaceColor', 'r', 'LineWidth', 2);

end