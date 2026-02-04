% procesar_datos_finales.m
% Versión final para los archivos CSV con todas las columnas

clear all; clc;

%% Paso 1: Cargar datos
fprintf('Cargando datos de archivos CSV...\n');

% Cargar archivos
data_am = readtable('data\am.csv');
data_am_slow = readtable('data\am_slow.csv');
data_fm = readtable('data\fm.csv');
data_fm_slow = readtable('data\fm_slow.csv');

% Verificar que tengan la columna 'valor'
if ~ismember('valor', data_am.Properties.VariableNames)
    error('Archivo am.csv no tiene columna "valor"');
end

fprintf('Datos cargados exitosamente.\n');

%% Paso 2: Extraer solo las columnas necesarias

% Extraer timestamp y valor de cada archivo
am_ts = data_am.timestamp;
am_val = data_am.valor;

am_slow_ts = data_am_slow.timestamp;
am_slow_val = data_am_slow.valor;

fm_ts = data_fm.timestamp;
fm_val = data_fm.valor;

fm_slow_ts = data_fm_slow.timestamp;
fm_slow_val = data_fm_slow.valor;

%% Paso 3: Crear timeline común

% Encontrar rango temporal total
all_timestamps = [am_ts; am_slow_ts; fm_ts; fm_slow_ts];
t_min = min(all_timestamps);
t_max = max(all_timestamps);

% Crear timeline con intervalos de 60 segundos
% (Los .csv se generaron con intervalo de 60 segundos)
intervalo = 60; % segundos
timeline = t_min:intervalo:t_max;

fprintf('Timeline creado: %d puntos (desde %s hasta %s)\n', ...
        length(timeline), datestr(datetime(t_min, 'ConvertFrom', 'epochtime')), ...
        datestr(datetime(t_max, 'ConvertFrom', 'epochtime')));

%% Paso 4: Interpolar/agregar datos a la timeline

% Función para agregar datos cercanos
agregar_datos_cercanos = @(data_ts, data_val, timeline_ts, window) ...
    arrayfun(@(t) mean(data_val(abs(data_ts - t) <= window), 'omitnan'), timeline_ts);

window_size = 30; % 30 segundos (mitad del intervalo)

% Agregar datos AM normal
am_normal_agg = agregar_datos_cercanos(am_ts, am_val, timeline, window_size);

% Agregar datos AM slow
am_slow_agg = agregar_datos_cercanos(am_slow_ts, am_slow_val, timeline, window_size);

% Agregar datos FM normal
fm_normal_agg = agregar_datos_cercanos(fm_ts, fm_val, timeline, window_size);

% Agregar datos FM slow
fm_slow_agg = agregar_datos_cercanos(fm_slow_ts, fm_slow_val, timeline, window_size);

%% Paso 5: Crear tabla maestra y eliminar NaN

master_data = table();
master_data.timestamp = timeline';
master_data.am_normal = am_normal_agg';
master_data.am_slow = am_slow_agg';
master_data.fm_normal = fm_normal_agg';
master_data.fm_slow = fm_slow_agg';

% Eliminar filas con datos faltantes
valid_rows = ~isnan(master_data.am_normal) & ~isnan(master_data.am_slow) & ...
             ~isnan(master_data.fm_normal) & ~isnan(master_data.fm_slow);
master_data = master_data(valid_rows, :);

fprintf('Datos procesados: %d muestras válidas\n\n', height(master_data));

if height(master_data) == 0
    error('No se encontraron datos válidos. Verifica que los archivos CSV tengan datos superpuestos en el tiempo.');
end

%% Paso 6: Calcular estadísticas

% Total de clientes
master_data.am_total = master_data.am_normal + master_data.am_slow;
master_data.fm_total = master_data.fm_normal + master_data.fm_slow;

% Tasas de slow-listeners (evitar división por cero)
master_data.am_slow_rate = master_data.am_slow ./ (master_data.am_total + eps);
master_data.fm_slow_rate = master_data.fm_slow ./ (master_data.fm_total + eps);

% Estadísticas AM
am_stats = struct();
am_stats.total_media = mean(master_data.am_total, 'omitnan');
am_stats.normal_media = mean(master_data.am_normal, 'omitnan');
am_stats.slow_media = mean(master_data.am_slow, 'omitnan');
am_stats.slow_rate_media = mean(master_data.am_slow_rate, 'omitnan');

% Estadísticas FM
fm_stats = struct();
fm_stats.total_media = mean(master_data.fm_total, 'omitnan');
fm_stats.normal_media = mean(master_data.fm_normal, 'omitnan');
fm_stats.slow_media = mean(master_data.fm_slow, 'omitnan');
fm_stats.slow_rate_media = mean(master_data.fm_slow_rate, 'omitnan');

%% Paso 7: Calcular parámetros para simulación

T_sesion = 300; % segundos

lambda_AM = am_stats.total_media / T_sesion;
lambda_FM = fm_stats.total_media / T_sesion;

prob_slow_AM = am_stats.slow_rate_media;
prob_slow_FM = fm_stats.slow_rate_media;

prob_movil_AM = min(prob_slow_AM * 1.5, 0.8);
prob_movil_FM = min(prob_slow_FM * 1.5, 0.8);

%% Paso 8: Mostrar resultados

fprintf('=== RESULTADOS DE DATOS REALES ===\n\n');

fprintf('AM:\n');
fprintf('  Clientes totales promedio: %.1f\n', am_stats.total_media);
fprintf('  Clientes normales: %.1f\n', am_stats.normal_media);
fprintf('  Slow-listeners: %.1f\n', am_stats.slow_media);
fprintf('  Tasa de slow-listeners: %.2f%%\n', prob_slow_AM * 100);
fprintf('  Lambda AM: %.6f clientes/segundo\n\n', lambda_AM);

fprintf('FM:\n');
fprintf('  Clientes totales promedio: %.1f\n', fm_stats.total_media);
fprintf('  Clientes normales: %.1f\n', fm_stats.normal_media);
fprintf('  Slow-listeners: %.1f\n', fm_stats.slow_media);
fprintf('  Tasa de slow-listeners: %.2f%%\n', prob_slow_FM * 100);
fprintf('  Lambda FM: %.6f clientes/segundo\n\n', lambda_FM);

%% Paso 9: Guardar parámetros

parametros = struct();
parametros.base.lambda_AM = lambda_AM;
parametros.base.lambda_FM = lambda_FM;
parametros.base.prob_slow_AM = prob_slow_AM;
parametros.base.prob_slow_FM = prob_slow_FM;
parametros.base.prob_movil_AM = prob_movil_AM;
parametros.base.prob_movil_FM = prob_movil_FM;
parametros.base.velocidades = [128];

parametros.mejorado.lambda_AM = lambda_AM;
parametros.mejorado.lambda_FM = lambda_FM;
parametros.mejorado.prob_movil_AM = prob_movil_AM;
parametros.mejorado.prob_movil_FM = prob_movil_FM;
parametros.mejorado.probs_velocidades = [0.5, 0.3, 0.2];
parametros.mejorado.velocidades = [128, 96, 64];

parametros.T_sim = 86400;
parametros.mu = 1/T_sesion;
parametros.c_servidores = 3;
parametros.capacidad_cola = 50;

save('output\parametros_simulacion_final.mat', 'parametros', 'master_data', 'am_stats', 'fm_stats');
fprintf('\n? Parámetros guardados en parametros_simulacion_final.mat\n');

%% Paso 10: Gráficos

figure('Position', [100, 100, 1200, 800]);

subplot(2,2,1);
plot(datetime(master_data.timestamp, 'ConvertFrom', 'epochtime'), master_data.am_total, 'b-', 'LineWidth', 1);
hold on;
plot(datetime(master_data.timestamp, 'ConvertFrom', 'epochtime'), master_data.am_slow, 'r-', 'LineWidth', 1);
legend('Total AM', 'Slow AM');
title('AM - Clientes conectados');
xlabel('Fecha'); ylabel('Clientes');
grid on;

subplot(2,2,2);
plot(datetime(master_data.timestamp, 'ConvertFrom', 'epochtime'), master_data.fm_total, 'b-', 'LineWidth', 1);
hold on;
plot(datetime(master_data.timestamp, 'ConvertFrom', 'epochtime'), master_data.fm_slow, 'r-', 'LineWidth', 1);
legend('Total FM', 'Slow FM');
title('FM - Clientes conectados');
xlabel('Fecha'); ylabel('Clientes');
grid on;

subplot(2,2,3);
histogram(master_data.am_slow_rate, 20, 'Normalization', 'probability');
title('AM - Distribución tasa slow-listeners');
xlabel('Tasa slow-listeners'); ylabel('Probabilidad');
grid on;

subplot(2,2,4);
histogram(master_data.fm_slow_rate, 20, 'Normalization', 'probability');
title('FM - Distribución tasa slow-listeners');
xlabel('Tasa slow-listeners'); ylabel('Probabilidad');
grid on;

saveas(gcf, 'output\datos_reales_procesados.png');