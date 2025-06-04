# Dockerfile do backend (ajustado para porta 3000)

FROM python:3.11-slim

# Instala dependências
COPY requirements.txt /src/requirements.txt
RUN pip install --no-cache-dir -r /src/requirements.txt

# Copia a aplicação
COPY ./app /src/app

WORKDIR /src

# Porta que será exposta (ajustada para 3000)
EXPOSE 3000

# Comando padrão agora utiliza a porta 3000 (compatível com seu Service do Kubernetes)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "3000", "--reload"]