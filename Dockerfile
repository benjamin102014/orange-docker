FROM python:3.10-slim

WORKDIR /app

# install dependencies and missing packages (libxcb-icccm4, libxcb-image0, libxcb-keysyms1, libxcb-render-util0) for Orange3
RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    novnc \
    fluxbox \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-render-util0 \
    libxcb-cursor0 \
    libxkbcommon-x11-0 \
    libx11-xcb1 \
    libegl1-mesa \ 
    procps \
    git \
    gcc \
    build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Upgrade pip and setuptools
RUN pip install --upgrade pip setuptools

# Clone and install Orange3 and its dependencies
RUN git clone https://github.com/biolab/orange3.git && \
    pip install PyQt6 PyQt6-WebEngine && \
    pip install -e orange3

ENV DISPLAY=:0
EXPOSE 6080

COPY init.sh init.sh
RUN chmod +x init.sh

RUN --mount=type=secret,id=noVNC_password \
    NOVNC_PASSWORD=$(cat /run/secrets/noVNC_password) && \
    mkdir -p ~/.vnc && \
    x11vnc -storepasswd ${NOVNC_PASSWORD} ~/.vnc/passwd

# run the application
ENTRYPOINT ["./init.sh"]