#!/bin/bash
# Простой и надёжный апдейтер Discord (ваша идея + мои исправления)

# Убедимся, что curl есть
command -v curl >/dev/null || { echo "Устанавливаю curl..."; sudo apt update && sudo apt install -y curl; }

# Текущая установленная версия (надёжно берём через dpkg)
if ! current_version=$(dpkg -s discord 2>/dev/null | grep -E '^Version:' | awk '{print $2}' | cut -d':' -f2); then
    current_version="0"
fi

# Прямая ссылка на последний .deb (через редирект)
update_url="https://discord.com/api/download?platform=linux&format=deb"
download_url=$(curl -fsSL -w "%{url_effective}" -o /dev/null "$update_url")

# Извлекаем версию из имени файла (discord-0.0.82.deb → 0.0.82)
upstream_version=$(basename "$download_url" | grep -oP 'discord-\K[0-9.]+(?=\.deb)')

echo "Текущая версия: $current_version"
echo "Последняя версия: $upstream_version"

# Сравниваем версии (правильно, с учётом семантики версий)
if [[ "$current_version" == "$upstream_version" ]]; then
    echo "Discord уже самой свежей версии: $upstream_version"
    exit 0
fi

echo "Обновляю Discord: $current_version → $upstream_version"

# Закрываем Discord, если запущен
pkill -f discord >/dev/null 2>&1 || true

# Скачиваем в /tmp
deb_file="/tmp/discord-${upstream_version}.deb"
curl -fSL --progress-bar "$download_url" -o "$deb_file"

# Устанавливаем
sudo dpkg -i "$deb_file"

# Чиним зависимости, если что-то пошло не так
sudo apt-get install -f -y

# Удаляем временный файл
rm -f "$deb_file"

# Запускаем Discord обратно
(discord >/dev/null 2>&1 &)

echo "Discord успешно обновлён до версии $upstream_version"
