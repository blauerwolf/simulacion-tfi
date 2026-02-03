function t = InterArrivalGenerator(~)
% InterArrivalGenerator - Genera tiempos entre llegadas de clientes
% Basado en análisis de datos reales (distribución lognormal)

% PARÁMETROS DE TU ANÁLISIS REAL
% Reemplaza estos valores con los que obtuviste del script
mu_log = -1.2345;    % ? Tu valor real de mu
sigma_log = 0.6789;  % ? Tu valor real de sigma

% Generar tiempo entre llegadas (en segundos)
t = lognrnd(mu_log, sigma_log);

% Asegurar que sea positivo y razonable
if t <= 0 || t > 3600  % máximo 1 hora entre clientes
    t = 10; % valor por defecto razonable
end
end