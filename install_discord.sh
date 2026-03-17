# 1. Скачать
wget --retry-connrefused -cO /tmp/discord.deb "https://discord.com/api/download/stable?platform=linux&format=deb"

# 2. Закрыть Discord
pkill discord

# 3. Установить
sudo dpkg -i /tmp/discord.deb
sudo apt-get install -f -y

# 4. Проверить версию
dpkg -s discord | grep Version

# 5. Удалить временный файл
rm /tmp/discord.deb
