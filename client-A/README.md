# Conectar o Thunderbird ao correio da VM4

Conecte o Adaptador 1 do cliente à rede interna A no VirtualBox e execute o `rede.sh` desta pasta como root. O script aponta o DNS para a VM4. Confira se `host vm4.trabalho202624.com.br` retorna `172.26.24.4`.

## Adicionar a conta

No Thunderbird, adicione uma conta de e-mail existente. Informe o endereço `correio1@trabalho202624.com.br` e a senha definida para `correio1` na VM4. Selecione **Configurar manualmente**.

| Campo | Entrada | Saída |
| --- | --- | --- |
| Protocolo | IMAP | SMTP |
| Servidor | `vm4.trabalho202624.com.br` | `vm4.trabalho202624.com.br` |
| Porta | `993` | `25` |
| Segurança da conexão | SSL/TLS | STARTTLS |
| Autenticação | Senha normal | Sem autenticação |
| Nome de usuário | `correio1` | Deixe em branco |

Se o Thunderbird avisar sobre o certificado de laboratório, confira se o certificado exibido é o da VM4 antes de aceitar a exceção. Use o endereço completo no campo de e-mail e apenas `correio1` no campo de usuário IMAP.

## Testar envio e recebimento

1. Adicione `correio2@trabalho202624.com.br` com a senha de `correio2` e use `correio2` como usuário IMAP. Reutilize o mesmo servidor SMTP.
2. Envie uma mensagem de `correio1` para `correio2@trabalho202624.com.br`.
3. Abra a caixa de entrada de `correio2` e confira o remetente, o assunto e o corpo da mensagem.
