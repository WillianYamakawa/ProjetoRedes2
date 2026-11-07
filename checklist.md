# Checklist — Projeto Redes 2, grupo 24

## Rede implementada e validada no Docker

- [x] Criar um `rede.sh` para cada VM, da VM1 à VM6, e documentar a ordem de execução no `AGENTS.md`.
- [x] Documentar no `VM1/README.md` como preencher `IP_EXTERNO` (IPv4/prefixo) e `GATEWAY_EXTERNO` (IPv4).
- [x] Configurar IPs fixos e rotas para `172.26.24.0/25` (VM1 a VM4) e `172.26.24.128/25` (VM2, VM5 e VM6).
- [x] Habilitar o encaminhamento IPv4 na VM1 e na VM2 e configurar o SNAT na VM1.
- [x] Rodar os scripts em seis contêineres Debian 12 e conferir interfaces, rotas e segmentos contra o diagrama.
- [x] Validar 30 pings entre VMs, a passagem entre as sub-redes pela VM2 e seis pings para um destino externo simulado. Confirmar por captura o IP de origem da VM1 após o SNAT.

## Rede na appliance do professor

- [ ] Montar os três segmentos do diagrama e conferir os nomes das interfaces nas seis VMs.
- [ ] Preencher o IP com prefixo e o gateway reais do laboratório no `VM1/rede.sh`.
- [ ] Rodar os scripts na ordem VM1 a VM6 e verificar `service NetworkManager stop`. No contêiner Debian sem systemd ativo, o comando retornou `unrecognized service`.
- [ ] Repetir os testes de rotas, conectividade entre as sub-redes e SNAT a partir de um cliente da intranet.

## Serviços, firewall e QoS

Usar os comandos de materiais_professor. Manter a rede em rede.sh e documentar os comandos de serviço no README.md de cada VM, com a ordem de execução, os arquivos a editar e o que alterar.

- [ ] **VM1 — Firewall.** Aplicar bloqueio inicial e liberar ICMP entre redes internas e externa, acesso externo a HTTP/HTTPS, DNS e SMTP internos, consultas externas do DNS cache e acesso a HTTP/HTTPS e FTP externos somente pelo proxy.
- [ ] **VM1 — Testar firewall.** Conferir os fluxos permitidos nos sentidos previstos e verificar o bloqueio dos demais, incluindo acesso direto de um cliente interno a Web e FTP externos.
- [ ] **VM1 — HTB.** Configurar entrada de 50 MB/s (Web 25, FTP 15, demais 10) e saída de 20 MB/s (Web 10, SMTP 5, demais 5), conforme as restrições de compartilhamento do enunciado.
- [ ] **VM1 — Testar HTB.** Medir as classes sob tráfego simultâneo e verificar que, na entrada, os demais fluxos não usam a sobra de Web ou FTP e, na saída, os demais fluxos não usam a sobra de Web.
- [ ] **VM2 — DHCP.** Configurar o serviço indicado no diagrama e testar em um cliente a concessão de IP, máscara, gateway e DNS.
- [ ] **VM3 — HTTP, HTTPS e PHP.** Seguir o README na appliance e testar HTTP, HTTPS com certificado e execução de PHP.
- [ ] **VM3 — Webmail.** Implementar e testar envio e leitura em integração com a VM4.
- [ ] **VM4 — DNS.** Configurar as zonas direta e reversa de `trabalho202624.com.br` e habilitar o cache. Testar resolução direta e reversa na intranet e resolução externa pelo cache. Documentar o procedimento de registro no Registro.br.
- [ ] **VM4 — SMTP e IMAP.** Configurar o envio pela intranet, quatro caixas postais e um cliente de e-mail. Testar envio, entrega e leitura por IMAP.
- [ ] **VM5 — Samba.** Configurar o grupo `TRAB202624` e o compartilhamento `arquivos24`, com quatro usuários. Testar leitura e escrita para dois usuários e somente leitura para os outros dois.
- [ ] **VM5 — CUPS.** Configurar uma impressora PDF e testar a impressão a partir de um cliente.
- [x] **VM6 — Proxy.** Documentar em VM6/README.md a instalação do Squid, o cadastro de usuários e a edição do squid.conf.
- [x] **VM6 — Testes no Debian Docker.** Validar login, acesso HTTP e HTTPS permitido, bloqueio dos domínios e subdomínios pedidos, filtro do termo “sexo” em HTTP e bloqueio entre 23h e 8h com relógio simulado.
- [ ] **VM6 — Validação final.** Aplicar a configuração na appliance, cadastrar usuários, testar com um navegador da intranet e validar a integração com o firewall da VM1. Confirmar com o professor o escopo do filtro por termo em HTTPS.

## Entrega

- [ ] Preparar o relatório com requisitos, topologia, serviços, procedimentos de instalação e configuração e uso.
- [ ] Preparar a demonstração prática com os testes de rede e dos serviços.
