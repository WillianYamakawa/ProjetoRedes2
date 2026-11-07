# VM5 — Samba e CUPS do grupo 24

## Instalação na appliance

1. No console da VM5, entre como administrador com `su -`. Execute o `rede.sh` após configurar a VM1 e a VM2. A VM5 usa `172.26.24.130/25` em `enp0s3`, com gateway `172.26.24.129`.
2. Execute os comandos abaixo como administrador. A instalação precisa de acesso aos repositórios da appliance.

   ```sh
   apt-get update
   apt-get install samba
   apt-get install cups cups-core-drivers printer-driver-cups-pdf
   ```

## Samba

Crie as quatro contas locais e defina as senhas do Samba quando solicitado. Aceite os valores padrão dos campos de identificação ao usar `adduser`. Se uma conta já existir, pule o respectivo cadastro. Use a listagem final para verificar as quatro contas.

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
   guest ok = no
   valid users = editor1, editor2, leitor1, leitor2
   writable = no
   write list = editor1, editor2
   hosts allow = 127.0.0.1, 172.26.24.0/255.255.255.128, 172.26.24.128/255.255.255.128
```

Após salvar a configuração, reinicie o Samba.

```sh
service smbd stop
service smbd start
```

## CUPS

Antes de abrir a interface de administração, inicie o CUPS se o serviço ainda estiver parado.

```sh
service cups start
```

Abra `http://localhost:631/` na VM5. Em **Printers**, confira se a fila PDF já existe. Se necessário, use **Administration → Add Printer**, selecione o dispositivo CUPS-PDF e o modelo **Generic CUPS-PDF Printer (w/ options)**. Use a fila existente ou crie uma chamada `PDF`.

## Testes

- A partir de um cliente da intranet, abra `smb://172.26.24.130/arquivos24`. Abra uma nova sessão para cada conta. Confirme que os dois editores conseguem criar, ler e alterar seus arquivos e que os dois leitores conseguem ler um arquivo existente, com a escrita negada.
- Na fila PDF do CUPS, envie uma página de teste e confirme que o PDF foi gerado. O caminho de saída está definido em `Out` ou `AnonDirName` no arquivo `/etc/cups/cups-pdf.conf`.

## Referências

- Prática da Aula 09, itens 2 e 3, para instalação, cadastro, reinício e administração local.
- [Configuração do Samba](https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html).
