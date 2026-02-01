function estadisticas = calcular_estadisticas(llegadas_total, atendidos, rechazados, tiempo_espera_total, tiempo_servicio_total)
% Calcula métricas del sistema

estadisticas.llegadas = llegadas_total;
estadisticas.atendidos = atendidos;
estadisticas.rechazados = rechazados;

% Probabilidad de rechazo
if llegadas_total > 0
    estadisticas.prob_rechazo = rechazados / llegadas_total;
else
    estadisticas.prob_rechazo = 0;
end

% Tiempo promedio en cola
if atendidos > 0
    estadisticas.tiempo_prom_espera = tiempo_espera_total / atendidos;
    estadisticas.tiempo_prom_servicio = tiempo_servicio_total / atendidos;
else
    estadisticas.tiempo_prom_espera = 0;
    estadisticas.tiempo_prom_servicio = 0;
end

% Utilización
estadisticas.utilizacion = atendidos / (llegadas_total + eps);

end
