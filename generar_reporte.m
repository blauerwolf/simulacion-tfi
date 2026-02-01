function generar_reporte(resultados_base, resultados_mejorado)
% Genera reporte textual de la simulación

fid = fopen('reporte_simulacion.txt', 'w');

fprintf(fid, '===============================================\\n');
fprintf(fid, ' REPORTE DE SIMULACIÓN - SISTEMA ICECAST\\n');
fprintf(fid, '===============================================\\n\\n');

fprintf(fid, 'Fecha: %s\\n\\n', datestr(now));

emisoras = {'AM', 'FM'};

for e = 1:length(emisoras)
    emisora = emisoras{e};
    
    fprintf(fid, '\\n--- EMISORA %s ---\\n\\n', emisora);
    
    % Base
    base = resultados_base.(emisora).totales;
    fprintf(fid, 'ESCENARIO BASE (solo 128 kbps):\\n');
    fprintf(fid, '  Total de llegadas: %d\\n', base.llegadas);
    fprintf(fid, '  Clientes atendidos: %d\\n', base.atendidos);
    fprintf(fid, '  Tasa de éxito: %.2f%%\\n', base.tasa_exito * 100);
    fprintf(fid, '  Rechazados por BW (Slow-Listeners): %d (%.2f%%)\\n', ...
        base.rechazados_BW, base.tasa_slow_listener * 100);
    fprintf(fid, '  Rechazados por cola llena: %d\\n\\n', base.rechazados_cola);
    
    % Mejorado
    mejorado = resultados_mejorado.(emisora).totales;
    fprintf(fid, 'ESCENARIO MEJORADO (128, 96, 64 kbps):\\n');
    fprintf(fid, '  Total de llegadas: %d\\n', mejorado.llegadas);
    fprintf(fid, '  Clientes atendidos: %d\\n', mejorado.atendidos);
    fprintf(fid, '  Tasa de éxito: %.2f%%\\n', mejorado.tasa_exito * 100);
    fprintf(fid, '  Rechazados por BW (Slow-Listeners): %d (%.2f%%)\\n', ...
        mejorado.rechazados_BW, mejorado.tasa_slow_listener * 100);
    fprintf(fid, '  Rechazados por cola llena: %d\\n\\n', mejorado.rechazados_cola);
    
    % Mejoras
    mejora_exito = ((mejorado.tasa_exito - base.tasa_exito) / base.tasa_exito) * 100;
    reduccion_slow = ((base.tasa_slow_listener - mejorado.tasa_slow_listener) / base.tasa_slow_listener) * 100;
    
    fprintf(fid, 'MEJORAS OBTENIDAS:\\n');
    fprintf(fid, '  Incremento en tasa de éxito: %.2f%%\\n', mejora_exito);
    fprintf(fid, '  Reducción de Slow-Listeners: %.2f%%\\n', reduccion_slow);
    fprintf(fid, '  Clientes adicionales atendidos: %d\\n\\n', mejorado.atendidos - base.atendidos);
    
    % Detalles por velocidad (escenario mejorado)
    fprintf(fid, 'DETALLES POR VELOCIDAD (Escenario Mejorado):\\n');
    velocidades = resultados_mejorado.velocidades;
    for v = 1:length(velocidades)
        vel = velocidades(v);
        stats = resultados_mejorado.(emisora).(['vel_' num2str(vel)]);
        fprintf(fid, '  %d kbps:\\n', vel);
        fprintf(fid, '    Llegadas: %d\\n', stats.llegadas);
        fprintf(fid, '    Atendidos: %d\\n', stats.atendidos);
        fprintf(fid, '    Utilización: %.2f%%\\n', stats.utilizacion * 100);
        fprintf(fid, '    Tiempo prom. espera: %.2f seg\\n', stats.tiempo_prom_espera);
    end
    fprintf(fid, '\\n');
end

fprintf(fid, '\\n===============================================\\n');
fprintf(fid, ' FIN DEL REPORTE\\n');
fprintf(fid, '===============================================\\n');

fclose(fid);

end