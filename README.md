# Launcher in Docker
Команды для работы с GravitLauncher в Docker:
- `docker compose up -d --build` установить/обновить лаунчсервер
- `docker compose up -d` обновить настройки в docker-compose.yml без пересборки
- `docker compose attach gravitlauncher` подключится к консоли лаунчсервера (**вы не будете видеть предыдущие логи**)
- `docker compose logs gravitlauncher` посмотреть логи лаунчсервера
- `docker compose stop` остановить лаунчсервер
- `docker compose start` запустить лаунчсервер
- `docker compose down` удалить контейнеры (данные updates, конфигурация сохранятся в volume)
- `docker compose down -v` полностью удалить лаунчсервер вместе с данными
- `docker compose ps` просмотреть статус
- `docker compose stats` посмотреть общее потребление лаунчсервера (CPU/Memory/Disk)
- `docker compose exec gravitlauncher /app/install_launchserver_module.sh MODULE_NAME` установить модуль для лаунчсервера
- `docker compose exec gravitlauncher /app/install_launcher_module.sh MODULE_NAME` установить модуль для лаунчера
- `docker compose exec -it gravitlauncher /bin/bash` войти в консоль bash
- `docker compose cp gravitlauncher:SRCPATH DSTPATH` скопировать файл SRCPATH из контейнера в DSTPATH (на хост машину)
- `docker compose cp SRCPATH gravitlauncher:DSTPATH` скопировать файл SRCPATH в DSTPATH в контейнере (из хост машины)


## Структура контейнера

Контейнер лаунчсервера содержит в себе jdk 21, vim/nano, osslsigncode и javafx. Вы можете использовать все стандартные команды если вдруг они вам нужны. Процесс лаунчсервера внутри контейнера всегда имеет PID 1

При обновлении лаунчсервера модули установленные скриптами install_launchserver_module.sh и install_launcher_module.sh обновятся автоматически. Модуль рантайма так же обновится автоматически, но папка runtime - нет.

Файлы контейнера находятся в /app, а рабочая директория (workdir) в /app/data


## Обновление лаунчсервера

- Убедитиесь что в `setup-docker.sh` указана нужная вам ветка/версия
- Выполните команду `docker compose up -d --build`
- Если вы не меняли папку рантайма вы можете удалить папку `/app/data/runtime` и перезапустить лаунчсервер что бы она обновилась

## Настройка nginx

По умолчанию лаунчсервер с настроенным nginx доступен по адресу `http://localhost:17549`. Если у вас есть сайт на этой машине с настроенным nginx используйте следующий конфиг (конфиг предоставлен для http, при необходимости добавьте туда параметры для ssl):


```nginx
upstream gravitlauncher {
    server 127.0.0.1:17549;
}

server {
    listen 80;
    server launcher.mydomain.ru;

    charset utf-8;
    #access_log  /var/log/nginx/launcher.access.log;
    #error_log  /var/log/nginx/launcher.error.log notice;

    location / {
        proxy_pass http://gravitlauncher;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

```
