FROM example-org/app-base:latest

COPY --chown=worker:worker \
  ./container-scripts/gunicorn_conf.py \
  ./container-scripts/start.sh \
  ./container-scripts/start-dev.sh \
  ./container-scripts/start-reload.sh \
  /
RUN chmod +x /start.sh && chmod +x /start-dev.sh && chmod +x /start-reload.sh

EXPOSE 80
CMD ["/start.sh"]
