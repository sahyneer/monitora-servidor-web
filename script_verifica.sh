#!/bin/bash

. /monitora-servidor-web/.env

URL=$(hostname -I)

requisicaoHTTP=$(curl -Is $URL | head -n 1)

# Definição de cores para melhor visualização dos logs
fonteVermelho='\033[0;31m'
fonteVerde='\033[0;32m'
fonteSemCor='\033[0m' # reset de cor

formatacaoData=$(date "+%Y/%m/%d %H:%M:%S")

if [ "$requisicaoHTTP" ]; then
  printf "${fonteVerde}${formatacaoData} Servidor Online ($URL)${fonteSemCor}\n"
else
  printf "${fonteVermelho}${formatacaoData} Servidor Offline ($URL)${fonteSemCor}\n"
  # Envio da mensagem para o Discord e ocultacao de saida do curl para o log
  curl -H "Content-Type: application/json" \
       -X POST \
       -d "{\"content\": \"🔴 [$formatacaoData] - **Servidor Offline**\"}" \
       "$discordWebhook" > /dev/null 2>&1
fi