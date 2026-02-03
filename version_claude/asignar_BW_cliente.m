function [BW_disponible, es_movil] = asignar_BW_cliente(u1, u2, prob_movil, media_desktop, std_desktop, media_movil, std_movil)
% Asigna ancho de banda disponible a cada cliente
% u1, u2 = números aleatorios uniformes [0,1]

% Determinar si es móvil o desktop
if u1 < prob_movil
    es_movil = 1;
    % Generar BW para móvil (distribución normal)
    z = sqrt(-2*log(u2)) * cos(2*pi*u2); % Box-Muller
    BW_disponible = media_movil + std_movil * z;
else
    es_movil = 0;
    % Generar BW para desktop
    z = sqrt(-2*log(u2)) * cos(2*pi*u2);
    BW_disponible = media_desktop + std_desktop * z;
end

% Asegurar BW mínimo de 32 kbps
BW_disponible = max(BW_disponible, 32);

end