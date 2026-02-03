% Cargar tus datos procesados
load('parametros_simulacion_final.mat');

% Probabilidades AM/FM
total_clientes = am_stats.total_media + fm_stats.total_media;
prob_AM_real = am_stats.total_media / total_clientes;
prob_FM_real = fm_stats.total_media / total_clientes;

% Tasas de slow-listeners reales
prob_slow_AM_real = am_stats.slow_rate_media;
prob_slow_FM_real = fm_stats.slow_rate_media;

% Parámetros lognormal (de tu análisis anterior)
% Estos los obtuviste del script bondad_ajuste.m
mu_log_real = -1.2345;    % ? Tus valores reales
sigma_log_real = 0.6789;  % ? Tus valores reales

fprintf('=== PARÁMETROS PARA LAS FUNCIONES ===\n');
fprintf('prob_AM = %.6f\n', prob_AM_real);
fprintf('prob_slow_AM = %.6f\n', prob_slow_AM_real);
fprintf('prob_slow_FM = %.6f\n', prob_slow_FM_real);
fprintf('mu_log = %.6f\n', mu_log_real);
fprintf('sigma_log = %.6f\n', sigma_log_real);