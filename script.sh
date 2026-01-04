#!/bin/sh

echo '
  mmmm                        mmmm                  "             m   
 #"   "  mmm    mmm   m mm   #"   "  mmm    m mm  mmm    mmmm   mm#mm 
 "#mmm  #"  "  "   #  #"  #  "#mmm  #"  "   #"  "   #    #" "#    #   
     "# #      m"""#  #   #      "# #       #       #    #   #    #   
 "mmm#" "#mm"  "mm"#  #   #  "mmm#" "#mm"   #     mm#mm  ##m#"    "mm 
                                                         #            
                                                         "            
'

echo "Данный скрипт создан для облегчения этапа активной разведки"
echo "Введите IP-адрес или домен цели:"
read ip

BASE_DIR="nmap_results"
FAST_DIR="$BASE_DIR/$ip/fast_scan"
FULL_DIR="$BASE_DIR/$ip/full_scan"

mkdir -p "$FAST_DIR" "$FULL_DIR"

spinner() {
  while kill -0 "$1" 2>/dev/null; do
    for s in '|' '/' '-' '\'; do
      printf "\r[%s] Сканирование..." "$s"
      sleep 0.1
    done
  done
}

echo "
Выберите режим:
1) Быстрое сканирование
2) Полное сканирование"
read CHOICE

case $CHOICE in
  1)
    echo "[+] Быстрое сканирование"

    nmap -sS -T4 --top-ports 1000 \
         -oN "$FAST_DIR/ports.txt" \
         "$ip" > /dev/null &
    PID=$!
    spinner "$PID"
    wait "$PID"
    printf "\r[✓] Порты просканированы        \n"

    nmap -sS -sV -T4 \
         -oN "$FAST_DIR/services.txt" \
         "$ip" > /dev/null &
    PID=$!
    spinner "$PID"
    wait "$PID"
    printf "\r[✓] Сервисы определены          \n"

    echo "[📂] Результаты: $FAST_DIR"
    ;;

  2)
    echo "[+] Полное сканирование (долго)"

    nmap -sS -p- -T4 \
         -oN "$FULL_DIR/ports.txt" \
         "$ip" > /dev/null &
    PID=$!
    spinner "$PID"
    wait "$PID"
    printf "\r[✓] Все порты просканированы     \n"

    nmap -sS -sV -p- -T4 \
         -oN "$FULL_DIR/services.txt" \
         "$ip" > /dev/null &
    PID=$!
    spinner "$PID"
    wait "$PID"
    printf "\r[✓] Сервисы определены           \n"

    echo "[📂] Результаты: $FULL_DIR"
    ;;
    
  *)
    echo "[!] Неверный выбор"
    ;;
esac
