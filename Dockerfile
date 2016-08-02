FROM python:2

EXPOSE 8000

ENV GUNICORN_VERSION=19.6.0
ENV DJANGO_VERSION=1.9.8
ENV PYTZ_VERSION=2016.6.1


# install oracle & dependencies & utils
RUN apt-get update && apt-get install -y \
  alien \
  libaio1 \
  vim

COPY client.rpm /tmp/
COPY client-sdk.rpm /tmp/

RUN alien -i /tmp/client.rpm /tmp/client-sdk.rpm

# create directory which can be a place for generated static content
# volume can be used to serve these files with a webserver
RUN mkdir -p /var/www/static
VOLUME /var/www/static

# create directory for application source code
# volume can be used for live-reload during development
RUN mkdir -p /usr/django/app
VOLUME /usr/django/app

# add gunicorn config
RUN mkdir -p /etc/gunicorn
COPY gunicorn.conf /etc/gunicorn/

# install oracle client, gunicorn, django and pytz
RUN pip install gunicorn==$GUNICORN_VERSION
RUN pip install django==$DJANGO_VERSION
RUN pip install pytz==$PYTZ_VERSION
#RUN pip install gunicorn
#RUN pip install django
#RUN pip install pytz
#RUN pip install cx_Oracle

# run start.sh on container start
COPY start.sh /usr/django/
WORKDIR /usr/django
CMD bash start.sh
