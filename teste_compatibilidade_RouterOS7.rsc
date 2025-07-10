# Script de Teste - RouterOS 7 Compatibilidade
# Execute este script primeiro para verificar se a sintaxe está funcionando

:put "=== TESTE DE COMPATIBILIDADE RouterOS 7 ==="
:put ""

# Teste 1: Inicialização de variáveis
:put "1. Testando inicialização de variáveis..."
:local testeString ""
:local testeArray ""
:if ([:typeof $testeString] = "str") do={
    :put "   ✅ String inicializada corretamente"
} else={
    :put "   ❌ Erro na inicialização de string"
}

# Teste 2: Função find
:put "2. Testando função [:find]..."
:local textoTeste "usuario_192.168.1.1_login_2025-03-15"
:local pos [:find $textoTeste "_"]
:if ($pos >= 0) do={
    :put ("   ✅ Função find funcionando: posição " . $pos)
} else={
    :put "   ❌ Erro na função find"
}

# Teste 3: Função pick
:put "3. Testando função [:pick]..."
:local resultado [:pick $textoTeste 0 7]
:if ($resultado = "usuario") do={
    :put "   ✅ Função pick funcionando: " . $resultado
} else={
    :put "   ❌ Erro na função pick"
}

# Teste 4: Incremento de variáveis
:put "4. Testando incremento de variáveis..."
:local contador 0
:set contador ($contador + 1)
:if ($contador = 1) do={
    :put "   ✅ Incremento funcionando: " . $contador
} else={
    :put "   ❌ Erro no incremento"
}

# Teste 5: Concatenação de strings
:put "5. Testando concatenação de strings..."
:local historico ""
:local novoItem "teste1"
:if ([:len $historico] = 0) do={
    :set historico $novoItem
} else={
    :set historico ($historico . "|" . $novoItem)
}
:if ($historico = "teste1") do={
    :put "   ✅ Concatenação funcionando: " . $historico
} else={
    :put "   ❌ Erro na concatenação"
}

# Teste 6: System identity
:put "6. Testando system identity..."
:local nomeRouter [/system identity get name]
:if ([:len $nomeRouter] > 0) do={
    :put ("   ✅ System identity funcionando: " . $nomeRouter)
} else={
    :put "   ❌ Erro no system identity"
}

# Teste 7: System clock
:put "7. Testando system clock..."
:local dataAtual [/system clock get date]
:local horaAtual [/system clock get time]
:if ([:len $dataAtual] > 0 && [:len $horaAtual] > 0) do={
    :put ("   ✅ System clock funcionando: " . $dataAtual . " " . $horaAtual)
} else={
    :put "   ❌ Erro no system clock"
}

# Teste 8: Logs
:put "8. Testando acesso aos logs..."
:local logs [/log print as-value where topics~"info"]
:if ([:len $logs] > 0) do={
    :put ("   ✅ Acesso aos logs funcionando: " . [:len $logs] . " entradas")
} else={
    :put "   ❌ Erro no acesso aos logs"
}

# Teste 9: Função personalizada
:put "9. Testando função personalizada..."
:local testeFunc do={
    :local entrada $1
    :return ("processado: " . $entrada)
}
:local resultado [$testeFunc "teste"]
:if ($resultado = "processado: teste") do={
    :put "   ✅ Função personalizada funcionando: " . $resultado
} else={
    :put "   ❌ Erro na função personalizada"
}

# Teste 10: Verificação de connectividade (opcional)
:put "10. Testando conectividade (opcional)..."
:do {
    /tool fetch url="https://www.google.com" keep-result=no mode=https
    :put "   ✅ Conectividade funcionando"
} on-error={
    :put "   ⚠️ Sem conectividade (normal se sem internet)"
}

:put ""
:put "=== TESTE CONCLUÍDO ==="
:put "Se todos os testes passaram, o script principal deve funcionar!"
:put ""