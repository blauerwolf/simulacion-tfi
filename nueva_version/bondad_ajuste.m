% bondad_ajuste.m
% Versión final compatible con MATLAB R2015a

clear all; clc;

% Cargar datos
load('parametros_simulacion_final.mat');

% Extraer datos AM
datos = master_data.am_total;
datos = datos(~isnan(datos) & datos > 0);

fprintf('Analizando %d puntos de datos\n', length(datos));
fprintf('Rango: %.1f - %.1f\n', min(datos), max(datos));
fprintf('Media: %.2f, Desv. estándar: %.2f\n', mean(datos), std(datos));

% Visualizar histograma
figure;
histogram(datos, 'Normalization', 'pdf');
title('Distribución de Clientes Conectados (AM)');
xlabel('Número de clientes');
ylabel('Densidad');

% Estadísticas clave
media_datos = mean(datos);
var_datos = var(datos);
fprintf('\nEstadísticas de los datos:\n');
fprintf('Media = %.2f, Varianza = %.2f\n', media_datos, var_datos);
fprintf('Ratio varianza/media = %.2f\n', var_datos / media_datos);

if var_datos > media_datos * 1.5
    fprintf('?? Alta sobre-dispersión ? usar LOGNORMAL\n');
else
    fprintf('? Varianza moderada ? considerar POISSON\n');
end

% Ajustar distribuciones continuas
fprintf('\nAjustando distribuciones...\n');

% Lognormal
mu_log = mean(log(datos));
sigma_log = std(log(datos));
loglik_log = sum(log(lognpdf(datos, mu_log, sigma_log) + eps));
aic_log = -2 * loglik_log + 2 * 2;

% Weibull  
params_weibull = wblfit(datos);
a_weibull = params_weibull(1); 
b_weibull = params_weibull(2);
loglik_weibull = sum(log(wblpdf(datos, a_weibull, b_weibull) + eps));
aic_weibull = -2 * loglik_weibull + 2 * 2;

% Gamma
params_gamma = gamfit(datos);
a_gamma = params_gamma(1);
b_gamma = params_gamma(2);
loglik_gamma = sum(log(gampdf(datos, a_gamma, b_gamma) + eps));
aic_gamma = -2 * loglik_gamma + 2 * 2;

% Exponencial
lambda_exp = 1 / mean(datos);
loglik_exp = sum(log(exppdf(datos, 1/lambda_exp) + eps));
aic_exp = -2 * loglik_exp + 2 * 1;

% Mostrar resultados
fprintf('lognormal:     AIC = %.2f\n', aic_log);
fprintf('weibull:       AIC = %.2f\n', aic_weibull);
fprintf('gamma:         AIC = %.2f\n', aic_gamma);
fprintf('exponential:   AIC = %.2f\n', aic_exp);

% Encontrar mejor
aic_vals = [aic_log, aic_weibull, aic_gamma, aic_exp];
[mejor_aic, idx_mejor] = min(aic_vals);
nombres = {'lognormal', 'weibull', 'gamma', 'exponential'};
mejor_distribucion = nombres{idx_mejor};

fprintf('\n? MEJOR DISTRIBUCIÓN: %s (AIC = %.2f)\n', mejor_distribucion, mejor_aic);

% Visualizar la mejor distribución
figure;
histogram(datos, 'Normalization', 'pdf');
hold on;
x = linspace(min(datos), max(datos), 1000);

switch mejor_distribucion
    case 'lognormal'
        y = lognpdf(x, mu_log, sigma_log);
        fprintf('\nParámetros Lognormal:\n');
        fprintf('mu = %.4f, sigma = %.4f\n', mu_log, sigma_log);
        
    case 'weibull'
        y = wblpdf(x, a_weibull, b_weibull);
        fprintf('\nParámetros Weibull:\n');
        fprintf('a = %.4f, b = %.4f\n', a_weibull, b_weibull);
        
    case 'gamma'
        y = gampdf(x, a_gamma, b_gamma);
        fprintf('\nParámetros Gamma:\n');
        fprintf('a = %.4f, b = %.4f\n', a_gamma, b_gamma);
        
    case 'exponential'
        y = exppdf(x, 1/lambda_exp);
        fprintf('\nParámetro Exponencial:\n');
        fprintf('lambda = %.6f\n', lambda_exp);
end

plot(x, y, 'r-', 'LineWidth', 2);
legend('Datos', sprintf('%s ajustada', mejor_distribucion));
title(sprintf('Ajuste de Distribución - %s', mejor_distribucion));
xlabel('Número de clientes');
ylabel('Densidad');

% Recomendación para simulación
fprintf('\n=== RECOMENDACIÓN PARA SIMULACIÓN ===\n');
fprintf('Usa la distribución %s para generar el número de clientes.\n', mejor_distribucion);

switch mejor_distribucion
    case 'lognormal'
        fprintf('En tu código de simulación, usa:\n');
        fprintf('clientes = round(lognrnd(%.4f, %.4f));\n', mu_log, sigma_log);
        
    case 'weibull'
        fprintf('En tu código de simulación, usa:\n');
        fprintf('clientes = round(wblrnd(%.4f, %.4f));\n', a_weibull, b_weibull);
        
    case 'gamma'
        fprintf('En tu código de simulación, usa:\n');
        fprintf('clientes = round(gamrnd(%.4f, %.4f));\n', a_gamma, b_gamma);
        
    case 'exponential'
        fprintf('En tu código de simulación, usa:\n');
        fprintf('clientes = round(exprnd(%.4f));\n', 1/lambda_exp);
end

fprintf('\n? Análisis completado exitosamente!\n');