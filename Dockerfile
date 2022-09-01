FROM debian:latest

# Подготовка каталогов перед установкой
#RUN apt update && apt install -y systemd
## Prometheus
RUN mkdir -p /etc/prometheus; mkdir -p /var/lib/prometheus; mkdir -p /opt/prometheus
## Alertmanager
RUN mkdir -p /etc/alertmanager; mkdir -p /var/lib/prometheus/alertmanager

# Архивы..
## Alertmanager
ADD ./archives/ /opt/prometheus/
## Prometheus
#ADD ./archives/ /opt/prometheus/
## Node_exporter
#ADD ./archives/node_exporter.tar.gz /opt/prometheus/

# Распаковка
## Alertmanager
RUN tar -xvf /opt/prometheus/alertmanager.tar.gz -C /opt/prometheus/
## Prometheus
RUN tar -xvf /opt/prometheus/prometheus.tar.gz -C /opt/prometheus/
## Node_exporter
RUN tar -xvf /opt/prometheus/node_exporter.tar.gz -C /opt/prometheus/


# Добавляем сервис для автозапуска 
## Prometheus
COPY ./services/prometheus.service /etc/systemd/system/prometheus.service
## Alertmanager
COPY ./services/alertmanager.service /etc/systemd/system/alertmanager.service
## Node_exporter
COPY ./services/node_exporter.service /etc/systemd/system/node_exporter.service

# Копируем исполняемые файлы и файлы конфигурации 
## Prometheus
RUN ls /opt/prometheus/ && cp /opt/prometheus/prometheus*/prometheus /usr/local/bin/ && \
    cp /opt/prometheus/prometheus*/promtool /usr/local/bin/ && \
    cp -r /opt/prometheus/prometheus*/console_libraries /etc/prometheus && \
    cp -r /opt/prometheus/prometheus*/consoles /etc/prometheus && \
    cp /opt/prometheus/prometheus*/prometheus.yml /etc/prometheus
## Alertmanager
RUN cp /opt/prometheus/alertmanager*/alertmanager /usr/local/bin/ && \
    cp /opt/prometheus/alertmanager*/amtool /usr/local/bin/ && \
    cp /opt/prometheus/alertmanager*/alertmanager.yml /etc/alertmanager
## Node_exporter
RUN cp /opt/prometheus/node_exporter*/node_exporter /usr/local/bin/

# Добавляем пользователей
## Prometheus    
RUN useradd --no-create-home --shell /bin/false prometheus && \
    chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus && \
    chown prometheus:prometheus /usr/local/bin/prometheus && \
    chown prometheus:prometheus /usr/local/bin/promtool
## Alertmanager
RUN useradd --no-create-home --shell /bin/false alertmanager && \
    chown -R alertmanager:alertmanager /etc/alertmanager /var/lib/prometheus/alertmanager && \
    chown alertmanager:alertmanager /usr/local/bin/alertmanager && \
    chown alertmanager:alertmanager /usr/local/bin/amtool
## Node_exporter
RUN useradd --no-create-home --shell /bin/false nodeusr && \
    chown -R nodeusr:nodeusr /usr/local/bin/node_exporter

#RUN apt update && apt install -y systemd
#RUN systemctl daemon-reload && systemctl enable --now prometheus
#RUN systemctl daemon-reload && systemctl enable --now alertmanager
#RUN systemctl daemon-reload && systemctl enable --now node_exporter
#CMD [ "watch", "systemctl", "is-active", "prometheus" ]
