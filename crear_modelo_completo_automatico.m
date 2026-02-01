% crear_modelo_completo_automatico.m
% Script maestro para crear el modelo visual completo

clear all;
close all;
clc;

fprintf('========================================\n');
fprintf('  CREACIÓN DE MODELO VISUAL SIMULINK\n');
fprintf('  Sistema de Streaming Icecast\n');
fprintf('========================================\n\n');

%% PASO 1: Crear estructura de bloques
fprintf('PASO 1: Creando estructura de bloques...\n');
crear_modelo_simulink;
fprintf('? Estructura creada\n\n');

%% PASO 2: Mostrar código de funciones
fprintf('PASO 2: Generando código de funciones MATLAB...\n');
configurar_funciones_matlab('streaming_icecast_visual');
fprintf('? Código generado\n\n');

%% PASO 3: Intentar conectar bloques
fprintf('PASO 3: Conectando bloques...\n');
try
    conectar_bloques('streaming_icecast_visual');
    fprintf('? Bloques conectados\n\n');
catch
    fprintf('? Algunas conexiones deben hacerse manualmente\n\n');
end

%% PASO 4: Instrucciones finales
fprintf('========================================\n');
fprintf('  MODELO CREADO\n');
fprintf('========================================\n\n');

fprintf('PRÓXIMOS PASOS:\n\n');

fprintf('1. Abre el modelo:\n');
fprintf('   >> open_system(''streaming_icecast_visual'')\n\n');

fprintf('2. Entra a cada subsistema (AM_Sistema y FM_Sistema)\n\n');

fprintf('3. Configura cada bloque MATLAB Function:\n');
fprintf('   - Doble clic en el bloque\n');
fprintf('   - Copia el código que se mostró arriba\n');
fprintf('   - Ctrl+S para guardar\n\n');

fprintf('4. Verifica las conexiones entre bloques\n\n');

fprintf('5. Ejecuta la simulación:\n');
fprintf('   >> sim(''streaming_icecast_visual'')\n\n');

fprintf('6. Visualiza resultados:\n');
fprintf('   >> analizar_resultados_simulink\n\n');

fprintf('========================================\n');

%% Abrir el modelo automáticamente
open_system('streaming_icecast_visual');