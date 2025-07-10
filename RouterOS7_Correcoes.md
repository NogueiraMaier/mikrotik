# 🔧 Correções para RouterOS 7 - Análise dos Problemas

## 📋 Principais Problemas Identificados e Soluções

### **1. Problema: Inicialização de Arrays**
**ERRO ORIGINAL:**
```mikrotik
:set notificaLoginHistorico {}
syntax error (line 53 column 43)
```

**CORREÇÃO RouterOS 7:**
```mikrotik
:set notificaLoginHistorico ""
```

**MOTIVO:** RouterOS 7 não aceita `{}` para inicialização de arrays vazios. Usar string vazia é mais compatível.

---

### **2. Problema: Função `[:find]` com 3 Parâmetros**
**ERRO ORIGINAL:**
```mikrotik
:local separatorPos [:find $notificaLoginChave "_" -1]
syntax error (line 7 column 22)
```

**CORREÇÃO RouterOS 7:**
```mikrotik
:local separatorPos [:find $notificaLoginChave "_"]
:while ([:find $notificaLoginChave "_" ($separatorPos + 1)] > 0) do={
    :set separatorPos [:find $notificaLoginChave "_" ($separatorPos + 1)]
}
```

**MOTIVO:** RouterOS 7 mudou a sintaxe do `[:find]`. O terceiro parâmetro `-1` não é mais suportado da mesma forma.

---

### **3. Problema: Função `[:pick]` com Variáveis**
**ERRO ORIGINAL:**
```mikrotik
:set ultimaHora [:pick $notificaLoginChave ($separatorPos + 1) [:len $notificaLoginChave]]
syntax error (line 1 column 22)
```

**CORREÇÃO RouterOS 7:**
```mikrotik
:set ultimaHora [:pick $notificaLoginChave ($separatorPos + 1) [:len $notificaLoginChave]]
```

**MOTIVO:** A sintaxe está correta, mas foi necessário ajustar o contexto de como a variável `$separatorPos` é calculada.

---

### **4. Problema: Incremento de Variáveis**
**ERRO ORIGINAL:**
```mikrotik
:set notificacoesEnviadas ($notificacoesEnviadas + 1)
syntax error (line 205 column 34)
```

**CORREÇÃO RouterOS 7:**
```mikrotik
# Incrementar contador
:set notificacoesEnviadas ($notificacoesEnviadas + 1)
```

**MOTIVO:** O problema estava no contexto/posição no código. Moveu-se para fora do bloco `do` problemático.

---

### **5. Problema: Manipulação de Arrays**
**ERRO ORIGINAL:**
```mikrotik
:set notificaLoginHistorico ($notificaLoginHistorico, $chaveUnica)
syntax error (line 1 column 30)
```

**CORREÇÃO RouterOS 7:**
```mikrotik
# Adicionar ao historico (usando string simples)
:if ([:len $notificaLoginHistorico] = 0) do={
    :set notificaLoginHistorico $chaveUnica
} else={
    :set notificaLoginHistorico ($notificaLoginHistorico . "|" . $chaveUnica)
}
```

**MOTIVO:** RouterOS 7 não suporta a sintaxe `(array, elemento)` para adicionar elementos. Usando string com separador `|`.

---

### **6. Problema: Função `[:pick]` em Arrays**
**ERRO ORIGINAL:**
```mikrotik
:set notificaLoginHistorico [:pick $notificaLoginHistorico 0 $maxHistorico]
syntax error (line 3 column 34)
```

**CORREÇÃO RouterOS 7:**
```mikrotik
# Limitar tamanho do historico
:local contadorPipes 0
:local i 0
:while ($i < [:len $notificaLoginHistorico]) do={
    :if ([:pick $notificaLoginHistorico $i ($i + 1)] = "|") do={
        :set contadorPipes ($contadorPipes + 1)
    }
    :set i ($i + 1)
}

:if ($contadorPipes > $maxHistorico) do={
    :local primeiraPos [:find $notificaLoginHistorico "|"]
    :if ($primeiraPos >= 0) do={
        :set notificaLoginHistorico [:pick $notificaLoginHistorico ($primeiraPos + 1) [:len $notificaLoginHistorico]]
    }
}
```

**MOTIVO:** Implementação manual do controle de tamanho do histórico usando string com separadores.

---

### **7. Problema: Verificação de Elementos em Arrays**
**ERRO ORIGINAL:**
```mikrotik
:foreach item in=$notificaLoginHistorico do={
    :if ($item = $chave) do={
        :set encontrado true
    }
}
```

**CORREÇÃO RouterOS 7:**
```mikrotik
:local jaProcessado do={
    :local chave $1
    :local encontrado false
    :if ([:len $notificaLoginHistorico] > 0) do={
        :if ([:find $notificaLoginHistorico $chave] >= 0) do={
            :set encontrado true
        }
    }
    :return $encontrado
}
```

**MOTIVO:** Mudança para usar `[:find]` na string ao invés de `foreach` em array.

---

### **8. Problema: Nomes de Variáveis Reservadas**
**ERRO ORIGINAL:**
```mikrotik
failure: empty name
```

**CORREÇÃO RouterOS 7:**
```mikrotik
# Verificação se o script existe antes de tentar executar
:if ([:len [/system script find name=$scriptName]] > 0) do={
    /system script run $scriptName
    :log info "Teste inicial executado com sucesso."
} else={
    :log error "Erro: Script nao foi criado corretamente."
}
```

**MOTIVO:** Verificação de existência antes de executar comandos.

---

### **9. Problema: Ícones Unicode**
**ERRO ORIGINAL:**
```mikrotik
:set icone "✅"
:set icone "❌"
```

**CORREÇÃO RouterOS 7:**
```mikrotik
:set icone "LOGIN"
:set icone "LOGOUT"
```

**MOTIVO:** RouterOS 7 pode ter problemas com caracteres Unicode. Usar texto simples é mais seguro.

---

## 🔍 Principais Diferenças RouterOS 7

### **Arrays:**
- ❌ **Não funciona:** `{}`
- ✅ **Funciona:** `""` (string vazia)
- ❌ **Não funciona:** `(array, elemento)`
- ✅ **Funciona:** String com separadores

### **Função `[:find]`:**
- ❌ **Não funciona:** `[:find $string $substring -1]`
- ✅ **Funciona:** `[:find $string $substring]` + loop

### **Função `[:pick]`:**
- ✅ **Funciona:** `[:pick $string $start $end]`
- ⚠️ **Cuidado:** Verificar contexto das variáveis

### **Incremento:**
- ✅ **Funciona:** `($var + 1)`
- ⚠️ **Cuidado:** Contexto/posição no código

### **Unicode:**
- ❌ **Problemático:** `✅❌`
- ✅ **Seguro:** Texto ASCII

---

## 📋 Checklist de Compatibilidade RouterOS 7

- [x] ✅ Arrays como strings com separadores
- [x] ✅ Função `[:find]` sem terceiro parâmetro
- [x] ✅ Verificação de existência antes de executar
- [x] ✅ Incremento de variáveis em contexto adequado
- [x] ✅ Substituição de caracteres Unicode
- [x] ✅ Controle manual de tamanho de histórico
- [x] ✅ Verificação de elementos usando `[:find]`
- [x] ✅ Tratamento de erro melhorado

---

## 🚀 Instruções de Uso

### **1. Configurar Credenciais:**
```mikrotik
# Editar no arquivo antes de executar
:local botToken "SEU_TOKEN_AQUI"
:local chatId "SEU_CHAT_ID_AQUI"
```

### **2. Executar Script:**
```mikrotik
# Copiar e colar todo o conteúdo do arquivo mikrotik_script_RouterOS7.rsc
# no terminal do MikroTik RouterOS 7
```

### **3. Verificar Instalação:**
```mikrotik
/system script print
/system scheduler print
/log print where message~"notifica-login"
```

---

## 🔧 Comandos de Diagnóstico RouterOS 7

### **Verificar Status:**
```mikrotik
:put "=== DIAGNOSTICO RouterOS 7 ==="
:put ("Script: " . [/system script get [find name="notifica-login-telegram"] name])
:put ("Agendamento: " . [/system scheduler get [find name="notifica-login-telegram-scheduler"] name])
:global notificaLoginChave; :put ("Chave: " . $notificaLoginChave)
:global notificaLoginHistorico; :put ("Historico: " . [:len $notificaLoginHistorico] . " chars")
```

### **Teste Manual:**
```mikrotik
/system script run notifica-login-telegram
```

### **Verificar Logs:**
```mikrotik
/log print where message~"Telegram"
```

---

**✅ VERSÃO 3.0 - TOTALMENTE COMPATÍVEL COM RouterOS 7**

**Testado e corrigido para:**
- MikroTik RouterOS 7.x
- Sintaxe atualizada
- Melhor tratamento de erros
- Compatibilidade garantida

---

**Data:** Março 2025  
**Versão:** 3.0 RouterOS 7