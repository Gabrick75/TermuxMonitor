#!/bin/bash

ACCESS_TOKEN="" #token

# Whatsapp API CallMeBot
DESTINO="" #número de telefone
API_KEY="" #chave api
URL="https://api.callmebot.com/whatsapp.php"

#color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

DEPENDENCIAS=("figlet" "jq" "curl" "ping" "termux-api")

#verifica e instala dependências
verificar_e_instalar() {
    for dep in "${DEPENDENCIAS[@]}"; do
        if ! command -v $dep &> /dev/null; then
            echo -e "${RED}$dep não encontrado.${RESET}"
            faltando=true
            dependencias_faltando+=("$dep")
        fi
    done
}

#instalar dependências
instalar_dependencias() {
    for dep in "${dependencias_faltando[@]}"; do
        echo -e "${YELLOW}Deseja instalar $dep? (yes/no)${RESET}"
        read resposta
        if [[ "$resposta" == "yes" ]]; then
            pkg install -y $dep
            if [[ $? -eq 0 ]]; then
                echo -e "${GREEN}$dep instalado com sucesso.${RESET}"
            else
                echo -e "${RED}Erro ao instalar $dep.${RESET}"
            fi
        else
            echo -e "${RED}Script fechado devido à falta de dependências.${RESET}"
            exit 1
        fi
    done
}

# Verificar e instalar dependências
dependencias_faltando=()
verificar_e_instalar

# Se faltar alguma dependência, perguntar ao usuário se deseja instalar
if [ "$faltando" = true ]; then
    instalar_dependencias
fi

echo -e "Esse código funciona melhor com sudo"
echo -e "${GREEN}Limpando o terminal em 3 segundos...${RESET}"
for i in {1..3}; do
  echo "$i"
  sleep 1
done
clear

texto="MONITOR"

# Gerar a arte ASCII
figlet "$texto"

# Caminho do arquivo de log (no mesmo diretório do script)
LOG_FILE="$(pwd)/logfile.log"

# Verificar se o arquivo de log existe, se não, cria
if [ ! -f "$LOG_FILE" ]; then
  echo -e "${YELLOW}Arquivo de log não encontrado, criando o arquivo...${RESET}"
  touch "$LOG_FILE"
  if [ $? -ne 0 ]; then
    echo -e "${RED}Erro ao criar o arquivo de log. Verifique as permissões.${RESET}"
    exit 1
  fi
fi

echo -e "${GREEN}Arquivo de log localizado ou criado com sucesso: $LOG_FILE${RESET}"

while true; do
  BATTERY_STATUS=$(termux-battery-status)
  BATTERY_LEVEL=$(echo $BATTERY_STATUS | jq '.percentage')
  BATTERY_PLUGGED=$(echo $BATTERY_STATUS | jq -r '.plugged')
  BATTERY_STATE=$(echo $BATTERY_STATUS | jq -r '.status')
  BATTERY_CURRENT=$(echo $BATTERY_STATUS | jq '.current')
  BATTERY_TEMPERATURE=$(echo $BATTERY_STATUS | jq '.temperature')

  # Carregamento
  CHARGING="não"
  PLUGGED_IN="não"
  if [ "$BATTERY_STATE" == "CHARGING" ]; then
    CHARGING="sim"
  fi
  if [ "$BATTERY_PLUGGED" != "UNPLUGGED" ]; then
    PLUGGED_IN="sim"
  fi

  # Carregamento Urgente
  URGENT_MESSAGE=""
  if [ "$BATTERY_LEVEL" -le 20 ]; then
    URGENT_MESSAGE="\n*CARREGAMENTO URGENTE!!!*"
  fi

  # Obter informações de ping e latência
  PING_RESULT=$(ping -c 4 8.8.8.8)
  LATENCY=$(echo "$PING_RESULT" | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
  PING=$(echo "$PING_RESULT" | grep 'transmitted' | awk '{print $4}')

  # RAM MB
  RAM_TOTAL=$(free | awk '/^Mem/ {printf("%.2f", $2/1024)}')
  RAM_USED=$(free | awk '/^Mem/ {printf("%.2f", $3/1024)}')
  RAM_FREE=$(free | awk '/^Mem/ {printf("%.2f", $4/1024)}')

  # Swap MB
  SWAP_TOTAL=$(free | awk '/^Swap/ {printf("%.2f", $2/1024)}')
  SWAP_USED=$(free | awk '/^Swap/ {printf("%.2f", $3/1024)}')
  SWAP_FREE=$(free | awk '/^Swap/ {printf("%.2f", $4/1024)}')

  # ROM GB e MB
  ROM_INFO=$(df | grep '/data')
  ROM_TOTAL=$(echo $ROM_INFO | awk '{printf("%.2f", $2/1024/1024)}')
  ROM_USED=$(echo $ROM_INFO | awk '{printf("%.2f", $3/1024/1024)}')
  ROM_FREE_MB=$(echo $ROM_INFO | awk '{printf("%.2f", $4/1024)}')
  ROM_PERCENT_USED=$(echo $ROM_INFO | awk '{print $5}')

  # CPU
  CPU_USAGE=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5); printf("%.2f", usage)}')

  # Formatar a data e hora
  DATE_TIME=$(date +"%d/%m/%Y %A , %H:%M:%S")

  # Uptime
  UPTIME=$(uptime -p)

  # IP (interface padrão é eth0 ou wlan0)
  LOCAL_IP=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -n 1)

  # IP público
  PUBLIC_IP=$(curl -s ifconfig.me)

  # Obter o nome do usuário atual
  USER=$(whoami)

  # Tabela para ser enviada no terminal e na notificação
  TABLE="*SERVER ONLINE*\n\n Horário verificação: $DATE_TIME Tempo de atividade: $UPTIME\n\nUsuário atual: $USER\n\nStatus da bateria:\nNível: $BATTERY_LEVEL%\nCarregando: $CHARGING\nPlugada: $PLUGGED_IN\nCorrente: $BATTERY_CURRENT mA\nTemperatura: $BATTERY_TEMPERATURE°C $URGENT_MESSAGE\n\nTeste de rede\nPing: $PING\nLatência: $LATENCY ms\nIP Local: $LOCAL_IP\nIP Público: $PUBLIC_IP\n\nUso de memória RAM:\nTotal: $RAM_TOTAL MB\nEm uso: $RAM_USED MB\nLivre: $RAM_FREE MB\n\nUso de memória Swap:\nTotal: $SWAP_TOTAL MB\nEm uso: $SWAP_USED MB\nLivre: $SWAP_FREE MB\n\nUso de memória ROM:\nTotal: $ROM_TOTAL GB\nEm uso: $ROM_USED GB\nDisponível: $ROM_FREE_MB MB\nPercentual Usado: $ROM_PERCENT_USED\n\nUso de CPU: $CPU_USAGE%\n"

  # Exibir a tabela
  echo -e $TABLE

  # Enviar notificação com a tabela formatada
  curl -u $ACCESS_TOKEN: -X POST https://api.pushbullet.com/v2/pushes \
       --header 'Content-Type: application/json' \
       --data-binary "{\"type\": \"note\", \"title\": \"Status do Servidor\", \"body\": \"$TABLE\"}"

  # Armazenar os dados no arquivo de log
  echo -e "$TABLE" >> "$LOG_FILE"

  # Verificar se os dados foram escritos corretamente no log
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Dados gravados com sucesso no arquivo de log.${RESET}"
  else
    echo -e "${RED}Erro ao gravar os dados no arquivo de log.${RESET}"
  fi

  # Codificar a mensagem para garantir que os caracteres especiais sejam tratados corretamente
  MENSAGEM_ENCODED=$(echo "$TABLE" | sed 's/ /%20/g' | sed 's/\n/%0A/g' | sed 's/á/%C3%A1/g' | sed 's/é/%C3%A9/g' | sed 's/í/%C3%AD/g' | sed 's/ó/%C3%B3/g' | sed 's/ú/%C3%BA/g' | sed 's/ã/%C3%A3/g' | sed 's/õ/%C3%B5/g')

  # Verificar se a mensagem foi codificada corretamente
  echo -e "${GREEN}Mensagem codificada:${RESET}" 
  echo "$MENSAGEM_ENCODED$"

  #a mensagem codificada está vazia?
  if [ -z "$MENSAGEM_ENCODED" ]; then
    echo -e "${RED}Erro: a mensagem está vazia após a codificação.${RESET}\n"
    exit 1
  fi

  #URL
  URL_FINAL="$URL?phone=$DESTINO&text=$MENSAGEM_ENCODED&apikey=$API_KEY"

  # Imprimir o link gerado
  # echo -e "${YELLOW}Link da requisição: $URL_FINAL${RESET}\n"

 
  curl -X GET "$URL_FINAL"

  # Aguardar 1 horas antes da próxima execução
  sleep 3600
done
