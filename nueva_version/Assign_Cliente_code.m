function [emisora, bitrate, isSlow] = Assign_Cliente(trigger)
%% Generado por bootstrap_inicial.m - 03-Feb-2026 00:21:33
persistent init prob_AM prob_slow_AM prob_slow_FM;
if isempty(init)
    prob_AM = 0.755356;
    prob_slow_AM = 0.007112;
    prob_slow_FM = 0.002006;
    init = 1;
end

r = rand();
if r < prob_AM
    emisora = 0; %% AM
else
    emisora = 1; %% FM
end

if emisora == 0
    prob_slow = prob_slow_AM;
else
    prob_slow = prob_slow_FM;
end

%% Distribución de bitrates
r_bit = rand();
if r_bit < 0.6
    bitrate = 128;
elseif r_bit < 0.9
    bitrate = 96;
else
    bitrate = 64;
end

isSlow = 0;
if rand() < prob_slow
    isSlow = 1;
end
end