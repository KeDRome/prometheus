FROM debian:latest

RUN mkdir -p /etc/prometheus; mkdir -p /var/lib/prometheus; mkdir -p /opt/prometheus
ADD ./prometheus.tar.gz /opt/prometheus/
ADD ./prometheus.service /etc/systemd/system/prometheus.service

RUN cp /opt/prometheus/{prometheus,promtool} /usr/local/bin/ && \
    cp -r /opt/prometheus/{console_libraries,consoles,prometheus.yml} /etc/prometheus

RUN useradd --no-create-home --shell /bin/false prometheus
RUN chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus && \
    chown prometheus:prometheus /usr/local/bin/{prometheus,promtool}

RUN systemctl daemon-reload && systemctl enable --now prometheus
CMD [ "watch systemctl status prometheus" ]