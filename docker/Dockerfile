FROM node:14-buster-slim

ENV FLEI_ROOT_PATH=/opt/flei

COPY src "${FLEI_ROOT_PATH}"

# yarn install in a separate stage to ensure there is no
# yarn cache in home, or some other stuff adding to
# the image size
RUN yarn install --frozen-lockfile --cwd "${FLEI_ROOT_PATH}"

# Stage 2
FROM node:14-buster-slim

ENV FLEI_ROOT_PATH=/opt/flei
ENV FLEI_PROJECT_ROOT=/opt/flei-project-root

# we need libgssapi-krb5-2 for nodegit to work
# ca-certificates are required to do successful https calls
RUN apt-get update \
    && apt-get install -y libgssapi-krb5-2 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/flei/node_modules/.bin:${PATH}"

COPY --from=0 "${FLEI_ROOT_PATH}" ${FLEI_ROOT_PATH}

ENTRYPOINT ["/opt/flei/entrypoint"]
CMD ["flei", "help"]
