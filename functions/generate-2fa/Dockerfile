# Image Python légère
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY handler.py ./

# Installation de fwatchdog
ADD https://github.com/openfaas/classic-watchdog/releases/download/0.3.3/fwatchdog-amd64 /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

ENV fprocess="python handler.py"
EXPOSE 8080
CMD ["fwatchdog"]