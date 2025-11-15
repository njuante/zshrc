# zshrc

Mi configuración personalizada de Zsh optimizada para **pentesting** y **CTFs** (Capture The Flag).

## 🎯 Descripción

Esta configuración proporciona un entorno de shell potente y eficiente para trabajar en pentesting, seguridad ofensiva y competiciones CTF. Incluye funciones automatizadas, aliases útiles, y un entorno visualmente atractivo con Powerlevel10k.

## ✨ Características Principales

### 🎨 Interfaz
- **Powerlevel10k**: Tema moderno y rápido para Zsh
- **Oh My Zsh**: Framework completo de gestión de configuración
- **Páginas man con colores**: Lectura más agradable de documentación

### 🔌 Plugins Incluidos
- `git`: Aliases y funciones para Git
- `z`: Navegación rápida entre directorios
- `sudo`: Doble ESC para agregar sudo al comando anterior
- `command-not-found`: Sugerencias cuando un comando no existe
- `history-substring-search`: Búsqueda inteligente en historial
- `zsh-autosuggestions`: Autocompletado inteligente basado en historial
- `zsh-syntax-highlighting`: Resaltado de sintaxis en tiempo real
- `colored-man-pages`: Páginas man con formato colorido
- `extract`: Extraer cualquier archivo comprimido con un solo comando

### 🛠️ Herramientas Mejoradas
- `lsd`: Reemplazo moderno de `ls` con iconos y colores
- `batcat`: Reemplazo de `cat` con resaltado de sintaxis
- Soporte para portapapeles del sistema (`xclip`)

## 📦 Instalación

### Prerrequisitos

```bash
# Instalar Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Instalar Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Instalar plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Instalar herramientas adicionales
sudo apt install lsd bat xclip -y
```

### Aplicar Configuración

```bash
# Descargar el archivo zshrc
curl -o ~/.zshrc https://raw.githubusercontent.com/njuante/zshrc/main/zshrc

# Recargar la configuración
source ~/.zshrc

# Configurar Powerlevel10k (solo la primera vez)
p10k configure
```

## 🎯 Funciones CTF / Pentesting

### Gestión de Objetivos (Target Management)
```bash
settarget 10.10.10.123      # Establece IP objetivo (persiste entre sesiones)
showtarget                  # Muestra el target actual
cleartarget                 # Limpia el target
```

### Estructura de Directorios
```bash
mkt                         # Crea: nmap/, content/, exploits/, scripts/
mkctf HackTheBox            # Crea directorio "HackTheBox" con estructura CTF
```

### Escaneo de Puertos
```bash
nmapQuick 10.10.10.5        # Escaneo rápido con scripts (-sCV)
nmapFull 10.10.10.5         # Escaneo completo de todos los puertos
nmapUDP 10.10.10.5          # Escaneo UDP de top-100 puertos
extractPorts nmap/allports  # Extrae puertos y copia al portapapeles
osttl 10.10.10.5            # Detecta SO por TTL (Linux ~64, Windows ~128)
```

### Reconocimiento Web
```bash
webrecon http://target.com              # Ejecuta whatweb y nikto
dirfuzz http://target.com               # Directory fuzzing (feroxbuster/gobuster)
dirfuzz http://target.com /path/dict    # Con diccionario personalizado
```

### Reverse Shells
```bash
revshell 4444 bash          # Genera reverse shell bash
revshell 4444 python        # Python reverse shell
revshell 4444 nc            # Netcat reverse shell
revshell 4444 php           # PHP reverse shell
revshell 4444 perl          # Perl reverse shell
ttyupgrade                  # Muestra pasos para mejorar TTY shell
```

### Utilidades
```bash
hashidentify <hash>         # Identifica tipo de hash por longitud
rmk archivo.txt             # Borrado seguro con confirmación
serve                       # HTTP server en puerto 8000
serve80                     # HTTP server en puerto 80 (requiere sudo)
```

## 🔥 Aliases Útiles

### Navegación y Archivos
```bash
ll          # lsd -lh (listado detallado)
la          # lsd -a (incluye archivos ocultos)
lla         # lsd -lha (detallado + ocultos)
..          # cd ..
...         # cd ../..
back        # Vuelve al directorio anterior ($OLDPWD)
```

### Utilidades del Sistema
```bash
c / cls     # clear (limpiar pantalla)
cat         # batcat (con resaltado de sintaxis)
ports       # Ver todos los puertos en uso
listening   # Ver puertos en escucha
localip     # Muestra tu IP local
myip        # Muestra tu IP pública
```

### Portapapeles
```bash
pbcopy      # Copiar al portapapeles
pbpaste     # Pegar desde portapapeles
```

### Python
```bash
py          # python3
ipy         # ipython3
```

### Git
```bash
gs          # git status
ga          # git add
gc          # git commit -m
gp          # git push
```

### Configuración
```bash
zshconfig   # Edita ~/.zshrc
p10kconfig  # Reconfigura Powerlevel10k
```

## 📚 Ayuda

```bash
ctfhelp     # Muestra lista completa de funciones
help        # Alias de ctfhelp
info        # Alias de ctfhelp
welcome     # Mensaje de bienvenida con target actual
```

## ⚙️ Variables de Entorno

```bash
EDITOR=nano                             # nano (por defecto)
WORDLISTS=/usr/share/wordlists          # Diccionarios
SECLISTS=/usr/share/seclists            # SecLists
PATH=$HOME/.local/bin:$HOME/tools:$PATH
TARGET=<auto-cargada>                   # IP objetivo (auto-cargada)
```

## 🎨 Opciones de Zsh Configuradas

- `autocd`: Cambiar de directorio sin escribir `cd`
- `correct_all`: Corrección automática de comandos
- `nocaseglob`: Búsqueda insensible a mayúsculas
- `histignoredups`: No guardar comandos duplicados
- `sharehistory`: Compartir historial entre sesiones
- `hist_ignore_space`: Comandos que empiezan con espacio no se guardan
- Historial de 10,000 comandos
- Búsqueda en historial con flechas ↑↓

## 🔧 Personalización

Puedes modificar el archivo `~/.zshrc` según tus necesidades:

1. Cambiar el editor: `export EDITOR="vim"`
2. Agregar más aliases personalizados
3. Modificar rutas de wordlists
4. Añadir tus propias funciones

## 📝 Notas

- La configuración está optimizada para Kali Linux / Parrot OS / Ubuntu
- Requiere permisos de sudo para algunas funciones (nmapFull, serve80)
- Los escaneos se guardan automáticamente en el directorio `nmap/`
- El target IP persiste entre sesiones del shell

## 🤝 Contribuciones

Siéntete libre de hacer fork, modificar y mejorar esta configuración. ¡Los PRs son bienvenidos!

## 📄 Licencia

Libre uso para propósitos de pentesting ético y aprendizaje.

---

**Autor**: njuante  
**Uso**: Pentesting / CTF / Seguridad Ofensiva
