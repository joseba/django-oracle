FROM python:2

ENV GUNICORN_VERSION=19.6.0
ENV DJANGO_VERSION=1.9.8
ENV PYTZ_VERSION=2016.6.1


# install base software 
RUN apt-get update && apt-get install -y \
  alien \
  nginx \
  libaio1 \
  vim

# install oracle software
COPY client.rpm /tmp/
COPY client-sdk.rpm /tmp/
RUN alien -i /tmp/client.rpm /tmp/client-sdk.rpm

# setup all the configfiles
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
COPY nginx.conf /etc/nginx/sites-available/default
COPY supervisord.conf /etc/supervisor/
RUN mkdir -p /etc/gunicorn
COPY gunicorn.conf /etc/gunicorn/
RUN mkdir /var/log/supervisor

# create directory which can be a place for generated static content
RUN mkdir -p /usr/django/static
RUN mkdir -p /usr/django/media

# create directory for application source code
# volume can be used for live-reload during development
RUN mkdir -p /usr/django/app
VOLUME /usr/django/app

# install python packages
#RUN pip install gunicorn==$GUNICORN_VERSION
#RUN pip install django==$DJANGO_VERSION
#RUN pip install pytz==$PYTZ_VERSION
RUN pip install supervisor
RUN pip install gunicorn
RUN pip install django
RUN pip install pytz
RUN pip install cx_Oracle

# run start.sh on container start
#COPY start.sh /usr/django/
#WORKDIR /usr/django
#CMD bash start.sh

EXPOSE 8000
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
