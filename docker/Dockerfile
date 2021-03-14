FROM bash:latest

ENV FLEI_ROOT_PATH=/opt/flei
ENV FLEI_PROJECT_ROOT=/opt/flei-project-root

COPY src "${FLEI_ROOT_PATH}"

ENTRYPOINT ["/opt/flei/entrypoint"]
CMD ["flei", "help"]