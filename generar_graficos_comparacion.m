function generar_graficos_comparacion(resultados_base, resultados_mejorado)
% Genera gráficos comparativos entre escenarios

emisoras = {'AM', 'FM'};

%% Gráfico 1: Comparación de Tasas de Éxito
figure('Name', 'Comparación Tasa de Éxito', 'Position', [100, 100, 800, 500]);

tasa_exito_base = zeros(1, length(emisoras));
tasa_exito_mejorado = zeros(1, length(emisoras));

for e = 1:length(emisoras)
    emisora = emisoras{e};
    tasa_exito_base(e) = resultados_base.(emisora).totales.tasa_exito * 100;
    tasa_exito_mejorado(e) = resultados_mejorado.(emisora).totales.tasa_exito * 100;
end

X = 1:length(emisoras);
bar(X, [tasa_exito_base' tasa_exito_mejorado'], 'grouped');
set(gca, 'XTickLabel', emisoras);
ylabel('Tasa de Éxito (%)');
title('Comparación: Tasa de Éxito por Escenario');
legend('Base (solo 128 kbps)', 'Mejorado (128, 96, 64 kbps)');
grid on;
ylim([0 100]);

%% Gráfico 2: Comparación de Slow-Listeners
figure('Name', 'Comparación Slow-Listeners', 'Position', [100, 100, 800, 500]);

slow_base = zeros(1, length(emisoras));
slow_mejorado = zeros(1, length(emisoras));

for e = 1:length(emisoras)
    emisora = emisoras{e};
    slow_base(e) = resultados_base.(emisora).totales.tasa_slow_listener * 100;
    slow_mejorado(e) = resultados_mejorado.(emisora).totales.tasa_slow_listener * 100;
end

bar(X, [slow_base' slow_mejorado'], 'grouped');
set(gca, 'XTickLabel', emisoras);
ylabel('Tasa de Slow-Listeners (%)');
title('Comparación: Tasa de Slow-Listeners por Escenario');
legend('Base (solo 128 kbps)', 'Mejorado (128, 96, 64 kbps)');
grid on;

%% Gráfico 3: Mejora Porcentual
figure('Name', 'Mejora Porcentual', 'Position', [100, 100, 800, 500]);

mejora_exito = zeros(1, length(emisoras));
reduccion_slow = zeros(1, length(emisoras));

for e = 1:length(emisoras)
    emisora = emisoras{e};
    base_ex = resultados_base.(emisora).totales.tasa_exito;
    mejor_ex = resultados_mejorado.(emisora).totales.tasa_exito;
    mejora_exito(e) = ((mejor_ex - base_ex) / base_ex) * 100;
    
    base_slow = resultados_base.(emisora).totales.tasa_slow_listener;
    mejor_slow = resultados_mejorado.(emisora).totales.tasa_slow_listener;
    reduccion_slow(e) = ((base_slow - mejor_slow) / base_slow) * 100;
end

bar(X, [mejora_exito' reduccion_slow'], 'grouped');
set(gca, 'XTickLabel', emisoras);
ylabel('Mejora (%)');
title('Mejora Porcentual: Éxito y Reducción de Slow-Listeners');
legend('Incremento en Éxito', 'Reducción de Slow-Listeners');
grid on;

end