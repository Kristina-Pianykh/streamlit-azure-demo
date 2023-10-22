FROM python:3.9 as build
WORKDIR /build

RUN curl -sSL https://install.python-poetry.org | python -
ENV PATH /root/.local/bin:$PATH
COPY pyproject.toml poetry.lock ./
RUN poetry export -f requirements.txt --output requirements.txt --without-hashes --without=dev

FROM python:3.9-slim

WORKDIR /app
COPY --from=build /build/requirements.txt ./

RUN pip3 install -r requirements.txt
COPY ./src/app .

EXPOSE 80

HEALTHCHECK CMD curl --fail http://localhost:80/_stcore/health

ENTRYPOINT ["streamlit", "run", "streamlit_app.py", "--server.port=80", "--server.address=0.0.0.0"]
