FROM python:2

# install base software 
RUN apt-get update && apt-get install -y \
  alien \
  nginx \
  lsof \
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
COPY gunicorn.conf /etc/gunicorn/

# create directories
RUN mkdir -p /usr/django/static
RUN mkdir -p /usr/django/media
RUN mkdir -p /usr/django/app
VOLUME /usr/django/app
VOLUME /usr/django/static
VOLUME /usr/django/media

# install python packages
RUN pip install supervisor
RUN pip install gunicorn
RUN pip install django
RUN pip install pytz
RUN pip install cx_Oracle
RUN pip install djangorestframework
RUN pip install markdown       
RUN pip install django-filter
RUN pip install httpie
RUN pip install coreapi
RUN pip install coreapi-cli
RUN pip install --upgrade setuptools
RUN pip install django-excel
RUN pip install pyexcel-xls
RUN pip install requests_ntlm
RUN pip install openpyxl

EXPOSE 8000
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
