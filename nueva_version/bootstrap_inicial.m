% bootstrap_inicial.m
% Pipeline completo con bondad_ajuste incluido

clear all; clc;

fprintf('? INICIANDO PIPELINE DE INICIALIZACIÓN\n');
fprintf('========================================\n');

%% Paso 1: Procesar datos crudos
fprintf('\n1. Procesando datos crudos...\n');
try
    procesar_datos_finales();
    fprintf('? Datos procesados exitosamente\n');
catch ME
    error('? Error en procesar_datos_finales: %s', ME.message);
end

%% Paso 2: Análisis de bondad de ajuste
fprintf('\n2. Ejecutando análisis de bondad de ajuste...\n');
try
    bondad_ajuste();
    fprintf('? Análisis de bondad completado\n');
    
    % Extraer parámetros del análisis
    % Como bondad_ajuste no guarda resultados en variables, los cargamos/calculamos
    load('parametros_simulacion_final.mat');
    datos = master_data.am_total;
    datos = datos(~isnan(datos) & datos > 0);
    mu_log = mean(log(datos));
    sigma_log = std(log(datos));
    
catch ME
    warning('?? Error en bondad_ajuste (calculando directamente): %s', ME.message);
    load('parametros_simulacion_final.mat');
    datos = master_data.am_total;
    datos = datos(~isnan(datos) & datos > 0);
    mu_log = mean(log(datos));
    sigma_log = std(log(datos));
end

%% Paso 3: Calcular tasas reales y aplicar FACTORES DE CORRECCIÓN
fprintf('\n3. Calculando parámetros con corrección de distribución...\n');
try
    load('parametros_simulacion_final.mat');
    
    % --- CONFIGURACIÓN DE ESCENARIO ---
    T_sesion = 300;         % Duración promedio de sesión (5 min)
    
    % FACTORES DE CORRECCIÓN (TUNING)
    factor_correccion_AM = 1.0;  
    factor_correccion_FM = 2.5;  % <--- Corrección de demanda FM
    
    % 1. Calcular Lambdas Base (Clientes por segundo reales)
    raw_lambda_AM = am_stats.total_media / T_sesion;
    raw_lambda_FM = fm_stats.total_media / T_sesion;
    
    % 2. Aplicar la corrección (Escenario simulado)
    target_lambda_AM = raw_lambda_AM * factor_correccion_AM;
    target_lambda_FM = raw_lambda_FM * factor_correccion_FM;
    
    % 3. Recalcular el Lambda Total del sistema
    lambda_total_simulacion = target_lambda_AM + target_lambda_FM;
    
    % 4. Recalcular la Probabilidad de Split (Crucial para el bloque Assign)
    prob_AM_corregida = target_lambda_AM / lambda_total_simulacion;
    
    % Tasas de Slow
    prob_slow_AM = am_stats.slow_rate_media; 
    prob_slow_FM = fm_stats.slow_rate_media; 

    fprintf('? Parámetros ajustados (Factor FM: x%.1f):\n', factor_correccion_FM);
    fprintf('   Lambda TOTAL (Generador): %.4f clientes/seg\n', lambda_total_simulacion);
    fprintf('   ------------------------------------------------\n');
    fprintf('   Probabilidad AM (Split): %.2f%%\n', prob_AM_corregida * 100);
    fprintf('   Probabilidad FM (Split): %.2f%% (Antes era menor)\n', (1 - prob_AM_corregida) * 100);
    
catch ME
    error('? Error al calcular parámetros: %s', ME.message);
end

%% Paso 4: Validar y guardar (BLOQUE ÚNICO Y CORRECTO)
fprintf('\n4. Guardando parámetros finales...\n');

% Validación de seguridad
if prob_AM_corregida <= 0.01, prob_AM_corregida = 0.01; end
if prob_AM_corregida >= 0.99, prob_AM_corregida = 0.99; end

parametros_reales = struct();
% Guardamos el lambda YA CORREGIDO
parametros_reales.lambda_total = lambda_total_simulacion; 
parametros_reales.lambda_AM = target_lambda_AM;
parametros_reales.lambda_FM = target_lambda_FM;

% Guardamos la probabilidad YA CORREGIDA (IMPORTANTE: Se guarda como prob_AM)
parametros_reales.prob_AM = prob_AM_corregida; 

parametros_reales.prob_slow_AM = prob_slow_AM;
parametros_reales.prob_slow_FM = prob_slow_FM;
parametros_reales.mu_log = mu_log;       % Agregamos mu para lognormal
parametros_reales.sigma_log = sigma_log; % Agregamos sigma para lognormal
parametros_reales.fecha_generacion = datetime('now');
parametros_reales.version = '3.0_corregida_FM';

save('parametros_reales.mat', 'parametros_reales');

%% Paso 5: Generar código para funciones
fprintf('\n5. Generando código para funciones...\n');

% NOTA: Aquí inyectamos los valores calculados arriba.
% Usamos 'prob_AM_corregida' que es la variable que existe en el workspace.

% Código para InterArrival_General (Usa Lognormal según tu Paso 2)
codigo_interarrival = ['function t = InterArrival_General(~)' char(10) ...
    '%% Generado por bootstrap_inicial.m - ' datestr(now) char(10) ...
    'persistent init mu_log sigma_log;' char(10) ...
    'if isempty(init)' char(10) ...
    '    mu_log = ' num2str(mu_log, '%.6f') ';' char(10) ...
    '    sigma_log = ' num2str(sigma_log, '%.6f') ';' char(10) ...
    '    init = 1;' char(10) ...
    'end' char(10) ...
    't = lognrnd(mu_log, sigma_log);' char(10) ...
    'if t <= 0 || t > 3600' char(10) ...
    '    t = 10;' char(10) ...
    'end' char(10) ...
    'end'];

% Código para Assign_Cliente  
codigo_assign = ['function [emisora, bitrate, isSlow] = Assign_Cliente(trigger)' char(10) ...
    '%% Generado por bootstrap_inicial.m - ' datestr(now) char(10) ...
    'persistent init prob_AM prob_slow_AM prob_slow_FM;' char(10) ...
    'if isempty(init)' char(10) ...
    '    prob_AM = ' num2str(prob_AM_corregida, '%.6f') ';' char(10) ... % <--- CORREGIDO AQUÍ
    '    prob_slow_AM = ' num2str(prob_slow_AM, '%.6f') ';' char(10) ...
    '    prob_slow_FM = ' num2str(prob_slow_FM, '%.6f') ';' char(10) ...
    '    init = 1;' char(10) ...
    'end' char(10) ...
    char(10) ...
    'r = rand();' char(10) ...
    'if r < prob_AM' char(10) ...
    '    emisora = 0; %% AM' char(10) ...
    'else' char(10) ...
    '    emisora = 1; %% FM' char(10) ...
    'end' char(10) ...
    char(10) ...
    'if emisora == 0' char(10) ...
    '    prob_slow = prob_slow_AM;' char(10) ...
    'else' char(10) ...
    '    prob_slow = prob_slow_FM;' char(10) ...
    'end' char(10) ...
    char(10) ...
    '%% Distribución de bitrates' char(10) ...
    'r_bit = rand();' char(10) ...
    'if r_bit < 0.6' char(10) ...
    '    bitrate = 128;' char(10) ...
    'elseif r_bit < 0.9' char(10) ...
    '    bitrate = 96;' char(10) ...
    'else' char(10) ...
    '    bitrate = 64;' char(10) ...
    'end' char(10) ...
    char(10) ...
    'isSlow = 0;' char(10) ...
    'if rand() < prob_slow' char(10) ...
    '    isSlow = 1;' char(10) ...
    'end' char(10) ...
    'end'];

% Guardar archivos
fid1 = fopen('InterArrival_General_code.m', 'w');
fwrite(fid1, codigo_interarrival, 'char');
fclose(fid1);

fid2 = fopen('Assign_Cliente_code.m', 'w');
fwrite(fid2, codigo_assign, 'char');
fclose(fid2);

fprintf('\n? ¡PIPELINE COMPLETADO EXITOSAMENTE!\n');
fprintf('Archivos generados:\n');
fprintf('  - parametros_reales.mat\n');
fprintf('  - InterArrival_General_code.m\n');
fprintf('  - Assign_Cliente_code.m\n');