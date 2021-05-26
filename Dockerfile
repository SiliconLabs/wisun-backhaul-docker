FROM alpine:3.13 AS builder
LABEL maintainer="Jérôme Pouiller <jerome.pouiller@silabs.com>"
RUN apk add build-base

WORKDIR /usr/src
COPY tunslip6-install.sh .
COPY tunslip6            ./tunslip6
RUN  ./tunslip6-install.sh

WORKDIR /usr/src
COPY ndppd-install.sh                          .
COPY ndppd-0001-Fixes-strerror_r-GNU-XSI.patch .
COPY ndppd-0002-fix-poll-header.patch          .
RUN  ./ndppd-install.sh

FROM alpine:3.13 AS runtime
RUN mkdir -p /run/radvd
RUN apk add --no-cache radvd
RUN apk add --no-cache ndisc6
RUN apk add --no-cache libstdc++
RUN apk add --no-cache tshark
RUN apk add --no-cache openocd
COPY --from=builder /usr/local /usr/local
COPY init-container.sh /init

ENTRYPOINT [ "/init" ]
CMD [ "auto" ]
