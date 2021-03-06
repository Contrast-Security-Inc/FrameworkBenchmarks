FROM python:3.6.6-stretch

ADD ./ /flask

WORKDIR /flask

RUN pip3 install -r /flask/requirements.txt

EXPOSE 8080

# Start Contrast Additions
COPY contrast-agent.tar.gz contrast-agent.tar.gz
COPY contrast_security.yaml /etc/contrast/contrast_security.yaml

ENV CONTRAST__ASSESS__ENABLE=false
ENV CONTRAST__PROTECT__ENABLE=false

run pip3 install ./contrast-agent.tar.gz
# End Contrast Additions

# Uses alternate gunicorn config
CMD gunicorn app-contrast:app -c gunicorn_conf-contrast.py
