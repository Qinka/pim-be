# pim-server
FROM debian:latest
MAINTAINER qinka
RUN apt update && apt install -y libgmp10 python3 python
ADD bin /usr/bin
ENTRYPOINT ["pim-server"]
EXPOSE 3000
