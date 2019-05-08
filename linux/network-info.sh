#!/bin/bash

# edite o arquivo /etc/init/tty1.conf e substitua a linha:
# exec /sbin/getty -8 38400 tty1
# por
# exec /home/douglas/bin/network-info.sh

inicio() {

network=`/sbin/ifconfig|grep -1 "^[a-zA-Z]"|grep -v "\-\-"`
dns=`cat /etc/resolv.conf | egrep '(nameserver|search)'`

dialog --ok-label "Tecle ENTER para ir ao Menu de Gerenciamento" --backtitle "Script para gerenciamento do servidor SNEP-PBX" --msgbox "$network" 30 80
#dialog --ok-label "Tecle ENTER para ir ao Menu de Gerenciamento" --backtitle "Script para gerenciamento do servidor SNEP-PBX" --msgbox "Placas de Rede e IPs:\n\n\n$network\n\n\n\n\nDNS\n\n\n\n$dns" 30 80

HEIGHT=15
WIDTH=70
CHOICE_HEIGHT=7
BACKTITLE="Script para gerenciamento do servidor SNEP-PBX"
TITLE="SNEP-PBX"
MENU="Escolha uma das opções abaixo:"

OPTIONS=(1 "Fixar IP em uma placa de rede"
         2 "Habilitar DHCP no servidor"
         3 "Requisitar IP dinamico - DHCP"
	 4 "Alterar o DNS do servidor"
         5 "Checar se a maquina esta conectada a Internet"
         6 "Reiniciar o servidor"
         7 "Voltar a tela de Status de Rede")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)      NET_CONFIP=$(dialog --stdout --inputbox "Digite o IP que deseja fixar neste servidor" 10 50)

                        if test $? -eq 0
                        then

                NET_CONFMASK=$(dialog --stdout --inputbox "Digite qual a mascara de rede que o servidor utilizara" 10 50)

                        	if test $? -eq 0
	                        then
				
                NET_CONFGW=$(dialog --stdout --inputbox "Digite o GW de rede que será utilizado pelo servidor" 10 50)
                
		       	                if test $? -eq 0
        	        	        then

			                dialog --title "Confirmacao:" --yesno "Confirme se as configurações de rede estão corretas.\n\n            Podemos aplica-las? \n\n\n IP: $NET_CONFIP \n MASCARA: $NET_CONFMASK \n GW: $NET_CONFGW  " 20 50
						
						if test $? -eq 0
                                        	then


echo "# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet static
        address $NET_CONFIP
        netmask $NET_CONFMASK
        gateway $NET_CONFGW" > /etc/network/interfaces


					dialog --msgbox "Configuracoes salvas com sucesso!" 10 70
					inicio
	                                        else
        	                                   inicio
                	                        fi

	                                else
        	                           inicio
                	                fi

			        else
                	           inicio
        	                fi

			else
                           inicio
                        fi

            ;;

        2)	dialog --ok-label "Continuar" --title "IMPORTANTE!" --msgbox "Por padrao, o servidor ja vem com o DHCP habilitado.\n\nEssa opcao deve ser utiizada caso voce ja tenha FIXADO um IP e deseja voltar as confs originais." 10 70
		dialog --title "Confirmacao:" --yesno "Podemos voltar as configuracoes de rede originais, ativando o DHCP?" 7 80

                        if test $? -eq 0
                        then

echo "# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet dhcp" > /etc/network/interfaces


                        dialog --msgbox "Pronto. Rede alterada para DHCP" 7 70

                        else
                           inicio
                        fi
            ;;


	3)      dialog --title "Solicitando DHCP para rede" 

		dhclient  

                inicio

            ;;



	4)	dialog --ok-label "Salvar e Aplicar" --editbox "/etc/resolv.conf" 30 80
		inicio
		
	    ;;

        5)     dialog --title "Testar conexao com a internet" --yesno "\nEsse teste consiste em efetuar um PING externo, validando a conexao com a internet e as configuracoes de DNS.\n\n\n                               Vamos começar?" 10 80
		
                        if test $? -eq 0
                        then

			ping -c 6 ocl.opens.com.br > /tmp/ping & dialog --exit-label "Voltar" --title 'Testando conexao com a internet...' --tailbox /tmp/ping 20 80			

			else

                	inicio

			fi
            ;;

        6)      dialog --title "ATENÇÃO!!" --yesno "Você tem certeza que quer mesmo reiniciar o servidor?\n\n " 10 60

                        if test $? -eq 0
                        then

                        reboot -n

                        else

                        inicio

                        fi

                inicio

            ;;

esac

inicio

}

inicio

