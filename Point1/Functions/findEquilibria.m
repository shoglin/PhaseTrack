function equilibria = findEquilibria(XMAX)
% Функция поиска особых точек
% Для нашей системы: x2 = 0, 2*x1^3 - 5*x1 + 1 = 0

% Находим корни кубического уравнения 2*x^3 - 5*x + 1 = 0
coeff = [2, 0, -5, 1];  % коэффициенты полинома
roots_eq = roots(coeff);

% Отбираем только действительные корни
real_roots = roots_eq(abs(imag(roots_eq)) < 1e-10);
real_roots = real(real_roots);

% Отбираем корни в пределах области
real_roots = real_roots(abs(real_roots) <= XMAX);

% Формируем матрицу особых точек [x1; x2]
equilibria = [real_roots'; zeros(1, length(real_roots))];

% Выводим информацию
fprintf('Найдено %d особых точек:\n', length(real_roots));
for k = 1:length(real_roots)
    fprintf('  Точка %d: x1 = %.4f, x2 = 0\n', k, real_roots(k));
end
end