function t = InterArrival_General(~)
%% Generado por iniciar_presimulacion.m - 03-Feb-2026 14:43:12
persistent init mu_log sigma_log;
if isempty(init)
    mu_log = 3.489817;
    sigma_log = 0.802625;
    init = 1;
end
t = lognrnd(mu_log, sigma_log);
if t <= 0 || t > 3600
    t = 10;
end
end