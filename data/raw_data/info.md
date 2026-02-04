# raw_data
Aquí se encuentras las capturas de datos realizadas al sistema real.
Se tomaron muestras automáticas de 90 días de duración, con una resolución de 60 segundos.

# Archivos
- icecast_am_listeners_90d_60s_20260202_2103.csv: Oyentes de /am (128kbps)
- icecast_am_slow_90d_60s_20260202_2104.csv: Slow Listeners para /am
- icecast_fm_listeners_90d_60s_20260202_2103: Oyentes de /fm (128kbps)
- icecast_fm_slow_90d_60s_2026022_2104.csv: Slow Listeners para /fm

# Toma de datos
La extracción de datos se automatizó mediante un script de python debido 
a una limitación de exportación de base de datos de serie de tiempos 
de Grafana y su conector Prometheus.