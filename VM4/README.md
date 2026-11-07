# VM4 — SMTP e IMAP do grupo 24

## Instalar

1. Na appliance da VM4, entre como administrador com `su -` e aplique `rede.sh` conforme a ordem do projeto. A VM4 usa `172.26.24.4/25` e alcança a sub-rede B pela VM2.
2. Instale o Exim e o servidor IMAP do Dovecot. Crie quatro contas locais com diretório pessoal. Defina uma senha para cada conta quando solicitado e aceite os campos de identificação padrão.

   ```sh
   apt-get update
   apt-get install exim4 dovecot-imapd

   adduser correio1
   adduser correio2
   adduser correio3
   adduser correio4
   ```

## Configurar o correio

Em `/etc/mailname`, deixe apenas a linha `trabalho202624.com.br`. Em `/etc/exim4/update-exim4.conf.conf`, ajuste as linhas abaixo e preserve as demais.

```sh
dc_eximconfig_configtype='internet'
dc_other_hostnames='trabalho202624.com.br'
dc_local_interfaces=''
dc_relay_domains=''
dc_relay_nets='127.0.0.1 ; 172.26.24.0/25 ; 172.26.24.128/25'
dc_localdelivery='mail_spool'
```

O Exim entrega as mensagens do domínio local em `/var/mail/<usuário>`. O Dovecot dos pacotes Debian 12 e 13 usa essa mesma caixa de entrada por padrão, autentica pelas contas locais e fornece IMAP com TLS na porta 993. Mantenha as configurações padrão de caixa postal e TLS do Dovecot.

```sh
update-exim4.conf
service exim4 stop
service exim4 start
service dovecot stop
service dovecot start
```

## Configurar o cliente e testar

Em um cliente da intranet, adicione as contas `correio1@trabalho202624.com.br` a `correio4@trabalho202624.com.br` manualmente no Thunderbird ou em outro cliente SMTP/IMAP.

| Parâmetro | Recebimento | Envio |
| --- | --- | --- |
| Servidor | `172.26.24.4` | `172.26.24.4` |
| Protocolo e porta | IMAP, 993 | SMTP, 25 |
| Segurança da conexão | SSL/TLS | Nenhuma |
| Autenticação | Senha normal, com o login local (por exemplo, `correio1`) | Nenhuma, o Exim autoriza o envio pelo endereço da intranet |

O IMAP usa o certificado local do Debian. Se o cliente solicitar uma exceção, confira se o certificado exibido é o da VM4 do laboratório antes de aceitá-la.

Envie de `correio1` para `correio2`, de `correio2` para `correio3`, de `correio3` para `correio4` e de `correio4` para `correio1`. Em cada conta, abra a caixa de entrada e confira o remetente, o assunto e o corpo recebido via IMAP.

## Referências

- Prática da Aula 06, item 2 para o Exim e procedimento de reinício do Dovecot. O enunciado pede IMAP, que é fornecido pelo pacote `dovecot-imapd`.
- [Configuração do Exim no Debian](https://manpages.debian.org/bookworm/exim4-config/update-exim4.conf.8.en.html).
