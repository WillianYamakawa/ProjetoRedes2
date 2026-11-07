# VM1 — rede do laboratório

1. Confirme que a `enp0s3` está ligada à rede do laboratório e a `enp0s8` à sub-rede `172.26.24.0/25`. Se os nomes na appliance forem diferentes, ajuste as referências a essas interfaces no `rede.sh`.
2. Edite o início do `rede.sh` antes de aplicar a configuração. Em `IP_EXTERNO`, informe o IPv4 atribuído à VM1 seguido de uma barra e do prefixo. Em `GATEWAY_EXTERNO`, informe o IPv4 do gateway do laboratório, sem prefixo. Mantenha as aspas nos dois valores.
3. No console da VM1, entre como root com `su -` e aplique o `rede.sh`. Se for executar as linhas manualmente, cole também as duas atribuições de variáveis no mesmo terminal, antes dos demais comandos.
4. Aplique os arquivos de rede das VMs 2 a 6 nessa ordem. A configuração da VM1 limpa a tabela NAT. Aplique-a antes das futuras regras de firewall e redirecionamento.
