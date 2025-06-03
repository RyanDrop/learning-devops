# Dockerfile do frontend

FROM node:20-alpine

WORKDIR /src

# Copia apenas package.json e package-lock.json primeiro para instalar dependências
COPY package*.json ./

RUN npm install

# Copia o restante da aplicação
COPY ./app ./app

# Expõe a porta padrão do frontend (ajuste conforme necessário)
EXPOSE 3000

# Comando padrão (pode ser sobrescrito com docker run ...)
CMD ["npm", "run", "dev"]