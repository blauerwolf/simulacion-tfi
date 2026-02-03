% crear_modelo_simple.m
% Versión simplificada que funciona

clear all;
close all;
bdclose all;

fprintf('Creando modelo simplificado...\\n');

modelo = 'icecast_modelo';

% Eliminar si existe
if bdIsLoaded(modelo)
    close_system(modelo, 0);
end
if exist([modelo '.slx'], 'file')
    delete([modelo '.slx']);
end

% Crear modelo
new_system(modelo);
open_system(modelo);

% Configurar
set_param(modelo, 'Solver', 'FixedStepDiscrete');
set_param(modelo, 'FixedStep', '0.1');
set_param(modelo, 'StopTime', '1000');

fprintf('Modelo base creado\\n');

%% ==========================================
%% SUBSISTEMA AM - ESTRUCTURA COMPLETA
%% ==========================================

fprintf('Creando subsistema AM...\\n');

% Crear subsistema
add_block('built-in/Subsystem', [modelo '/AM']);
set_param([modelo '/AM'], 'Position', [100, 100, 300, 300]);

am = [modelo '/AM'];

% Limpiar subsistema
bloques = find_system(am, 'SearchDepth', 1);
for i = 2:length(bloques)
    try
        delete_block(bloques{i});
    catch
    end
end

%% CAPA 1: FUENTES DE DATOS

% Clock
add_block('simulink/Sources/Clock', [am '/Clock']);
set_param([am '/Clock'], 'Position', [50, 50, 80, 70]);

% Lambda
add_block('simulink/Sources/Constant', [am '/Lambda']);
set_param([am '/Lambda'], 'Value', '0.5');
set_param([am '/Lambda'], 'Position', [50, 100, 90, 120]);

% Random 1
add_block('simulink/Sources/Uniform Random Number', [am '/Rand1']);
set_param([am '/Rand1'], 'Position', [50, 150, 90, 170]);
set_param([am '/Rand1'], 'SampleTime', '0.1');
set_param([am '/Rand1'], 'Seed', '1');

% Random 2
add_block('simulink/Sources/Uniform Random Number', [am '/Rand2']);
set_param([am '/Rand2'], 'Position', [50, 200, 90, 220]);
set_param([am '/Rand2'], 'SampleTime', '0.1');
set_param([am '/Rand2'], 'Seed', '2');

% Random 3
add_block('simulink/Sources/Uniform Random Number', [am '/Rand3']);
set_param([am '/Rand3'], 'Position', [50, 250, 90, 270]);
set_param([am '/Rand3'], 'SampleTime', '0.1');
set_param([am '/Rand3'], 'Seed', '3');

% Prob Movil
add_block('simulink/Sources/Constant', [am '/ProbMovil']);
set_param([am '/ProbMovil'], 'Value', '0.4');
set_param([am '/ProbMovil'], 'Position', [50, 300, 90, 320]);

fprintf('  Fuentes creadas\\n');

%% CAPA 2: PROCESAMIENTO

% Mux para agrupar entradas del generador
add_block('simulink/Signal Routing/Mux', [am '/Mux1']);
set_param([am '/Mux1'], 'Inputs', '3');
set_param([am '/Mux1'], 'Position', [150, 70, 155, 130]);

% Generador de Llegadas
add_block('simulink/User-Defined Functions/MATLAB Function', [am '/GenLlegadas']);
set_param([am '/GenLlegadas'], 'Position', [200, 80, 300, 120]);

% Mux para asignar cliente
add_block('simulink/Signal Routing/Mux', [am '/Mux2']);
set_param([am '/Mux2'], 'Inputs', '3');
set_param([am '/Mux2'], 'Position', [150, 220, 155, 280]);

% Asignar Cliente
add_block('simulink/User-Defined Functions/MATLAB Function', [am '/AsigCliente']);
set_param([am '/AsigCliente'], 'Position', [200, 230, 300, 270]);

% Demux para separar salidas
add_block('simulink/Signal Routing/Demux', [am '/Demux1']);
set_param([am '/Demux1'], 'Outputs', '2');
set_param([am '/Demux1'], 'Position', [340, 235, 345, 265]);

fprintf('  Procesadores creados\\n');

%% CAPA 3: COLAS

% Constantes de velocidad
vel_pos = [400, 450, 500];
velocidades = [128, 96, 64];

for i = 1:3
    vel = velocidades(i);
    
    % Constante velocidad
    add_block('simulink/Sources/Constant', [am '/Vel' num2str(vel)]);
    set_param([am '/Vel' num2str(vel)], 'Value', num2str(vel));
    set_param([am '/Vel' num2str(vel)], 'Position', [400, vel_pos(i), 430, vel_pos(i)+20]);
    
    % Mux para entradas de cola
    add_block('simulink/Signal Routing/Mux', [am '/MuxCola' num2str(vel)]);
    set_param([am '/MuxCola' num2str(vel)], 'Inputs', '4');
    set_param([am '/MuxCola' num2str(vel)], 'Position', [480, vel_pos(i)-10, 485, vel_pos(i)+30]);
    
    % Cola MMc
    add_block('simulink/User-Defined Functions/MATLAB Function', [am '/Cola' num2str(vel)]);
    set_param([am '/Cola' num2str(vel)], 'Position', [530, vel_pos(i)-15, 630, vel_pos(i)+35]);
    
    % Demux salida cola
    add_block('simulink/Signal Routing/Demux', [am '/DemuxCola' num2str(vel)]);
    set_param([am '/DemuxCola' num2str(vel)], 'Outputs', '5');
    set_param([am '/DemuxCola' num2str(vel)], 'Position', [670, vel_pos(i)-20, 675, vel_pos(i)+40]);
end

fprintf('  Colas creadas\\n');

%% CAPA 4: RECOLECCIÓN

% Mux para recolector (9 entradas: 3 colas x 3 salidas)
add_block('simulink/Signal Routing/Mux', [am '/MuxRecolector']);
set_param([am '/MuxRecolector'], 'Inputs', '9');
set_param([am '/MuxRecolector'], 'Position', [720, 400, 725, 550]);

% Recolector
add_block('simulink/User-Defined Functions/MATLAB Function', [am '/Recolector']);
set_param([am '/Recolector'], 'Position', [760, 440, 860, 510]);

% Demux salida recolector
add_block('simulink/Signal Routing/Demux', [am '/DemuxStats']);
set_param([am '/DemuxStats'], 'Outputs', '3');
set_param([am '/DemuxStats'], 'Position', [900, 450, 905, 500]);

fprintf('  Recolector creado\\n');

%% CAPA 5: SALIDAS

% Display
add_block('simulink/Sinks/Display', [am '/Display']);
set_param([am '/Display'], 'Position', [940, 430, 1020, 460]);

% Scope
add_block('simulink/Sinks/Scope', [am '/Scope']);
set_param([am '/Scope'], 'Position', [940, 480, 970, 510]);
set_param([am '/Scope'], 'NumInputPorts', '3');

% To Workspace
add_block('simulink/Sinks/To Workspace', [am '/ToWS']);
set_param([am '/ToWS'], 'VariableName', 'datos_AM');
set_param([am '/ToWS'], 'Position', [940, 530, 990, 560]);
set_param([am '/ToWS'], 'SaveFormat', 'Structure');

fprintf('  Salidas creadas\\n');

%% ==========================================
%% CONECTAR BLOQUES
%% ==========================================

fprintf('Conectando bloques AM...\\n');

try
    % Mux1 (Clock, Lambda, Rand1)
    add_line(am, 'Clock/1', 'Mux1/1');
    add_line(am, 'Lambda/1', 'Mux1/2');
    add_line(am, 'Rand1/1', 'Mux1/3');
    
    % Mux1 -> GenLlegadas
    add_line(am, 'Mux1/1', 'GenLlegadas/1');
    
    % Mux2 (Rand2, Rand3, ProbMovil)
    add_line(am, 'Rand2/1', 'Mux2/1');
    add_line(am, 'Rand3/1', 'Mux2/2');
    add_line(am, 'ProbMovil/1', 'Mux2/3');
    
    % Mux2 -> AsigCliente
    add_line(am, 'Mux2/1', 'AsigCliente/1');
    
    % AsigCliente -> Demux1
    add_line(am, 'AsigCliente/1', 'Demux1/1');
    
    fprintf('  Conexiones básicas OK\\n');
    
    % Conectar colas
    for i = 1:3
        vel = velocidades(i);
        mux_cola = ['MuxCola' num2str(vel)];
        cola = ['Cola' num2str(vel)];
        demux_cola = ['DemuxCola' num2str(vel)];
        
        % Entradas a MuxCola: llegada, BW, velocidad, tiempo
        add_line(am, 'GenLlegadas/1', [mux_cola '/1']);
        add_line(am, 'Demux1/1', [mux_cola '/2']); % BW
        add_line(am, ['Vel' num2str(vel) '/1'], [mux_cola '/3']);
        add_line(am, 'Clock/1', [mux_cola '/4']);
        
        % MuxCola -> Cola
        add_line(am, [mux_cola '/1'], [cola '/1']);
        
        % Cola -> DemuxCola
        add_line(am, [cola '/1'], [demux_cola '/1']);
        
        fprintf('  Cola %d conectada\\n', vel);
    end
    
    % Conectar al recolector (aceptado, rechazado, slow de cada cola)
    add_line(am, 'DemuxCola128/1', 'MuxRecolector/1'); % aceptado 128
    add_line(am, 'DemuxCola128/2', 'MuxRecolector/2'); % rechazado 128
    add_line(am, 'DemuxCola128/5', 'MuxRecolector/3'); % slow 128
    
    add_line(am, 'DemuxCola96/1', 'MuxRecolector/4');
    add_line(am, 'DemuxCola96/2', 'MuxRecolector/5');
    add_line(am, 'DemuxCola96/5', 'MuxRecolector/6');
    
    add_line(am, 'DemuxCola64/1', 'MuxRecolector/7');
    add_line(am, 'DemuxCola64/2', 'MuxRecolector/8');
    add_line(am, 'DemuxCola64/5', 'MuxRecolector/9');
    
    % MuxRecolector -> Recolector
    add_line(am, 'MuxRecolector/1', 'Recolector/1');
    
    % Recolector -> DemuxStats
    add_line(am, 'Recolector/1', 'DemuxStats/1');
    
    % DemuxStats -> Salidas
    add_line(am, 'DemuxStats/1', 'Display/1');
    add_line(am, 'DemuxStats/1', 'Scope/1');
    add_line(am, 'DemuxStats/2', 'Scope/2');
    add_line(am, 'DemuxStats/3', 'Scope/3');
    add_line(am, 'DemuxStats/1', 'ToWS/1');
    
    fprintf('  Todas las conexiones OK\\n');
    
catch ME
    fprintf('  Error en conexiones: %s\\n', ME.message);
end

%% ==========================================
%% SUBSISTEMA FM (COPIA DE AM)
%% ==========================================

fprintf('\\nCreando subsistema FM...\\n');

add_block([modelo '/AM'], [modelo '/FM']);
set_param([modelo '/FM'], 'Position', [100, 350, 300, 550]);

% Cambiar Lambda a 0.8
set_param([modelo '/FM/Lambda'], 'Value', '0.8');

% Cambiar nombre de variable
set_param([modelo '/FM/ToWS'], 'VariableName', 'datos_FM');

fprintf('  Subsistema FM creado (copia de AM)\\n');

%% Guardar
save_system(modelo);

fprintf('\\n');
fprintf('??????????????????????????????????????????????????\\n');
fprintf('  MODELO CREADO: %s\\n', modelo);
fprintf('??????????????????????????????????????????????????\\n\\n');

fprintf('SIGUIENTE: Configurar las funciones MATLAB\\n');
fprintf('Ejecuta: configurar_funciones_simple\\n\\n');