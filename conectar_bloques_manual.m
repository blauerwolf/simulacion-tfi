% conectar_bloques_manual.m
% Intenta conectar bloques automáticamente

fprintf('Conectando bloques...\\n');

modelo = 'streaming_icecast_visual';
sys_am = [modelo '/AM_Sistema'];

try
    %% AM - Conexiones básicas
    add_line(sys_am, 'Clock/1', 'Generador_Llegadas/1', 'autorouting', 'on');
    add_line(sys_am, 'Random_Llegadas/1', 'Generador_Llegadas/2', 'autorouting', 'on');
    add_line(sys_am, 'Lambda_AM/1', 'Generador_Llegadas/3', 'autorouting', 'on');
    
    add_line(sys_am, 'Random_Tipo/1', 'Asignar_Cliente/1', 'autorouting', 'on');
    add_line(sys_am, 'Random_BW/1', 'Asignar_Cliente/2', 'autorouting', 'on');
    add_line(sys_am, 'Prob_Movil/1', 'Asignar_Cliente/3', 'autorouting', 'on');
    
    add_line(sys_am, 'Asignar_Cliente/1', 'Selector_Velocidad/1', 'autorouting', 'on');
    
    add_line(sys_am, 'Generador_Llegadas/1', 'Scope_Llegadas/1', 'autorouting', 'on');
    
    %% Conexiones a colas
    velocidades = [128, 96, 64];
    for v = 1:length(velocidades)
        vel = velocidades(v);
        cola = ['Cola_' num2str(vel)];
        
        add_line(sys_am, 'Generador_Llegadas/1', [cola '/1'], 'autorouting', 'on');
        add_line(sys_am, 'Asignar_Cliente/1', [cola '/2'], 'autorouting', 'on');
        add_line(sys_am, ['Vel_' num2str(vel) '/1'], [cola '/3'], 'autorouting', 'on');
        add_line(sys_am, 'Clock/1', [cola '/4'], 'autorouting', 'on');
    end
    
    %% Conexiones al recolector
    add_line(sys_am, 'Cola_128/1', 'Recolector_Stats/1', 'autorouting', 'on');
    add_line(sys_am, 'Cola_128/2', 'Recolector_Stats/2', 'autorouting', 'on');
    add_line(sys_am, 'Cola_128/5', 'Recolector_Stats/3', 'autorouting', 'on');
    
    add_line(sys_am, 'Cola_96/1', 'Recolector_Stats/4', 'autorouting', 'on');
    add_line(sys_am, 'Cola_96/2', 'Recolector_Stats/5', 'autorouting', 'on');
    add_line(sys_am, 'Cola_96/5', 'Recolector_Stats/6', 'autorouting', 'on');
    
    add_line(sys_am, 'Cola_64/1', 'Recolector_Stats/7', 'autorouting', 'on');
    add_line(sys_am, 'Cola_64/2', 'Recolector_Stats/8', 'autorouting', 'on');
    add_line(sys_am, 'Cola_64/5', 'Recolector_Stats/9', 'autorouting', 'on');
    
    %% Salidas
    add_line(sys_am, 'Recolector_Stats/1', 'Display_Stats/1', 'autorouting', 'on');
    add_line(sys_am, 'Recolector_Stats/1', 'ToWorkspace_AM/1', 'autorouting', 'on');
    
    fprintf('? AM conectado\\n');
    
    %% FM (similar)
    sys_fm = [modelo '/FM_Sistema'];
    
    add_line(sys_fm, 'Clock/1', 'Generador_Llegadas/1', 'autorouting', 'on');
    add_line(sys_fm, 'Random_Llegadas/1', 'Generador_Llegadas/2', 'autorouting', 'on');
    add_line(sys_fm, 'Lambda_FM/1', 'Generador_Llegadas/3', 'autorouting', 'on');
    
    add_line(sys_fm, 'Random_Tipo/1', 'Asignar_Cliente/1', 'autorouting', 'on');
    add_line(sys_fm, 'Random_BW/1', 'Asignar_Cliente/2', 'autorouting', 'on');
    add_line(sys_fm, 'Prob_Movil/1', 'Asignar_Cliente/3', 'autorouting', 'on');
    
    add_line(sys_fm, 'Asignar_Cliente/1', 'Selector_Velocidad/1', 'autorouting', 'on');
    add_line(sys_fm, 'Generador_Llegadas/1', 'Scope_Llegadas/1', 'autorouting', 'on');
    
    for v = 1:length(velocidades)
        vel = velocidades(v);
        cola = ['Cola_' num2str(vel)];
        
        add_line(sys_fm, 'Generador_Llegadas/1', [cola '/1'], 'autorouting', 'on');
        add_line(sys_fm, 'Asignar_Cliente/1', [cola '/2'], 'autorouting', 'on');
        add_line(sys_fm, ['Vel_' num2str(vel) '/1'], [cola '/3'], 'autorouting', 'on');
        add_line(sys_fm, 'Clock/1', [cola '/4'], 'autorouting', 'on');
    end
    
    add_line(sys_fm, 'Cola_128/1', 'Recolector_Stats/1', 'autorouting', 'on');
    add_line(sys_fm, 'Cola_128/2', 'Recolector_Stats/2', 'autorouting', 'on');
    add_line(sys_fm, 'Cola_128/5', 'Recolector_Stats/3', 'autorouting', 'on');
    
    add_line(sys_fm, 'Cola_96/1', 'Recolector_Stats/4', 'autorouting', 'on');
    add_line(sys_fm, 'Cola_96/2', 'Recolector_Stats/5', 'autorouting', 'on');
    add_line(sys_fm, 'Cola_96/5', 'Recolector_Stats/6', 'autorouting', 'on');
    
    add_line(sys_fm, 'Cola_64/1', 'Recolector_Stats/7', 'autorouting', 'on');
    add_line(sys_fm, 'Cola_64/2', 'Recolector_Stats/8', 'autorouting', 'on');
    add_line(sys_fm, 'Cola_64/5', 'Recolector_Stats/9', 'autorouting', 'on');
    
    add_line(sys_fm, 'Recolector_Stats/1', 'Display_Stats/1', 'autorouting', 'on');
    add_line(sys_fm, 'Recolector_Stats/1', 'ToWorkspace_FM/1', 'autorouting', 'on');
    
    fprintf('? FM conectado\\n');
    
    save_system(modelo);
    fprintf('\\n? Conexiones completadas\\n');
    
catch ME
    fprintf('? Error: %s\\n', ME.message);
    fprintf('Conecta los bloques manualmente arrastrando líneas.\\n');
end