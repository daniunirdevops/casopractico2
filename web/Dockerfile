# define la imagen base del contenedor, que es una imagen de Nginx construida sobre
# Apline Linux, que es muy ligera 
# FROM nginx:stable-alpine
FROM docker.io/library/nginx:stable-alpine

# instalamos herramientas adicionales en el contenedor mediante el gestor de paquetes
# de Alpine:
  # - openssl: para generar certificados de seguridad
  # - apache2-utils: contiene la herramienta htpasswd, necesaria para crear contraseñas
RUN apk add --no-cache openssl apache2-utils

# creamos el certificado autofirmado para habilitar HTTPS
# previmamente creamos la carpeta para los certificados, usando openssl para generar una 
# clave privada y un certificado público con una duración de 365 dias.
RUN mkdir -p /etc/nginx/certs && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /etc/nginx/certs/server.key \
      -out /etc/nginx/certs/server.crt \
      -subj "/C=ES/ST=Madrid/L=Madrid/O=UNIR/OU=DevOps/CN=cp2.unir.local"

# configuración de la autenticación por usuario y contraseña
      # crea un archi
RUN htpasswd -cb /etc/nginx/.htpasswd alumno unir2026

# reemplaza la configuración de Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# copiamos los archivos de la carpeta pomodoro (*.html, *.css y *.js) a la carpeta donde Nginx 
# busca las pàginas web
COPY pomodoro /usr/share/nginx/html

# puerto que utiliza el contenedor, escuchará por el puerto 443, que es el puerto estándar para 
# conexiones seguras HTTPS
EXPOSE 443

# arranca el servidor Nginx en primer plano
CMD ["nginx", "-g", "daemon off;"]