FROM python:3.8.3-slim-buster

RUN apt-get update \
    && apt-get -y install curl build-essential libssl-dev \
    && apt-get clean \
    && pip install --upgrade pip

# Prepare environment
RUN mkdir /freqtrade
WORKDIR /freqtrade

# Install TA-lib
COPY build_helpers/* /tmp/
RUN cd /tmp && /tmp/install_ta-lib.sh && rm -r /tmp/*ta-lib*

ENV LD_LIBRARY_PATH /usr/local/lib

# Install dependencies
COPY requirements.txt requirements-common.txt requirements-hyperopt.txt /freqtrade/
RUN pip install numpy --no-cache-dir \
  && pip install -r requirements-hyperopt.txt --no-cache-dir

# Install and execute
COPY . /freqtrade/
RUN pip install -e . --no-cache-dir

ENV LOGFILE syslog
ENV DBURL sqlite:////freqtrade/user_data/tradesv3.sqlite
ENV CONFIG /freqtrade/user_data/config.json
ENV STRATEGY Simple


# ENTRYPOINT ["freqtrade"]
# Default to trade mode
WORKDIR /freqtrade
CMD freqtrade trade --logfile $LOGFILE --db-url $DBURL -c $CONFIG -s $STRATEGY
