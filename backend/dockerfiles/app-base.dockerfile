FROM python:3.7 as build

ENV POETRY_VERSION=1.0.0 \
    POETRY_VIRTUALENVS_CREATE=false \
    PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONHASHSEED=random \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    PATH="/root/.poetry/bin/:${PATH}"
RUN pip install --upgrade pip

# Install Poetry
# See https://github.com/sdispater/poetry/issues/1301 for pros/cons of this approach
RUN curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | python

WORKDIR /app
COPY ./app/requirements.txt /app/
RUN pip install \
    --user \
    --no-warn-script-location \
    -r requirements.txt
COPY ./app /app
RUN poetry install --no-dev

FROM python:3.7-slim as output

RUN useradd -m worker \
 && mkdir /app \
 && chown -R worker:worker /app
USER worker
WORKDIR /app

ENV PYTHONPATH=/app \
    HOME=/home/worker \
    PATH="/home/worker/.local/bin:${PATH}"

COPY --from=build --chown=worker:worker /usr/local/lib/python3.7/site-packages /usr/local/lib/python3.7/site-packages
COPY --from=build --chown=worker:worker /root/.local /home/worker/.local
COPY --from=build --chown=worker:worker /app /app
