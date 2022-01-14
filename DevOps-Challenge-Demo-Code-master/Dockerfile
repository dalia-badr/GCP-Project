FROM python:3.7
EXPOSE 8888
RUN mkdir -p /usr/src/app
COPY . /usr/src/app
WORKDIR /usr/src/app
RUN pip install -r requirements.txt


ENTRYPOINT ["python3", "hello.py"]
