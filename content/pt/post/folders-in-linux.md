---
title: "Ententendo as pastas no linux"
date: 2023-02-09T07:52:10-03:00
draft: false
tags: ['linux']
---

Você acabou de instalar o linux e está acostumado com a estrutura do windows e seus diretórios, então você vai dar uma olhada no seu gestor de arquivos procurando pelo disco C: e não encontra..
Conhecer os diretórios do linux pode ajudar a administrar o sistema e entender como ele funciona.

Se a gente for analisar o windows e o linux acabaram evoluindo de forma diferente com relação a estrutura de diretórios. O linux inclusive é muito mais parecido com qualquer outro sistema com raízes unix como o macOS. Na verdade, o windows, considerando a maior parte dos sistemas operacionais existentes, é o que tem a organização mais diferente.

A hierarquia de diretórios do linux não é mais difícil e também não é mais fácil é simplesmente diferente, tanto o disco C: do windows quanto a raiz do linux servem para a mesma coisa mas fazem isso de forma diferente.

Os sistemas linux possuem a hierarquia de sistema **FHS**, Filesystem hierarchy standard, padrão mantido pela linux foundation.


Existem pastas que possuem uma seta e outras que possuem um x.
As pastas que possuem a seta são chamadas de links simbólicos, que são atalhos para outras pastas ou arquivos, essas pastas podem ser acessadas mas quando você entra neles você está entrando em outro diretório. Como exemplo o /bin, se observar as propriedades dele vai ver que tem como destino a pasta /usr/bin, dessa forma se você for utilizar o terminal para fazer um shell script ou executar o bash, não é preciso executar o comando /usr/bin/bash e sim /bash.


Já as pastas que contém o x significa que não podem ser acessadas sem que esteja navegando como root, o usuário comum não tem permissão de escrita em nenhuma pasta com x.


Vamos observar a funcionalidade das pastas que compõem a raiz do linux.


**/**

O diretório **/** é oque chamamos de diretório raiz, é onde todos os outros diretórios e subdiretórios vão se abrigar.

**/bin**

Binaries ou binários
Nesse diretório você encontra os executáveis de diversos programas do sistema operacional, como o bash, cat, ls e etc. Encontrando também links simbólicos e shell script. Essa pasta é comparável com a pasta disco C: arquivos e programas do windows.

**/boot**

Contém os arquivos necessários para o sistema operacional iniciar.

**/cdroom**

Diretório legado, a imagem do disco será montada neste diretório.

**/dev**

Devices

Dentro dessa pasta você encontra arquivos que correspondem ao seu hardware, arquivos que podem ser configuráveis e mudar a forma que um determinado device funciona. É por isso que as unidades de discos são chamadas de **/dev/sda** e algum número. O número só aparece se houver partições nesse disco.

Curiosidade: **/dev/null** é um diretorio buraco negro, que perde todas as informações que são enviadas para ele.

**/etc**

Edit to config ou et cetera

A função dessa pasta é manter os arquivos de configuração do sistema, de forma system wide, ou seja, para todos os usuários do sistema e não configurações específicas de um usuário, essas configurações específicas ficam em /home.


**/home**

Onde ficam os usuários comuns dos sistema, dentro de cada pasta de usuário, é possível ter configurações específicas de aplicativos para o usuário em questão.

**/lib** 

Library


**/lib lib32 lib64 libx32**

Todas elas são pastas que contém bibliotecas de software para o sistema operacional e os aplicativos instalados, um novo programa instalado pode adicionar libs nessas pastas são comparadas com dlls do windows.

**/media** 

É a pasta onde vão ser montados automaticamente as unidades removíveis do sistema, como pendrive, hd externo ou outro disco incluindo unidades de rede mapeados pelo samba por exemplo.

**/mnt**

Mount 

Pensado para ser um ponto de montagem de unidades de disco, quando feito manualmente pelo usuário utilizando o fstab.


**/opt**

Optional

Nessa pasta onde encontra-se softwares instalados por fabricantes que enviam computadores com linux ou por softwares proprietários por exemplo.


**/proc** 

Processes

Onde encontra-se arquivos que contêm informações sobre o sistema e processos dele. É um diretório virtual, não existem realmente no disco, são criados toda vez que inicia o computador.


**/root**

Como o diretório home, mas para o usuário root.

**/run**

Runtime

É um diretório virtual, carregado na memória do computador e apagado ao desligar. Contém informações como usuários logados, daemons rodando etc.

**/sbin**

System binaries

Armazena binários também, programas que só podem ser utilizados pelo administrador do sistema sudo root.

**/snap**

Encontra diretórios para pacotes snaps, é uma forma de empacotamento diferente. O suporte a pacote snap é padrão no ubuntu.

**/srv**

Services
Se utilizar algum servidor web ou sftp é possível armazenar aqui arquivos que vão ser acessíveis para outros usuários. É possível montar ela a partir de um disco externo.

**/sys**

System

Aqui armazena-se arquivos que interagem diretamente com o kernel, como drivers e firmwares. Também é temporario.


**/tmp** 

Temp

Arquivos são apagados durante o reboot.

**/usr**

Diretório que mudou de função. Usr pode significar duas coisas, user ou unix system resources. Hoje em dia contém arquivos de programas e libs.

**/var**

Variable

Diretório de variáveis, arquivos que são esperados que aumentem de tamanho, arquivos de backup, log, cache do sistema por exemplo.
