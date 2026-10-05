#!/bin/bash
# Confere, de fora do servidor, se o painel responde, e avisa no Telegram quando cai
# e quando volta. O estado fica em estado.txt ("ok", ou "fora <desde> <último aviso>"),
# gravado por commit só quando muda. Um commit a cada 40 dias mantém o agendamento vivo:
# o GitHub desliga agendamentos de repositório parado há 60 dias.
set -u
agora=$(date +%s)
avisar() { curl -s -m 15 -o /dev/null "https://api.telegram.org/bot$TOKEN/sendMessage" \
  --data-urlencode "chat_id=$CHAT" --data-urlencode "text=$1"; }

ok=0
for i in 1 2 3; do curl -fsS -m 20 -o /dev/null "$URL" && { ok=1; break; }; sleep 20; done

read -r situacao desde aviso < estado.txt || true
situacao=${situacao:-ok}
atual="$(cat estado.txt)"; novo="$atual"
if [ "$ok" = 1 ]; then
  [ "$situacao" = fora ] && avisar "✅ Vigia externo: o painel voltou a responder pela internet (ficou fora $(( (agora - desde) / 60 )) min)."
  novo=ok
elif [ "$situacao" != fora ]; then
  avisar "🔴 Vigia externo: o painel da Autly NÃO responde pela internet. O SDR da Astro e o atendimento da S Vistorias estão fora do ar. Se não chegou aviso do vigia interno, o servidor inteiro caiu."
  novo="fora $agora $agora"
elif [ $((agora - aviso)) -gt 10800 ]; then
  avisar "🔴 Vigia externo: o painel continua fora do ar (há $(( (agora - desde) / 60 )) min)."
  novo="fora $desde $agora"
fi

ultimo=$(git log -1 --format=%ct)
if [ "$novo" != "$atual" ] || [ $((agora - ultimo)) -gt 3456000 ]; then
  echo "$novo" > estado.txt
  git config user.name vigia && git config user.email vigia@users.noreply.github.com
  git commit -qam "estado: $novo" --allow-empty && git push -q
fi
