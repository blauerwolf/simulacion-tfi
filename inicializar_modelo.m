% inicializar_modelo.m
% Parámetros del Sistema de Streaming Icecast

clear all;
clc;

%% Parámetros Generales
T_simulacion = 10000; % Tiempo de simulación en segundos

%% Parámetros de Llegadas (Lambda - clientes/segundo)
lambda_AM = 0.5;      % Tasa de llegada AM (ajusta según tus datos)
lambda_FM = 0.8;      % Tasa de llegada FM (ajusta según tus datos)

%% Parámetros de Servicio (Mu - clientes/segundo)
% Tiempo promedio de conexión (ajusta según tus datos)
mu_128 = 1/300;  % Promedio 300 segundos de conexión
mu_96  = 1/300;
mu_64  = 1/300;

%% Número de Servidores
c_servidores = 3; % 3 servidores por velocidad

%% Capacidad de Cola
capacidad_cola = 50; % Clientes en espera máximo

%% Velocidades disponibles (kbps)
velocidades = [128, 96, 64];

%% Distribución de Ancho de Banda de Clientes
% Simula el BW disponible de los clientes (distribución normal)
media_BW_desktop = 150;  % kbps promedio desktop
std_BW_desktop = 30;

media_BW_movil = 80;     % kbps promedio móvil
std_BW_movil = 25;

%% Probabilidad de tipo de cliente
prob_movil = 0.4; % 40% clientes móviles

%% Parámetros de tu distribución de EasyFit
% AJUSTA ESTOS según tu análisis
% Ejemplo para Weibull (reemplaza con tu distribución)
dist_shape = 1.5;  % Parámetro de forma
dist_scale = 200;  % Parámetro de escala