# 🧪 Exemplos e Casos de Teste - Script MikroTik

## 📋 Casos de Teste

### **Teste 1: Instalação Básica**
```mikrotik
# 1. Verificar se não existe script anterior
/system script print

# 2. Executar script de instalação
# (Cole o conteúdo do mikrotik_script_corrigido.rsc)

# 3. Verificar criação
/system script print where name="notifica-login-telegram"
/system scheduler print where name="notifica-login-telegram-scheduler"

# 4. Verificar logs
/log print where message~"notifica-login"
```

**Resultado Esperado:**
```
Script notifica-login-telegram criado com sucesso.
Agendamento notifica-login-telegram-scheduler configurado para script notifica-login-telegram.
Regras de firewall adicionadas para Telegram.
SUCCESS: Script notifica-login-telegram e agendamento notifica-login-telegram-scheduler configurados e ativos.
```

---

### **Teste 2: Execução Manual**
```mikrotik
# Executar script manualmente
/system script run notifica-login-telegram

# Verificar logs de execução
/log print where message~"Processamento concluido"
```

**Resultado Esperado:**
```
Nenhuma nova notificacao para enviar.
OU
Processamento concluido. Enviadas X notificacoes.
```

---

### **Teste 3: Simulação de Login**
```mikrotik
# Criar usuário de teste
/user add name=teste-user password=123456 group=read

# Fazer login via SSH ou Telnet com o usuário teste
# (Isso deve gerar logs que serão capturados)

# Verificar logs
/log print where message~"logged in"

# Executar script para processar
/system script run notifica-login-telegram
```

**Resultado Esperado:**
- Notificação no Telegram: "✅ [RouterName] Usuario: teste-user conectou | IP: X.X.X.X | Via: ssh"

---

### **Teste 4: Verificar Controle de Duplicatas**
```mikrotik
# Executar script duas vezes seguidas
/system script run notifica-login-telegram
/system script run notifica-login-telegram

# Verificar logs
/log print where message~"Nenhuma nova notificacao"
```

**Resultado Esperado:**
- Primeira execução: processa novos logins
- Segunda execução: "Nenhuma nova notificacao para enviar"

---

## 🔧 Comandos de Diagnóstico

### **Verificar Status Completo**
```mikrotik
# Script personalizado para diagnóstico
{
:put "=== DIAGNOSTICO SCRIPT TELEGRAM ==="
:put ""

# Verificar script
:local scriptExists [/system script find name="notifica-login-telegram"]
:if ([:len $scriptExists] > 0) do={
    :put "✅ Script encontrado"
    :put ("   Politicas: " . [/system script get $scriptExists policy])
} else={
    :put "❌ Script NAO encontrado"
}

# Verificar agendamento
:local schedulerExists [/system scheduler find name="notifica-login-telegram-scheduler"]
:if ([:len $schedulerExists] > 0) do={
    :put "✅ Agendamento encontrado"
    :put ("   Intervalo: " . [/system scheduler get $schedulerExists interval])
    :put ("   Desabilitado: " . [/system scheduler get $schedulerExists disabled])
    :put ("   Proximo: " . [/system scheduler get $schedulerExists next-run])
} else={
    :put "❌ Agendamento NAO encontrado"
}

# Verificar firewall
:local firewallRules [/ip firewall filter find comment~"Telegram"]
:if ([:len $firewallRules] > 0) do={
    :put ("✅ Regras de firewall: " . [:len $firewallRules] . " encontradas")
} else={
    :put "❌ Regras de firewall NAO encontradas"
}

# Verificar variáveis globais
:global notificaLoginChave
:global notificaLoginHistorico
:put ("📊 Ultima chave: " . $notificaLoginChave)
:put ("📊 Historico: " . [:len $notificaLoginHistorico] . " entradas")

# Verificar conectividade
:put ""
:put "🌐 Testando conectividade..."
:do {
    /tool fetch url="https://api.telegram.org" keep-result=no mode=https
    :put "✅ Telegram API acessivel"
} on-error={
    :put "❌ Erro ao acessar Telegram API"
}

:put ""
:put "=== FIM DIAGNOSTICO ==="
}
```

---

## 📊 Exemplos de Mensagens

### **Mensagem de Login SSH**
```
✅ [MikroTik-Office] Usuario: admin conectou | IP: 192.168.1.100 | Via: ssh | Hora: 2025-03-15 10:30:45
```

### **Mensagem de Logout Web**
```
❌ [MikroTik-Office] Usuario: manager desconectou | IP: 192.168.1.50 | Via: web | Hora: 2025-03-15 11:15:20
```

### **Mensagem de Login Telnet**
```
✅ [MikroTik-Branch] Usuario: tech conectou | IP: 10.0.0.5 | Via: telnet | Hora: 2025-03-15 14:22:10
```

---

## 🔄 Casos de Uso Avançados

### **Caso 1: Múltiplos Roteadores**
```mikrotik
# Para cada roteador, alterar o nome para identificação
/system identity set name="MikroTik-Filial-01"
/system identity set name="MikroTik-Matriz"
/system identity set name="MikroTik-Backup"
```

### **Caso 2: Diferentes Intervalos por Localização**
```mikrotik
# Matriz (verificação mais frequente)
/system scheduler set [find name="notifica-login-telegram-scheduler"] interval=30s

# Filiais (verificação normal)
/system scheduler set [find name="notifica-login-telegram-scheduler"] interval=2m

# Backup (verificação menos frequente)
/system scheduler set [find name="notifica-login-telegram-scheduler"] interval=5m
```

### **Caso 3: Filtros por Usuário**
Para adicionar filtros por usuário específico, modifique esta parte do script:

```mikrotik
# Adicionar após a extração do usuário
:local usuariosMonitorados {"admin"; "manager"; "tech"}
:local monitorarUsuario false
:foreach usuarioPermitido in=$usuariosMonitorados do={
    :if ($usuario = $usuarioPermitido) do={
        :set monitorarUsuario true
    }
}

# Só processar se o usuário estiver na lista
:if ($monitorarUsuario) do={
    # ... resto do código de notificação
}
```

---

## 🚨 Cenários de Emergência

### **Cenário 1: Script com Erro**
```mikrotik
# Desabilitar agendamento
/system scheduler disable notifica-login-telegram-scheduler

# Verificar logs de erro
/log print where topics~"error"

# Remover script problemático
/system script remove notifica-login-telegram

# Reinstalar versão corrigida
```

### **Cenário 2: Muitas Notificações**
```mikrotik
# Parar temporariamente
/system scheduler disable notifica-login-telegram-scheduler

# Limpar histórico
:global notificaLoginHistorico; :set notificaLoginHistorico {}
:global notificaLoginChave; :set notificaLoginChave ""

# Aumentar intervalo
/system scheduler set [find name="notifica-login-telegram-scheduler"] interval=5m

# Reativar
/system scheduler enable notifica-login-telegram-scheduler
```

### **Cenário 3: Bot Telegram Inacessível**
```mikrotik
# Verificar conectividade
/tool fetch url="https://api.telegram.org/botSEU_TOKEN/getMe" keep-result=no mode=https

# Se falhar, verificar:
# 1. Firewall
/ip firewall filter print where comment~"Telegram"

# 2. DNS
/ip dns print

# 3. Rota padrão
/ip route print where dst-address=0.0.0.0/0
```

---

## 📈 Monitoramento de Performance

### **Métricas Importantes**
```mikrotik
# Verificar CPU durante execução
/system resource print

# Verificar memória
/system resource print

# Verificar logs por período
/log print where time>="10:00:00" and time<="11:00:00" and message~"Telegram"
```

### **Otimizações Recomendadas**
```mikrotik
# Para roteadores com muitos logs, aumentar intervalo
/system scheduler set [find name="notifica-login-telegram-scheduler"] interval=2m

# Para roteadores com poucos usuários, manter padrão
/system scheduler set [find name="notifica-login-telegram-scheduler"] interval=1m

# Limpar logs antigos periodicamente
/system logging set [find topics~"account"] action=memory
```

---

## 🎯 Validação Final

### **Checklist de Validação**
- [ ] Script criado sem erros
- [ ] Agendamento ativo
- [ ] Firewall configurado
- [ ] Teste manual funcionando
- [ ] Notificação recebida no Telegram
- [ ] Controle de duplicatas funcionando
- [ ] Logs sendo gerados corretamente
- [ ] Performance aceitável

### **Comando de Validação Completa**
```mikrotik
{
:put "=== VALIDACAO COMPLETA ==="
:local erros 0

# Teste 1: Script existe
:if ([:len [/system script find name="notifica-login-telegram"]] = 0) do={
    :put "❌ Script nao encontrado"
    :set erros ($erros + 1)
} else={
    :put "✅ Script encontrado"
}

# Teste 2: Agendamento existe e está ativo
:local scheduler [/system scheduler find name="notifica-login-telegram-scheduler"]
:if ([:len $scheduler] = 0) do={
    :put "❌ Agendamento nao encontrado"
    :set erros ($erros + 1)
} else={
    :if ([/system scheduler get $scheduler disabled]) do={
        :put "⚠️ Agendamento desabilitado"
        :set erros ($erros + 1)
    } else={
        :put "✅ Agendamento ativo"
    }
}

# Teste 3: Firewall configurado
:if ([:len [/ip firewall filter find comment~"Telegram"]] = 0) do={
    :put "❌ Firewall nao configurado"
    :set erros ($erros + 1)
} else={
    :put "✅ Firewall configurado"
}

# Teste 4: Conectividade
:do {
    /tool fetch url="https://api.telegram.org" keep-result=no mode=https
    :put "✅ Conectividade OK"
} on-error={
    :put "❌ Erro de conectividade"
    :set erros ($erros + 1)
}

# Resultado final
:put ""
:if ($erros = 0) do={
    :put "🎉 VALIDACAO COMPLETA - TUDO OK!"
} else={
    :put ("❌ VALIDACAO FALHOU - " . $erros . " erros encontrados")
}
:put "========================"
}
```

---

**Última atualização:** Março 2025  
**Versão:** 2.0 - Corrigida e Otimizada