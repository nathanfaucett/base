FROM alpine:3.17

RUN apk --no-cache add postgresql15-client

WORKDIR /app
COPY . .

CMD [ "/app/init.sh" ]
ENTRYPOINT [ "/app/init.sh" ]