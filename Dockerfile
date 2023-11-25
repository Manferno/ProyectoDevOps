FROM node:19.2-alpine3.16 as build

# cd app
WORKDIR  /app

# Dest /app
COPY package.json ./

# Instalar las dependencias
RUN npm install

# Dest /app
COPY . .


# Eliminar archivos y directorios no necesarios en PROD
RUN rm -rf node_modules

# Unicamente las dependencias de prod
RUN npm install --prod


# Configura la imagen nginx para servir la app react
FROM nginx:latest

# Copia los archivos generados en la etapa de construcción al directorio de la imagen de nginx
COPY --from=build /app/build /usr/share/nginx/html

# Exponer el puerto 80 para el servidor nginx
EXPOSE 80

# Comando para arrancar nginx cuando se ejecute el contenedor
CMD ["nginx", "-g", "daemon off;"]

# Utiliza la imagen oficial de MongoDB
FROM mongo:latest

# Establece el directorio de trabajo
WORKDIR /usr/src/app

# Copia el archivo JSON de datos a la carpeta del contenedor
COPY ./data/package.json .

# Comando para importar los datos al iniciar el contenedor
CMD mongoimport --host mongodb --db personajes --collection personajes --type json --file package.json --jsonArray
