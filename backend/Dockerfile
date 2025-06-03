# Dockerfile do backend

FROM python:3.11-slim

# Instala dependências (ajuste requirements.txt conforme necessário)
COPY requirements.txt /src/requirements.txt
RUN pip install --no-cache-dir -r /src/requirements.txt

# Copia a aplicação
COPY ./app /src/app

WORKDIR /src

# Porta que será exposta
EXPOSE 8000

# Comando padrão (pode ser sobrescrito com docker run ...)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
