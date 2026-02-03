% ejecutar_simulacion_completa.m
% Script maestro para ejecutar todas las simulaciones

clear all;
clc;
close all;

fprintf('===================================================\\n');
fprintf('   SIMULACIÓN SISTEMA DE STREAMING ICECAST\\n');
fprintf('===================================================\\n\\n');

%% PASO 1: Inicializar parámetros
fprintf('1. Inicializando parámetros...\\n');
inicializar_modelo;
fprintf('   ? Parámetros cargados\\n\\n');

%% PASO 2: Ejecutar simulación ESCENARIO BASE (solo 128 kbps)
fprintf('2. Ejecutando ESCENARIO BASE (solo 128 kbps)...\\n');
% Modificar para solo simular 128 kbps
velocidades_base = [128];
[resultados_base] = simular_escenario(lambda_AM, lambda_FM, velocidades_base, T_simulacion, c_servidores, capacidad_cola, mu_128, prob_movil);
fprintf('   ? Escenario base completado\\n\\n');

%% PASO 3: Ejecutar simulación ESCENARIO MEJORADO (128, 96, 64 kbps)
fprintf('3. Ejecutando ESCENARIO MEJORADO (múltiples velocidades)...\\n');
velocidades_mejorado = [128, 96, 64];
[resultados_mejorado] = simular_escenario(lambda_AM, lambda_FM, velocidades_mejorado, T_simulacion, c_servidores, capacidad_cola, mu_128, prob_movil);
fprintf('   ? Escenario mejorado completado\\n\\n');

%% PASO 4: Comparar resultados
fprintf('4. Generando comparación de resultados...\\n');
comparar_escenarios(resultados_base, resultados_mejorado);
fprintf('   ? Comparación completada\\n\\n');

%% PASO 5: Generar reporte
fprintf('5. Generando reporte final...\\n');
generar_reporte(resultados_base, resultados_mejorado);
fprintf('   ? Reporte guardado en "reporte_simulacion.txt"\\n\\n');

fprintf('===================================================\\n');
fprintf('   SIMULACIÓN COMPLETADA EXITOSAMENTE\\n');
fprintf('===================================================\\n');