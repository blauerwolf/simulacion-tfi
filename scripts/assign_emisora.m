function [emisora, bitrate, isSlow] = AssignEmisora(trigger)
% AssignEmisora - Asigna tipo de emisora y atributos del cliente
% Basado en datos reales de tu sistema

persistent init;
if isempty(init)
    % Semilla fija para reproducibilidad
    rng(12345);
    init = 1;
end

% PROBABILIDADES REALES DE LOS DATOS
prob_AM = 0.9375;    % ? Valor real (ej: 93.75%)
prob_FM = 1 - prob_AM;

% Asignar emisora (0 = AM, 1 = FM)
if rand() < prob_AM
    emisora = 0; % AM
else
    emisora = 1; % FM
end

% PROBABILIDADES DE SLOW-LISTENER POR EMISORA
if emisora == 0 % AM
    prob_slow = 0.05;   % ? Valor real para AM
    % Distribución de bitrates para AM
    r = rand();
    if r < 0.7
        bitrate = 128;
    elseif r < 0.9
        bitrate = 96;
    else
        bitrate = 64;
    end
else % FM
    prob_slow = 0.15;   % ? Valor real para FM (ej: 15%)
    % Distribución de bitrates para FM  
    r = rand();
    if r < 0.6
        bitrate = 128;
    elseif r < 0.85
        bitrate = 96;
    else
        bitrate = 64;
    end
end

% Asignar slow-listener
isSlow = 0;
if rand() < prob_slow
    isSlow = 1;
end
end