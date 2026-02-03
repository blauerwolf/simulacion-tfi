function velocidad_asignada = seleccionar_velocidad(BW_disponible, velocidades_disponibles)
% Selecciona la velocidad más alta que el cliente puede soportar
% BW_disponible = ancho de banda del cliente
% velocidades_disponibles = [128, 96, 64] o subconjunto

velocidad_asignada = 0;

% Ordenar velocidades de mayor a menor
velocidades_ordenadas = sort(velocidades_disponibles, 'descend');

% Seleccionar la velocidad más alta soportada
for i = 1:length(velocidades_ordenadas)
    if BW_disponible >= velocidades_ordenadas(i) * 1.1 % 10% margen
        velocidad_asignada = velocidades_ordenadas(i);
        break;
    end
end

% Si ninguna velocidad es soportada
if velocidad_asignada == 0
    velocidad_asignada = min(velocidades_disponibles); % Asignar la más baja
end

end