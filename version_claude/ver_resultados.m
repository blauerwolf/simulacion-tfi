% ver_resultados.m
% Visualiza resultados de la simulación

if ~exist('datos_AM', 'var') || ~exist('datos_FM', 'var')
    fprintf('ERROR: No hay datos. Ejecuta primero la simulación.\\n');
    fprintf('       >> sim(''icecast_modelo'')\\n');
    return;
end

fprintf('\\n');
fprintf('???????????????????????????????????????????????????\\n');
fprintf('            RESULTADOS DE LA SIMULACIÓN\\n');
fprintf('???????????????????????????????????????????????????\\n\\n');

% Extraer últimos valores
am_final = datos_AM.signals.values(end,:);
fm_final = datos_FM.signals.values(end,:);

fprintf('??? EMISORA AM ???\\n');
fprintf('  Tasa de Éxito:        %.2f%%\\n', am_final(1));
fprintf('  Tasa Slow-Listeners:  %.2f%%\\n', am_final(2));
fprintf('  Total Atendidos:      %.0f\\n\\n', am_final(3));

fprintf('??? EMISORA FM ???\\n');
fprintf('  Tasa de Éxito:        %.2f%%\\n', fm_final(1));
fprintf('  Tasa Slow-Listeners:  %.2f%%\\n', fm_final(2));
fprintf('  Total Atendidos:      %.0f\\n\\n', fm_final(3));

% Gráficos
figure('Name', 'Resultados Simulación Icecast', 'Position', [100,100,1200,500]);

subplot(1,2,1);
bar(1:2, [am_final(1) fm_final(1)]);
set(gca, 'XTickLabel', {'AM', 'FM'});
ylabel('Tasa de Éxito (%)');
title('Tasa de Éxito por Emisora');
grid on;
ylim([0 100]);

subplot(1,2,2);
bar(1:2, [am_final(2) fm_final(2)]);
set(gca, 'XTickLabel', {'AM', 'FM'});
ylabel('Tasa Slow-Listeners (%)');
title('Slow-Listeners por Emisora');
grid on;

% Evolución temporal
figure('Name', 'Evolución Temporal', 'Position', [100,100,1200,500]);

subplot(1,2,1);
plot(datos_AM.time, datos_AM.signals.values(:,1), 'b', 'LineWidth', 2);
hold on;
plot(datos_AM.time, datos_AM.signals.values(:,2), 'r', 'LineWidth', 2);
title('AM - Evolución');
xlabel('Tiempo (s)');
ylabel('Porcentaje (%)');
legend('Éxito', 'Slow-Listeners');
grid on;

subplot(1,2,2);
plot(datos_FM.time, datos_FM.signals.values(:,1), 'b', 'LineWidth', 2);
hold on;
plot(datos_FM.time, datos_FM.signals.values(:,2), 'r', 'LineWidth', 2);
title('FM - Evolución');
xlabel('Tiempo (s)');
ylabel('Porcentaje (%)');
legend('Éxito', 'Slow-Listeners');
grid on;

fprintf('???????????????????????????????????????????????????\\n');