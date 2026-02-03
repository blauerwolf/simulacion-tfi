function figura_comparacion(resultados)
% Genera gráficos comparativos

emisoras = {'AM', 'FM'};
velocidades = [128, 96, 64];

%% Figura 1: Probabilidad de Rechazo por Velocidad
figure('Name', 'Comparación de Rechazos', 'Position', [100, 100, 1200, 500]);

for e = 1:length(emisoras)
    emisora = emisoras{e};
    
    prob_rechazo_BW = zeros(1, length(velocidades));
    prob_rechazo_cola = zeros(1, length(velocidades));
    
    for v = 1:length(velocidades)
        vel = velocidades(v);
        prob_rechazo_BW(v) = resultados.(emisora).(['vel_' num2str(vel)]).prob_rechazo_BW;
        prob_rechazo_cola(v) = resultados.(emisora).(['vel_' num2str(vel)]).prob_rechazo_cola;
    end
    
    subplot(1, 2, e);
    bar(velocidades, [prob_rechazo_BW' prob_rechazo_cola'], 'grouped');
    title(['Rechazos en ' emisora]);
    xlabel('Velocidad (kbps)');
    ylabel('Probabilidad');
    legend('Rechazo por BW', 'Rechazo por Cola');
    grid on;
end

%% Figura 2: Utilización de Servidores
figure('Name', 'Utilización de Servidores', 'Position', [100, 100, 1200, 500]);

for e = 1:length(emisoras)
    emisora = emisoras{e};
    
    utilizacion = zeros(1, length(velocidades));
    
    for v = 1:length(velocidades)
        vel = velocidades(v);
        utilizacion(v) = resultados.(emisora).(['vel_' num2str(vel)]).utilizacion;
    end
    
    subplot(1, 2, e);
    bar(velocidades, utilizacion);
    title(['Utilización ' emisora]);
    xlabel('Velocidad (kbps)');
    ylabel('Utilización');
    ylim([0 1]);
    grid on;
end

%% Figura 3: Probabilidad de Éxito
figure('Name', 'Probabilidad de Éxito', 'Position', [100, 100, 800, 500]);

datos_exito = zeros(length(emisoras), length(velocidades));

for e = 1:length(emisoras)
    emisora = emisoras{e};
    for v = 1:length(velocidades)
        vel = velocidades(v);
        datos_exito(e, v) = resultados.(emisora).(['vel_' num2str(vel)]).prob_exito;
    end
end

bar(velocidades, datos_exito');
title('Probabilidad de Éxito por Velocidad y Emisora');
xlabel('Velocidad (kbps)');
ylabel('Probabilidad de Éxito');
legend(emisoras);
grid on;
ylim([0 1]);

end