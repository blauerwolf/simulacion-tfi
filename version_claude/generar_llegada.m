function tiempo_entre_llegadas = generar_llegada(lambda, u)
% Genera tiempos entre llegadas
% u = número aleatorio uniforme [0,1]
% lambda = tasa de llegadas

% Si usas distribución exponencial (Poisson)
tiempo_entre_llegadas = -log(u) / lambda;

% Si EasyFit te dio otra distribución, reemplaza aquí
% Ejemplo Weibull:
% shape = 1.5;
% scale = 1/lambda;
% tiempo_entre_llegadas = scale * (-log(u))^(1/shape);

end