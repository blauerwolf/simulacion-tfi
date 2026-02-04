%% SCRIPT DE GRÁFICOS FINALES

% 1. Verificar que existan los datos
if ~exist('total_AM_128', 'var') || ~exist('total_FM_128', 'var')
    error('? Error: No se encuentran las variables. Asegúrate de haber renombrado los bloques en Simulink y corrido la simulación.');
end

% 2. Base de tiempo (Usamos squeeze para asegurar que sea un vector simple)
t = squeeze(total_AM_128.Time);

% 3. Suma de Tráfico Total (Usamos squeeze en cada suma)
% Simulink a veces guarda datos como [Nx1x1], squeeze lo convierte a [Nx1]
raw_AM = total_AM_128.Data + total_AM_96.Data + total_AM_64.Data;
AM_Total = squeeze(raw_AM);

raw_FM = total_FM_128.Data + total_FM_96.Data + total_FM_64.Data;
FM_Total = squeeze(raw_FM);

% 4. Suma de Tráfico Slow
raw_AM_Slow = slow_AM_128.Data + slow_AM_96.Data + slow_AM_64.Data;
AM_Slow_Total = squeeze(raw_AM_Slow);

raw_FM_Slow = slow_FM_128.Data + slow_FM_96.Data + slow_FM_64.Data;
FM_Slow_Total = squeeze(raw_FM_Slow);

%% GRÁFICO 1: COMPARATIVA DE DEMANDA (Usando plotyy)
figure('Name', 'Comparativa AM vs FM', 'Color', 'w');

% plotyy crea dos ejes (AX) y dos manipuladores de línea (H1, H2)
[AX, H1, H2] = plotyy(t, AM_Total, t, FM_Total);

% --- Estilo Eje Izquierdo (AM) ---
ylabel(AX(1), 'Oyentes AM (Escala Alta)');
set(H1, 'LineWidth', 2, 'Color', 'b'); % Línea Azul
set(AX(1), 'YColor', 'b'); 

% Añadir línea promedio AM manualmente
hold(AX(1), 'on');
plot(AX(1), t, ones(size(t))*mean(AM_Total), 'b--');

% --- Estilo Eje Derecho (FM) ---
ylabel(AX(2), 'Oyentes FM (Escala Baja)');
set(H2, 'LineWidth', 2, 'Color', 'm'); % Línea Magenta
set(AX(2), 'YColor', 'm'); 

% Ajustar límite FM para que se vea bien
max_fm = max(FM_Total);
if max_fm == 0, max_fm = 1; end
set(AX(2), 'YLim', [0, max_fm * 1.5]); % Un poco más de aire arriba

title('Dinámica de Carga: AM vs FM (Escala Doble)');
legend([H1, H2], 'Tráfico AM', 'Tráfico FM', 'Location', 'northwest');
grid on;

%% GRÁFICO 2: USUARIOS CON CORTES (SLOW)
figure('Name', 'Usuarios Afectados (Slow)', 'Color', 'w');

subplot(2,1,1);
plot(t, AM_Slow_Total, 'r', 'LineWidth', 1.5);
title('AM: Usuarios Experimentando Cortes (Slow)');
ylabel('Usuarios'); grid on;

subplot(2,1,2);
% Usamos un color RGB personalizado [0.8 0 0.5] para magenta oscuro
plot(t, FM_Slow_Total, 'Color', [0.8 0 0.5], 'LineWidth', 1.5);
title('FM: Usuarios Experimentando Cortes (Slow)');
ylabel('Usuarios'); xlabel('Tiempo (s)'); grid on;