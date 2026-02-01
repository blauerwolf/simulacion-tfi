function [en_servicio, cola_actual, rechazado, tiempo_espera] = sistema_MMc(llegada, BW_cliente, velocidad_stream, servidores_libres, cola_actual, capacidad_cola, tiempo_actual, mu)
% Simula un sistema M/M/c
% Retorna estado actualizado

rechazado = 0;
tiempo_espera = 0;
en_servicio = 0;

% Verificar si es Slow-Listener
if BW_cliente < velocidad_stream * 1.1 % 10% margen de seguridad
    rechazado = 1; % Cliente no puede sostener la velocidad
    return;
end

% Si hay llegada
if llegada == 1
    % Verificar si hay servidores libres
    if servidores_libres > 0
        en_servicio = 1;
        servidores_libres = servidores_libres - 1;
    else
        % Agregar a la cola si hay espacio
        if cola_actual < capacidad_cola
            cola_actual = cola_actual + 1;
        else
            rechazado = 1; % Cola llena
        end
    end
end

end