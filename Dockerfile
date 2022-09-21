FROM centos:8 AS builder
WORKDIR /src
RUN groupadd -g 1001 clamav
RUN useradd -g clamav -u 1001 clamav 
RUN yum install -y epel-release && \
    yum groupinstall "Development Tools" -y && \
    yum install 'dnf-command(config-manager)' -y && \
    yum config-manager --set-enabled PowerTools && \
    yum update -y && \
    yum install -y openssl openssl-devel libcurl-devel zlib-devel libpng-devel libxml2-devel \
        http://mirror.centos.org/centos/8/PowerTools/x86_64/os/Packages/json-c-devel-0.13.1-0.2.el8.x86_64.rpm \
        bzip2-devel pcre2-devel ncurses-devel 
COPY clamav-0.103.5.tar.gz /src
RUN tar zxvf clamav-0.103.5.tar.gz && \
    cd clamav-0.103.5 && \
    ./configure && \
    make 

FROM centos:8
RUN groupadd -g 1001 clamav && \
    useradd -g clamav -u 1001 clamav 
RUN  yum install -y epel-release && \
     yum install -y make libprelude gcc gcc-c++ openssl-devel http://mirror.centos.org/centos/8/PowerTools/x86_64/os/Packages/json-c-devel-0.13.1-0.2.el8.x86_64.rpm libxml2-devel bzip2-devel libcurl-devel ncurses-devel
COPY --from=builder /src/clamav-0.103.5 /src/clamav-0.103.5
RUN cd /src/clamav-0.103.5 && \
    make install
RUN mkdir -p /usr/local/etc/clamav /usr/local/share/clamav /var/log/clamav && \
    chown clamav:clamav -R /usr/local/etc/clamav /usr/local/share/clamav /var/log/clamav

COPY start-clamd.sh /usr/local/sbin/start-clamd.sh
COPY freshclam.sh /usr/local/sbin/freshclam.sh

CMD ["/usr/local/sbin/start-clamd.sh"] 
