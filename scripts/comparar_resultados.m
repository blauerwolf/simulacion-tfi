% comparar_resultados_final.m
% Comparativa Normalizada: Realidad vs Simulación Inteligente

%% 1. OBTENER DATOS
% Datos Reales (Histórico 90 días)
slow_total_real_90dias = 15420;
dias_muestra = 90;
horas_totales_real = dias_muestra * 24;

% Datos Simulación (Lectura automática)
if ~exist('total_AM_128', 'var'), error('Faltan variables de simulación'); end

% Detectamos cuánto duró la simulación realmente (ej: 10000s)
tiempo_simulado_segundos = total_AM_128.Time(end); 
horas_totales_sim = tiempo_simulado_segundos / 3600;

% Sumamos los cortes simulados (AM + FM)
sim_slow_count = 0;
vars_slow = {slow_AM_128, slow_AM_96, slow_AM_64, slow_FM_128, slow_FM_96, slow_FM_64};
for i = 1:length(vars_slow), sim_slow_count = sim_slow_count + max(vars_slow{i}.Data); end

%% 2. CÁLCULO DE INDICADORES (KPIs)
% KPI: Cortes por Hora (CPH)
cph_real = slow_total_real_90dias / horas_totales_real;
cph_sim  = sim_slow_count / horas_totales_sim;

% Proyección: ¿Cuántos cortes habría en 24h según la simulación?
proyeccion_cortes_24h_sim = cph_sim * 24;
promedio_cortes_24h_real  = cph_real * 24;

%% 3. REPORTE FINAL
fprintf('\n======================================================\n');
fprintf('       VALIDACIÓN DE HIPÓTESIS (NORMALIZADA)\n');
fprintf('======================================================\n');
fprintf('Tiempo Simulado: %.1f horas (%.0f segundos)\n', horas_totales_sim, tiempo_simulado_segundos);

fprintf('\nINDICADOR CLAVE: CORTES POR HORA (CPH)\n');
fprintf('? Realidad (Actual):       %6.2f usuarios/hora sufren cortes\n', cph_real);
fprintf('? Propuesta (Inteligente): %6.2f usuarios/hora sufren cortes\n', cph_sim);

fprintf('\nPROYECCIÓN A 24 HORAS (DÍA TÍPICO)\n');
fprintf('   Cortes Esperados Realidad:   %4.0f usuarios\n', promedio_cortes_24h_real);
fprintf('   Cortes Esperados Propuesta:  %4.0f usuarios\n', proyeccion_cortes_24h_sim);

fprintf('\n------------------------------------------------------\n');
% Cálculo de mejora
delta = promedio_cortes_24h_real - proyeccion_cortes_24h_sim;
mejora_pct = ((promedio_cortes_24h_real - proyeccion_cortes_24h_sim) / promedio_cortes_24h_real) * 100;

if mejora_pct > 0
    fprintf('? CONCLUSIÓN: La arquitectura propuesta es SUPERIOR.\n');
    fprintf('   Se evitan aprox. %d cortes diarios.\n', round(delta));
    fprintf('   EFICIENCIA INCREMENTAL: +%.1f%%\n', mejora_pct);
else
    fprintf('?? RESULTADO NO CONCLUYENTE.\n');
end
fprintf('======================================================\n');