# VM3 — servidor web do grupo 24

## Instalação na appliance

1. No console da VM3, acesse a conta administrativa com `su -`. Execute o `rede.sh` conforme a ordem do projeto. A VM3 usa `172.26.24.3/25` em `enp0s3`.
2. No console da VM3, execute os comandos abaixo como administrador. A instalação precisa de acesso aos repositórios de pacotes da appliance.

   ```sh
   apt-get update
   apt-get install apache2
   apt-get install openssl
   apt-get install libapache2-mod-php
   a2enmod ssl
   a2ensite default-ssl
   service apache2 stop
   service apache2 start
   ```
3. Coloque o `index.html` desta pasta em `/var/www/html/index.html`. Acesse `http://172.26.24.3/` de um cliente da intranet e confira o cabeçalho “VM3 — Redes II”.

## HTTPS

A prática da Aula 08 usa o site `default-ssl`. Em `/etc/apache2/sites-available/default-ssl.conf`, confira se `SSLCertificateFile` e `SSLCertificateKeyFile` apontam para o certificado e a chave locais da appliance. Para o teste inicial, abra `https://172.26.24.3/` e confira o certificado apresentado. Um certificado de laboratório pode gerar aviso de confiança e de divergência de nome no teste pelo IP.

## Teste do PHP

Depois de instalar o módulo PHP, coloque `teste-php.php` em `/var/www/html`. Abra `http://172.26.24.3/teste-php.php` no navegador e confira a mensagem “PHP em execução na VM3”. Remova o arquivo de teste após a verificação.

## Pendente

O Webmail aparece na VM3 no diagrama do plano (p. 3). A implementação depende do SMTP e do IMAP da VM4.

## Referências

- Prática da Aula 08, itens 2 e 3, para Apache e HTTPS.
- [Pacote Debian libapache2-mod-php](https://packages.debian.org/bookworm/libapache2-mod-php).
