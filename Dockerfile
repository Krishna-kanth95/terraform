FROM amazon/aws-lambda-python:3.9

WORKDIR /tmp/lambda

RUN apt-get update \
    && apt-get install -y zip \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
COPY lambda_ec2.py .

RUN pip install -r requirements.txt -t .

# RUN python -c "import site; print(site.getsitepackages())" > site_packages.txt
# RUN cp -r $(cat site_packages.txt)/requests .
# RUN cp -r /usr/local/lib/python3.10/site-packages/requests/* .

RUN rm requirements.txt

RUN zip -r9 /tmp/python.zip .


# FROM ubuntu

# RUN ulimit -n 1024 && \
#     apt -y update && \
#     apt -y upgrade && \
#     apt -y install \
#         python3-pip \\
#         python3-venv \
#         zip \
#         && \
#     apt clean all && \
#     rm -rf /var/cache/apt && \
#     pip3 install virtualenv

# RUN mkdir -p venv

# COPY ./docker_install.sh /venv/
# COPY ./requirements.txt /venv/

# RUN chmod +x /venv/docker_install.sh

# CMD ["/bin/bash", "/venv/docker_install.sh"]
