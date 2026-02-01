% simulacion_icecast.m
% Simulación de eventos discretos del sistema Icecast

clear all;
clc;

%% Parámetros
T_sim = 10000; % segundos
lambda_AM = 0.5;
lambda_FM = 0.8;
mu = 1/300; % tasa de servicio
c = 3; % servidores por velocidad
capacidad_cola = 50;
velocidades = [128, 96, 64];

%% Inicialización
% Estructuras para AM y FM
emisoras = {'AM', 'FM'};
lambdas = [lambda_AM, lambda_FM];

resultados = struct();

for e = 1:length(emisoras)
    emisora = emisoras{e};
    lambda = lambdas(e);
    
    fprintf('\\n========== Simulando %s ==========\\n', emisora);
    
    % Para cada velocidad
    for v = 1:length(velocidades)
        vel = velocidades(v);
        
        fprintf('Velocidad: %d kbps\\n', vel);
        
        % Estado del sistema
        servidores_libres = c;
        cola = 0;
        
        % Contadores
        llegadas = 0;
        atendidos = 0;
        rechazados_BW = 0;
        rechazados_cola = 0;
        
        % Tiempos
        tiempo_espera_total = 0;
        tiempo_servicio_total = 0;
        
        % Lista de eventos
        eventos = []; % [tiempo, tipo, datos]
        
        % Primer evento de llegada
        tiempo_prox_llegada = exprnd(1/lambda);
        eventos = [eventos; tiempo_prox_llegada, 1, 0]; % tipo 1 = llegada
        
        % Servidores ocupados [tiempo_fin, BW_cliente]
        servidores_ocupados = zeros(c, 2);
        
        % Cola FIFO [tiempo_entrada, BW_cliente]
        cola_fifo = [];
        
        % Simulación de eventos discretos
        t = 0;
        
        while t < T_sim
            % Ordenar eventos por tiempo
            eventos = sortrows(eventos, 1);
            
            if isempty(eventos)
                break;
            end
            
            % Obtener próximo evento
            evento = eventos(1,:);
            eventos(1,:) = [];
            
            t = evento(1);
            tipo_evento = evento(2);
            
            % EVENTO: LLEGADA
            if tipo_evento == 1
                llegadas = llegadas + 1;
                
                % Generar BW del cliente
                if rand() < 0.4 % móvil
                    BW_cliente = normrnd(80, 25);
                else % desktop
                    BW_cliente = normrnd(150, 30);
                end
                BW_cliente = max(BW_cliente, 32);
                
                % Verificar Slow-Listener
                if BW_cliente < vel * 1.1
                    rechazados_BW = rechazados_BW + 1;
                else
                    % Verificar servidor disponible
                    if servidores_libres > 0
                        % Atender inmediatamente
                        atendidos = atendidos + 1;
                        servidores_libres = servidores_libres - 1;
                        
                        % Generar tiempo de servicio
                        tiempo_servicio = exprnd(1/mu);
                        tiempo_servicio_total = tiempo_servicio_total + tiempo_servicio;
                        
                        % Asignar a servidor
                        for i = 1:c
                            if servidores_ocupados(i,1) == 0
                                servidores_ocupados(i,:) = [t + tiempo_servicio, BW_cliente];
                                % Agregar evento de fin de servicio
                                eventos = [eventos; t + tiempo_servicio, 2, i]; % tipo 2 = fin
                                break;
                            end
                        end
                    else
                        % Agregar a cola
                        if cola < capacidad_cola
                            cola = cola + 1;
                            cola_fifo = [cola_fifo; t, BW_cliente];
                        else
                            rechazados_cola = rechazados_cola + 1;
                        end
                    end
                end
                
                % Generar próxima llegada
                tiempo_prox_llegada = t + exprnd(1/lambda);
                if tiempo_prox_llegada < T_sim
                    eventos = [eventos; tiempo_prox_llegada, 1, 0];
                end
            end
            
            % EVENTO: FIN DE SERVICIO
            if tipo_evento == 2
                servidor_id = evento(3);
                
                % Liberar servidor
                servidores_ocupados(servidor_id,:) = [0, 0];
                servidores_libres = servidores_libres + 1;
                
                % Atender cliente de la cola si hay
                if cola > 0
                    % Sacar de la cola
                    cliente_cola = cola_fifo(1,:);
                    cola_fifo(1,:) = [];
                    cola = cola - 1;
                    
                    tiempo_entrada = cliente_cola(1);
                    BW_cliente_cola = cliente_cola(2);
                    
                    % Calcular tiempo de espera
                    tiempo_espera = t - tiempo_entrada;
                    tiempo_espera_total = tiempo_espera_total + tiempo_espera;
                    
                    % Atender
                    atendidos = atendidos + 1;
                    servidores_libres = servidores_libres - 1;
                    
                    % Generar tiempo de servicio
                    tiempo_servicio = exprnd(1/mu);
                    tiempo_servicio_total = tiempo_servicio_total + tiempo_servicio;
                    
                    % Asignar a servidor
                    servidores_ocupados(servidor_id,:) = [t + tiempo_servicio, BW_cliente_cola];
                    
                    % Agregar evento de fin
                    eventos = [eventos; t + tiempo_servicio, 2, servidor_id];
                end
            end
        end
        
        % Guardar resultados
        resultados.(emisora).(['vel_' num2str(vel)]).llegadas = llegadas;
        resultados.(emisora).(['vel_' num2str(vel)]).atendidos = atendidos;
        resultados.(emisora).(['vel_' num2str(vel)]).rechazados_BW = rechazados_BW;
        resultados.(emisora).(['vel_' num2str(vel)]).rechazados_cola = rechazados_cola;
        resultados.(emisora).(['vel_' num2str(vel)]).prob_rechazo_BW = rechazados_BW / llegadas;
        resultados.(emisora).(['vel_' num2str(vel)]).prob_rechazo_cola = rechazados_cola / llegadas;
        resultados.(emisora).(['vel_' num2str(vel)]).prob_exito = atendidos / llegadas;
        
        if atendidos > 0
            resultados.(emisora).(['vel_' num2str(vel)]).tiempo_prom_espera = tiempo_espera_total / atendidos;
            resultados.(emisora).(['vel_' num2str(vel)]).tiempo_prom_servicio = tiempo_servicio_total / atendidos;
        else
            resultados.(emisora).(['vel_' num2str(vel)]).tiempo_prom_espera = 0;
            resultados.(emisora).(['vel_' num2str(vel)]).tiempo_prom_servicio = 0;
        end
        
        resultados.(emisora).(['vel_' num2str(vel)]).utilizacion = (tiempo_servicio_total / c) / T_sim;
        
        fprintf('  Llegadas: %d\\n', llegadas);
        fprintf('  Atendidos: %d\\n', atendidos);
        fprintf('  Rechazados por BW: %d (%.2f%%)\\n', rechazados_BW, rechazados_BW/llegadas*100);
        fprintf('  Rechazados por Cola: %d (%.2f%%)\\n', rechazados_cola, rechazados_cola/llegadas*100);
        fprintf('  Prob. Éxito: %.4f\\n', atendidos/llegadas);
        fprintf('  Utilización: %.4f\\n', (tiempo_servicio_total / c) / T_sim);
    end
end

%% Guardar resultados
save('resultados_simulacion.mat', 'resultados');

%% Generar gráficos comparativos
figura_comparacion(resultados);

fprintf('\\n========== Simulación Completada ==========\\n');