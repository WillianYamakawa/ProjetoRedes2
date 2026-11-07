# Plano de execução — ProjetoRedes2

## O que foi feito em Redes 1

O enunciado (p. 1–2) pedia dividir 172.26.N.0/24 em seis sub-redes, montar quatro gateways Linux com roteamento estático, fazer NAT na VM1 e usar pelo menos duas VMs adicionais como hosts para os testes.

Os quatro scripts usam N=21. Os blocos atendem à capacidade solicitada: Rede 1 em 172.26.21.240/28, Rede 2 em 172.26.21.192/27, Rede 3 em 172.26.21.224/28, Rede 4 em 172.26.21.0/25, Rede 5 em 172.26.21.128/27 e Rede 6 em 172.26.21.160/27. A VM1 liga a Rede 1 à rede externa com SNAT. Pela Rede 1, a VM2 liga as Redes 2 e 3, a VM3 liga a Rede 4 e a VM4 liga as Redes 5 e 6. Os scripts configuram IPs e rotas estáticas e ativam o encaminhamento IPv4 nos quatro gateways. O IP externo da VM1 ficou com um marcador e o gateway registrado é o do ambiente anterior. O material disponível contém os quatro scripts de gateway. A configuração das VMs clientes e os testes não puderam ser verificados a partir desses arquivos.

## Redes 2 — configuração de rede

Usar a appliance Linux do professor nas seis VMs. Montar três segmentos distintos no virtualizador, conforme o diagrama (p. 3): rede do laboratório, sub-rede A (172.26.24.0/25) e sub-rede B (172.26.24.128/25). Ligar apenas a interface externa da VM1 ao segmento do laboratório.

O grupo em Redes 2 é 24. Os IPs internos da tabela já estão nos scripts. Antes de executar o rede.sh da VM1, preencher IP_EXTERNO com o IPv4 e o prefixo e GATEWAY_EXTERNO com o IPv4 do gateway do laboratório. Conferir os nomes das interfaces na appliance. A ordem e o preenchimento estão no README.md da VM1.

| VM | Interfaces e endereços | Gateway padrão | Rota estática adicional |
|---|---|---|---|
| VM1 | enp0s3 no laboratório, enp0s8 em A: 172.26.24.1/25 | Gateway do laboratório | 172.26.24.128/25 via 172.26.24.2 |
| VM2 | enp0s3 em A: 172.26.24.2/25, enp0s8 em B: 172.26.24.129/25 | 172.26.24.1 | — |
| VM3 | enp0s3 em A: 172.26.24.3/25 | 172.26.24.1 | 172.26.24.128/25 via 172.26.24.2 |
| VM4 | enp0s3 em A: 172.26.24.4/25 | 172.26.24.1 | 172.26.24.128/25 via 172.26.24.2 |
| VM5 | enp0s3 em B: 172.26.24.130/25 | 172.26.24.129 | — |
| VM6 | enp0s3 em B: 172.26.24.131/25 | 172.26.24.129 | — |

As rotas da VM3 e da VM4 para B fazem o tráfego entre as duas sub-redes passar pela VM2 nos dois sentidos. O gateway padrão da VM3 e da VM4 é a VM1, também usada para o retorno das conexões externas previstas no enunciado.

## Ordem de implementação e verificação

1. Confirmar os parâmetros e montar os adaptadores nos três segmentos. Usar o console das VMs, pois a configuração substitui os IPs das interfaces.
2. Usar o rede.sh de cada pasta, de VM1 a VM6. Os arquivos seguem os comandos da prática da Aula 11 para parada da configuração automática, limpeza de IP, configuração das interfaces e inclusão de rotas.
3. Aplicar a rede na ordem VM1, VM2, VM3, VM4, VM5 e VM6. Habilitar o encaminhamento IPv4 na VM1 e na VM2. Configurar SNAT somente na VM1, pela interface do laboratório e com o IP externo confirmado. Reservar as regras finais de firewall para a etapa dos serviços, pois elas dependem dos servidores e dos fluxos do enunciado.
4. Conferir os IPs com ifconfig e as rotas com route -n. Usar ping da VM3 para a VM5 e da VM5 para a VM3, e da VM5 ou VM6 para um IP externo conhecido que responda a ICMP. O ping valida a conectividade. Para verificar a tradução, usar um destino externo controlado e conferir o endereço de origem visto do lado externo, com o Wireshark da prática da Aula 3, em um host de teste no segmento do laboratório.
5. Na etapa seguinte, criar o arquivo de serviços separado em cada pasta conforme os papéis do diagrama. Quando houver edição manual dentro da VM, criar um README.md na pasta dessa VM com a ordem dos scripts, o caminho de cada arquivo a editar e os valores ou trechos a alterar.

## Fontes permitidas para os comandos

- Dentro de materiais_professor, Aula 11 - 20102026 / RCII_Aula11 - Prática.pdf.txt, p. 2–3: ifconfig, ip a flush, parada da configuração automática, route -n, route add default gw, route add -net, encaminhamento IPv4 e SNAT. A seção tem o título “NAT MASQUERADE”, mas a regra publicada usa SNAT.
- Aula 13 - 03112026 / RCII_Aula13 - Prática.pdf.txt: su - e ping. Usar somente as formas pertinentes à configuração e ao teste de rede.
- Aula 03 - 25082026 / RCII_Aula3 - Prática.txt.txt, item 3(a): captura com Wireshark para conferir o IP de origem após o SNAT.
- Antes de incluir qualquer comando, localizar sua forma no material do professor, inclusive para rodar os arquivos ou verificar o NAT. Adaptar apenas os parâmetros da topologia. Se faltar um comando documentado, registrar a pendência.

## VM6 — plano do proxy Squid

1. Aplicar VM6/rede.sh depois das redes da VM1 e da VM2. A VM6 usa 172.26.24.131/25, com gateway 172.26.24.129.
2. Criar VM6/servicos.sh com a instalação do Squid. Seguir a prática da Aula 08 para instalar o pacote, editar /etc/squid/squid.conf e parar e iniciar o serviço depois da edição. Manter a porta 3128.
3. Criar VM6/README.md com a sequência rede.sh, servicos.sh, edição manual e reinício. No squid.conf, manter as regras padrão de portas, aplicar os bloqueios antes da permissão geral e liberar apenas clientes autenticados das duas sub-redes internas. Encerrar com a negação dos demais acessos.
4. Bloquear instagram.com, tiktok.com e facebook.com, incluindo subdomínios. Bloquear o termo “sexo” nas URLs HTTP. Dividir o bloqueio noturno em duas faixas, de 23h até a meia-noite e da meia-noite até 8h, pelo horário da VM6.
5. Testar em um cliente configurado com o proxy 172.26.24.131:3128. Verificar credenciais válidas e inválidas, um site permitido em HTTP e HTTPS, os três domínios bloqueados, uma URL HTTP com o termo e o bloqueio dentro e fora do horário. Validar a integração com o firewall da VM1 na etapa da VM1.

A instalação está em VM6/servicos.sh e o procedimento completo está em VM6/README.md. A prática da Aula 08 é a referência de instalação, edição e reinício. A documentação oficial do Squid complementa o cadastro de usuários e as ACLs, conforme autorizado para a VM6. A configuração passou nos testes em Debian 12 no Docker. Falta validar na appliance e com o firewall da VM1. Em HTTPS via CONNECT, o caminho e a consulta da URL ficam criptografados. Confirmar com o professor se o teste por palavra em HTTP atende ao requisito.
