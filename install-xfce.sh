#!/data/data/com.termux/files/usr/bin/bash
extralink="https://raw.githubusercontent.com/andistro/app/main" # Para a versão main

android_version=$(getprop ro.build.version.release 2>/dev/null)         # Versão do Android
android_architecture=$(getprop ro.product.cpu.abi 2>/dev/null)         # Arquitetura do aparelho
device_manufacturer=$(getprop ro.product.manufacturer 2>/dev/null)     # Fabricante
device_model=$(getprop ro.product.model 2>/dev/null)                   # Modelo
device_model_complete=$(getprop ril.product_code 2>/dev/null)          # Código do modelo

device_hardware=$(getprop ro.hardware.chipname 2>/dev/null)            # Chipset Processador
system_country=$(getprop ro.csc.country_code 2>/dev/null)              # País
system_country_iso=$(getprop ro.csc.countryiso_code 2>/dev/null)       # Abreviação do País
system_icu_locale_code=$(getprop persist.sys.locale 2>/dev/null)       # Locale
system_timezone=$(getprop persist.sys.timezone 2>/dev/null)            # Timezone

device_dpi=$(getprop ro.sf.lcd_density 2>/dev/null)                     # DPI

rm -rf storage
termux-setup-storage

# Configurações do Termux
# Verifica se a configuração já foi aplicada
# Adiciona a configuração de teclas extras se não estiver presente
if ! grep -Fq "extra-keys = [['DRAWER','PASTE'],['ESC','/','-','HOME','UP','END','PGUP','KEYBOARD'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN','ENTER']]" ~/.termux/termux.properties; then
    # Aplica os sed
    sed -i "s|^# *extra-keys = \[\['ESC','/','-','HOME','UP','END','PGUP'\], \\\\|extra-keys = [['DRAWER','PASTE'],['ESC','/','-','HOME','UP','END','PGUP','KEYBOARD'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN','ENTER']]|" ~/.termux/termux.properties
    sed -i "s|^#[[:space:]]*\['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]||" ~/.termux/termux.properties

    # Recarrega Termux settings
    termux-reload-settings
fi

#1 Atualiza os repositórios
pkg update

#2 Instala o bash
pkg install --option=Dpkg::Options::="--force-confold" bash -y


#3 Instala o openssl
pkg install --option=Dpkg::Options::="--force-confold" openssl -y

#4 Instala o apt
pkg install --option=Dpkg::Options::="--force-confold" apt -y

#5 Atualiza os pacotes
pkg upgrade -y

pkg install termux-exec proot x11-repo termux-x11-nightly pulseaudio wget dialog tar curl unzip zip xz-utils debootstrap dbus pv -y

{
    for i in {1..50}; do
        sleep 0.1
        echo $((i * 2))
    done
} | dialog --no-shadow --gauge "O fuso horário será definido de forma automárica \nFuso horário detectado: $system_timezone\n\nEsta mensagem irá desaparecer em 5 segundos." 10 60 0


export distro_name="debian"
codinome="trixie"
bin="$HOME/start-$distro_name"
folder="$HOME/$distro_name/$codinome"
binds="$HOME/$distro_name/binds"
case `dpkg --print-architecture` in
aarch64)
    archurl="arm64" ;;
arm)
    archurl="armhf" ;;
*)
    echo "unknown architecture"; exit 1 ;;
esac

# Verificar e criar diretórios necessários
if [ ! -d "$HOME/$distro_name" ];then
    mkdir -p "$HOME/$distro_name"
fi

wget -O $folder.tar.xz "https://github.com/andistro/app/releases/download/${distro_name}_${codinome}/installer-${archurl}.tar.xz"

cat > $bin <<- EOM
#!/bin/bash
if [ ! -d "\$HOME/storage" ];then
    termux-setup-storage
fi

#cd \$(dirname \$0)
cd \$HOME

#Start termux-x11
#termux-x11 :1 &

pulseaudio --start --exit-idle-time=-1
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
pacmd load-module module-aaudio-sink
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
command+=" --kill-on-exit"
command+=" --link2symlink"
command+=" -0"
command+=" -r $folder"
if [ -n "\$(ls -A $binds)" ]; then
    for f in $binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
command+=" -b \$TMPDIR:/tmp"
command+=" -b /proc/meminfo:/proc/meminfo"
command+=" -b /sys"
command+=" -b /data"
command+=" -b $folder/root:/dev/shm"
## uncomment the following line to have access to the home directory of termux
#command+=" -b /data/data/com.termux/files/home:/root"
command+=" -b /data/data/com.termux/files/home:/termux-home"
command+=" -b /sdcard"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" MOZ_FAKE_NO_SANDBOX=1"
command+=" HOME=/root"
command+=" DISPLAY=:1"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
#command+=" LANG=C.UTF-8"
command+=" LANG=pt_BR.UTF-8"
command+=" /bin/bash --login"
com="\$@"
if [ -z "\$1" ]; then
    exec \$command
else
    \$command -c "\$com"
fi
PA_PID=\$(pgrep pulseaudio)
if [ -n "\$PA_PID" ]; then
  kill \$PA_PID
fi
EOM
chmod +x $bin

echo "127.0.0.1 localhost localhost" | tee $folder/etc/hosts
echo "nameserver 8.8.8.8" | tee $folder/etc/resolv.conf 
echo "$system_timezone" | tee $folder/etc/timezone

mkdir -p "$folder/usr/share/backgrounds/"
mkdir -p "$folder/usr/share/icons/"
mkdir -p "$folder/root/.vnc/"
mkdir -p "$folder/.config/gtk-3.0"



echo "APT::Acquire::Retries \"3\";" > $folder/etc/apt/apt.conf.d/80-retries #Setting APT retry count
touch $folder/root/.hushlogin

cat > $folder/usr/local/bin/startvnc <<- EOM
#!/bin/bash

set +H
largura_default=""; altura_default=""; escala_default="1"; porta_default="1"
tentou=""
foi_confirmado=0

while true; do
    dialog_msgbox="Insira a resolução personalizada no formato LARGURAxALTURA. Exemplo: 1920x1200\n"Insira o número da porta. Exemplo: 2. A porta padrão é 1\nAtenção: Não tecle ENTER (↲) antes de preencher todos os campos. Clique no texto para selecionar e poder digitar.\nLegenda: o campo em azul é o que está selecionado para digitar. Use as teclas ↑ e ↓ para trocar a seleção. Pode clicar nos nomes para selecionar.\n\n"
    mensagem_erro=""

    # Checa se já houve tentativa e há campos problemáticos
    if [[ -n "\$tentou" ]]; then
        falta_msg=""
        [[ -z "\$largura_default"  || ! "\$largura_default"  =~ ^[0-9]+$ ]] && falta_msg="\${falta_msg}\${label_width} [SOMENTE NÚMEROS]\n"
        [[ -z "\$altura_default"   || ! "\$altura_default"   =~ ^[0-9]+$ ]] && falta_msg="\${falta_msg}\${label_height} [SOMENTE NÚMEROS]\n"
        [[ -z "\$escala_default"   || ! "\$escala_default"   =~ ^[0-9]+$ ]] && falta_msg="\${falta_msg}\${label_scale} [SOMENTE NÚMEROS]\n"
        [[ -z "\$porta_default"    || ! "\$porta_default"    =~ ^[0-9]+$ ]] && falta_msg="\${falta_msg}\${label_port} [SOMENTE NÚMEROS]\n"
        [[ -n "\$falta_msg" ]] && mensagem_erro="Faltam ou há valores inválidos nos campos abaixo:\n\$falta_msg"
    fi

    cabecalho="Configurando o VNC"
    if [[ -n "\$mensagem_erro" ]]; then
        titulo="\$dialog_msgbox\n----------------\n\$mensagem_erro\n\n[SOMENTE NÚMEROS]"
    else
        titulo="\$dialog_msgbox\n[SOMENTE NÚMEROS]"
    fi
    exec 3>&1
    result=$(dialog --no-shadow --ok-label "Confirmar" --cancel-label "Cancelar" --backtitle "\$cabecalho" \
        --form "\$titulo" \
        0 0 4 \
        "Largura:" 1 1 "\$largura_default" 1 20 10 0 \
        "Altura:"  2 1 "\$altura_default"  2 20 10 0 \
        "Escala:"  3 1 "\$escala_default"  3 20 10 0 \
        "Porta:"   4 1 "\$porta_default"   4 20 10 0 \
        2>&1 1>&3)
    dialog_exit_status=$?
    exec 3>&-

    if [[ \$dialog_exit_status -eq 1 || \$dialog_exit_status -eq 255 || -z "\$result" ]]; then
        echo "Cancelado. Use o comando startvnc para selecionar outra resolução"
        clear
        startvnc
        break
    fi

    tentou=1
    largura_default="$(echo "\$result" | sed -n 1p)"
    altura_default="$(echo "\$result" | sed -n 2p)"
    escala_default="$(echo "\$result" | sed -n 3p)"
    porta_default="$(echo "\$result" | sed -n 4p)"

    if [[ "\$largura_default" =~ ^[0-9]+$ ]] &&
    [[ "\$altura_default"  =~ ^[0-9]+$ ]] &&
    [[ "\$escala_default"  =~ ^[0-9]+$ ]] &&
    [[ "\$porta_default"   =~ ^[0-9]+$ ]]; then
        foi_confirmado=1
        break
    fi
done
set -H

# Só mostra se foi confirmado
if [[ \$foi_confirmado -eq 1 ]]; then
    echo "Resolução definida: \${largura_default}x\${altura_default}, Escala: \${escala_default}, Porta: \${porta_default}"
fi
GEO="-geometry \${largura_default}x\${altura_default}" PORT=\$porta_default vnc
xfconf-query -c xsettings -p /Gdk/WindowScalingFactor -s \$escala_default
EOM

chmod +x $folder/usr/local/bin/startvnc


cat > $folder/usr/local/bin/vnc <<- EOM
#!/bin/bash
wlan_ip_localhost=$(ifconfig 2>/dev/null | grep 'inet ' | grep broadcast | awk '{print $2}') # IP da rede 
vncserver -localhost no -depth 24 -name remote-desktop \$GEO :\$PORT

if pgrep -x "xfce4-session" > /dev/null; then
    xfconf-query -c xsettings -p /Gdk/WindowScalingFactor -s \$escala_default
fi

echo -e "\nO servidor VNC foi iniciado. A senha padrão é a senha da conta $USER\n\n
Local: \$HOSTNAME:\$PORT / 120.0.0.1:\$PORT / \$wlan_ip_localhost:\$PORT\n\n
Esqueceu a senha? Use o comando 'vncpasswd' para redefinir a senha.\n"
EOM

chmod +x $folder/usr/local/bin/vnc


cat > $folder/root/.bash_profile <<- EOM
#!/bin/bash
export NEWT_COLORS="window=,white border=black,white title=black,white textbox=black,white button=white,blue"
# Define o LANG como pt_BR durante a execução.
export LANG=pt_BR.UTF-8

sed -i "s/^# export LS_OPTIONS='--color=auto'/export LS_OPTIONS='--color=auto'/" ~/.bashrc

apt update


apt install sudo wget dialog locales --no-install-recommends -y

sed -i 's/^# *\(pt_BR.UTF-8\)/\1/' /etc/locale.gen

locale-gen

echo 'LANG=pt_BR.UTF-8' > /etc/locale.conf
echo 'export LC_ALL=pt_BR.UTF-8' >> ~/.bashrc
echo 'export LANG=pt_BR.UTF-8' >> ~/.bashrc
echo 'export LANGUAGE=pt_BR.UTF-8' >> ~/.bashrc
apt update


etc_timezone=\$(cat /etc/timezone)
sudo ln -sf "/usr/share/zoneinfo/\$etc_timezone" /etc/localtime

HEIGHT=0
WIDTH=100
CHOICE_HEIGHT=5
export PORT=1

OPTIONS=(1 "\${MENU_theme_select_light}"
		 2 "\${MENU_theme_select_dark}")

CHOICE=\$(dialog --no-shadow --clear \
                --title "\$TITLE" \
                --menu "\$MENU_theme_select" \
                \$HEIGHT \$WIDTH \$CHOICE_HEIGHT \
                "\${OPTIONS[@]}" \
                2>&1 >/dev/tty)
case \$CHOICE in
	1)	
		echo "Light Theme"
		export distro_theme="Light"
	;;
	2)	
		echo "Dark Theme"
		export distro_theme="Dark"
	;;
esac

mkdir -p /usr/share/backgrounds/unsplash
mkdir -p /usr/share/backgrounds/unsplash/square
mkdir -p /usr/share/backgrounds/unsplash/portrait
mkdir -p /usr/share/backgrounds/unsplash/landscape

wget -O "/usr/share/backgrounds/unsplash/square/tiagojose-RiTmt0xGYnA.jpg" "https://unsplash.com/photos/RiTmt0xGYnA/download"
wget -O "/usr/share/backgrounds/unsplash/square/tiagojose-OhLxeq6DKvI.jpg" "https://unsplash.com/photos/OhLxeq6DKvI/download"

sudo apt clean
sudo apt full-upgrade -y

sudo apt install --no-install-recommends -y wget xz-utils curl gpg git python3 tar unzip zip apt-utils lsb-release exo-utils dbus-x11 nano net-tools font-managersynapticgvfs-backends bleachbit pulseaudio pavucontrol tumbler tigervnc-standalone-server tigervnc-common tigervnc-tools keyboard-configuration
sudo DEBIAN_FRONTEND=noninteractive apt install tzdata --no-install-recommends -y
sudo dpkg --configure -a

sudo apt --fix-broken install

sudo install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list
echo"Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000" | sudo tee /etc/apt/preferences.d/mozilla

wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo 'deb [arch=arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main' | sudo tee /etc/apt/sources.list.d/vscode.list
rm -f packages.microsoft.gpg

sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.lis

sudo apt update

sudo apt install --no-install-recommends -y firefox firefox-l10n-pt-br code

sudo sed -i 's/^Exec=synaptic-pkexec/Exec=synaptic/' /usr/share/applications/synaptic.desktop
sudo sed -i 's|Exec=/usr/share/code/code|Exec=/usr/share/code/code --no-sandbox|' /usr/share/applications/code*.desktop

echo -e "file:///sdcard sdcard" | sudo tee \$HOME/.config/gtk-3.0/bookmarks


git clone https://github.com/andistro/themes.git

mv themes/AnDistro*/ /usr/share/themes/

echo '[Settings]
gtk-theme-name=AnDistro-Majorelle-Blue-\${distro_theme}' | sudo tee \$HOME/.config/gtk-3.0/settings.ini

echo 'gtk-theme-name="AnDistro-Majorelle-Blue-\${distro_theme}"' | sudo tee \$HOME/.gtkrc-2.0

sudo dpkg --configure -a

sudo apt --fix-broken install -y

sudo apt install --no-install-recommends -y xfce4 xfce4-goodies xfce4-terminal xfce4-panel-profiles

bash -c "cat > \$HOME/.local/share/applications/xfce4-keyboard-settings.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Teclado
Comment=Editar preferências de teclado
Exec=xfce4-keyboard-settings
Icon=preferences-desktop-keyboard
Categories=Settings;DesktopSettings;X-XFCE;GTK;
EOF
"

bash -c "cat > \$HOME/.vnc/xstartup <<EOF
#!/bin/bash
export PULSE_SERVER=127.0.0.1
[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r \$HOME/.Xresources ] && xrdb \$HOME/.Xresources
echo $$ > /tmp/xsession.pid
dbus-launch --exit-with-session /usr/bin/startxfce4
EOF
"

chmod +x ~/.vnc/xstartup

echo 'export DISPLAY=":1"' >> /etc/profile

sudo apt --fix-broken install -y

vncpasswd


if [ "\$distro_theme" = "Light" ]; then
    wallpaper="unsplash/square/tiagojose-OhLxeq6DKvI.jpg"
elif [ "\$distro_theme" = "Dark" ]; then
    wallpaper="unsplash/square/tiagojose-RiTmt0xGYnA.jpg"
fi

source /etc/profile

vncserver -name remote-desktop -geometry 1920x1080 :1
sleep 5
xfconf-query -c xsettings -p /Net/ThemeName -s AnDistro-Majorelle-Blue-\${distro_theme}
xfconf-query -c xsettings -p /Net/IconThemeName -s AnDistro-Majorelle-Blue-\${distro_theme}
xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitorVNC-0/workspace0/last-image --create --type string --set "/usr/share/backgrounds/\${wallpaper}"
wget --tries=20 "https://raw.githubusercontent.com/andistro/app/main/config/package-manager-setups/apt/environment/xfce4/xfce4-panel.tar.bz2"  -O ~/xfce4-panel.tar.bz2
chmod +x ~/xfce4-panel.tar.bz2
xfce4-panel-profiles load xfce4-panel.tar.bz2


firefox > /dev/null 2>&1 & PID=$!; sleep 5; kill \$PID
sed -i '/security.sandbox.content.level/d' ~/.mozilla/firefox/*.default-release/prefs.js
echo "user_pref(\"security.sandbox.content.level\", 0);" >> ~/.mozilla/firefox/*.default-release/prefs.js

sudo apt clean

startvnc
EOM

bash $bin
