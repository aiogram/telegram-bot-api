# Example

By default [tdlib/telegram-bot-api](https://github.com/tdlib/telegram-bot-api) 
doesn't provide possibility to download files from API (without local-mode) 
so that's meat you will need to expose files somehow differently, for example by nginx.

In this example used docker-compose configuration with running 2 containers:
 - [aiogram/telegram-bot-api](https://hub.docker.com/r/aiogram/telegram-bot-api)
 - [nginx](https://hub.docker.com/_/nginx)

This example is recommended only for local development but in production you can use it only by your own risk.
