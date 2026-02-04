% calcular_slow_listeners_reales.m
% Calcula slow listeners totales de tus datos CSV

clear all; clc;

%% Cargar datos reales
fprintf('Cargando datos reales...\n');

% Cargar archivos CSV
data_am_slow = readtable('data\am_slow.csv');
data_fm_slow = readtable('data\fm_slow.csv');

% Extraer valores de slow listeners
am_slow_valores = data_am_slow.valor;
fm_slow_valores = data_fm_slow.valor;

%% Calcular estadísticas de slow listeners reales

% Eliminar NaN y valores inválidos
am_slow_validos = am_slow_valores(~isnan(am_slow_valores) & am_slow_valores >= 0);
fm_slow_validos = fm_slow_valores(~isnan(fm_slow_valores) & fm_slow_valores >= 0);

% Estadísticas AM
am_slow_total = sum(am_slow_validos);
am_slow_promedio = mean(am_slow_validos);
am_slow_maximo = max(am_slow_validos);

% Estadísticas FM  
fm_slow_total = sum(fm_slow_validos);
fm_slow_promedio = mean(fm_slow_validos);
fm_slow_maximo = max(fm_slow_validos);

% Totales combinados
slow_total_real = am_slow_total + fm_slow_total;
slow_promedio_real = am_slow_promedio + fm_slow_promedio;

%% Mostrar resultados
fprintf('=== SLOW LISTENERS REALES (90 días) ===\n\n');

fprintf('AM Slow Listeners:\n');
fprintf('  Total acumulado: %d\n', am_slow_total);
fprintf('  Promedio por muestra: %.2f\n', am_slow_promedio);
fprintf('  Máximo en una muestra: %d\n\n', am_slow_maximo);

fprintf('FM Slow Listeners:\n');
fprintf('  Total acumulado: %d\n', fm_slow_total);
fprintf('  Promedio por muestra: %.2f\n', fm_slow_promedio);
fprintf('  Máximo en una muestra: %d\n\n', fm_slow_maximo);

fprintf('TOTAL SLOW LISTENERS:\n');
fprintf('  Total acumulado (90 días): %d\n', slow_total_real);
fprintf('  Promedio por muestra: %.2f\n', slow_promedio_real);

%% Calcular tasa de slow listeners

% Cargar también los datos totales para calcular tasas
data_am_total = readtable('data\am.csv');
data_fm_total = readtable('data\fm.csv');

am_total_valores = data_am_total.valor;
fm_total_valores = data_fm_total.valor;

% Filtrar datos válidos
am_total_validos = am_total_valores(~isnan(am_total_valores) & am_total_valores > 0);
fm_total_validos = fm_total_valores(~isnan(fm_total_valores) & fm_total_valores > 0);

% Asegurar misma longitud (usar la más corta)
min_len = min(length(am_total_validos), length(am_slow_validos));
am_total_sync = am_total_validos(1:min_len);
am_slow_sync = am_slow_validos(1:min_len);

min_len_fm = min(length(fm_total_validos), length(fm_slow_validos));
fm_total_sync = fm_total_validos(1:min_len_fm);
fm_slow_sync = fm_slow_validos(1:min_len_fm);

% Calcular tasas
am_slow_rate = mean(am_slow_sync ./ am_total_sync, 'omitnan');
fm_slow_rate = mean(fm_slow_sync ./ fm_total_sync, 'omitnan');

fprintf('\n=== TASAS DE SLOW LISTENERS ===\n');
fprintf('AM: %.2f%%\n', am_slow_rate * 100);
fprintf('FM: %.2f%%\n', fm_slow_rate * 100);
fprintf('Global: %.2f%%\n', (am_slow_rate + fm_slow_rate) / 2 * 100);