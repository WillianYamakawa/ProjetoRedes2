# VM6 — Proxy Squid

## Configurar

1. Com a rede da VM1 e da VM2 pronta, entre como root com `su -` no console da VM6. Na pasta que contém os scripts, rode `bash rede.sh` e confira o IP `172.26.24.131/25` e o gateway `172.26.24.129`.
2. Com acesso aos repositórios do Debian, rode `bash servicos.sh` como root. Confirme a instalação dos pacotes se o apt perguntar. O script instala o Squid e cadastra `proxy1` e `proxy2`. As senhas estão definidas nas variáveis `SENHA_PROXY1` e `SENHA_PROXY2` no início do script. Edite esses valores para trocar as senhas antes de rodar. O cadastro usa os valores do arquivo automaticamente. Como ficam legíveis no script, mantenha o arquivo restrito ao grupo. Ao rodar o script novamente, as senhas dessas duas contas são atualizadas e as demais contas são preservadas.

Para adicionar outro usuário ou trocar uma senha individualmente, use `htpasswd -B /etc/squid/squid.pass USUARIO`.

3. Edite `/etc/squid/squid.conf` com `nano` ou com o editor disponível na VM. Substitua todo o conteúdo pelo bloco abaixo e salve o arquivo.

```conf
http_port 3128

auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/squid.pass
acl autenticados proxy_auth REQUIRED
acl intranet src 172.26.24.0/25 172.26.24.128/25

acl portas_permitidas port 21 80 443
acl porta_https port 443
acl dominios_bloqueados dstdomain .instagram.com .tiktok.com .facebook.com
acl termo_bloqueado url_regex -i sexo
acl bloqueio_noite time 23:00-23:59
acl bloqueio_manha time 00:00-07:59

http_access deny !portas_permitidas
http_access deny CONNECT !porta_https
http_access deny bloqueio_noite
http_access deny bloqueio_manha
http_access deny dominios_bloqueados
http_access deny termo_bloqueado
http_access allow intranet autenticados
http_access deny all
```

4. Valide com `squid -k parse`. Se a configuração estiver válida, aplique-a com `service squid stop` e depois `service squid start`.

## Testar

Configure o navegador de um cliente da intranet para usar `172.26.24.131:3128` como proxy de HTTP e HTTPS.

- Entre com uma senha incorreta e depois com a senha válida. Confira que um destino permitido funciona com o login válido.
- Confira o bloqueio de Instagram, TikTok e Facebook, incluindo subdomínios.
- Confira o bloqueio de uma URL HTTP que contenha `sexo`. Em HTTPS, o túnel CONNECT expõe o domínio, e o caminho e a consulta da URL ficam criptografados.
- Confira o bloqueio às 23h e durante a madrugada, e o acesso a destinos permitidos a partir das 8h. A regra usa o horário local da VM6. Confira se o relógio e o fuso da VM correspondem ao horário do laboratório.

## Referências

- Aula 08 — prática de instalação e configuração do Squid em `materiais_professor`.
- [Autenticação com arquivo de senhas no Squid](https://wiki.squid-cache.org/ConfigExamples/Authenticate/Ncsa)
- [Helper de autenticação no Debian](https://manpages.debian.org/bookworm/squid/basic_ncsa_auth.8.en.html)
- [Diretivas de ACL do Squid](https://www.squid-cache.org/Doc/config/acl/)
- [Validação da configuração do Squid](https://wiki.squid-cache.org/SquidFaq/InstallingSquid)
- [HTTPS via CONNECT no Squid](https://wiki.squid-cache.org/Features/HTTPS)
