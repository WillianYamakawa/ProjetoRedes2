# VM5 — Samba e CUPS do grupo 24

## Instalação na appliance

1. No console da VM5, entre como administrador com `su -`. Execute o `rede.sh` após configurar a VM1 e a VM2. A VM5 usa `172.26.24.130/25` em `enp0s3`, com gateway `172.26.24.129`.
2. Confira a tabela de rotas exibida pelo `rede.sh` e teste a comunicação com o gateway e a VM3 (`172.26.24.3`).
3. Execute os comandos abaixo como administrador. A instalação precisa de acesso aos repositórios da appliance.

   ```sh
   apt-get update
   apt-get install samba smbclient cifs-utils
   apt-get install cups cups-core-drivers printer-driver-cups-pdf
   ```

## Samba

Crie as quatro contas locais e defina as senhas do Samba quando solicitado. Se uma conta já existir, pule o respectivo cadastro. Use a listagem final para verificar as quatro contas.

```sh
adduser --disabled-login --no-create-home editor1
adduser --disabled-login --no-create-home editor2
adduser --disabled-login --no-create-home leitor1
adduser --disabled-login --no-create-home leitor2

smbpasswd -a editor1
smbpasswd -a editor2
smbpasswd -a leitor1
smbpasswd -a leitor2
pdbedit -L
```

Crie o diretório se ele ainda não existir e aplique o modo da prática da aula. O modo 777 permite gravação a usuários locais. As restrições por conta abaixo se aplicam ao acesso pelo Samba.

```sh
mkdir /home/arquivos24
chmod 777 /home/arquivos24
```

Em `/etc/samba/smb.conf`, ajuste `workgroup = TRAB202624` na seção `[global]`. Adicione a seção abaixo ao final do arquivo. Se ela já existir, atualize a seção existente.

```ini
[arquivos24]
   path = /home/arquivos24
   available = yes
   guest ok = no
   valid users = editor1, editor2, leitor1, leitor2
   writable = no
   write list = editor1, editor2
   hosts allow = 127.0.0.1, 172.26.24.0/255.255.255.128, 172.26.24.128/255.255.255.128
   create mask = 0666
   force create mode = 0666
   directory mask = 0777
   force directory mode = 0777
```

Após salvar a configuração, reinicie o Samba.

```sh
service smbd stop
service smbd start
```

## CUPS

1. Abra `http://localhost:631/` no navegador da VM5. Em **Printers**, confira se o pacote criou uma fila PDF. Se necessário, use **Administration → Add Printer**, selecione o dispositivo CUPS-PDF e o modelo PDF correspondente. Se criar a fila, use o nome `PDF`.
2. Em **Administration**, habilite o compartilhamento de impressoras. Nas opções da fila, marque **Share This Printer**. Deixe a administração remota desabilitada.
3. Em `/etc/cups/cupsd.conf`, confira se o serviço escuta na porta 631 também no endereço da VM5. Preserve o socket Unix e os blocos de administração. No bloco `<Location />`, mantenha `Order allow,deny` e permita explicitamente `localhost`, `172.26.24.0/25` e `172.26.24.128/25` com diretivas `Allow`. Substitua uma regra genérica como `Allow @LOCAL` pelas redes explícitas.
4. Reinicie o CUPS após salvar a configuração.

   ```sh
   service cups stop
   service cups start
   ```

5. No cliente, adicione a impressora pelo endereço `ipp://172.26.24.130:631/printers/PDF`. Se reutilizou uma fila com outro nome, use o nome exibido em **Printers**.

## Testes na intranet

- Abra `smb://172.26.24.130/arquivos24` no gerenciador de arquivos Linux ou `\\172.26.24.130\arquivos24` no Windows. Abra uma nova sessão para cada usuário.
- Com `editor1` e `editor2`, teste leitura, criação, alteração e exclusão. Inclua a alteração de um arquivo criado pelo outro editor.
- Com `leitor1` e `leitor2`, abra um arquivo existente e confirme que as tentativas de criar, alterar e excluir são negadas. Confirme a recusa com senha incorreta.
- Envie uma página de teste pela fila IPP. Na VM5, confira se o trabalho foi concluído e abra o PDF gerado. Consulte `/etc/cups/cups-pdf.conf` para identificar a saída configurada em `Out` ou `AnonDirName`, conforme o usuário reconhecido pelo servidor.
- Repita o acesso aos dois serviços a partir de um cliente na sub-rede A para verificar o caminho pela VM2.

## Referências

- Prática da Aula 09, itens 2 e 3, para instalação, cadastro, reinício e administração local.
- [Configuração do Samba](https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html) e [compartilhamento de impressoras no CUPS](https://openprinting.github.io/cups/doc/sharing.html).
