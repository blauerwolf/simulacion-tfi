% crear_modelo_icecast_r2015a.m
% Modelo para MATLAB R2015a con ruta exacta:
% SimEvents/Generators/Entity Generators/...

clear all;
close all;
bdclose all;

fprintf('Creando modelo Icecast para R2015a...\n');

modelo = 'icecast_sim_r2015a';
if bdIsLoaded(modelo), close_system(modelo, 0); end
if exist([modelo '.slx'], 'file'), delete([modelo '.slx']); end

new_system(modelo);
open_system(modelo);

% Configurar solver
set_param(modelo, 'Solver', 'FixedStepDiscrete');
set_param(modelo, 'FixedStep', '1');
set_param(modelo, 'StopTime', '10000');

%% ========================================
%% SISTEMA AM
%% ========================================
fprintf('Creando sistema AM...\n');

% --- Generador de Entidades AM ---
add_block('SimEvents/Generators/Entity Generators/Time-Based Entity Generator', [modelo '/Gen_AM']);
set_param([modelo '/Gen_AM'], 'Position', [50, 100, 120, 150]);
set_param([modelo '/Gen_AM'], 'GenerationMode', 'Signal');
set_param([modelo '/Gen_AM'], 'SignalEntityDeparture', 'on');

% --- Constante AM ---
add_block('simulink/Sources/Constant', [modelo '/Lambda_AM']);
set_param([modelo '/Lambda_AM'], 'Value', '0.5');
set_param([modelo '/Lambda_AM'], 'SampleTime', 'Inf');
set_param([modelo '/Lambda_AM'], 'Position', [50, 200, 80, 220]);

% --- Función de tiempos ---
add_block('simulink/User-Defined Functions/MATLAB Function', [modelo '/InterArrival_AM']);
set_param([modelo '/InterArrival_AM'], 'MATLABFunction', 'function t = fcn(lambda) t = exprnd(1/lambda); end');
set_param([modelo '/InterArrival_AM'], 'Position', [150, 120, 250, 170]);

% --- Conexiones AM ---
add_line(modelo, 'Lambda_AM/1', 'InterArrival_AM/1');
add_line(modelo, 'InterArrival_AM/1', 'Gen_AM/t');

%% ========================================
%% SISTEMA FM
%% ========================================
fprintf('Creando sistema FM...\n');

add_block('SimEvents/Generators/Entity Generators/Time-Based Entity Generator', [modelo '/Gen_FM']);
set_param([modelo '/Gen_FM'], 'Position', [50, 300, 120, 350]);
set_param([modelo '/Gen_FM'], 'GenerationMode', 'Signal');
set_param([modelo '/Gen_FM'], 'SignalEntityDeparture', 'on');

add_block('simulink/Sources/Constant', [modelo '/Lambda_FM']);
set_param([modelo '/Lambda_FM'], 'Value', '0.8');
set_param([modelo '/Lambda_FM'], 'SampleTime', 'Inf');
set_param([modelo '/Lambda_FM'], 'Position', [50, 400, 80, 420]);

add_block('simulink/User-Defined Functions/MATLAB Function', [modelo '/InterArrival_FM']);
set_param([modelo '/InterArrival_FM'], 'MATLABFunction', 'function t = fcn(lambda) t = exprnd(1/lambda); end');
set_param([modelo '/InterArrival_FM'], 'Position', [150, 320, 250, 370]);

add_line(modelo, 'Lambda_FM/1', 'InterArrival_FM/1');
add_line(modelo, 'InterArrival_FM/1', 'Gen_FM/t');

%% ========================================
%% ASIGNACIÓN DE ATRIBUTOS (solo configuración básica)
%% ========================================
fprintf('Configurando atributos...\n');

% Para evitar errores, creamos solo los bloques esenciales
add_block('SimEvents/Generators/Entity Management/Set Attribute', [modelo '/SetAttr_AM']);
set_param([modelo '/SetAttr_AM'], 'Position', [360, 100, 440, 150]);

add_block('SimEvents/Generators/Entity Management/Set Attribute', [modelo '/SetAttr_FM']);
set_param([modelo '/SetAttr_FM'], 'Position', [360, 300, 440, 350]);

%% Guardar modelo mínimo
save_system(modelo);
fprintf('\n? Modelo creado exitosamente!\n');
fprintf('Modelo: %s.slx\n', modelo);
fprintf('\nAhora abre el modelo y configura manualmente:\n');
fprintf('- Doble clic en Gen_AM ? GenerationMode: "Signal"\n');
fprintf('- Conecta Lambda_AM ? InterArrival_AM ? Gen_AM/t\n');
fprintf('- En SetAttr_AM, configura atributos manualmente\n');