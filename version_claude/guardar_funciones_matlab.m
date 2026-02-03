% guardar_funciones_matlab.m
% Guarda las funciones MATLAB en archivos .m

fprintf('Creando archivos de funciones MATLAB...\\n');

%% FUNCIÓN 1: Generador de Llegadas
fprintf('  - Creando funcion_generador_llegadas.m\\n');

fid = fopen('funcion_generador_llegadas.m', 'w');
fprintf(fid, 'function [nueva_llegada, tiempo_siguiente] = funcion_generador_llegadas(t, u, lambda)\\n');
fprintf(fid, '%% Genera llegadas segun proceso de Poisson\\n');
fprintf(fid, '\\n');
fprintf(fid, 'persistent tiempo_proxima_llegada;\\n');
fprintf(fid, 'persistent contador;\\n');
fprintf(fid, '\\n');
fprintf(fid, 'if isempty(tiempo_proxima_llegada)\\n');
fprintf(fid, '    tiempo_proxima_llegada = 0;\\n');
fprintf(fid, '    contador = 0;\\n');
fprintf(fid, 'end\\n');
fprintf(fid, '\\n');
fprintf(fid, 'nueva_llegada = 0;\\n');
fprintf(fid, '\\n');
fprintf(fid, 'if t >= tiempo_proxima_llegada\\n');
fprintf(fid, '    nueva_llegada = 1;\\n');
fprintf(fid, '    contador = contador + 1;\\n');
fprintf(fid, '    tiempo_entre = -log(u) / lambda;\\n');
fprintf(fid, '    tiempo_proxima_llegada = t + tiempo_entre;\\n');
fprintf(fid, 'end\\n');
fprintf(fid, '\\n');
fprintf(fid, 'tiempo_siguiente = tiempo_proxima_llegada;\\n');
fclose(fid);

%% FUNCIÓN 2: Asignar Cliente
fprintf('  - Creando funcion_asignar_cliente.m\\n');

fid = fopen('funcion_asignar_cliente.m', 'w');
fprintf(fid, 'function [BW_disponible, es_movil] = funcion_asignar_cliente(u_tipo, u_bw, prob_movil)\\n');
fprintf(fid, '%% Asigna ancho de banda y tipo de cliente\\n');
fprintf(fid, '\\n');
fprintf(fid, 'media_BW_desktop = 150;\\n');
fprintf(fid, 'std_BW_desktop = 30;\\n');
fprintf(fid, 'media_BW_movil = 80;\\n');
fprintf(fid, 'std_BW_movil = 25;\\n');
fprintf(fid, '\\n');
fprintf(fid, 'if u_tipo < prob_movil\\n');
fprintf(fid, '    es_movil = 1;\\n');
fprintf(fid, '    media = media_BW_movil;\\n');
fprintf(fid, '    std_dev = std_BW_movil;\\n');
fprintf(fid, 'else\\n');
fprintf(fid, '    es_movil = 0;\\n');
fprintf(fid, '    media = media_BW_desktop;\\n');
fprintf(fid, '    std_dev = std_BW_desktop;\\n');
fprintf(fid, 'end\\n');
fprintf(fid, '\\n');
fprintf(fid, 'z = sqrt(-2*log(u_bw)) * cos(2*pi*u_bw);\\n');
fprintf(fid, 'BW_disponible = media + std_dev * z;\\n');
fprintf(fid, 'BW_disponible = max(BW_disponible, 32);\\n');
fclose(fid);

%% FUNCIÓN 3: Selector Velocidad
fprintf('  - Creando funcion_selector_velocidad.m\\n');

fid = fopen('funcion_selector_velocidad.m', 'w');
fprintf(fid, 'function velocidad_asignada = funcion_selector_velocidad(BW_disponible)\\n');
fprintf(fid, '%% Selecciona velocidad optima\\n');
fprintf(fid, '\\n');
fprintf(fid, 'velocidades = [128, 96, 64];\\n');
fprintf(fid, 'margen = 1.1;\\n');
fprintf(fid, '\\n');
fprintf(fid, 'velocidad_asignada = 64;\\n');
fprintf(fid, '\\n');
fprintf(fid, 'for i = 1:length(velocidades)\\n');
fprintf(fid, '    if BW_disponible >= velocidades(i) * margen\\n');
fprintf(fid, '        velocidad_asignada = velocidades(i);\\n');
fprintf(fid, '        break;\\n');
fprintf(fid, '    end\\n');
fprintf(fid, 'end\\n');
fclose(fid);

%% FUNCIÓN 4: Cola M/M/c (genérica)
fprintf('  - Creando funcion_cola_mmc.m\\n');

fid = fopen('funcion_cola_mmc.m', 'w');
fprintf(fid, 'function [aceptado, rechazado, en_cola, serv_ocup, slow] = funcion_cola_mmc(llegada, BW_cliente, vel_stream, t)\\n');
fprintf(fid, '%% Sistema M/M/c con 3 servidores\\n');
fprintf(fid, '\\n');
fprintf(fid, 'persistent cola;\\n');
fprintf(fid, 'persistent servidores_libres;\\n');
fprintf(fid, 'persistent clientes_servicio;\\n');
fprintf(fid, 'persistent cola_fifo;\\n');
fprintf(fid, 'persistent stats;\\n');
fprintf(fid, '\\n');
fprintf(fid, 'if isempty(cola)\\n');
fprintf(fid, '    cola = 0;\\n');
fprintf(fid, '    servidores_libres = 3;\\n');
fprintf(fid, '    clientes_servicio = zeros(3, 2);\\n');
fprintf(fid, '    cola_fifo = [];\\n');
fprintf(fid, '    stats.llegadas = 0;\\n');
fprintf(fid, '    stats.atendidos = 0;\\n');
fprintf(fid, '    stats.rechazados_BW = 0;\\n');
fprintf(fid, '    stats.rechazados_cola = 0;\\n');
fprintf(fid, 'end\\n');
fprintf(fid, '\\n');
fprintf(fid, 'aceptado = 0;\\n');
fprintf(fid, 'rechazado = 0;\\n');
fprintf(fid, 'slow = 0;\\n');
fprintf(fid, '\\n');
fprintf(fid, '%% Procesar fin de servicio\\n');
fprintf(fid, 'for i = 1:3\\n');
fprintf(fid, '    if clientes_servicio(i,1) > 0 && t >= clientes_servicio(i,1)\\n');
fprintf(fid, '        clientes_servicio(i,:) = [0, 0];\\n');
fprintf(fid, '        servidores_libres = servidores_libres + 1;\\n');
fprintf(fid, '        \\n');
fprintf(fid, '        if cola > 0 && ~isempty(cola_fifo)\\n');
fprintf(fid, '            cola = cola - 1;\\n');
fprintf(fid, '            cliente = cola_fifo(1,:);\\n');
fprintf(fid, '            cola_fifo(1,:) = [];\\n');
fprintf(fid, '            \\n');
fprintf(fid, '            servidores_libres = servidores_libres - 1;\\n');
fprintf(fid, '            mu = 1/300;\\n');
fprintf(fid, '            t_serv = -log(rand()) / mu;\\n');
fprintf(fid, '            clientes_servicio(i,:) = [t + t_serv, cliente(2)];\\n');
fprintf(fid, '            stats.atendidos = stats.atendidos + 1;\\n');
fprintf(fid, '        end\\n');
fprintf(fid, '    end\\n');
fprintf(fid, 'end\\n');
fprintf(fid, '\\n');
fprintf(fid, '%% Procesar llegada\\n');
fprintf(fid, 'if llegada == 1\\n');
fprintf(fid, '    stats.llegadas = stats.llegadas + 1;\\n');
fprintf(fid, '    \\n');
fprintf(fid, '    if BW_cliente < vel_stream * 1.1\\n');
fprintf(fid, '        rechazado = 1;\\n');
fprintf(fid, '        slow = 1;\\n');
fprintf(fid, '        stats.rechazados_BW = stats.rechazados_BW + 1;\\n');
fprintf(fid, '    else\\n');
fprintf(fid, '        if servidores_libres > 0\\n');
fprintf(fid, '            aceptado = 1;\\n');
fprintf(fid, '            servidores_libres = servidores_libres - 1;\\n');
fprintf(fid, '            \\n');
fprintf(fid, '            mu = 1/300;\\n');
fprintf(fid, '            t_serv = -log(rand()) / mu;\\n');
fprintf(fid, '            \\n');
fprintf(fid, '            for i = 1:3\\n');
fprintf(fid, '                if clientes_servicio(i,1) == 0\\n');
fprintf(fid, '                    clientes_servicio(i,:) = [t + t_serv, BW_cliente];\\n');
fprintf(fid, '                    break;\\n');
fprintf(fid, '                end\\n');
fprintf(fid, '            end\\n');
fprintf(fid, '            stats.atendidos = stats.atendidos + 1;\\n');
fprintf(fid, '        else\\n');
fprintf(fid, '            if cola < 50\\n');
fprintf(fid, '                cola = cola + 1;\\n');
fprintf(fid, '                cola_fifo = [cola_fifo; t, BW_cliente];\\n');
fprintf(fid, '            else\\n');
fprintf(fid, '                rechazado = 1;\\n');
fprintf(fid, '                stats.rechazados_cola = stats.rechazados_cola + 1;\\n');
fprintf(fid, '            end\\n');
fprintf(fid, '        end\\n');
fprintf(fid, '    end\\n');
fprintf(fid, 'end\\n');
fprintf(fid, '\\n');
fprintf(fid, 'en_cola = cola;\\n');
fprintf(fid, 'serv_ocup = 3 - servidores_libres;\\n');
fclose(fid);

%% FUNCIÓN 5: Recolector
fprintf('  - Creando funcion_recolector_stats.m\\n');

fid = fopen('funcion_recolector_stats.m', 'w');
fprintf(fid, 'function stats_salida = funcion_recolector_stats(a1,r1,s1, a2,r2,s2, a3,r3,s3)\\n');
fprintf(fid, '%% Recolecta estadisticas\\n');
fprintf(fid, '\\n');
fprintf(fid, 'persistent stats;\\n');
fprintf(fid, '\\n');
fprintf(fid, 'if isempty(stats)\\n');
fprintf(fid, '    stats = zeros(12,1);\\n');
fprintf(fid, 'end\\n');
fprintf(fid, '\\n');
fprintf(fid, 'stats(1) = stats(1) + a1 + a2 + a3;\\n');
fprintf(fid, 'stats(2) = stats(2) + r1 + r2 + r3;\\n');
fprintf(fid, 'stats(3) = stats(3) + s1 + s2 + s3;\\n');
fprintf(fid, '\\n');
fprintf(fid, 'total = stats(1) + stats(2);\\n');
fprintf(fid, 'if total > 0\\n');
fprintf(fid, '    tasa_exito = stats(1) / total;\\n');
fprintf(fid, '    tasa_slow = stats(3) / total;\\n');
fprintf(fid, 'else\\n');
fprintf(fid, '    tasa_exito = 0;\\n');
fprintf(fid, '    tasa_slow = 0;\\n');
fprintf(fid, 'end\\n');
fprintf(fid, '\\n');
fprintf(fid, 'stats_salida = [tasa_exito; tasa_slow; stats(1)];\\n');
fclose(fid);

fprintf('\\n? Funciones creadas en archivos .m\\n');
fprintf('\\nAhora copia el contenido de cada archivo en su bloque correspondiente.\\n');