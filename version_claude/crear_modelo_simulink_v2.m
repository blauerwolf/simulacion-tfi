% crear_modelo_simulink_v2.m
% Versión corregida compatible con R2015a

clear all;
close all;
bdclose all;

fprintf('Creando modelo visual de Simulink (R2015a)...\\n');

% Nombre del modelo
modelo = 'streaming_icecast_visual';

% Verificar si el modelo existe y cerrarlo
if bdIsLoaded(modelo)
    close_system(modelo, 0);
end

% Eliminar modelo si existe
if exist([modelo '.slx'], 'file')
    delete([modelo '.slx']);
end

% Crear nuevo modelo
new_system(modelo);
open_system(modelo);

% Configurar parámetros del modelo
set_param(modelo, 'Solver', 'FixedStepDiscrete');
set_param(modelo, 'FixedStep', '0.1');
set_param(modelo, 'StopTime', '10000');

fprintf('Modelo base creado. Construyendo bloques...\\n');

%% ========================================
%% SUBSISTEMA AM
%% ========================================

fprintf('Creando subsistema AM...\\n');

% Crear subsistema principal AM
add_block('built-in/Subsystem', [modelo '/AM_Sistema']);
set_param([modelo '/AM_Sistema'], 'Position', [50, 50, 250, 400]);

% Nombre del subsistema
sys_am = [modelo '/AM_Sistema'];

% Eliminar bloques por defecto de forma segura
try
    if exist_block([sys_am '/In1'])
        delete_block([sys_am '/In1']);
    end
    if exist_block([sys_am '/Out1'])
        delete_block([sys_am '/Out1']);
    end
catch
    % Ignorar errores
end

%% --- GENERADORES DE ENTRADA ---

% Clock
add_block('simulink/Sources/Clock', [sys_am '/Clock']);
set_param([sys_am '/Clock'], 'Position', [30, 30, 60, 50]);

% Constante Lambda AM
add_block('simulink/Sources/Constant', [sys_am '/Lambda_AM']);
set_param([sys_am '/Lambda_AM'], 'Value', '0.5');
set_param([sys_am '/Lambda_AM'], 'Position', [30, 80, 80, 100]);

% Random para llegadas
add_block('simulink/Sources/Uniform Random Number', [sys_am '/Random_Llegadas']);
set_param([sys_am '/Random_Llegadas'], 'Position', [30, 130, 80, 160]);
set_param([sys_am '/Random_Llegadas'], 'Minimum', '0');
set_param([sys_am '/Random_Llegadas'], 'Maximum', '1');
set_param([sys_am '/Random_Llegadas'], 'SampleTime', '0.1');
set_param([sys_am '/Random_Llegadas'], 'Seed', '12345');

% Random para BW
add_block('simulink/Sources/Uniform Random Number', [sys_am '/Random_BW']);
set_param([sys_am '/Random_BW'], 'Position', [30, 190, 80, 220]);
set_param([sys_am '/Random_BW'], 'Minimum', '0');
set_param([sys_am '/Random_BW'], 'Maximum', '1');
set_param([sys_am '/Random_BW'], 'SampleTime', '0.1');
set_param([sys_am '/Random_BW'], 'Seed', '23456');

% Random para tipo
add_block('simulink/Sources/Uniform Random Number', [sys_am '/Random_Tipo']);
set_param([sys_am '/Random_Tipo'], 'Position', [30, 250, 80, 280]);
set_param([sys_am '/Random_Tipo'], 'Minimum', '0');
set_param([sys_am '/Random_Tipo'], 'Maximum', '1');
set_param([sys_am '/Random_Tipo'], 'SampleTime', '0.1');
set_param([sys_am '/Random_Tipo'], 'Seed', '34567');

% Constante Prob Movil
add_block('simulink/Sources/Constant', [sys_am '/Prob_Movil']);
set_param([sys_am '/Prob_Movil'], 'Value', '0.4');
set_param([sys_am '/Prob_Movil'], 'Position', [30, 310, 80, 330]);

%% --- BLOQUES MATLAB FUNCTION ---

% Generador de Llegadas
add_block('simulink/User-Defined Functions/MATLAB Function', [sys_am '/Generador_Llegadas']);
set_param([sys_am '/Generador_Llegadas'], 'Position', [150, 60, 280, 120]);

% Asignar Cliente
add_block('simulink/User-Defined Functions/MATLAB Function', [sys_am '/Asignar_Cliente']);
set_param([sys_am '/Asignar_Cliente'], 'Position', [150, 200, 280, 260]);

% Selector Velocidad
add_block('simulink/User-Defined Functions/MATLAB Function', [sys_am '/Selector_Velocidad']);
set_param([sys_am '/Selector_Velocidad'], 'Position', [350, 180, 450, 220]);

%% --- COLAS M/M/c ---

velocidades = [128, 96, 64];
pos_y_base = 100;
espaciado = 200;

for v = 1:length(velocidades)
    vel = velocidades(v);
    nombre_cola = ['Cola_' num2str(vel)];
    
    pos_y = pos_y_base + (v-1) * espaciado;
    
    % MATLAB Function Cola
    add_block('simulink/User-Defined Functions/MATLAB Function', [sys_am '/' nombre_cola]);
    set_param([sys_am '/' nombre_cola], 'Position', [550, pos_y, 670, pos_y+80]);
    
    % Constante velocidad
    add_block('simulink/Sources/Constant', [sys_am '/Vel_' num2str(vel)]);
    set_param([sys_am '/Vel_' num2str(vel)], 'Value', num2str(vel));
    set_param([sys_am '/Vel_' num2str(vel)], 'Position', [500, pos_y+90, 530, pos_y+110]);
    
    fprintf('  - Cola %d kbps creada\\n', vel);
end

%% --- VISUALIZACIÓN ---

% Scope
add_block('simulink/Sinks/Scope', [sys_am '/Scope_Llegadas']);
set_param([sys_am '/Scope_Llegadas'], 'Position', [320, 30, 350, 60]);

% Display
add_block('simulink/Sinks/Display', [sys_am '/Display_Stats']);
set_param([sys_am '/Display_Stats'], 'Position', [750, 300, 800, 330]);

% To Workspace
add_block('simulink/Sinks/To Workspace', [sys_am '/ToWorkspace_AM']);
set_param([sys_am '/ToWorkspace_AM'], 'VariableName', 'datos_AM');
set_param([sys_am '/ToWorkspace_AM'], 'Position', [750, 350, 800, 380]);
set_param([sys_am '/ToWorkspace_AM'], 'SaveFormat', 'Structure');

% Recolector Stats
add_block('simulink/User-Defined Functions/MATLAB Function', [sys_am '/Recolector_Stats']);
set_param([sys_am '/Recolector_Stats'], 'Position', [700, 200, 800, 380]);

fprintf('  - Subsistema AM completado\\n');

%% ========================================
%% SUBSISTEMA FM
%% ========================================

fprintf('Creando subsistema FM...\\n');

add_block('built-in/Subsystem', [modelo '/FM_Sistema']);
set_param([modelo '/FM_Sistema'], 'Position', [50, 450, 250, 800]);

sys_fm = [modelo '/FM_Sistema'];

% Eliminar bloques default
try
    if exist_block([sys_fm '/In1'])
        delete_block([sys_fm '/In1']);
    end
    if exist_block([sys_fm '/Out1'])
        delete_block([sys_fm '/Out1']);
    end
catch
end

%% Duplicar estructura AM para FM

add_block('simulink/Sources/Clock', [sys_fm '/Clock']);
set_param([sys_fm '/Clock'], 'Position', [30, 30, 60, 50]);

add_block('simulink/Sources/Constant', [sys_fm '/Lambda_FM']);
set_param([sys_fm '/Lambda_FM'], 'Value', '0.8');
set_param([sys_fm '/Lambda_FM'], 'Position', [30, 80, 80, 100]);

add_block('simulink/Sources/Uniform Random Number', [sys_fm '/Random_Llegadas']);
set_param([sys_fm '/Random_Llegadas'], 'Position', [30, 130, 80, 160]);
set_param([sys_fm '/Random_Llegadas'], 'Minimum', '0');
set_param([sys_fm '/Random_Llegadas'], 'Maximum', '1');
set_param([sys_fm '/Random_Llegadas'], 'SampleTime', '0.1');
set_param([sys_fm '/Random_Llegadas'], 'Seed', '45678');

add_block('simulink/Sources/Uniform Random Number', [sys_fm '/Random_BW']);
set_param([sys_fm '/Random_BW'], 'Position', [30, 190, 80, 220]);
set_param([sys_fm '/Random_BW'], 'Minimum', '0');
set_param([sys_fm '/Random_BW'], 'Maximum', '1');
set_param([sys_fm '/Random_BW'], 'SampleTime', '0.1');
set_param([sys_fm '/Random_BW'], 'Seed', '56789');

add_block('simulink/Sources/Uniform Random Number', [sys_fm '/Random_Tipo']);
set_param([sys_fm '/Random_Tipo'], 'Position', [30, 250, 80, 280]);
set_param([sys_fm '/Random_Tipo'], 'Minimum', '0');
set_param([sys_fm '/Random_Tipo'], 'Maximum', '1');
set_param([sys_fm '/Random_Tipo'], 'SampleTime', '0.1');
set_param([sys_fm '/Random_Tipo'], 'Seed', '67890');

add_block('simulink/Sources/Constant', [sys_fm '/Prob_Movil']);
set_param([sys_fm '/Prob_Movil'], 'Value', '0.4');
set_param([sys_fm '/Prob_Movil'], 'Position', [30, 310, 80, 330]);

add_block('simulink/User-Defined Functions/MATLAB Function', [sys_fm '/Generador_Llegadas']);
set_param([sys_fm '/Generador_Llegadas'], 'Position', [150, 60, 280, 120]);

add_block('simulink/User-Defined Functions/MATLAB Function', [sys_fm '/Asignar_Cliente']);
set_param([sys_fm '/Asignar_Cliente'], 'Position', [150, 200, 280, 260]);

add_block('simulink/User-Defined Functions/MATLAB Function', [sys_fm '/Selector_Velocidad']);
set_param([sys_fm '/Selector_Velocidad'], 'Position', [350, 180, 450, 220]);

for v = 1:length(velocidades)
    vel = velocidades(v);
    nombre_cola = ['Cola_' num2str(vel)];
    pos_y = pos_y_base + (v-1) * espaciado;
    
    add_block('simulink/User-Defined Functions/MATLAB Function', [sys_fm '/' nombre_cola]);
    set_param([sys_fm '/' nombre_cola], 'Position', [550, pos_y, 670, pos_y+80]);
    
    add_block('simulink/Sources/Constant', [sys_fm '/Vel_' num2str(vel)]);
    set_param([sys_fm '/Vel_' num2str(vel)], 'Value', num2str(vel));
    set_param([sys_fm '/Vel_' num2str(vel)], 'Position', [500, pos_y+90, 530, pos_y+110]);
end

add_block('simulink/Sinks/Scope', [sys_fm '/Scope_Llegadas']);
set_param([sys_fm '/Scope_Llegadas'], 'Position', [320, 30, 350, 60]);

add_block('simulink/Sinks/Display', [sys_fm '/Display_Stats']);
set_param([sys_fm '/Display_Stats'], 'Position', [750, 300, 800, 330]);

add_block('simulink/Sinks/To Workspace', [sys_fm '/ToWorkspace_FM']);
set_param([sys_fm '/ToWorkspace_FM'], 'VariableName', 'datos_FM');
set_param([sys_fm '/ToWorkspace_FM'], 'Position', [750, 350, 800, 380]);
set_param([sys_fm '/ToWorkspace_FM'], 'SaveFormat', 'Structure');

add_block('simulink/User-Defined Functions/MATLAB Function', [sys_fm '/Recolector_Stats']);
set_param([sys_fm '/Recolector_Stats'], 'Position', [700, 200, 800, 380]);

fprintf('  - Subsistema FM completado\\n');

%% Guardar modelo
save_system(modelo);

fprintf('\\n¡Modelo creado exitosamente!\\n');
fprintf('Modelo: %s\\n', modelo);
fprintf('\\nPróximo paso: Configurar las funciones MATLAB\\n');


