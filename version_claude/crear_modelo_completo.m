% crear_modelo_completo.m
% Crea el modelo completo de streaming Icecast

% Cerrar modelos abiertos
close_all;
bdclose all;

% Nombre del modelo
modelo = 'streaming_icecast';

% Crear nuevo modelo
new_system(modelo);
open_system(modelo);

% Configurar solver
set_param(modelo, 'Solver', 'FixedStepDiscrete');
set_param(modelo, 'FixedStep', '0.1');
set_param(modelo, 'StopTime', '10000');

%% Posiciones para organizar bloques
pos_base_y = 100;
pos_spacing_y = 300;
pos_x_start = 50;

%% ============ SUBSISTEMA AM ============
pos_am_y = pos_base_y;

% Crear subsistema AM
add_block('built-in/Subsystem', [modelo '/Subsistema_AM']);
set_param([modelo '/Subsistema_AM'], 'Position', [pos_x_start, pos_am_y, pos_x_start+200, pos_am_y+100]);

% Dentro del subsistema AM
subsistema_am = [modelo '/Subsistema_AM'];

% Clock
add_block('simulink/Sources/Clock', [subsistema_am '/Clock']);
set_param([subsistema_am '/Clock'], 'Position', [50, 50, 80, 70]);

% Random Numbers para llegadas
add_block('simulink/Sources/Uniform Random Number', [subsistema_am '/Random_Llegadas']);
set_param([subsistema_am '/Random_Llegadas'], 'Position', [50, 120, 100, 150]);
set_param([subsistema_am '/Random_Llegadas'], 'Minimum', '0');
set_param([subsistema_am '/Random_Llegadas'], 'Maximum', '1');
set_param([subsistema_am '/Random_Llegadas'], 'SampleTime', '0.1');

% Random para BW
add_block('simulink/Sources/Uniform Random Number', [subsistema_am '/Random_BW']);
set_param([subsistema_am '/Random_BW'], 'Position', [50, 200, 100, 230]);
set_param([subsistema_am '/Random_BW'], 'Minimum', '0');
set_param([subsistema_am '/Random_BW'], 'Maximum', '1');
set_param([subsistema_am '/Random_BW'], 'SampleTime', '0.1');

% Random para tipo cliente
add_block('simulink/Sources/Uniform Random Number', [subsistema_am '/Random_Tipo']);
set_param([subsistema_am '/Random_Tipo'], 'Position', [50, 280, 100, 310]);
set_param([subsistema_am '/Random_Tipo'], 'Minimum', '0');
set_param([subsistema_am '/Random_Tipo'], 'Maximum', '1');
set_param([subsistema_am '/Random_Tipo'], 'SampleTime', '0.1');

% MATLAB Function: Generador de Llegadas
add_block('simulink/User-Defined Functions/MATLAB Function', [subsistema_am '/Gen_Llegadas']);
set_param([subsistema_am '/Gen_Llegadas'], 'Position', [200, 100, 300, 160]);

% MATLAB Function: Asignar Cliente
add_block('simulink/User-Defined Functions/MATLAB Function', [subsistema_am '/Asignar_Cliente']);
set_param([subsistema_am '/Asignar_Cliente'], 'Position', [200, 200, 300, 280]);

% Constante Lambda AM
add_block('simulink/Sources/Constant', [subsistema_am '/Lambda_AM']);
set_param([subsistema_am '/Lambda_AM'], 'Value', 'lambda_AM');
set_param([subsistema_am '/Lambda_AM'], 'Position', [50, 360, 100, 390]);

%% Crear subsistemas para cada velocidad (128, 96, 64 kbps)
velocidades = [128, 96, 64];
pos_y_vel = 100;

for v = 1:length(velocidades)
    vel = velocidades(v);
    nombre_vel = ['Cola_' num2str(vel) 'kbps'];
    
    % MATLAB Function: Sistema M/M/c para esta velocidad
    add_block('simulink/User-Defined Functions/MATLAB Function', [subsistema_am '/' nombre_vel]);
    set_param([subsistema_am '/' nombre_vel], 'Position', [400, pos_y_vel, 500, pos_y_vel+80]);
    
    % Scope para visualizar
    add_block('simulink/Sinks/Scope', [subsistema_am '/Scope_' num2str(vel)]);
    set_param([subsistema_am '/Scope_' num2str(vel)], 'Position', [600, pos_y_vel, 630, pos_y_vel+30]);
    
    pos_y_vel = pos_y_vel + 120;
end

%% ============ REPETIR PARA FM ============
pos_fm_y = pos_base_y + pos_spacing_y;

% Crear subsistema FM (similar a AM)
add_block('built-in/Subsystem', [modelo '/Subsistema_FM']);
set_param([modelo '/Subsistema_FM'], 'Position', [pos_x_start, pos_fm_y, pos_x_start+200, pos_fm_y+100]);

% [Código similar para FM...]

%% ============ ESTADÍSTICAS ============
% Crear subsistema de estadísticas
add_block('built-in/Subsystem', [modelo '/Estadisticas']);
set_param([modelo '/Estadisticas'], 'Position', [300, 500, 500, 600]);

% Guardar modelo
save_system(modelo);

disp('Modelo creado exitosamente');
disp(['Abre el modelo con: open_system(''' modelo ''')']);