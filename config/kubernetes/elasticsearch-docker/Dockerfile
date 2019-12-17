FROM elasticsearch:1.7

RUN addgroup --gid 1000 --system appgroup && \
    adduser --uid 1000 --system appuser --ingroup appgroup

USER elasticsearch
USER 105

CMD ["elasticsearch"]

