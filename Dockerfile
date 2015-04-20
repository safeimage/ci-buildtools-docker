FROM intermediate_app_image

RUN locale-gen en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

CMD ["/bin/sh", "-l"]
