# Script MikroTik Corrigido - Configuracao de agendamento dinamico com notificacoes Telegram
# Versao: 2.0 - Corrigida e otimizada
# Data: Marco 2025

:local scriptName "notifica-login-telegram"
:local schedulerName ($scriptName . "-scheduler")

# Passo 1: Verificar se o script existe
:if ([:len [/system script find name=$scriptName]] = 0) do={
    :log info "Script $scriptName nao encontrado. Criando script..."

    # Criar o script notifica-login-telegram (versao corrigida)
    /system script add name=$scriptName source={
        # Configuracoes globais
        :global notificaLoginChave
        :global notificaLoginHistorico
        
        # Configuracoes do bot Telegram
        :local botToken "5973276634:AAE9MdC7S8h5y3Lf_6qzB1EOwAeC8C-GTwQ"
        :local chatId "-1002751530697"
        :local routerName [/system identity get name]
        
        # Inicializacao de variaveis
        :local ultimaHora "1970-01-01 00:00:00"
        :local ultimaMensagem ""
        :local maxHistorico 20
        
        # Inicializar notificaLoginChave se nao existir
        :if ([:typeof $notificaLoginChave] = "nothing") do={
            :set notificaLoginChave ""
        }
        
        # Inicializar notificaLoginHistorico como array se nao existir
        :if ([:typeof $notificaLoginHistorico] = "nothing") do={
            :set notificaLoginHistorico {}
        }
        
        # Extrair ultima mensagem e hora de notificaLoginChave
        :if ([:len $notificaLoginChave] > 0) do={
            :local separatorPos [:find $notificaLoginChave "_" -1]
            :if ($separatorPos >= 0) do={
                :set ultimaMensagem [:pick $notificaLoginChave 0 $separatorPos]
                :set ultimaHora [:pick $notificaLoginChave ($separatorPos + 1) [:len $notificaLoginChave]]
            }
        }
        
        # Funcao melhorada para codificacao URL
        :local urlEncode do={
            :local input $1
            :local result ""
            :local i 0
            :while ($i < [:len $input]) do={
                :local char [:pick $input $i ($i + 1)]
                :if ($char = " ") do={
                    :set result ($result . "%20")
                } else={
                    :if ($char = "&") do={
                        :set result ($result . "%26")
                    } else={
                        :if ($char = "=") do={
                            :set result ($result . "%3D")
                        } else={
                            :if ($char = "+") do={
                                :set result ($result . "%2B")
                            } else={
                                :if ($char = "#") do={
                                    :set result ($result . "%23")
                                } else={
                                    :if ($char = "?") do={
                                        :set result ($result . "%3F")
                                    } else={
                                        :set result ($result . $char)
                                    }
                                }
                            }
                        }
                    }
                }
                :set i ($i + 1)
            }
            :return $result
        }
        
        # Funcao simplificada para comparacao de timestamps
        :local isNewer do={
            :local timestamp1 $1
            :local timestamp2 $2
            
            # Se timestamp2 for vazio ou muito antigo, timestamp1 e mais novo
            :if ([:len $timestamp2] = 0 || $timestamp2 = "1970-01-01 00:00:00") do={
                :return true
            }
            
            # Comparacao simples por string (funciona para formato YYYY-MM-DD HH:MM:SS)
            :return ($timestamp1 > $timestamp2)
        }
        
        # Funcao para verificar se ja foi processado
        :local jaProcessado do={
            :local chave $1
            :local encontrado false
            :foreach item in=$notificaLoginHistorico do={
                :if ($item = $chave) do={
                    :set encontrado true
                }
            }
            :return $encontrado
        }
        
        # Obter data/hora atual
        :local dataAtual [/system clock get date]
        :local horaAtual [/system clock get time]
        :local timestampAtual ($dataAtual . " " . $horaAtual)
        
        # Processar logs de conta (login/logout)
        :local logs [/log print as-value where topics~"account"]
        :local notificacoesEnviadas 0
        
        :foreach logEntry in=$logs do={
            :local mensagem ($logEntry->"message")
            :local hora ($logEntry->"time")
            :local data ($logEntry->"date")
            
            # Construir timestamp completo
            :local timestampLog ""
            :if ([:len $data] > 0) do={
                :set timestampLog ($data . " " . $hora)
            } else={
                :set timestampLog ($dataAtual . " " . $hora)
            }
            
            # Verificar se e mais recente que a ultima verificacao
            :if ([$isNewer $timestampLog $ultimaHora]) do={
                :local usuario ""
                :local enderecoIP ""
                :local metodo ""
                :local acao ""
                :local icone ""
                
                # Detectar login
                :if ([:find $mensagem "logged in"] >= 0) do={
                    :set acao "conectou"
                    :set icone "✅"
                    
                    # Extrair usuario
                    :local userPos [:find $mensagem "user "]
                    :if ($userPos >= 0) do={
                        :local userStart ($userPos + 5)
                        :local userEnd [:find $mensagem " logged"]
                        :if ($userEnd > $userStart) do={
                            :set usuario [:pick $mensagem $userStart $userEnd]
                        }
                    }
                    
                    # Extrair IP
                    :local fromPos [:find $mensagem "from "]
                    :if ($fromPos >= 0) do={
                        :local fromStart ($fromPos + 5)
                        :local fromEnd [:find $mensagem " via"]
                        :if ($fromEnd > $fromStart) do={
                            :set enderecoIP [:pick $mensagem $fromStart $fromEnd]
                        }
                    }
                    
                    # Extrair metodo
                    :local viaPos [:find $mensagem "via "]
                    :if ($viaPos >= 0) do={
                        :local viaStart ($viaPos + 4)
                        :set metodo [:pick $mensagem $viaStart [:len $mensagem]]
                    }
                }
                
                # Detectar logout
                :if ([:find $mensagem "logged out"] >= 0) do={
                    :set acao "desconectou"
                    :set icone "❌"
                    
                    # Extrair usuario
                    :local userPos [:find $mensagem "user "]
                    :if ($userPos >= 0) do={
                        :local userStart ($userPos + 5)
                        :local userEnd [:find $mensagem " logged"]
                        :if ($userEnd > $userStart) do={
                            :set usuario [:pick $mensagem $userStart $userEnd]
                        }
                    }
                    
                    # Extrair IP
                    :local fromPos [:find $mensagem "from "]
                    :if ($fromPos >= 0) do={
                        :local fromStart ($fromPos + 5)
                        :local fromEnd [:find $mensagem " via"]
                        :if ($fromEnd > $fromStart) do={
                            :set enderecoIP [:pick $mensagem $fromStart $fromEnd]
                        }
                    }
                    
                    # Extrair metodo
                    :local viaPos [:find $mensagem "via "]
                    :if ($viaPos >= 0) do={
                        :local viaStart ($viaPos + 4)
                        :set metodo [:pick $mensagem $viaStart [:len $mensagem]]
                    }
                }
                
                # Se encontrou uma acao valida
                :if ([:len $usuario] > 0 && [:len $enderecoIP] > 0 && [:len $acao] > 0) do={
                    :local chaveUnica ($usuario . "_" . $enderecoIP . "_" . $acao . "_" . $timestampLog)
                    
                    # Verificar se ja foi processado
                    :if (![$jaProcessado $chaveUnica]) do={
                        # Construir mensagem de notificacao
                        :local textoNotificacao ($icone . " [" . $routerName . "] Usuario: " . $usuario . " " . $acao . " | IP: " . $enderecoIP . " | Via: " . $metodo . " | Hora: " . $timestampLog)
                        
                        # Enviar notificacao via Telegram
                        :local urlTelegram ("https://api.telegram.org/bot" . $botToken . "/sendMessage?chat_id=" . $chatId . "&text=" . [$urlEncode $textoNotificacao])
                        
                        :do {
                            /tool fetch url=$urlTelegram keep-result=no mode=https
                            :log info ("Telegram enviado: " . $textoNotificacao)
                            :set notificacoesEnviadas ($notificacoesEnviadas + 1)
                        } on-error={
                            :log error ("Erro ao enviar Telegram: " . $textoNotificacao)
                        }
                        
                        # Atualizar controles
                        :set ultimaHora $timestampLog
                        :set ultimaMensagem ($usuario . "_" . $enderecoIP . "_" . $acao)
                        :set notificaLoginChave ($ultimaMensagem . "_" . $timestampLog)
                        
                        # Adicionar ao historico
                        :set notificaLoginHistorico ($notificaLoginHistorico, $chaveUnica)
                        
                        # Limitar tamanho do historico
                        :if ([:len $notificaLoginHistorico] > $maxHistorico) do={
                            :set notificaLoginHistorico [:pick $notificaLoginHistorico 0 $maxHistorico]
                        }
                    }
                }
            }
        }
        
        # Log de resumo
        :if ($notificacoesEnviadas > 0) do={
            :log info ("Processamento concluido. Enviadas " . $notificacoesEnviadas . " notificacoes.")
        } else={
            :log info "Nenhuma nova notificacao para enviar."
        }
        
    } policy=read,write,policy,test,password,sensitive
    
    :log info "Script $scriptName criado com sucesso."
} else={
    :log info "Script $scriptName ja existe."
    # Garantir permissoes do script
    /system script set [find name=$scriptName] policy=read,write,policy,test,password,sensitive
}

# Passo 2: Gerenciar agendamento
:local schedulerExistente [/system scheduler find name=$schedulerName]
:if ([:len $schedulerExistente] > 0) do={
    :log info "Agendamento $schedulerName ja existe. Atualizando..."
    /system scheduler set $schedulerExistente interval=1m on-event=("/system script run " . $scriptName) comment=("Monitoramento de logins via Telegram - Versao 2.0")
} else={
    :log info "Criando novo agendamento $schedulerName..."
    # Usar data/hora atual + 1 minuto para inicio
    :local dataInicio [/system clock get date]
    :local horaInicio [/system clock get time]
    
    /system scheduler add name=$schedulerName interval=1m on-event=("/system script run " . $scriptName) policy=read,write,policy,test,password,sensitive comment=("Monitoramento de logins via Telegram - Versao 2.0") start-date=$dataInicio start-time=$horaInicio
}

:log info "Agendamento $schedulerName configurado para script $scriptName."

# Passo 3: Configurar regra de firewall para Telegram
:local regraExistente [/ip firewall filter find comment="Permitir Telegram API"]
:if ([:len $regraExistente] = 0) do={
    /ip firewall filter add chain=output action=accept protocol=tcp dst-port=443 dst-address=149.154.160.0/20 comment="Permitir Telegram API"
    /ip firewall filter add chain=output action=accept protocol=tcp dst-port=443 dst-address=91.108.4.0/22 comment="Permitir Telegram API"
    :log info "Regras de firewall adicionadas para Telegram."
} else={
    :log info "Regras de firewall para Telegram ja existem."
}

# Passo 4: Configurar DNS se necessario
:if ([:len [/ip dns get servers]] = 0) do={
    /ip dns set servers=8.8.8.8,8.8.4.4
    :log info "Servidores DNS configurados."
}

# Passo 5: Teste inicial
:log info "Executando teste inicial do script $scriptName..."
/system script run $scriptName

# Passo 6: Verificacao final
:delay 5s
:local statusScheduler [/system scheduler get [find name=$schedulerName] disabled]
:if (!$statusScheduler) do={
    :log info "SUCCESS: Script $scriptName e agendamento $schedulerName configurados e ativos."
} else={
    :log warning "ATENCAO: Agendamento $schedulerName esta desabilitado."
}

:log info "Configuracao completa. Monitoramento de logins via Telegram ativo."