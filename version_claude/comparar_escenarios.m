function comparar_escenarios(resultados_base, resultados_mejorado)
% Compara escenario base vs mejorado

emisoras = {'AM', 'FM'};

fprintf('\\n========== COMPARACIÓN DE ESCENARIOS ==========\\n\\n');

for e = 1:length(emisoras)
    emisora = emisoras{e};
    
    fprintf('--- %s ---\\n', emisora);
    
    % Escenario base
    base = resultados_base.(emisora).totales;
    % Escenario mejorado
    mejorado = resultados_mejorado.(emisora).totales;
    
    fprintf('ESCENARIO BASE (solo 128 kbps):\\n');
    fprintf('  Tasa de éxito: %.2f%%\\n', base.tasa_exito * 100);
    fprintf('  Slow-Listeners: %.2f%%\\n', base.tasa_slow_listener * 100);
    
    fprintf('\\nESCENARIO MEJORADO (128, 96, 64 kbps):\\n');
    fprintf('  Tasa de éxito: %.2f%%\\n', mejorado.tasa_exito * 100);
    fprintf('  Slow-Listeners: %.2f%%\\n', mejorado.tasa_slow_listener * 100);
    
    mejora_exito = ((mejorado.tasa_exito - base.tasa_exito) / base.tasa_exito) * 100;
    reduccion_slow = ((base.tasa_slow_listener - mejorado.tasa_slow_listener) / base.tasa_slow_listener) * 100;
    
    fprintf('\\nMEJORAS:\\n');
    fprintf('  Incremento en tasa de éxito: %.2f%%\\n', mejora_exito);
    fprintf('  Reducción de Slow-Listeners: %.2f%%\\n\\n', reduccion_slow);
end

% Generar gráficos
generar_graficos_comparacion(resultados_base, resultados_mejorado);

end