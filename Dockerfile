FROM alpine:3.17

RUN apk add git && \
    apk add github-cli && \
    apk add --no-cache bash

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
