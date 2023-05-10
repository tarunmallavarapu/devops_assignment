FROM ubuntu:latest

RUN apt-get update && apt-get install -y nginx python3 python3-pip

COPY requirements.txt /app/requirements.txt
RUN pip3 install -r /app/requirements.txt

RUN rm /etc/nginx/sites-enabled/default
COPY nginx.conf /etc/nginx/sites-enabled/

COPY app.py /app/app.py

EXPOSE 8080

CMD service nginx start && python3 /app/app.py