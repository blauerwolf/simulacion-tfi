function [bitrate, emisora, userSpeed, duration, targetPort] = Assign_Cliente(trigger)
%% Generado por iniciar_presimulacion.m - 03-Feb-2026 14:43:12 (MODO INTELIGENTE)
persistent init prob_AM prob_slow_AM prob_slow_FM;
if isempty(init)
    prob_AM = 0.755356;
    prob_slow_AM = 0.007112;
    prob_slow_FM = 0.002006;
    init = 1;
end

%% 1. Asignar Emisora
r = rand();
if r < prob_AM
    emisora = 0; %% AM
else
    emisora = 1; %% FM
end

%% 2. Asignar userSpeed (PRIORITARIO)
%% Primero determinamos la capacidad del usuario antes de asignarle servidor
if emisora == 0
    if rand() < prob_slow_AM
        userSpeed = round(normrnd(80, 20));
        if userSpeed <= 0, userSpeed = 50; end
    else
        userSpeed = round(normrnd(160, 30));
    end
else
    if rand() < prob_slow_FM
        userSpeed = round(normrnd(80, 20));
        if userSpeed <= 0, userSpeed = 50; end
    else
        userSpeed = round(normrnd(160, 30));
    end
end

%% 3. Ruteo Inteligente (Smart Routing)
%% Asignamos el mejor bitrate que el usuario soporte SIN cortes
if userSpeed >= 128
    bitrate = 128;
    targetPort = 1; %% Calidad Alta
elseif userSpeed >= 96
    bitrate = 96;
    targetPort = 2; %% Calidad Media
else
    bitrate = 64;
    targetPort = 3; %% Calidad Baja (Salvavidas)
end

%% 4. Asignar duration
if emisora == 0
    duration = round(normrnd(300, 60));
else
    duration = round(normrnd(240, 40));
end
if duration <= 0
    duration = 60;
end
end