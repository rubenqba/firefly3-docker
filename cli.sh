docker service create --name ff3 \
    --network ff3_ff3 --network proxy \
    -p 8081:8080 \
    --secret ff3_db_user_new_password --secret ff3_encryption_key --secret ff3_crontab_token --secret ff3_gmail_password \
    --env DB_CONNECTION=mysql  --env DB_HOST=db  --env DB_PORT=3306  --env DB_DATABASE=ff3 --env DB_USERNAME=ff3_db_user --env DB_PASSWORD_FILE=/run/secrets/ff3_db_user_new_password \
    --env APP_URL=https://ff3.cloud.bresler.homes  \
    --env TRUSTED_PROXIES="**" \
    --env SITE_OWNER=ruben1981@gmail.com \
    --env APP_KEY_FILE=/run/secrets/ff3_encryption_key \
    --env STATIC_CRON_TOKEN_FILE=/run/secrets/ff3_crontab_token \
    --env MAIL_MAILER=smtp \
    --env MAIL_HOST=smtp.gmail.com \
    --env MAIL_PORT=587 \
    --env MAIL_FROM=ruben1981@gmail.com \
    --env MAIL_USERNAME=ruben1981@gmail.com \
    --env MAIL_PASSWORD_FILE=/run/secrets/ff3_gmail_password \
    --env MAIL_ENCRYPTION=tls \
    --env ENABLE_EXTERNAL_RATES="true" \
    fireflyiii-core:version-6.2.9