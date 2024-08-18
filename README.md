# Observability2025
# 1 ДЗ : Установка и настройка Prometheus, использование exporters

Установить и настроить Prometheus для мониторинга системы с использованием Docker. Собрать метрики со всех компонентов системы, включая CMS, Nginx, PHP-FPM, MySQL, а также доступность сервиса с помощью blackbox exporter.

## Структура проекта

- `docker-compose.yml` — основной файл для запуска всех сервисов.
- `GAP-1/` — директория с конфигурациями для Prometheus и Alertmanager.
- `README.md` — документация по проекту.

## Метрики

Система собирает метрики с:
- Виртуальной машины (используя Node Exporter).
- Доступности CMS (используя Blackbox Exporter).
- Nginx, PHP-FPM, и MySQL.

## Использованные технологии

- Docker 27.1.2, Docker Compose V2
- Prometheus
- Exporters (Node, Blackbox)
- MySQL
- Nginx
- PHP-FPM

## Install Wordpress
http://localhost:8080/wp-admin/install.php

## Pro, reload
curl -X POST http://localhost:9090/-/reload

## Docker debug
docker compose down
docker compose up -d

## Manual run
docker run --rm -it   --name mysql_exporter   --network maria_monitoring   -e DATA_SOURCE_NAME="root:root_password@tcp(db:3306)/"   prom/mysqld-exporter:v0.12.1

## #what ip has container cms
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cms

## push to git
git push --force origin domz1

## install lab: Create VM and install docker. Clone Repo.

## Debug: Fix rights (The user 472 corresponds to the Grafana user inside the container.)

sudo chown -R www-data:www-data /home/maria/wp_data
sudo chown -R 999:root /home/maria/db_data
sudo chown -R 472:0 ./grafana_data