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
  - Regras documentadas no README. Em rede isolada no WSL, passaram 20 verificações de liberação e bloqueio, incluindo dois pings e verificação do SNAT. O canal de dados passivo foi acrescentado à configuração. O teste anterior cobriu a porta 21. Falta validar uma transferência pelo Squid na appliance.
- [ ] **VM1 — Testar firewall.** Conferir os fluxos permitidos nos sentidos previstos e verificar o bloqueio dos demais, incluindo acesso direto de um cliente interno a Web e FTP externos.
- [ ] **VM1 — HTB.** Configurar entrada de 50 MB/s (Web 25, FTP 15, demais 10) e saída de 20 MB/s (Web 10, SMTP 5, demais 5), conforme as restrições de compartilhamento do enunciado.
  - Estrutura de classes aceita no WSL antes da inclusão dos filtros finais. A classificação de Web, FTP e SMTP está configurada no README. Falta aplicar e medir as taxas com tráfego simultâneo na appliance.
- [ ] **VM1 — Testar HTB.** Medir as classes sob tráfego simultâneo e verificar que, na entrada, os demais fluxos não usam a sobra de Web ou FTP e, na saída, os demais fluxos não usam a sobra de Web.
- [ ] **VM3 — HTTP, HTTPS e PHP.** Seguir o README na appliance e testar HTTP, HTTPS com certificado e execução de PHP.
- [x] **VM3 — Testes no Debian Docker.** Validar HTTP, HTTPS com certificado de laboratório e execução de PHP a partir de um cliente da intranet.
- [ ] **VM4 — DNS.** Configurar as zonas direta e reversa de `trabalho202624.com.br` e habilitar o cache. Testar resolução direta e reversa na intranet e resolução externa pelo cache. Documentar o procedimento de registro no Registro.br.
  - Debian 12 em Docker: 28 consultas A/PTR e dois testes de MX passaram nas sub-redes A e B. Com a diretiva de recursão, o teste isolado no WSL confirmou o cache nas duas sub-redes. Do segmento externo, o BIND respondeu à zona do projeto e recusou consultas recursivas e ao cache. Falta aplicar e validar na appliance com a VM1.
- [x] **VM4 — SMTP e IMAP na appliance.** Configurar quatro caixas postais na Redes2-VM4 e validar envio SMTP, entrega e leitura por IMAP com TLS, com cliente de teste isolado na sub-rede A.
- [x] **VM4 — Testes no Debian Docker.** Validar envio SMTP a partir da intranet e entrega e leitura por IMAP com TLS nas quatro caixas em Debian 12 e 13.
- [x] **VM5 — Samba na appliance.** Configurar TRAB202624 e arquivos24 e validar a escrita dos dois editores e a leitura dos dois leitores, com escrita negada aos leitores, usando cliente de teste isolado na sub-rede B.
- [x] **VM5 — CUPS na appliance.** Configurar a fila PDF e confirmar a geração e abertura do PDF de teste na VM5.
- [x] **VM5 — Testes no Debian Docker.** Validar os dois editores, os dois leitores e a recusa de senha incorreta no Samba. Enviar um trabalho IPP da sub-rede A e conferir o conteúdo do PDF gerado e o bloqueio da administração remota do CUPS.
- [x] **VM6 — Proxy.** Documentar em VM6/README.md a instalação do Squid, o cadastro de usuários e a edição do squid.conf.
- [x] **VM6 — Testes no Debian Docker.** Validar login, acesso HTTP e HTTPS permitido, bloqueio dos domínios e subdomínios pedidos, filtro do termo “sexo” em HTTP e bloqueio entre 23h e 8h com relógio simulado.
- [ ] **VM6 — Validação final.** Aplicar a configuração na appliance, cadastrar usuários, testar com um navegador da intranet e validar a integração com o firewall da VM1. Confirmar com o professor o escopo do filtro por termo em HTTPS.

## Entrega

- [ ] Preparar o relatório com requisitos, topologia, serviços, procedimentos de instalação e configuração e uso.
- [ ] Preparar a demonstração prática com os testes de rede e dos serviços.
