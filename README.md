# Vigia externo

Agendamento que confere, de fora do servidor, se o painel responde, e avisa no Telegram
quando ele cai e quando volta. Roda a cada 5 minutos pelo GitHub Actions.

O endereço conferido e os dados do Telegram ficam nos segredos do repositório
(`URL_PAINEL`, `TELEGRAM_TOKEN`, `TELEGRAM_CHAT_ID`). Para testar na hora: aba Actions,
"Vigia externo", "Run workflow".
