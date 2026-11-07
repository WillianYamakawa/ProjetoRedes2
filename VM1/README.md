# VM1 — rede do laboratório

1. Confirme que a `enp0s3` está ligada à rede do laboratório e a `enp0s8` à sub-rede `172.26.24.0/25`. Se os nomes na appliance forem diferentes, ajuste as referências a essas interfaces no `rede.sh`.
2. Edite o início do `rede.sh` antes de aplicar a configuração. Em `IP_EXTERNO`, informe o IPv4 atribuído à VM1 seguido de uma barra e do prefixo. Em `GATEWAY_EXTERNO`, informe o IPv4 do gateway do laboratório, sem prefixo. Mantenha as aspas nos dois valores.
3. No console da VM1, entre como root com `su -` e aplique o `rede.sh`. Se for executar as linhas manualmente, cole também as duas atribuições de variáveis no mesmo terminal, antes dos demais comandos.
4. Aplique os arquivos de rede das VMs 2 a 6 nessa ordem. A configuração da VM1 limpa a tabela NAT. Aplique-a antes do firewall e do HTB.

## Firewall IPv4

Aplique no console da VM1, depois de `rede.sh`. O filtro cobre o tráfego encaminhado entre a rede do laboratório (`enp0s3`) e a intranet (`enp0s8`). A VM1 mantém o SNAT de `rede.sh`. Para testar a entrada, adicione no cliente Linux do laboratório uma rota para a intranet via o IPv4 externo da VM1, usando `route add -net 172.26.24.0/24 gw IP_DA_VM1`. Acesse os IPs internos dos servidores por essa rota.

O Squid usa FTP passivo por padrão. Abra uma nova sessão FTP depois de aplicar o bloco, para que o rastreamento acompanhe a negociação desde o início.

```sh
modprobe nf_conntrack_ftp
modprobe nf_nat_ftp

iptables -t raw -C PREROUTING -i enp0s8 -p tcp -s 172.26.24.131 --dport 21 -j CT --helper ftp ||
iptables -t raw -A PREROUTING -i enp0s8 -p tcp -s 172.26.24.131 --dport 21 -j CT --helper ftp

iptables -P FORWARD DROP
iptables -F FORWARD

iptables -A FORWARD -i enp0s3 -o enp0s8 -p icmp -d 172.26.24.0/24 -j ACCEPT
iptables -A FORWARD -i enp0s8 -o enp0s3 -p icmp -s 172.26.24.0/24 -j ACCEPT

# HTTP e HTTPS externos para a VM3.
iptables -A FORWARD -i enp0s3 -o enp0s8 -p tcp -d 172.26.24.3 --dport 80 -j ACCEPT
iptables -A FORWARD -i enp0s8 -o enp0s3 -p tcp -s 172.26.24.3 --sport 80 -j ACCEPT
iptables -A FORWARD -i enp0s3 -o enp0s8 -p tcp -d 172.26.24.3 --dport 443 -j ACCEPT
iptables -A FORWARD -i enp0s8 -o enp0s3 -p tcp -s 172.26.24.3 --sport 443 -j ACCEPT

# DNS da VM4 para o laboratório e consultas da VM4 a servidores externos.
iptables -A FORWARD -i enp0s3 -o enp0s8 -p udp -d 172.26.24.4 --dport 53 -j ACCEPT
iptables -A FORWARD -i enp0s8 -o enp0s3 -p udp -s 172.26.24.4 --sport 53 -j ACCEPT
iptables -A FORWARD -i enp0s3 -o enp0s8 -p tcp -d 172.26.24.4 --dport 53 -j ACCEPT
iptables -A FORWARD -i enp0s8 -o enp0s3 -p tcp -s 172.26.24.4 --sport 53 -j ACCEPT
iptables -A FORWARD -i enp0s8 -o enp0s3 -p udp -s 172.26.24.4 --dport 53 -j ACCEPT
iptables -A FORWARD -i enp0s3 -o enp0s8 -p udp -d 172.26.24.4 --sport 53 -j ACCEPT
iptables -A FORWARD -i enp0s8 -o enp0s3 -p tcp -s 172.26.24.4 --dport 53 -j ACCEPT
iptables -A FORWARD -i enp0s3 -o enp0s8 -p tcp -d 172.26.24.4 --sport 53 -j ACCEPT

# SMTP da VM4 nos dois sentidos.
iptables -A FORWARD -i enp0s3 -o enp0s8 -p tcp -d 172.26.24.4 --dport 25 -j ACCEPT
iptables -A FORWARD -i enp0s8 -o enp0s3 -p tcp -s 172.26.24.4 --sport 25 -j ACCEPT
iptables -A FORWARD -i enp0s8 -o enp0s3 -p tcp -s 172.26.24.4 --dport 25 -j ACCEPT
iptables -A FORWARD -i enp0s3 -o enp0s8 -p tcp -d 172.26.24.4 --sport 25 -j ACCEPT

# Saída Web e canal de controle FTP da VM6.
iptables -A FORWARD -i enp0s8 -o enp0s3 -p tcp -s 172.26.24.131 --dport 80 -j ACCEPT
iptables -A FORWARD -i enp0s3 -o enp0s8 -p tcp -d 172.26.24.131 --sport 80 -j ACCEPT
iptables -A FORWARD -i enp0s8 -o enp0s3 -p tcp -s 172.26.24.131 --dport 443 -j ACCEPT
iptables -A FORWARD -i enp0s3 -o enp0s8 -p tcp -d 172.26.24.131 --sport 443 -j ACCEPT
iptables -A FORWARD -i enp0s8 -o enp0s3 -p tcp -s 172.26.24.131 --dport 21 -m conntrack --ctstate NEW,ESTABLISHED --ctdir ORIGINAL -j ACCEPT
iptables -A FORWARD -i enp0s3 -o enp0s8 -p tcp -d 172.26.24.131 --sport 21 -m conntrack --ctstate ESTABLISHED --ctdir REPLY -j ACCEPT

# Dados FTP passivos negociados pelo canal de controle da VM6.
iptables -A FORWARD -i enp0s8 -o enp0s3 -p tcp -s 172.26.24.131 -m conntrack --ctstate RELATED,ESTABLISHED --ctdir ORIGINAL -m helper --helper ftp -j ACCEPT
iptables -A FORWARD -i enp0s3 -o enp0s8 -p tcp -d 172.26.24.131 -m conntrack --ctstate ESTABLISHED --ctdir REPLY -m helper --helper ftp -j ACCEPT

iptables -L
```

A prática da Aula 11 (item 7) usa regras separadas para ida e volta, com seleção por porta de origem ou destino. Para o FTP, o helper acompanha apenas o controle da VM6 na porta 21. O primeiro pacote do canal de dados passivo precisa estar relacionado a essa negociação. O módulo de NAT acompanha a conexão de dados traduzida pela VM1.

Do cliente do laboratório, use `ping` para os IPs da intranet, abra HTTP e HTTPS da VM3 no navegador, consulte `host vm3.trabalho202624.com.br 172.26.24.4` e teste `telnet 172.26.24.4 25`. Confira que `telnet 172.26.24.4 993` fica bloqueado. Da intranet, confira a resolução externa pelo DNS da VM4 e tente HTTP e HTTPS externos pelo Squid e diretamente. O acesso direto deve ficar bloqueado. Com um cliente que aceite uma URL FTP via proxy HTTP, baixe um arquivo de um servidor FTP externo de teste pelo Squid e confira o conteúdo recebido. Repita sem o proxy para verificar o bloqueio.

## HTB

A entrada na intranet é controlada na saída de `enp0s8`, e a saída para o laboratório na saída de `enp0s3`. As taxas em `kbps` seguem a unidade em bytes usada na prática da Aula 12. Os totais são 50 MB/s e 20 MB/s. A entrada reserva um pai de 40 MB/s para Web e FTP, deixando 10 MB/s para a classe padrão. Na saída, Web tem 10 MB/s separados e SMTP e demais compartilham os outros 10 MB/s.

Aplique depois do firewall. A tabela `mangle` marca os pacotes encaminhados antes do SNAT. O HTB lê essas marcas para distinguir Web, FTP e SMTP, e usa a classe padrão para os demais fluxos. O bloco recria as filas HTB da VM1 ao ser reaplicado.

```sh
iptables -t mangle -F FORWARD

# Entrada Web para a VM3 e respostas Web para o Squid.
iptables -t mangle -A FORWARD -i enp0s3 -o enp0s8 -p tcp -d 172.26.24.3 -m multiport --dports 80,443 -j MARK --set-mark 10
iptables -t mangle -A FORWARD -i enp0s3 -o enp0s8 -p tcp -d 172.26.24.131 -m multiport --sports 80,443 -j MARK --set-mark 10

# Entrada FTP para a VM6, incluindo o canal de dados negociado.
iptables -t mangle -A FORWARD -i enp0s3 -o enp0s8 -p tcp -d 172.26.24.131 --sport 21 -m conntrack --ctstate ESTABLISHED --ctdir REPLY -j MARK --set-mark 11
iptables -t mangle -A FORWARD -i enp0s3 -o enp0s8 -p tcp -d 172.26.24.131 -m conntrack --ctstate ESTABLISHED --ctdir REPLY -m helper --helper ftp -j MARK --set-mark 11

# Saída Web em resposta a clientes externos e SMTP iniciado pela VM4.
iptables -t mangle -A FORWARD -i enp0s8 -o enp0s3 -p tcp -s 172.26.24.3 -m multiport --sports 80,443 -m conntrack --ctdir REPLY -j MARK --set-mark 10
iptables -t mangle -A FORWARD -i enp0s8 -o enp0s3 -p tcp -s 172.26.24.4 --dport 25 -m conntrack --ctdir ORIGINAL -j MARK --set-mark 12

tc qdisc del dev enp0s8 root handle 1: 2>/dev/null || true
tc qdisc del dev enp0s3 root handle 2: 2>/dev/null || true

tc qdisc add dev enp0s8 root handle 1: htb default 13
tc class add dev enp0s8 parent 1: classid 1:1 htb rate 50000kbps ceil 50000kbps
tc class add dev enp0s8 parent 1:1 classid 1:2 htb rate 40000kbps ceil 40000kbps
tc class add dev enp0s8 parent 1:2 classid 1:10 htb rate 25000kbps ceil 40000kbps
tc class add dev enp0s8 parent 1:2 classid 1:11 htb rate 15000kbps ceil 40000kbps
tc class add dev enp0s8 parent 1:1 classid 1:13 htb rate 10000kbps ceil 10000kbps

tc filter add dev enp0s8 protocol ip parent 1:0 prio 1 handle 10 fw classid 1:10
tc filter add dev enp0s8 protocol ip parent 1:0 prio 1 handle 11 fw classid 1:11

tc qdisc add dev enp0s3 root handle 2: htb default 13
tc class add dev enp0s3 parent 2: classid 2:1 htb rate 20000kbps ceil 20000kbps
tc class add dev enp0s3 parent 2:1 classid 2:10 htb rate 10000kbps ceil 10000kbps
tc class add dev enp0s3 parent 2:1 classid 2:2 htb rate 10000kbps ceil 10000kbps
tc class add dev enp0s3 parent 2:2 classid 2:12 htb rate 5000kbps ceil 10000kbps
tc class add dev enp0s3 parent 2:2 classid 2:13 htb rate 5000kbps ceil 10000kbps

tc filter add dev enp0s3 protocol ip parent 2:0 prio 1 handle 10 fw classid 2:10
tc filter add dev enp0s3 protocol ip parent 2:0 prio 1 handle 12 fw classid 2:12

tc qdisc show dev enp0s8
tc class show dev enp0s8
tc filter show dev enp0s8
tc qdisc show dev enp0s3
tc class show dev enp0s3
tc filter show dev enp0s3
```

Na validação, gere tráfego Web, FTP e demais fluxos simultaneamente na entrada e tráfego Web, SMTP e demais fluxos na saída. Confira em quais classes os pacotes entraram e verifique se a classe padrão respeita os limites quando houver sobra nas classes reservadas.

Referências do professor para esta etapa. Aula 09, páginas 42 a 44, e prática da Aula 11, item 7, para o filtro. Aula 10, páginas 35 a 39, e prática da Aula 12 para a hierarquia e as classes HTB.

Referências complementares para o FTP passivo e a classificação por marca. [Extensões do iptables](https://manpages.debian.org/bookworm/iptables/iptables-extensions.8.en.html), [FTP passivo do Squid](https://www.squid-cache.org/Doc/config/ftp_passive/) e [classificador fw do tc](https://manpages.debian.org/bookworm/iproute2/tc-fw.8.en.html).
