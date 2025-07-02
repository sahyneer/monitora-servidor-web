<h1 align="center">Sistema Monitorador de Servidor Web</h1>

<div align="center">
  <strong>🚨 Criado para executar tarefas automatizadas de monitoramento em um servidor web com notificações em tempo real via Discord 🚨</strong>
</div>

</br>

<p align="center">
	<img alt="Status Em Desenvolvimento" src="https://img.shields.io/badge/STATUS-EM%20DESENVOLVIMENTO-green">
    <a href="https://img.shields.io/github/repo-size/sahyneer/servidor-nginx-ubuntu">
        <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/sahyneer/servidor-nginx-ubuntu">
    </a>
    <img alt="Tamanho do Repositório" src="https://img.shields.io/github/repo-size/sahyneer/servidor-nginx-ubuntu">
</p>

<p align="center">
    <a href="#-visão-do-projeto">Visão do projeto</a> •
    <a href="#-tecnologias">Tecnologias</a> •
    <a href="#-instruções">Instruções</a> •
    <a href="#-testes">Testes</a> •
    <a href="#-autora">Autora</a>
 </p>

</br>

## 🔭 Visão do projeto

O projeto foi desenvolvido durante a 1º Sprint do Programa Compass.Uol Scholarship, que tinha por desafio construir uma instância Amazon EC2 com um servidor Nginx no Ubuntu 24.04 e um script de monitoramento e notificação através do Webhook Discord.

O sistema foi configurado para funcionar automaticamente ao ligar a máquina e reiniciar em caso de falha ou interrupção, além de realizar monitoramentos a cada minuto sobre status de funcionamento. Caso o sistema não estiver funcionando, o script envia avisos informando a indisponibilidade do servidor, juntamente com data e hora de detecção.

</br>


## 💻 Tecnologias

[![Tenologias](https://skillicons.dev/icons?i=linux,bash,ubuntu,discord,nginx,aws,git)](https://skillicons.dev)

</br>

## ⚙️ Instruções

### Índice

- [Configuração da VPC](#configuração-da-vpc)

    + [Criando a VPC](#criando-a-vpc)

    + [Criando Subredes](#criando-subredes)

    + [Criando o Internet Gateway](#criando-o-internet-gateway)

    + [Criando Tabelas de Rotas](#criando-tabelas-de-rotas)

    + [Mapa de Recursos](#mapa-de-recursos)

- [Configurando a EC2](#configurando-a-ec2)

    + [Criando a EC2](#criando-a-ec2)

    + [Criando um Grupo de Segurança](#criando-um-grupo-de-segurança)

    + [Acessando a EC2](#acessando-a-ec2)

- [Configurações Iniciais da VM](#configurações-iniciais-da-vm)

    + [Ativando o Superusuário](#ativando-o-superusuário)

    + [Ajustando Data e Hora](#ajuste-de-data-e-hora)

- [Instalação do Servidor Nginx](#instalação-do-servidor-nginx)

    + [Testando o Servidor Nginx](#testando-o-servidor-nginx)

- [Configurações Gerais do Nginx](#configurações-gerais-do-nginx)

    + [Iniciando o Servidor Automaticamente](#iniciando-o-servidor-automaticamente)

    + [Reiniciando o Servidor em Caso de Interrupção ou Falha](#reiniciando-o-servidor-em-caso-de-interrupção-ou-falha)

- [Localizando a Página HTML](#localizando-a-página-html)

- [Criando o Ambiente de Webhook no Discord](#criando-o-ambiente-de-webhook-no-discord)

- [Criando o Arquivo .env](#criando-o-arquivo-env)

- [Importando o Script](#importando-o-script)

    + [Script de Monitoramento](#script-de-monitoramento)

- [Funcionamento do Script a Cada Minuto](#funcionamento-do-script-a-cada-minuto)

    + [Comandos Básicos do Cron](#comandos-básicos-do-cron)

    + [Configurando o Cron para o Script](#configurando-o-cron-para-o-script)

</br>

### Configuração da VPC

Antes de criar uma instância EC2, é essencial configurar uma VPC (Virtual Private Cloud) para garantir que os recursos estejam isolados, organizados e seguros dentro de um ambiente personalidado.

##### Criando a VPC

1. Acesse o AWS VPC Console
2. Painel da VPC > Nuvem Privada Virtual > Suas VPC's
3. Criar VPC
4. Selecione "Only VPC" e configure:
    * Nome: `PB - JUN 2025`
    * CIDR IPv4: `10.0.0.0/16`
    * CIDR IPv6: `none`
    * Tags: rótulos definidos no projeto.

#### Criando Subredes
1. Painel da VPC > Nuvem Privada Virtual > Sub-redes
2. Criar sub-rede
3. Digite o ID da VPC.
4. Configure as sub-redes:

</br>

| **Subredes** | **Tipo** | **Zona de Disponibilidade** | **CIDR IPv4** |
|:------------:|:--------:|:---------------------------:|:-------------:|
|    subpb-A   |  Pública |          us-east-1a         |  10.0.1.0/24  |
|    subpb-B   |  Pública |          us-east-1b         |  10.0.2.0/24  |
|    subpv-A   |  Privada |          us-east-1c         |  10.0.3.0/24  |
|    subpv-B   |  Privada |          us-east-1d         |  10.0.4.0/24  |

</br>

#### Criando o Internet Gateway

1. Painel da VPC > Nuvem Privada Virtual > Gateways da Internet
2. Criar Gateway da Internet

    * Nome: `PB-Gateway`

4. Clicar em criar Gateway da Internet
5. Anexar o gateway à VPC

#### Criando Tabelas de Rotas
* Subredes Públicas

    1. Painel da VPC > Nuvem Privada Virtual > Tabelas de Rotas
    2. Criar Tabela de Rotas
        * Nome: `subredes-publicas-PB`
        * VPC: `PB - JUN 2025`
    3. Editar a tabela para adicionar a rota `0.0.0.0` apontando para o Gateway de Internet
    4. Associar com as sub-redes públicas

* Subredes Privadas

    1. Painel da VPC > Nuvem Privada Virtual > Tabelas de Rotas
    2. Criar Tabela de Rotas

        * Nome: `subredes-privadas-PB`
        * VPC: `PB - JUN 2025`

    3. Associar com as sub-redes públicas

### Mapa de Recursos

Abaixo temos a representação resumida das estrtura da VPC:

<img src="./img-README/mapa-de-recursos.png" alt="Mapa de Recursos da VPC">

</br>

### Configurando a EC2

#### Criando a EC2

1. Acesse o AWS EC2 Console
2. EC2 > Instâncias > Instâncias
3. Executar Instâncias:

    * Nome e Tags: de acordo com o projeto
    * Selecionar imagem do Sistema Operacional (SO)
    * Gerar par de chaves para login (RSA/.pem)
    * Outras configurações de preferência

4. Clicar em Executar Instância

#### Criando um Grupo de Segurança

1. EC2 > Rede e Segurança > Security Groups
2. Criar Grupo de Segurança

    * Nome: `securityGroup-PB`
    * Descrição: `Permitir acesso SSH e HTTP`
    * VPC: `PB - JUN 2025`

3. Adicionar Regras de Entrada para permitir acesso público via HTTP e SSH do próprio IP, a fim de garantir mais segurança ao sistema.

<img src="./img-README/regras-de-entrada-security-group.png" alt="Regras de Entrada do Security Group">

#### Acessando a EC2

Como foi definido as regras de acesso via SSH, a conexão se dará via Prompt de Comando ou Terminal:

1. EC2 > Instâncias > Instâncias
2. Selecionar a VPC
3. Estado da Instância > Iniciar Instâncias
4. Abra o Promp de Comando ou Terminal no mesmo diretório que está a chave de login .pem
5. Execute o comando `ssh -i "chave.pem" ubuntu@ip_publico`
6. Siga os passos fianis para o acesso

> Para garantir que a chave de acesso não fique visível publicamente no computador, execute o comando: chmod 400 "chave.pem"

</br>

### Configuração da Máquina Virtual

Realize as configurações básicas de qualquer SO, definindo usuários, senhas e outras configurações de preferência.

</br>

#### Ativando o Superusuário

Logo após acessar a VM, é de extrema importância estar logado como super usuário, para que assim as configurações possam ser realizadas sem problemas de permissão. Para entrar como superusuário digite o comando abaixo e logo em seguida a senha definida na instalação do SO:

```bash
sudo su
```

</br>

#### Ajustando Data e Hora
Para obter melhores resultados no uso do sistema, as configurações de data e hora precisam estar ajustadas corretamente. Para conferir isso, digite `date`.

Caso não esteja, use o comando `timedatectl` para resolver esse problema. Antes de usá-lo, confira a região geográfica que se encontra a partir da lista gerada pelo seguinte comando:
```bash
timedatectl list-timezone
```
Depois de conferir, digite de acordo com o continente e cidade que deseja alterar:
```bash
timectl set-timezone continente/cidade
```

</br>

### Instalação do Servidor Nginx

<p>Antes de qualquer instalação é importante realizar uma atualização da lista de pacotes para evitar erros de instalação:</p>

```bash
apt-get update
```
<p>Após isso podemos realizar a instalação do servidor Nginx:</p>

```bash
apt install nginx
```

<p>Ao longo da instalação, podem ser requisitados confirmação para continuar com a instalação, basta digitar S e a tecla Enter.</p>

Para confirmar se está instalado, use o comando `systemctl status nginx`. Deve mostrar status ativo como na imagem abaixo:

<img src="./img-README/status-nginx.png" alt="Status enable do Nginx">

</br>

#### Testando o Servidor Nginx

Digite o ip público da EC2 no navegador, caso apareça o site, o Nginx está funcionando corretamente. O ip pode ser encontrado na página que contém informações da instância ao inicia-la:

<img src="./img-README/ec2-ip.png" alt="Ip público no EC2">

Em casos de aplicação em VM local, execute o comando `ip a` para saber o ip local:

<img src="./img-README/ip-a.png" alt="Ip público no EC2">

</br>

### Configurações Gerais do Nginx

O `systemd` é o sistema de inicialização padrão das distribuições modernas do Linux, responsável por inicializar o sistema, gerenciar serviços e processos em segundo plano. 

Para controlar os serviços do `systemd` usa-se o comando `systemctl`, e com ele que as principais tarefas de configuração e análise do servidor podem ser executadas.

</br>

#### Iniciando o servidor automaticamente

Normalmente após a instalação do Nginx, o servidor é automaticamente configurado para iniciar justamente com o boot do sistema. É possível conferir isso, executando o comando `systemctl is-enabled nginx`. O resultado esperado é `enabled`.

Caso não seja esse o caso, use o comando ``systemctl enable nginx`` para ativar e confira o status novamente com o `systemctl is-enabled nginx`.

</br>

#### Reiniciando o servidor em caso de interrupção ou falha
 
 Para essa configuração é necessário acessar o arquivo que controla o serviço do Nginx:


```bash
/etc/systemd/system/multi-user.target.wants/nginx.service
```

> O caminho mostrado acima trata-se de um link simbólico para o arquivo real, que depende de cada distribuição e versão do SO. Os caminhos normalmente são /lib/systemd/system/nginx.service ou /etc/systemd/system/nginx.service. Para saber o real caminho execute ls -l /etc/systemd/system/multi-user.target.wants/nginx.service.

Ao abrir o arquivo, tem por `default` algumas configurações do Nginx, como mostrado abaixo:

<img src="./img-README/systemd-nginx-config.png" alt="Configurações default do Nginx">

Para fazer a modificação do documento, use o `nano`, `vi`, ou qualquer outro editor, e acrescente em `service` as seguintes linhas:

```bash
Restart=always # reiniciar sempre que parar
RestartSec=10 # reinicia após 10 segundos
```

Após salvar as modificações, execute os seguintes comandos:
```bash
systemctl daemon-reload # recarregar novas configurações
systemctl restart nginx # reiniciar o servidor
systemctl status nginx # verificar status de funcionamento
```

</br>

### Localizando a Página HTML

A localização do html é definida dentro das configurações do Nginx. No Ubuntu em específico, o arquivo pode ser encontrado no caminho `/etc/nginx/sites-available/default`.

> Em algumas distribuições pode estar localizado em /etc/nginx/conf.d/default.conf

Dentro do arquivo, é preciso procurar `root` no bloco `server`. Abaixo, vemos que o arquivo html está no caminho `/var/www/html` com o nome `index` ou `index.html`

<img src="./img-README/nginx-config.png" alt="Status após a interrupção do Nginx ">

> Lembrando que esse caminho pode mudar de acordo com cada distribuição e versão, por isso é importante verificar primeiro antes de acessar o repositório!

Portanto, para alterar esse arquivo basta ir até o diretório e editar o arquivo ou importar um arquivo.

</br>

### Criando o Ambiente de Webhook no Discord

Antes de gerenciar o recurso, é preciso ter criado um servidor e um canal de texto.

1. No servidor, abra a aba de configurações do canal;
2. Selecione a opção "editar canal";
3. No lado esquerdo da tela, selecione "integrações";
4. Selecione a opção "Webhooks";
5. Crie um "Novo Webhook";
6. Copie a URL.

> A URL não pode ser compartilhada publicamente, pois pode ser usada por qualquer pessoa para enviar mensagens. Por isso, será criado um arquivo .env para encriptar os dados de acesso contidos e não deixar exposto no script.

<img src="./img-README/discord.png" alt="Configuração do Webhook no Discord">

</br>

### Criando o Arquivo .env

Dentro do diretório crie o arquivo .env para colocar a URL do Webhook copiada dentro da variável `discordWebhook`:

```bash
discordWebhook="URL"
```

>CUIDADO ao criar esse arquivo, não pode conter espaços antes, dentro e/ou depois da linha de código. Caso o contrário o script não será capaz de detectar corretamente o conteúdo do arquivo .env!

</br>

### Importando o Script

O script, escrito em bash, tem a função de verificar as requisições http e enviar logs de status do servidor, além de enviar um aviso via webhook do Discord em caso de status Offline.

Para isso, basta importar este repositório no diretório raíz:

```bash
git clone https://github.com/sahyneer/monitora-servidor-web.git
```

#### Script de Monitoramento

```bash
#!/bin/bash

. /monitora-servidor-web/.env

URL=$(hostname -I)

requisicaoHTTP=$(curl -Is $URL | head -n 1)

# Definição de cores para melhor visualização dos logs
fonteVermelho='\033[0;31m'
fonteVerde='\033[0;32m'
fonteSemCor='\033[0m' # reset de cor

formatacaoData=$(date "+%Y/%m/%d %H:%M:%S")

if [ "$requisicaoHTTP" ]; then
  printf "${fonteVerde}${formatacaoData} Servidor Online ($URL)${fonteSemCor}\n"
else
  printf "${fonteVermelho}${formatacaoData} Servidor Offline ($URL)${fonteSemCor}\n"
  # Envio da mensagem para o Discord e ocultacao de saida do curl para o log
  curl -H "Content-Type: application/json" \
       -X POST \
       -d "{\"content\": \"🔴 [$formatacaoData] - **Servidor Offline**\"}" \
       "$discordWebhook" > /dev/null 2>&1
fi
```

É necessário tornar o script executável, para isso, dentro do diretório do arquivos, digite o comando:

```bash
chmod +x script_verifica.sh
```

</br>

### Funcionamento do Script a Cada Minuto

O cron é um agendador de tarefas do sistema que permite executar comandos ou scripts automaticamente em horários ou intervalos regulares. As definições são feitas dentro do arquivo crontab e devem ser carregadas para funcionar corretamente.

</br>

#### Comandos Básicos do Cron

1. Verificar status: `service cron status`
2. Iniciar serviço: `service cron start`
3. Parar serviço: `service cron stop`
4. Listar os todos os cronjobs em funcionamento: `crontab -l`

>É importante destacar que os cronjobs são definidos por usuários, ou seja, se definiu um cronjob com o usuário root, não pode alterar ou listar a menos que esteja logado como usuário root!

</br>

#### Configurando o Cron para o Script

Primeiramente, abra o arquivo do crontab para edição como o comando: `crontab -e` e acrescente o seguinte código:

```bash
* * * * * /monitora-servidor-web/script_verifica.sh >> /var/log/monitora.log 2>&1
```
O comando acima está determinando que o script_verifica.sh irá rodar a cada minuto (* * * * *) e sua saída será armazenada no arquivo monitora.log (2>&1) sem sobrepor o que já foi escrito a cada ciclo (>>).

Por fim, use o comando `service cron start` para carregar as novas configurações do crontab.

</br>

## 🧪 Testes

### 1. Verificando a Reinicialização Automática 

Podemos simular uma interrupção brusca no servidor ao forçar a finalização do processo em execução. Use o seguinte comando:

```bash
kill -9 $(pidof nginx)
```

Após 10 segundos execute o comando `systemctl status nginx` para verificar o status do servidor e verá a seguinte informação:

<img src="./img-README/teste-nginx.png" alt="Status após a interrupção do Nginx ">

Note no que final da saída, ocorreu uma falha de conexão (escrito em laranja) e na linha seguinte, mostra que 10 segundos depois, o Nginx reiniciou automaticamente como definido nas configurações.

### 2. Verificando Monitoramento de Status

Ao acessar o arquivo de monitoramento `/var/log/monitora.log`, vemos todas as verificações a partir do momento que o servidor é ativado quando ligado:

<img src="./img-README/teste-monitora.png" alt="Status após a interrupção do Nginx ">

Também, vemos abaixo as notificações recebidas no canal do Discord quando o servidor está Offline:

<img src="./img-README/teste-discord.png" alt="Status após a interrupção do Nginx ">

</br>

## 🧙‍♂️ Autora

<p>Feito com 💛 por Sarah Cabral<p>

<p>Vamos nos conectar?</p>

[![Gmail Badge](https://img.shields.io/badge/-Sarah_Cabral-006bed?style=flat-square&logo=Gmail&logoColor=white&link=mailto:sahyneer@gmail.com)](mailto:sahyneer@gmail.com)
[![Linkedin: Sarah Cabral](https://img.shields.io/badge/-in/sahyneer-blue?style=flat-square&logo=Linkedin&logoColor=white&link=https://www.linkedin.com/in/sahyneer//)](https://www.linkedin.com/in/sahyneer/)
[![GitHub](https://img.shields.io/github/followers/sahyneer?label=follow&style=social)](https://github.com/sahyneer)