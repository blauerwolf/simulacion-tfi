function [resultados] = simular_escenario(lambda_AM, lambda_FM, velocidades, T_sim, c, capacidad_cola, mu, prob_movil)
% Simula un escenario completo

emisoras = {'AM', 'FM'};
lambdas = [lambda_AM, lambda_FM];

resultados = struct();
resultados.velocidades = velocidades;
resultados.config.c_servidores = c;
resultados.config.capacidad_cola = capacidad_cola;
resultados.config.T_sim = T_sim;

for e = 1:length(emisoras)
    emisora = emisoras{e};
    lambda = lambdas(e);
    
    % Acumuladores totales para el escenario
    llegadas_total = 0;
    atendidos_total = 0;
    rechazados_BW_total = 0;
    rechazados_cola_total = 0;
    
    for v = 1:length(velocidades)
        vel = velocidades(v);
        
        % Simulación para esta velocidad
        [stats] = simular_velocidad(lambda, vel, T_sim, c, capacidad_cola, mu, prob_movil);
        
        % Guardar resultados
        resultados.(emisora).(['vel_' num2str(vel)]) = stats;
        
        % Acumular totales
        llegadas_total = llegadas_total + stats.llegadas;
        atendidos_total = atendidos_total + stats.atendidos;
        rechazados_BW_total = rechazados_BW_total + stats.rechazados_BW;
        rechazados_cola_total = rechazados_cola_total + stats.rechazados_cola;
    end
    
    % Estadísticas totales de la emisora
    resultados.(emisora).totales.llegadas = llegadas_total;
    resultados.(emisora).totales.atendidos = atendidos_total;
    resultados.(emisora).totales.rechazados_BW = rechazados_BW_total;
    resultados.(emisora).totales.rechazados_cola = rechazados_cola_total;
    resultados.(emisora).totales.tasa_exito = atendidos_total / llegadas_total;
    resultados.(emisora).totales.tasa_slow_listener = rechazados_BW_total / llegadas_total;
end

end

function [stats] = simular_velocidad(lambda, vel, T_sim, c, capacidad_cola, mu, prob_movil)
% Simula una velocidad específica

% Estado del sistema
servidores_libres = c;
cola = 0;

% Contadores
llegadas = 0;
atendidos = 0;
rechazados_BW = 0;
rechazados_cola = 0;
tiempo_espera_total = 0;
tiempo_servicio_total = 0;

% Lista de eventos
eventos = [];

% Primera llegada
tiempo_prox_llegada = exprnd(1/lambda);
eventos = [eventos; tiempo_prox_llegada, 1, 0];

% Servidores ocupados
servidores_ocupados = zeros(c, 2);

% Cola FIFO
cola_fifo = [];

% Simulación
t = 0;

while t < T_sim
    eventos = sortrows(eventos, 1);
    
    if isempty(eventos)
        break;
    end
    
    evento = eventos(1,:);
    eventos(1,:) = [];
    
    t = evento(1);
    tipo_evento = evento(2);
    
    % LLEGADA
    if tipo_evento == 1
        llegadas = llegadas + 1;
        
        % Generar BW cliente
        if rand() < prob_movil
            BW_cliente = max(normrnd(80, 25), 32);
        else
            BW_cliente = max(normrnd(150, 30), 32);
        end
        
        % Verificar Slow-Listener
        if BW_cliente < vel * 1.1
            rechazados_BW = rechazados_BW + 1;
        else
            if servidores_libres > 0
                atendidos = atendidos + 1;
                servidores_libres = servidores_libres - 1;
                
                tiempo_servicio = exprnd(1/mu);
                tiempo_servicio_total = tiempo_servicio_total + tiempo_servicio;
                
                for i = 1:c
                    if servidores_ocupados(i,1) == 0
                        servidores_ocupados(i,:) = [t + tiempo_servicio, BW_cliente];
                        eventos = [eventos; t + tiempo_servicio, 2, i];
                        break;
                    end
                end
            else
                if cola < capacidad_cola
                    cola = cola + 1;
                    cola_fifo = [cola_fifo; t, BW_cliente];
                else
                    rechazados_cola = rechazados_cola + 1;
                end
            end
        end
        
        % Próxima llegada
        tiempo_prox_llegada = t + exprnd(1/lambda);
        if tiempo_prox_llegada < T_sim
            eventos = [eventos; tiempo_prox_llegada, 1, 0];
        end
    end
    
    % FIN DE SERVICIO
    if tipo_evento == 2
        servidor_id = evento(3);
        servidores_ocupados(servidor_id,:) = [0, 0];
        servidores_libres = servidores_libres + 1;
        
        if cola > 0
            cliente_cola = cola_fifo(1,:);
            cola_fifo(1,:) = [];
            cola = cola - 1;
            
            tiempo_espera = t - cliente_cola(1);
            tiempo_espera_total = tiempo_espera_total + tiempo_espera;
            
            atendidos = atendidos + 1;
            servidores_libres = servidores_libres - 1;
            
            tiempo_servicio = exprnd(1/mu);
            tiempo_servicio_total = tiempo_servicio_total + tiempo_servicio;
            
            servidores_ocupados(servidor_id,:) = [t + tiempo_servicio, cliente_cola(2)];
            eventos = [eventos; t + tiempo_servicio, 2, servidor_id];
        end
    end
end

% Calcular estadísticas
stats.llegadas = llegadas;
stats.atendidos = atendidos;
stats.rechazados_BW = rechazados_BW;
stats.rechazados_cola = rechazados_cola;
stats.prob_rechazo_BW = rechazados_BW / llegadas;
stats.prob_rechazo_cola = rechazados_cola / llegadas;
stats.prob_exito = atendidos / llegadas;
stats.tiempo_prom_espera = tiempo_espera_total / max(atendidos, 1);
stats.tiempo_prom_servicio = tiempo_servicio_total / max(atendidos, 1);
stats.utilizacion = (tiempo_servicio_total / c) / T_sim;

end