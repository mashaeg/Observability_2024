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


## Docker debug
