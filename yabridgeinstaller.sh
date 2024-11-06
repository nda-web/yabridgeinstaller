#!/bin/bash
# Yabridge installation and configuration script for Linux
# This script automates the installation of Yabridge and sets up default plugin directories.

set -e  # Exit immediately if a command exits with a non-zero status

# Function to print a message with green color for clarity
function print_message {
  echo -e "\033[1;32m$1\033[0m"
}

# Function to print an error message in red
function print_error {
  echo -e "\033[1;31m$1\033[0m"
}

# Function to check if Wine is installed and its version
function check_wine {
  if command -v wine &> /dev/null; then
    WINE_VERSION=$(wine --version)
    if [[ $WINE_VERSION == *"Staging"* ]]; then
      print_message "Wine Staging ya está instalado."
      return 0
    else
      print_message "Wine está instalado, pero no es Wine Staging."
      return 1
    fi
  else
    print_message "Wine no está instalado."
    return 2
  fi
}

# Function to check if Git is installed
function check_git {
  if command -v git &> /dev/null; then
    print_message "Git ya está instalado."
    return 0
  else
    print_message "Git no está instalado. Instalando Git..."
    case $DISTRO in
      ubuntu|debian|linuxmint|pop)
        sudo apt update
        sudo apt install -y git
        ;;
      arch|manjaro)
        sudo pacman -Syu --needed git
        ;;
      fedora)
        sudo dnf install -y git
        ;;
      opensuse*)
        sudo zypper install -y git
        ;;
      *)
        echo "Distribución no soportada. Saliendo."
        exit 1
        ;;
    esac
  fi
}

# Function to check if Yabridge is installed
function check_yabridge {
  if command -v yabridgectl &> /dev/null; then
    print_message "Yabridge ya está instalado."
    return 0
  else
    print_message "Yabridge no está instalado."
    return 1
  fi
}

# Function to download Yabridge from GitHub releases
function download_yabridge {
  print_message "Descargando la última versión de Yabridge..."
  YABRIDGE_LATEST_URL=$(curl -s https://api.github.com/repos/robbert-vdh/yabridge/releases/latest | grep "browser_download_url.*tar.gz" | cut -d '"' -f 4)
  wget -O /tmp/yabridge.tar.gz "$YABRIDGE_LATEST_URL" || { print_error "No se pudo descargar Yabridge. Saliendo."; exit 1; }
  mkdir -p ~/.local/share/yabridge
  tar -xzf /tmp/yabridge.tar.gz -C ~/.local/share/yabridge --strip-components=1 || { print_error "No se pudo extraer Yabridge. Saliendo."; exit 1; }
  rm /tmp/yabridge.tar.gz
  print_message "Yabridge descargado y extraído. Verificando la instalación..."
  ls -l ~/.local/share/yabridge

  # Verify that yabridgectl exists after extraction
  if [[ ! -f "$HOME/.local/share/yabridge/yabridgectl" ]]; then
    print_error "No se encontró yabridgectl después de la extracción. Por favor, verifica los archivos extraídos."
    exit 1
  fi
}

# Determine the distribution
if [[ -f /etc/os-release ]]; then
  . /etc/os-release
  DISTRO=$ID
else
  echo "No se pudo determinar la distribución. Saliendo."
  exit 1
fi

# Print actions to be taken
print_message "Este script realizará las siguientes acciones:"
print_message "1. Comprobar si Wine Staging está instalado."
print_message "2. Instalar Wine Staging si no está instalado."
print_message "3. Comprobar si Git está instalado."
print_message "4. Instalar Git si no está instalado."
print_message "5. Descargar e instalar Yabridge."
print_message "6. Agregar directorios de plugins predeterminados a Yabridgectl."
print_message "7. Configurar Yabridge para su uso con tus plugins."
print_message "¿Deseas continuar? (s/n)"
read -r PROCEED
if [[ $PROCEED != "s" ]]; then
  echo "Operación cancelada por el usuario. Saliendo."
  exit 0
fi

# Check and install Wine Staging
check_wine
WINE_STATUS=$?
if [[ $WINE_STATUS -eq 2 ]]; then
  print_message "Instalando Wine Staging..."
  case $DISTRO in
    ubuntu|debian|linuxmint|pop)
      sudo dpkg --add-architecture i386
      sudo mkdir -pm755 /etc/apt/keyrings
      wget -nc https://dl.winehq.org/wine-builds/winehq.key
      sudo mv winehq.key /etc/apt/keyrings/winehq-archive.key
      sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/$(lsb_release -cs)/winehq-$(lsb_release -cs).sources
      sudo apt update
      sudo apt install -y --install-recommends winehq-staging
      ;;
    arch|manjaro)
      sudo pacman -Syu --needed wine-staging
      ;;
    fedora)
      sudo dnf install -y winehq-staging
      ;;
    opensuse*)
      sudo zypper install -y winehq-staging
      ;;
    *)
      echo "Distribución no soportada. Saliendo."
      exit 1
      ;;
  esac
elif [[ $WINE_STATUS -eq 1 ]]; then
  print_message "Wine está instalado, pero no es Wine Staging. ¿Deseas desinstalar la versión actual e instalar Wine Staging? (s/n)"
  read -r REPLACE_WINE
  if [[ $REPLACE_WINE == "s" ]]; then
    case $DISTRO in
      ubuntu|debian|linuxmint|pop)
        sudo apt remove --purge -y wine*
        sudo dpkg --add-architecture i386
        sudo mkdir -pm755 /etc/apt/keyrings
        wget -nc https://dl.winehq.org/wine-builds/winehq.key
        sudo mv winehq.key /etc/apt/keyrings/winehq-archive.key
        sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/$(lsb_release -cs)/winehq-$(lsb_release -cs).sources
        sudo apt update
        sudo apt install -y --install-recommends winehq-staging
        ;;
      arch|manjaro)
        sudo pacman -Rns wine
        sudo pacman -Syu --needed wine-staging
        ;;
      fedora)
        sudo dnf remove -y wine*
        sudo dnf install -y winehq-staging
        ;;
      opensuse*)
        sudo zypper remove -y wine
        sudo zypper install -y winehq-staging
        ;;
      *)
        echo "Distribución no soportada. Saliendo."
        exit 1
        ;;
    esac
  else
    echo "Operación cancelada por el usuario. Saliendo."
    exit 0
  fi
fi

# Check and install Git
check_git

# Download the latest Yabridge release
if check_yabridge; then
  print_message "Yabridge ya está instalado. Saltando la descarga."
else
  download_yabridge
fi

# Add Yabridge to PATH if not already in PATH
if [[ ":$PATH:" != *":$HOME/.local/share/yabridge:"* ]]; then
  print_message "Agregando Yabridge al PATH del sistema..."
  echo "export PATH=\"\$HOME/.local/share/yabridge:\$PATH\"" >> ~/.bashrc
  export PATH="$HOME/.local/share/yabridge:$PATH"
  print_message "Yabridge agregado al PATH del sistema."
else
  print_message "Yabridge ya está en el PATH del sistema. Saltando este paso."
fi

# Ensure yabridgectl has execution permissions
chmod +x ~/.local/share/yabridge/yabridgectl

# Add default plugin directories to yabridgectl
print_message "Agregando directorios de plugins predeterminados a Yabridgectl..."

PLUGIN_DIRS=(
  "$HOME/.wine/drive_c/Program Files/Steinberg/VstPlugins"
  "$HOME/.wine/drive_c/Program Files/VstPlugins"
  "$HOME/.wine/drive_c/Program Files/Common Files/VST3"
  "$HOME/.wine/drive_c/Program Files/Common Files/CLAP"
)

for DIR in "${PLUGIN_DIRS[@]}"; do
  if [[ ! -d "$DIR" ]]; then
    print_message "El directorio $DIR no existe. Creándolo..."
    mkdir -p "$DIR"
  fi
  yabridgectl add "$DIR" || print_error "No se pudo agregar el directorio $DIR"
done

# Running yabridgectl sync to set up plugins
print_message "Ejecutando yabridgectl sync..."
if [[ -f ~/.local/share/yabridge/yabridgectl ]]; then
  yabridgectl sync || { print_error "No se pudo ejecutar yabridgectl sync. Saliendo."; exit 1; }
else
  print_error "No se encontró yabridgectl después de la descarga. Saliendo."
  ls -l ~/.local/share/yabridge
  exit 1
fi

print_message "¡Yabridge se ha instalado y configurado correctamente!"
print_message "Para usar Yabridge, instala tus plugins de Windows en el prefijo de Wine y utiliza 'yabridgectl' para gestionarlos."
