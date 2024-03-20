# Firefly 3 stack

Servicios de metricas y monitoreo de aplicaciones

## Getting started

Crear la estructura de directorios donde se almacenarán los datos del stack. Este directorio es el que se utilizará para definir la variable **FF3_STACK_DIR**. 

```sh
mkdir -p /usr/srv/firefly3/{db,uploads}
```

Definir las contraseñas de MariaDB para el usuario `root` y el usuario de la aplicación `ff3_db_user`. Para la generación de las contraseñas se utiliza la applicación `openssl`, pero se puede ustilizar cualquier otro utilitario para el mismo propósito. Aunque la BD no quedará expuesta a conexiones externas, se recomienda generar una contraseña segura de al menos 16 bytes para garantizar un nivel de seguridad adecuado.

```bash
openssl rand -base64 16 | docker secret create ff3_db_root_password -
openssl rand -base64 16 | docker secret create ff3_db_user_password -
```

Para el correcto funcionamiento de Firefly 3 se necesita especificar una key para el cifrado de las sessiones y para los trabajos de Crontab. A continuación como crearlos. Tenga en cuenta que estas configuraciones requieren que el secreto sea una cadena de exactamente 32 caracteres. 

```bash
openssl rand -hex 16 | docker secret create ff3_encryption_key -
openssl rand -hex 16 | docker secret create ff3_crontab_token -
```

### Inicialización de la BD (opcional)

Si se cuenta con un backup de la BD se debe crear una configuración con el archivo `*.sql` y configurarlo en el directorio `/docker-entrypoint-initdb.d/01-initdb.sql` tal como se especifica en la [documentación de MariaDB](https://hub.docker.com/_/mariadb).

Se necesita crear una configuración con el archivo de backup:

```bash
docker config create ff3_last_backup config/ff3_backup_20240319.sql
```

Luego se debe habilitar en el archivo [compose.yml](./compose.yml)

```yaml
...
configs:
  last_backup: 
    name: ${FF3_LAST_BACKUP_FILE:-ff3_last_backup}
    external: true
services:
  db:
    ...
    configs:
      - source: last_backup
        target: /docker-entrypoint-initdb.d/01-initdb.sql
        mode: 0600
```

Tenga en consideración que este archivo solo se tomará en cuenta si la BD se está inicializando por primera vez. Si es la primera vez o no requieres un archivo de inicialización puedes comentar las secciones pertinentes en el archivo `compose.yml` o simplemente crear un archivo en blanco. 

De igual forma considera usar `secrets` en vez de `configurations` para importar los datos de la BD teniendo en cuenta que en el backup puede existir información sensible que no se desee compartir con otros administradores del servicio Docker local.

### Deployment

Define las variables necesarias en el stack:

| Variable                           | Descripción                                                            | Valor por defecto      |
|:----|:---|:---:|
| **FF3_STACK_DIR**                  | Directorio de datos del stack (requerido)                              | `empty`                |
| **PROXY_NETWORK_NAME**             | Nombre de la red proxy para el LB                                      | `proxy`                |
| **FF3_MARIADB_ROOT_PASSWORD_NAME** | Nombre del secret con la contraseña del usuario `root` de MariaDB.     | `ff3_db_root_password` |
| **FF3_MARIADB_USER_PASSWORD_NAME** | Nombre del secret con la contraseña del usuario de la app para MariaDB | `ff3_db_user_password` |
| **FF3_LAST_BACKUP_FILE_NAME**      | Nombre del secret o configuración del archivo de inicio de la BD       | `ff3_last_backup`      |
| **FF3_FQDN**                       | Hostname del servicio en el proxy reverso                              | `empty`      |
| **FF3_DATABASE_NAME**              | Nombre de la BD                                                        | `ff3`      |
| **FF3_DATABASE_USER**              | Nombre del usuario con acceso a la BD.                                 | `ff3_db_user`      |
| **FF3_SITE_OWNER**                 | Email de contacto para mostrar mensajes de error a usuarios no admin   | `empty`      |
| **FF3_ENCRYPTION_KEY_NAME**        | Nombre del secret para encriptar datos de session                      | `ff3_encryption_key`      |
| **FF3_CRONTAB_TOKEN_NAME**         | Nombre del secret con el token de acceso para los trabajos de Crontab  | `ff3_crontab_token`      |
