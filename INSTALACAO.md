# 🔧 Guia de Instalação - Script MikroTik Corrigido

## Pré-requisitos

### 1. **Bot do Telegram**
- Criar bot via [@BotFather](https://t.me/BotFather)
- Anotar o `Bot Token`
- Adicionar o bot ao grupo/canal desejado
- Obter o `Chat ID` do grupo/canal

### 2. **MikroTik RouterOS**
- Versão 6.40 ou superior
- Acesso administrativo
- Conectividade com internet

---

## 📋 Passo a Passo

### **PASSO 1: Configurar Credenciais**

Antes de executar o script, altere as seguintes variáveis no arquivo `mikrotik_script_corrigido.rsc`:

```mikrotik
:local botToken "SEU_TOKEN_AQUI"
:local chatId "SEU_CHAT_ID_AQUI"
```

**Como obter o Chat ID:**
1. Adicione o bot [@userinfobot](https://t.me/userinfobot) ao seu grupo
2. Digite `/start` - ele mostrará o Chat ID
3. Remova o bot após obter o ID

### **PASSO 2: Executar o Script**

1. **Via Terminal MikroTik:**
```mikrotik
# Copie todo o conteúdo do arquivo mikrotik_script_corrigido.rsc
# Cole no terminal do MikroTik
# Pressione Enter para executar
```

2. **Via WinBox:**
- Abra WinBox
- Vá em `System > Scripts`
- Clique em `+` para adicionar novo script
- Cole o conteúdo
- Clique em `Run Script`

### **PASSO 3: Verificar Instalação**

```mikrotik
# Verificar se o script foi criado
/system script print

# Verificar se o agendamento foi criado
/system scheduler print

# Verificar logs
/log print where topics~"info"
```

---

## 🎯 Configurações Avançadas

### **Alterar Intervalo de Verificação**
```mikrotik
# Padrão: 1 minuto
# Para alterar para 30 segundos:
/system scheduler set [find name="notifica-login-telegram-scheduler"] interval=30s

# Para alterar para 5 minutos:
/system scheduler set [find name="notifica-login-telegram-scheduler"] interval=5m
```

### **Personalizar Mensagens**
Edite esta parte do script para customizar as mensagens:

```mikrotik
:local textoNotificacao ($icone . " [" . $routerName . "] Usuario: " . $usuario . " " . $acao . " | IP: " . $enderecoIP . " | Via: " . $metodo . " | Hora: " . $timestampLog)
```

### **Ajustar Histórico**
```mikrotik
# Padrão: 20 entradas
# Para alterar para 50:
:local maxHistorico 50
```

---

## 🛠️ Manutenção

### **Comandos Úteis**

```mikrotik
# Executar manualmente
/system script run notifica-login-telegram

# Habilitar/Desabilitar agendamento
/system scheduler enable notifica-login-telegram-scheduler
/system scheduler disable notifica-login-telegram-scheduler

# Remover script e agendamento
/system script remove notifica-login-telegram
/system scheduler remove notifica-login-telegram-scheduler

# Verificar variáveis globais
:global notificaLoginChave; :put $notificaLoginChave
:global notificaLoginHistorico; :put $notificaLoginHistorico
```

### **Limpar Histórico**
```mikrotik
# Limpar histórico de notificações
:global notificaLoginHistorico; :set notificaLoginHistorico {}
:global notificaLoginChave; :set notificaLoginChave ""
```

---

## 🔍 Troubleshooting

### **Problema: Não recebe notificações**

1. **Verificar conectividade:**
```mikrotik
/tool fetch url="https://api.telegram.org" keep-result=no mode=https
```

2. **Verificar firewall:**
```mikrotik
/ip firewall filter print where comment~"Telegram"
```

3. **Testar bot token:**
```mikrotik
# Substitua TOKEN pelo seu token
/tool fetch url="https://api.telegram.org/botTOKEN/getMe" keep-result=no mode=https
```

### **Problema: Muitas notificações duplicadas**

```mikrotik
# Aumentar intervalo do scheduler
/system scheduler set [find name="notifica-login-telegram-scheduler"] interval=2m

# Ou limpar o histórico
:global notificaLoginHistorico; :set notificaLoginHistorico {}
```

### **Problema: Script não executa**

1. **Verificar permissões:**
```mikrotik
/system script set [find name="notifica-login-telegram"] policy=read,write,policy,test,password,sensitive
```

2. **Verificar logs de erro:**
```mikrotik
/log print where topics~"error"
```

---

## 📊 Monitoramento

### **Dashboard de Status**
```mikrotik
# Verificar status geral
:put ("Script: " . [/system script get [find name="notifica-login-telegram"] name])
:put ("Agendamento: " . [/system scheduler get [find name="notifica-login-telegram-scheduler"] name])
:put ("Intervalo: " . [/system scheduler get [find name="notifica-login-telegram-scheduler"] interval])
:put ("Desabilitado: " . [/system scheduler get [find name="notifica-login-telegram-scheduler"] disabled])

# Verificar últimas notificações
:global notificaLoginChave; :put ("Ultima notificacao: " . $notificaLoginChave)
:global notificaLoginHistorico; :put ("Historico: " . [:len $notificaLoginHistorico] . " entradas")
```

### **Logs Importantes**
```mikrotik
# Ver apenas logs do script
/log print where message~"notifica-login"

# Ver logs de hoje
/log print where time>=[/system clock get time]
```

---

## ⚠️ Considerações de Segurança

1. **Proteja o Token do Bot:**
   - Nunca compartilhe o token
   - Use um bot dedicado para este propósito

2. **Monitore o Chat ID:**
   - Verifique se apenas pessoas autorizadas têm acesso
   - Considere usar canal privado

3. **Firewall:**
   - As regras criadas são específicas para Telegram
   - Monitore logs de firewall regularmente

4. **Backup:**
   - Sempre faça backup antes de aplicar
   - Documente alterações feitas

---

## 📞 Suporte

Para problemas ou dúvidas:
1. Verifique os logs: `/log print where topics~"info"`
2. Teste execução manual: `/system script run notifica-login-telegram`
3. Consulte a documentação oficial do MikroTik

---

**Última atualização:** Março 2025  
**Versão:** 2.0 - Corrigida e Otimizada