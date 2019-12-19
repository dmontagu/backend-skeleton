FROM example-org/app-base:latest

COPY --chown=worker:worker ./container-scripts/tests-start.sh /tests-start.sh
RUN chmod +x /tests-start.sh

CMD ["bash", "-c", "while true; do sleep 1; done"]
