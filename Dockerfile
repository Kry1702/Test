# Version 0.0.2
FROM debian:11
LABEL maintainer="email@kry.cn"

WORKDIR /root

RUN sed  -i "s#http://deb.debian.org/#http://mirrors.tuna.tsinghua.edu.cn/#g" /etc/apt/sources.list && \
    sed  -i "s#http://security.debian.org/#http://mirrors.tuna.tsinghua.edu.cn/#g" /etc/apt/sources.list && \
    apt-get update -y && \
    apt-get install -y sudo vim wget curl cmake gcc g++ git build-essential gdb && \
    apt-get autoremove -y && apt-get autoclean -y && apt-get clean -y

# python3
RUN apt-get install -y python3 python3-dev python3-pip && \
    python3 -m pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple && \
    python3 -m pip install ipython jupyter jupyterlab ipywidgets qtconsole -i https://pypi.tuna.tsinghua.edu.cn/simple && \
    python3 -m pip cache purge

# C
RUN python3 -m pip install jupyter-c-kernel -i https://pypi.tuna.tsinghua.edu.cn/simple && \
    install_c_kernel


# C++
RUN cd /usr/local && \
    wget https://raw.githubusercontent.com/root-project/cling/master/tools/packaging/cpt.py && \
    chmod +x cpt.py && \
    /bin/bash -c '/bin/echo -e "yes" | ./cpt.py --check-requirements && ./cpt.py --create-dev-env release --with-workdir=./cling-build/'; exit 0

# 安装Cling Kernel
ENV PATH="${PATH}:/usr/local/cling-build/builddir/bin"
RUN cd /usr/local/cling-build/cling-src/tools/cling/tools/Jupyter/kernel && \
    python3 -m pip install -e . -i https://pypi.tuna.tsinghua.edu.cn/simple && \
    jupyter-kernelspec install cling-cpp17 && \
    jupyter-kernelspec install cling-cpp1z && \
    jupyter-kernelspec install cling-cpp14 && \
    jupyter-kernelspec install cling-cpp11
WORKDIR /root

# Go #无法获取
#RUN wget https://dl.google.com/go/go1.17.6.linux-arm64.tar.gz && \
#    rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.6.linux-arm64.tar.gz && \
#    rm -f go1.17.6.linux-arm64.tar.gz
#ENV PATH="${PATH}:/usr/local/go/bin"

# Go Jupyter
# RUN go env -w GOPROXY=https://goproxy.cn,direct  # Depends on the specific situation
#RUN env GO111MODULE=on go get github.com/gopherdata/gophernotes && \
#    mkdir -p ~/.local/share/jupyter/kernels/gophernotes && \
#    cd /root/.local/share/jupyter/kernels/gophernotes && \
#    cp "$(go env GOPATH)"/pkg/mod/github.com/gopherdata/gophernotes@v0.7.4/kernel/*  "." && \
#    chmod +w ./kernel.json  # in case copied kernel.json has no write permission && \
#    sed "s|gophernotes|$(go env GOPATH)/bin/gophernotes|" < kernel.json.in > kernel.json
#WORKDIR /root

# Java  #外网无法拉取资源
#RUN apt-get install -y default-jdk && \
# Java Jupyter
#    git clone https://gh-proxy.com/https://github.com/SpencerPark/IJava.git && \
#    cd /root/IJava && \
#    ./gradlew installKernel
#WORKDIR /root

# Assembly
RUN python3 -m pip install emu86 && \
    python3 -m kernels.intel.install

# Bash
RUN python3 -m pip install bash_kernel && \
    python3 -m bash_kernel.install

# NodeJS
#RUN apt-get install -y nodejs npm && \
#    npm cache clean -f && \
#    npm install -g n && \
#    n stable
#ENV PATH="${PATH}"
#RUN npm install -g npm && \
# NodeJs Jupyter
#    npm install -g --unsafe-perm ijavascript && \
#    ijsinstall --install=global

# R
#RUN apt-get install -y r-base r-base-dev && \
#    Rscript -e 'install.packages("IRkernel")' && \
#    Rscript -e 'IRkernel::installspec()' && \
# Jupyter plugin(for RStudio’s shortcuts: https://github.com/IRkernel/IRkernel)
# need node.js and npm
#    jupyter labextension install @techrah/text-shortcuts

# php
# https://github.com/Rabrennie/jupyter-php-kernel
#RUN apt-get install -y php php-dev php-common php-zmq && \
#    curl -sS https://getcomposer.org/installer -o composer-setup.php && \
#    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
#ENV PATH="${PATH}:/root/.config/composer/vendor/bin"
#RUN composer global require rabrennie/jupyter-php-kernel && \
#    jupyter-php-kernel --install && \
#    composer clearcache

# Julia
#RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.7/julia-1.7.0-linux-aarch64.tar.gz && \
#    rm -rf /usr/local/julia && tar -C /usr/local -xzf julia-1.7.0-linux-aarch64.tar.gz && \
#    mv /usr/local/julia-1.7.0/ /usr/local/julia/ && \
#    rm -f julia-1.7.0-linux-aarch64.tar.gz
#ENV PATH="${PATH}:/usr/local/julia/bin"
# Julia Jupyter
#RUN julia -e 'using Pkg; Pkg.add("IJulia")'

# lua
# https://github.com/guysv/ilua
RUN apt-get install -y lua5.3 && \
   python3 -m pip install ilua -i  https://pypi.tuna.tsinghua.edu.cn/simple

# Ruby
#RUN apt-get install -y libtool libffi-dev ruby ruby-dev make && \
#    gem update --system && \
#    gem install rake && \
#    gem install iruby && \
#    iruby register --force

# clean cache
RUN apt-get autoremove -y && apt-get autoclean -y && apt-get clean -y

VOLUME /home/playground
WORKDIR /home/playground

EXPOSE 8888

ENTRYPOINT [ "jupyter", "lab", "--allow-root", "--no-browser", "--ip", "0.0.0.0", "--port", "8888" ]

#jupyter lab --allow-root --no-browser --ip 0.0.0.0 --port 8888
