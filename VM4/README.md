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

## DNS direto, reverso e cache

1. Na VM4, com a rede aplicada, instale o BIND9 como administrador.

   ```sh
   apt-get update
   apt-get install bind9
   ```

2. Use os arquivos de [dns/](dns/) como modelo da prática da Aula 05. Edite `/etc/bind/named.conf.local` para incluir as duas zonas declaradas no modelo. Crie `/etc/bind/db.trabalho202624.com.br` e `/etc/bind/db.172.26.24` com o conteúdo dos respectivos modelos.
3. Os registros iniciais cobrem as seis VMs. `vm2` identifica a interface da sub-rede A e `vm2-b` a da sub-rede B. Para cada cliente da intranet, adicione seu nome e IP como registro A e seu último octeto como registro PTR, seguindo os exemplos. Aumente o serial do arquivo de cada zona alterada.
4. Em `/etc/bind/named.conf.options`, adicione a linha abaixo dentro do bloco `options { ... };`. Se já houver uma diretiva `allow-recursion` nesse bloco, atualize-a. Ela permite a recursão e o uso do cache nas duas sub-redes da intranet e no próprio servidor.

   ```conf
   allow-recursion { localhost; 172.26.24.0/25; 172.26.24.128/25; };
   ```

5. Pare e inicie o serviço conforme a prática.

   ```sh
   service named stop
   service named start
   ```

6. Em um cliente de cada sub-rede, execute as consultas abaixo. Repita para cada VM e cliente cadastrado. Confira se a resolução direta e a reversa correspondem ao mesmo nome e IP, se o MX aponta para a VM4 e se a consulta externa resolve pela VM4. A resolução externa depende da saída DNS pela VM1.

   ```sh
   host vm5.trabalho202624.com.br 172.26.24.4
   host 172.26.24.130 172.26.24.4
   host -t MX trabalho202624.com.br 172.26.24.4
   host www.registro.br 172.26.24.4
   ```

   Para confirmar o cache, repita a consulta externa antes do vencimento do TTL e observe com o Wireshark se a VM4 responde sem repetir a consulta externa. Da rede do laboratório, confira também que a consulta de um nome interno funciona e que a consulta de um domínio externo pelo BIND retorna `REFUSED`.

7. Nos clientes Linux que usarão o DNS diretamente, ajuste `/etc/resolv.conf` como na prática e teste um nome curto com `host vm5`.

   ```text
   domain trabalho202624.com.br
   search trabalho202624.com.br
   nameserver 172.26.24.4
   ```

### Procedimento de registro do domínio

1. Pesquise `trabalho202624.com.br` no Registro.br e, se estiver disponível, selecione **Registrar**.
2. Entre na conta do titular ou faça o cadastro. Informe o CPF ou CNPJ do titular e preencha os dados solicitados. Aceite o contrato e envie a solicitação.
3. Para o registro, use os servidores autoritativos do Registro.br ou informe os servidores públicos próprios ou da hospedagem. Os endereços privados da intranet são usados na configuração do laboratório.
4. Acompanhe as mensagens do Registro.br, resolva as pendências indicadas e efetue o pagamento conforme as instruções. Confira a situação do domínio no painel.

Referências para DNS e registro. Prática da Aula 05, itens 2 e 3, Aula 05 teórica para `host -t MX`, prática da Aula 03 para captura no Wireshark e [tutorial oficial do Registro.br](https://registro.br/ajuda/tutoriais-administrativos/).
