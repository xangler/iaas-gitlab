from registry.host.com:5000/busybox

WORKDIR "/pdemo"
RUN mkdir -p /pdemo
COPY demo.out /pdemo/demo.out
