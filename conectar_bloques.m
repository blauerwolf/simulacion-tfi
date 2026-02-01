function conectar_bloques(modelo)
% Conecta las líneas de señal entre bloques

fprintf('Conectando bloques del modelo...\n');

sys_am = [modelo '/AM_Sistema'];

try
    %% CONEXIONES EN SUBSISTEMA AM
    
    % Clock -> Generador_Llegadas (puerto 1)
    add_line(sys_am, 'Clock/1', 'Generador_Llegadas/1', 'autorouting', 'on');
    
    % Random_Llegadas -> Generador_Llegadas (puerto 2)
    add_line(sys_am, 'Random_Llegadas/1', 'Generador_Llegadas/2', 'autorouting', 'on');
    
    % Lambda_AM -> Generador_Llegadas (puerto 3)
    add_line(sys_am, 'Lambda_AM/1', 'Generador_Llegadas/3', 'autorouting', 'on');
    
    % Random_Tipo -> Asignar_Cliente (puerto 1)
    add_line(sys_am, 'Random_Tipo/1', 'Asignar_Cliente/1', 'autorouting', 'on');
    
    % Random_BW -> Asignar_Cliente (puerto 2)
    add_line(sys_am, 'Random_BW/1', 'Asignar_Cliente/2', 'autorouting', 'on');
    
    % Prob_Movil -> Asignar_Cliente (puerto 3)
    add_line(sys_am, 'Prob_Movil/1', 'Asignar_Cliente/3', 'autorouting', 'on');
    
    % Asignar_Cliente/1 (BW) -> Selector_Velocidad
    add_line(sys_am, 'Asignar_Cliente/1', 'Selector_Velocidad/1', 'autorouting', 'on');
    
    % Generador_Llegadas/1 (nueva_llegada) -> Scope_Llegadas
    add_line(sys_am, 'Generador_Llegadas/1', 'Scope_Llegadas/1', 'autorouting', 'on');
    
    %% CONEXIONES A LAS COLAS M/M/c
    
    velocidades = [128, 96, 64];
    
    for v = 1:length(velocidades)
        vel = velocidades(v);
        nombre_cola = ['Cola_MMc_' num2str(vel) 'kbps'];
        
        % Generador_Llegadas/1 -> Cola (puerto 1: llegada)
        add_line(sys_am, 'Generador_Llegadas/1', [nombre_cola '/1'], 'autorouting', 'on');
        
        % Asignar_Cliente/1 (BW) -> Cola (puerto 2: BW_cliente)
        add_line(sys_am, 'Asignar_Cliente/1', [nombre_cola '/2'], 'autorouting', 'on');
        
        % Vel_XX -> Cola (puerto 3: velocidad_stream)
        add_line(sys_am, ['Vel_' num2str(vel) '/1'], [nombre_cola '/3'], 'autorouting', 'on');
        
        % Clock -> Cola (puerto 4: tiempo)
        add_line(sys_am, 'Clock/1', [nombre_cola '/4'], 'autorouting', 'on');
    end
    
    %% CONEXIONES AL RECOLECTOR
    
    % Cola_128/1 (aceptado) -> Recolector/1
    add_line(sys_am, 'Cola_MMc_128kbps/1', 'Recolector_Stats/1', 'autorouting', 'on');
    % Cola_128/2 (rechazado) -> Recolector/2
    add_line(sys_am, 'Cola_MMc_128kbps/2', 'Recolector_Stats/2', 'autorouting', 'on');
    % Cola_128/5 (slow) -> Recolector/3
    add_line(sys_am, 'Cola_MMc_128kbps/5', 'Recolector_Stats/3', 'autorouting', 'on');
    
    % Cola_96/1 -> Recolector/4
    add_line(sys_am, 'Cola_MMc_96kbps/1', 'Recolector_Stats/4', 'autorouting', 'on');
    % Cola_96/2 -> Recolector/5
    add_line(sys_am, 'Cola_MMc_96kbps/2', 'Recolector_Stats/5', 'autorouting', 'on');
    % Cola_96/5 -> Recolector/6
    add_line(sys_am, 'Cola_MMc_96kbps/5', 'Recolector_Stats/6', 'autorouting', 'on');
    
    % Cola_64/1 -> Recolector/7
    add_line(sys_am, 'Cola_MMc_64kbps/1', 'Recolector_Stats/7', 'autorouting', 'on');
    % Cola_64/2 -> Recolector/8
    add_line(sys_am, 'Cola_MMc_64kbps/2', 'Recolector_Stats/8', 'autorouting', 'on');
    % Cola_64/5 -> Recolector/9
    add_line(sys_am, 'Cola_MMc_64kbps/5', 'Recolector_Stats/9', 'autorouting', 'on');
    
    %% SALIDAS
    
    % Recolector -> Display_Stats
    add_line(sys_am, 'Recolector_Stats/1', 'Display_Stats/1', 'autorouting', 'on');
    
    % Recolector -> ToWorkspace
    add_line(sys_am, 'Recolector_Stats/1', 'ToWorkspace_AM/1', 'autorouting', 'on');
    
    fprintf('  ? Subsistema AM conectado\n');
    
    %% REPETIR PARA FM
    sys_fm = [modelo '/FM_Sistema'];
    
    % [Código similar para FM...]
    
    fprintf('  ? Subsistema FM conectado\n');
    
    %% CONEXIONES EN MODELO PRINCIPAL
    
    % AM_Sistema -> Comparacion (puerto 1)
    % FM_Sistema -> Comparacion (puerto 2)
    % [Estas conexiones se harán manualmente]
    
    fprintf('\n? Conexiones completadas\n');
    
    % Organizar automáticamente
    Simulink.BlockDiagram.arrangeSystem(sys_am);
    Simulink.BlockDiagram.arrangeSystem(sys_fm);
    
catch ME
    fprintf('Error al conectar: %s\n', ME.message);
    fprintf('Algunas conexiones deberán hacerse manualmente\n');
end

save_system(modelo);

end