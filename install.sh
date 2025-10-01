#!/data/data/com.termux/files/usr/bin/bash
# Configuraçoes do instalador
extralink="https://raw.githubusercontent.com/andistro/app/main" # Para a versão main

rm -rf /storage
termux-setup-storage > /dev/null 2>&1

# Log de erros
if [ ! -d "$HOME/storage/shared/termux/andistro/logs" ];then
    mkdir -p "$HOME/storage/shared/termux/"
    mkdir -p "$HOME/storage/shared/termux/andistro"
    mkdir -p "$HOME/storage/shared/termux/andistro/distros"
    mkdir -p "$HOME/storage/shared/termux/andistro/logs"
fi

# Cria os diretórios necessários
if [ ! -d "$PREFIX/var/lib/andistro/" ];then
	mkdir -p "$PREFIX/var/lib/andistro/"
	mkdir -p "$PREFIX/var/lib/andistro/lib/share/"
	mkdir -p "$PREFIX/var/lib/andistro/lib/share/locales/"
	mkdir -p "$PREFIX/var/lib/andistro/boot/"
fi

if [ -f "$PREFIX/var/lib/andistro/lib/share/global" ]; then
    source $PREFIX/var/lib/andistro/lib/share/global
fi

# Detecta o idioma do sistema
system_icu_locale_code=$(getprop persist.sys.locale)

echo -e "\n Aguarde"
update_progress() {
  current_step=$1
  total_steps=$2
  
  percent=$((current_step * 100 / total_steps))
  bar_length=30
  filled_length=$((percent * bar_length / 100))
  empty_length=$((bar_length - filled_length))
  
  filled_bar=$(printf "%${filled_length}s" | tr " " "=")
  empty_bar=$(printf "%${empty_length}s" | tr " " " ")
  
  printf "\r[%s%s] %3d%%" "$filled_bar" "$empty_bar" "$percent"
}

total_steps=25  # Número total de etapas que você quer monitorar
current_step=0

{
  #1 Atualiza os repositórios
  pkg update > /dev/null 2>&1
  ((current_step++))
  update_progress "$current_step" "$total_steps"; sleep 0.1
  
  #2 Instala o bash
  pkg install --option=Dpkg::Options::="--force-confold" bash -y > /dev/null 2>&1
  ((current_step++))
  update_progress "$current_step" "$total_steps"; sleep 0.1
  
  #3 Instala o openssl
  pkg install --option=Dpkg::Options::="--force-confold" openssl -y > /dev/null 2>&1
  ((current_step++))
  update_progress "$current_step" "$total_steps"; sleep 0.1
  
  #4 Instala o apt
  pkg install --option=Dpkg::Options::="--force-confold" apt -y > /dev/null 2>&1
  ((current_step++))
  update_progress "$current_step" "$total_steps"; sleep 0.1
  
  #5 Atualiza os pacotes
  pkg upgrade -y > /dev/null 2>&1
  ((current_step++))
  update_progress "$current_step" "$total_steps"; sleep 0.1
  
  #6 Verifica se o termux-exec está instalado
  if ! dpkg -l | grep -qw termux-exec; then
      pkg install termux-exec -y > /dev/null 2>&1
  fi
  ((current_step++))
  update_progress "$current_step" "$total_steps"; sleep 0.1
  
  #7 Verifica se o proot está instalado
  if ! dpkg -l | grep -qw proot; then
      pkg install proot -y > /dev/null 2>&1
  fi
  ((current_step++))
  update_progress "$current_step" "$total_steps"; sleep 0.1
  
  #8 Verifica se o x11-repo está instalado
  
  if ! dpkg -l | grep -qw x11-repo; then
      pkg install x11-repo -y > /dev/null 2>&1
  fi
  ((current_step++))
  update_progress "$current_step" "$total_steps"; sleep 0.1
  
  #9 Verifica se o termux-x11-nightly está instalado
  if ! dpkg -l | grep -qw termux-x11-nightly; then
      pkg install termux-x11-nightly -y > /dev/null 2>&1
  fi
  ((current_step++))
  update_progress "$current_step" "$total_steps"; sleep 0.1
  
  #10 Verifica se o pulseaudio está instalado
  if ! dpkg -l | grep -qw pulseaudio; then
      pkg install pulseaudio -y > /dev/null 2>&1
  fi
  ((current_step++))
  update_progress "$current_step" "$total_steps"; sleep 0.1
  
  #11 Verifica se o wget está instalado
  if ! dpkg -l | grep -qw wget; then
      pkg install wget -y > /dev/null 2>&1
  fi
  ((current_step++))
  update_progress "$current_step" "$total_steps"; sleep 0.1
  
  #12 Verifica se o dialog está instalado
  if ! dpkg -l | grep -qw dialog; then
      pkg install dialog -y > /dev/null 2>&1
  fi
  ((current_step++))
  update_progress "$current_step" "$total_steps"; sleep 0.1
  
  #13 Verifica se o tar está instalado
  if ! dpkg -l | grep -qw tar; then
      pkg install tar -y > /dev/null 2>&1
  fi
  ((current_step++))
  update_progress "$current_step" "$total_steps"; sleep 0.1
  
  #14 Verifica se o curl está instalado
  if ! dpkg -l | grep -qw curl; then
      pkg install curl -y > /dev/null 2>&1
  fi
  ((current_step++))
  update_progress "$current_step" "$total_steps"; sleep 0.1
  
  #15 Verifica se o unzip está instalado
  if ! dpkg -l | grep -qw unzip; then
      pkg install unzip -y > /dev/null 2>&1
  fi
  ((current_step++))
  update_progress "$current_step" "$total_steps"; sleep 0.1
  
  #16 Verifica se o xz-utils está instalado
  if ! dpkg -l | grep -qw xz-utils; then
      pkg install xz-utils -y > /dev/null 2>&1
  fi
  ((current_step++))
  update_progress "$current_step" "$total_steps"; sleep 0.1
  
  #17 Verifica se o debootstrap está instalado
  if ! dpkg -l | grep -qw debootstrap; then
      pkg install debootstrap -y > /dev/null 2>&1
  fi
  ((current_step++))
  update_progress "$current_step" "$total_steps"; sleep 0.1
  
  #18 Verifica se o dbus está instalado
  if ! dpkg -l | grep -qw dbus; then
      pkg install dbus -y > /dev/null 2>&1
  fi
  ((current_step++))
  update_progress "$current_step" "$total_steps"; sleep 0.1
  
  #19 Verifica se o pv está instalado
  if ! dpkg -l | grep -qw pv; then
      pkg install pv -y > /dev/null 2>&1
  fi
  ((current_step++))
  update_progress "$current_step" "$total_steps"; sleep 0.1
  
  #20 Verifica e baixa global
  if [ ! -f "$PREFIX/var/lib/andistro/lib/share/global" ]; then
      curl -s -o "$PREFIX/var/lib/andistro/lib/share/global" "${extralink}/config/global" > /dev/null 2>&1
  fi
  ((current_step++))
  update_progress "$current_step" "$total_steps"; sleep 0.1
  
  #21 Verifica e atualiza o global
  curl -s -o "$PREFIX/var/lib/andistro/lib/share/global.check" "${extralink}/config/global" 2>&1
  
  if [ -f "$PREFIX/var/lib/andistro/lib/share/global" ] && [ -f "$PREFIX/var/lib/andistro/lib/share/global.check" ]; then
      if ! cmp -s "$PREFIX/var/lib/andistro/lib/share/global" "$PREFIX/var/lib/andistro/lib/share/global.check"; then
          rm "$PREFIX/var/lib/andistro/lib/share/global"
          mv "$PREFIX/var/lib/andistro/lib/share/global.check" "$PREFIX/var/lib/andistro/lib/share/global"
          chmod +x "$PREFIX/var/lib/andistro/lib/share/global"
      else
          rm "$PREFIX/var/lib/andistro/lib/share/global.check"
      fi
  fi
  ((current_step++))
  update_progress "$current_step" "$total_steps"; sleep 0.1
  
  #22 Verifica e baixa l10n_${locale}.sh
  if [ ! -f "$PREFIX/var/lib/andistro/lib/share/locales/l10n_${system_icu_locale_code}.sh" ]; then
      curl -s -o "$PREFIX/var/lib/andistro/lib/share/locales/l10n_${system_icu_locale_code}.sh" "${extralink}/config/locale/l10n_${system_icu_locale_code}.sh" > /dev/null 2>&1
  fi
  ((current_step++))
  update_progress "$current_step" "$total_steps"; sleep 0.1
  
  #23 Verifica e atualiza o l10n_${locale}.sh
  curl -s -o "$PREFIX/var/lib/andistro/lib/share/locales/l10n_${system_icu_locale_code}.check" "${extralink}/config/locale/l10n_${system_icu_locale_code}.sh" 2>&1
          
  if [ -f "$PREFIX/var/lib/andistro/lib/share/locales/l10n_${system_icu_locale_code}.sh" ] && [ -f "$PREFIX/var/lib/andistro/lib/share/locales/l10n_${system_icu_locale_code}.check" ]; then
      if ! cmp -s "$PREFIX/var/lib/andistro/lib/share/locales/l10n_${system_icu_locale_code}.sh" "$PREFIX/var/lib/andistro/lib/share/locales/l10n_${system_icu_locale_code}.check"; then
          rm "$PREFIX/var/lib/andistro/lib/share/locales/l10n_${system_icu_locale_code}.sh"
          mv "$PREFIX/var/lib/andistro/lib/share/locales/l10n_${system_icu_locale_code}.check" "$PREFIX/var/lib/andistro/lib/share/locales/l10n_${system_icu_locale_code}.sh"
          chmod +x "$PREFIX/var/lib/andistro/lib/share/locales/l10n_${system_icu_locale_code}.sh"
      else
          rm "$PREFIX/var/lib/andistro/lib/share/locales/l10n_${system_icu_locale_code}.check"
      fi
  fi
  ((current_step++))
  update_progress "$current_step" "$total_steps"; sleep 0.1
  
  #24 Verifica se o andistro está em $HOME
  if [ -f "$HOME/andistro" ]; then
      mv "$HOME/andistro" "$PREFIX/bin/andistro"
      rm -rf "$HOME/andistro"
  fi
  chmod +x "$PREFIX/bin/andistro"
  ((current_step++))
  update_progress "$current_step" "$total_steps"; sleep 0.1
  
  # 25 Verifica e atualiza o andistro
  curl -s -o "$HOME/andistro.check" "${extralink}/andistro" 2>&1
  
  if [ -f "$PREFIX/bin/andistro" ] && [ -f "$HOME/andistro.check" ]; then
      if ! cmp -s "$PREFIX/bin/andistro" "$HOME/andistro.check"; then
          rm "$PREFIX/bin/andistro"
          mv "$HOME/andistro.check" "$PREFIX/bin/andistro"
          chmod +x "$PREFIX/bin/andistro"
      else
          rm "$HOME/andistro.check"
      fi
  fi
  ((current_step++))
  update_progress "$current_step" "$total_steps"; sleep 0.1
  
  echo  # pular linha no fim
}

clear

chmod +x "$PREFIX/var/lib/andistro/lib/share/global"
source "$PREFIX/var/lib/andistro/lib/share/global"
echo -e "$label_update_finish"

echo -e "${label_distro_alert_timezone_desc} \n$label_distro_alert_timezone_detected $system_timezone"
sleep 5

# Configuração do Debian no Termux
export distro_name="debian"
codinome="trixie"
andistro_files="$PREFIX/var/lib/andistro"
bin="$PREFIX/var/lib/andistro/boot/start-$distro_name"
folder="$PREFIX/var/lib/andistro/boot/$distro_name/$codinome"
binds="$PREFIX/var/lib/andistro/boot/$distro_name/binds"

if [ ! -d "$PREFIX/var/lib/andistro/boot/$distro_name" ];then
    mkdir -p "$PREFIX/var/lib/andistro/boot/$distro_name"
fi

if [ ! -d "$HOME/storage/shared/termux/andistro/boot/$distro_name/$codinome" ];then
    mkdir -p "$HOME/storage/shared/termux/"
    mkdir -p "$HOME/storage/shared/termux/andistro"
    mkdir -p "$HOME/storage/shared/termux/andistro/boot"
    mkdir -p "$HOME/storage/shared/termux/andistro/boot/$distro_name/$codinome"
fi

mkdir -p $binds

if [[ -n "${LANG_CODES[$system_icu_locale_code]}" ]]; then
    system_lang_code="$system_icu_locale_code"
else
    system_lang_code="en-US"
fi

# Montar opções do menu
OPTIONS=()
OPTIONS+=("auto" "→ ${LANG_CODES[$system_lang_code]} $label_detected")
OPTIONS+=("SEP" "────────────")  # Separador visual seguro

# Adicionar os demais idiomas em ordem alfabética (exceto o detectado)
for code in $(printf "%s\n" "${!LANG_CODES[@]}" | sort); do
    [[ "$code" == "$system_lang_code" ]] && continue
    OPTIONS+=("$code" "${LANG_CODES[$code]}")
done

# Tamanho da janela do dialog
HEIGHT=0
WIDTH=100
CHOICE_HEIGHT=10

# Mostrar menu com redirecionamento seguro
exec 3>&1
CHOICE=$(dialog --no-shadow --clear \
    --title "$MENU_language_select" \
    --menu "$MENU_language_select" \
    $HEIGHT $WIDTH $CHOICE_HEIGHT \
    "${OPTIONS[@]}" \
    2>&1 1>&3)
exec 3>&-

clear

# Determinar idioma selecionado
language_selected="pt-BR"

# Converter de pt-BR para pt_BR
language_transformed="${language_selected//-/_}"

# Exportar, se necessário
export language_selected
export language_transformed

if [ -d "$folder" ]; then
	first=1
	echo "${label_skip_download}"
fi

if [ "$first" != 1 ];then
	case `dpkg --print-architecture` in
	aarch64)
		archurl="arm64" ;;
	arm)
		archurl="armhf" ;;
	*)
		echo "unknown architecture"; exit 1 ;;
	esac

	show_progress_dialog wget "${label_distro_download}" -O $folder.tar.xz "https://github.com/andistro/app/releases/download/${distro_name}_${codinome}/installer-${archurl}.tar.xz"
	sleep 2
	# Extrai a imagem do sistema
	show_progress_dialog extract "${label_distro_download_extract}" "$folder.tar.xz"
	sleep 2
	rm -rf $folder.tar.xz # remove o arquivo
fi

cat > $bin <<- EOM
#!/bin/bash
if [ ! -d "\$HOME/storage" ];then
    termux-setup-storage
fi

#cd \$(dirname \$0)
cd \$HOME

#Start termux-x11
#termux-x11 :1 &

pulseaudio --start --exit-idle-time=20
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
command+=" LANG=$language_transformed.UTF-8"
command+=" /bin/bash --login"
command+=" -b /usr/local/bin/startvncserver"
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

# Configurações pós-instalação
# Baixa scripts de configuração de idioma
show_progress_dialog "wget" "${label_language_download}" 1 -P "$folder/root/" "${extralink}/config/package-manager-setups/apt/locale/locale_${language_selected}.sh"
sleep 2
chmod +x $folder/root/locale_${language_selected}.sh

# Adicionar entradas em hosts, resolv.conf e timezone
echo "127.0.0.1 localhost localhost" | tee $folder/etc/hosts
echo "nameserver 8.8.8.8" | tee $folder/etc/resolv.conf 
echo "$system_timezone" | tee $folder/etc/timezone

# Se não existir, será criado
mkdir -p "$folder/usr/share/backgrounds/"
mkdir -p "$folder/usr/share/icons/"
mkdir -p "$folder/root/.vnc/"
mkdir -p "$folder/usr/local/bin/locales/"

# Baixa as configurações, scripts do vnc e wallpapers adicionais
show_progress_dialog wget-labeled "${label_progress}" 12 \
	"${label_progress}" -P "$folder/root" "${extralink}/config/package-manager-setups/apt/system-config.sh" \
	"${label_progress}" -P "$folder/root" "${extralink}/config/package-manager-setups/apt/app-list-recommends.sh" \
	"${label_progress}" -O "$folder/usr/local/bin/andistro" "${extralink}/config/andistro_interno" \
	"${label_progress}" -O "$folder/root/wallpapers.sh" "${extralink}/config/wallpapers/config.sh" \
	"${label_progress}" -P "$folder/usr/local/bin" "${extralink}/config/global" \
	"${label_progress}" -P "$folder/usr/local/bin/locales" "${extralink}/config/locale/l10n_${language_selected}.sh" \
	"${label_progress}" -P "$folder/usr/local/bin" "${extralink}/config/package-manager-setups/apt/vnc/vnc" \
	"${label_progress}" -P "$folder/usr/local/bin" "${extralink}/config/package-manager-setups/apt/vnc/vncpasswd" \
	"${label_progress}" -P "$folder/usr/local/bin" "${extralink}/config/package-manager-setups/apt/vnc/startvnc" \
	"${label_progress}" -P "$folder/usr/local/bin" "${extralink}/config/package-manager-setups/apt/vnc/stopvnc" \
	"${label_progress}" -P "$folder/usr/local/bin" "${extralink}/config/package-manager-setups/apt/vnc/startvncserver"

chmod +x $folder/usr/local/bin/andistro
chmod +x $folder/usr/local/bin/vnc
chmod +x $folder/usr/local/bin/vncpasswd
chmod +x $folder/usr/local/bin/startvnc
chmod +x $folder/usr/local/bin/stopvnc
chmod +x $folder/usr/local/bin/startvncserver
chmod +x "$folder/usr/local/bin/global"
chmod +x "$folder/usr/local/bin/locales/l10n_${language_selected}.sh"
chmod +x "$folder/root/system-config.sh"
chmod +x "$folder/root/app-list-recommends.sh"
chmod +x "$folder/root/wallpapers.sh"
sleep 2

show_progress_dialog "wget" "${label_config_environment_gui}" 1 -O "$folder/root/config-environment.sh" "${extralink}/config/package-manager-setups/apt/environment/xfce4/config.sh"
chmod +x $folder/root/config-environment.sh

sleep 4
echo "APT::Acquire::Retries \"3\";" > $folder/etc/apt/apt.conf.d/80-retries #Setting APT retry count
touch $folder/root/.hushlogin

cat > $folder/root/.bash_profile <<- EOM
#!/bin/bash
# Define o LANG como $language_transformed durante a execução.
export LANG=$language_transformed.UTF-8

# Fonte modular configuração global
source "/usr/local/bin/global"
echo "source \"/usr/local/bin/global\"" >> ~/.bashrc

# Mensagem de inicialização
echo -e "\n\n${label_alert_autoupdate_for_u}\n\n"


# Este alias faz com que o comando 'ls' mostre arquivos e diretórios coloridos automaticamente
sed -i "s/^# export LS_OPTIONS='--color=auto'/export LS_OPTIONS='--color=auto'/" ~/.bashrc
#echo "alias ls='ls --color=auto'" >> ~/.bashrc

# Adiciona uma lista de fontes apt caso seja necessário
#echo 'deb http://deb.debian.org/debian $codinome main contrib non-free non-free-firmware
#deb http://security.debian.org/debian-security $codinome-security main contrib non-free
#deb http://deb.debian.org/debian $codinome-updates main contrib non-free' >> /etc/apt/sources.list

#======================================================================================================
# global == update_progress() {}
update_progress() {
    local current_step=\$1
    local total_steps=\$2
    local percent=\$((current_step * 100 / total_steps))
    local bar_length=30
    local filled_length=\$((percent * bar_length / 100))
    local empty_length=\$((bar_length - filled_length))

    local filled_bar
    local empty_bar
    filled_bar=\$(printf "%\${filled_length}s" | tr " " "=")
    empty_bar=\$(printf "%\${empty_length}s" | tr " " " ")

    # AQUI ESTÁ O PULO DO GATO: força a saída para o terminal
    printf "\r[%s%s] %3d%%" "\$filled_bar" "\$empty_bar" "\$percent" > /dev/tty
}

total_steps=4
current_step=0

apt update -qq -y > /dev/null 2>&1
((current_step++))
update_progress "\$current_step" "\$total_steps" "Atualizando repositórios"
sleep 0.5

if ! dpkg -l | grep -qw sudo; then
    apt install sudo --no-install-recommends -y > /dev/null 2>&1
fi
((current_step++))
update_progress "\$current_step" "\$total_steps" "Instalando sudo"
sleep 0.5

if ! dpkg -l | grep -qw wget; then
    apt install wget --no-install-recommends -y > /dev/null 2>&1
fi
((current_step++))
update_progress "\$current_step" "\$total_steps" "Instalando wget"
sleep 0.5

if ! dpkg -l | grep -qw dialog; then
    apt install dialog --no-install-recommends -y > /dev/null 2>&1
fi
((current_step++))
update_progress "\$current_step" "\$total_steps" "Instalando dialog"
sleep 0.5

echo    # quebra de linha ao final para não sobrepor prompt
#======================================================================================================

etc_timezone=\$(cat /etc/timezone)

sudo ln -sf "/usr/share/zoneinfo/\$etc_timezone" /etc/localtime

# Executa as configurações de idioma
bash ~/locale_\$system_icu_locale_code.sh

# Seletor de tema
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

# Baixa os wallpapers adicionais
bash ~/wallpapers.sh

# Executa as configurações base do sistema
bash ~/system-config.sh

bash ~/app-list-recommends.sh

# Configurações da inteface escolhida
bash ~/config-environment.sh

rm -rf ~/locale*.sh
rm -rf ~/.hushlogin
rm -rf ~/system-config.sh
rm -rf ~/config-environment.sh
rm -rf ~/start-environment.sh
rm -rf ~/.bash_profile
EOM

# Cria um dialog de inicialização
#sed -i '\|command+=" /bin/bash --login"|a command+=" -b /usr/local/bin/startvncserver"' $bin

# Inicia o sistema
bash $bin

# Remove o arquivo de instalação e configuração
rm -rf $PREFIX/var/lib/andistro/boot/install-$distro_name.sh
