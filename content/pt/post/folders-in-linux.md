---
title: "Ententendo as pastas no Linux"
date: 2023-02-09T07:52:10-03:00
draft: false
tags: ["linux"]
---
Se você acabou de instalar o Linux e está acostumado com a estrutura de diretórios do Windows, pode estar se perguntando onde está o "disco C:"? 
Conhecer os diretórios do Linux pode ajudar a administrar o sistema e entender como ele funciona.

## Estrutura de diretórios: Windows vs. Linux
Windows e Linux evoluíram de forma diferente em termos de estrutura de diretórios. O Linux é mais parecido com outros sistemas Unix-like, como o macOS, na verdade, o Windows é o que mais difere da maioria dos sistemas operacionais em termos de organização.

A hierarquia de diretórios do Linux não é mais difícil, nem mais fácil, é simplesmente diferente. Tanto o "disco C:" do Windows quanto a raiz do Linux (/), servem para a mesma finalidade, mas de maneiras distintas.

Os sistemas Linux seguem o padrão FHS (Filesystem Hierarchy Standard), mantido pela Linux Foundation.

## Tipos de diretórios e permissões

- **Links Simbólicos**: Pastas com uma seta são atalhos para outras pastas ou arquivos. Por exemplo, /bin é um link simbólico para /usr/bin.
- **Diretórios Protegidos**: Pastas com um "x" exigem permissões de root para serem acessadas ou modificadas.

## Diretórios principais no Linux

### /
- **Raiz**: O diretório raiz, onde todos os outros diretórios e subdiretórios residem.

### /bin
- **Binaries**: Contém executáveis de programas essenciais do sistema, como bash, cat, ls, etc. É comparável à pasta "Arquivos de Programas" do Windows.

### /boot
- **Inicialização**: Contém arquivos necessários para o sistema operacional iniciar.

### /cdrom
- **Legado**: Diretório onde a imagem do disco é montada.

### /dev
- **Devices**: Contém arquivos que representam dispositivos de hardware. Por exemplo, /dev/sda para discos.

### /etc
- **Configuração**: Armazena arquivos de configuração do sistema, válidos para todos os usuários.

### /home
- **Usuários**: Diretório onde ficam os diretórios pessoais dos usuários.

### /lib
- **Libraries**: Contém bibliotecas de software necessárias para o sistema operacional e aplicativos.

### /media
- **Mídia Removível**: Diretório onde são montadas automaticamente unidades removíveis como pendrives.

### /mnt
- **Montagem**: Ponto de montagem para unidades de disco configuradas manualmente.

### /opt
- **Optional**: Contém software adicional de fabricantes ou software proprietário.

### /proc
- **Processos**: Diretório virtual com informações sobre o sistema e processos em execução.

### /root
- **Home do Root**: Diretório pessoal do usuário root.

### /run
- **Runtime**: Diretório virtual na memória, apagado ao desligar. Contém informações sobre usuários logados e daemons.

### /sbin
- **System Binaries**: Contém executáveis que só podem ser usados pelo administrador do sistema (root).

### /snap
- **Pacotes Snap**: Diretórios para pacotes Snap, uma forma diferente de empacotamento de software.

### /srv
- **Services**: Usado para armazenar dados de serviços, como servidores web.

### /sys
- **System**: Contém arquivos que interagem diretamente com o kernel, como drivers e firmwares.

### /tmp
- **Temp**: Arquivos temporários que são apagados no reboot.

### /usr
- **User ou Unix System Resources**: Contém programas e bibliotecas.

### /var
- **Variáveis**: Diretório para arquivos que aumentam de tamanho, como logs e caches do sistema.
