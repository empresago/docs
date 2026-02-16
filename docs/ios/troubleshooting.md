---
sidebar_position: 6
---

# Troubleshooting

Resolução de problemas comuns ao usar o GoAB SDK para iOS.

## Problemas de inicialização

### SDK não inicializa

**Sintomas:**
- `isInitialized()` retorna `false`
- Sempre retorna valores padrão
- Erro nos logs ao inicializar

**Possíveis causas:**
1. Configuração inválida
2. Problemas de rede
3. Token de API inválido
4. URL base incorreta

**Soluções:**

```swift
// 1. Validar configuração
func validateConfig(accountId: Int, apiToken: String) -> Bool {
    accountId > 0 && !apiToken.isEmpty
}

// 2. Inicializar com tratamento de erro
Task {
    do {
        if validateConfig(accountId: 12345, apiToken: "your-token") {
            try await sdk.initialize()
        } else {
            print("GoAB: Configuração inválida")
        }
    } catch {
        print("GoAB: Erro ao inicializar - \(error)")
        // Usar valores padrão
    }
}
```

### Timeout na inicialização

**Sintomas:**
- SDK demora para inicializar
- Logs mostram timeout
- App parece travar

**Soluções:**

```swift
// 1. Aumentar timeout
let sdk = GoABSDKFactory.create(
    accountId: 12345,
    apiToken: "your-api-token",
    timeoutSeconds: 60
)

// 2. Inicializar em background
Task.detached(priority: .utility) {
    try? await sdk.initialize()
}
```

## Problemas de rede

### Falha ao buscar experimentos

**Sintomas:**
- Sempre retorna valores padrão
- Erro de rede nos logs
- Experimentos não atualizam

**Possíveis causas:**
1. Sem conexão
2. URL da API incorreta
3. Token inválido
4. Firewall ou proxy bloqueando

**Soluções:**

```swift
// 1. Verificar conectividade (exemplo com Network framework)
import Network

let monitor = NWPathMonitor()
monitor.pathUpdateHandler = { path in
    if path.status == .satisfied {
        Task { try? await sdk.initialize() }
    } else {
        print("GoAB: Sem conexão - usando cache local")
    }
}
monitor.start(queue: DispatchQueue.global())

// 2. Usar URL correta e token válido
let sdk = GoABSDKFactory.create(
    accountId: 12345,
    apiToken: "your-valid-token",
    timeoutSeconds: 30
)

// 3. Tratar falhas de rede
Task {
    do {
        try await sdk.initialize()
    } catch let error as URLError where error.code == .notConnectedToInternet {
        print("GoAB: Sem rede - usando cache local")
    } catch {
        print("GoAB: Erro - \(error)")
    }
}
```

### Experimentos não são atualizados

**Sintomas:**
- Valores antigos
- Mudanças no servidor não aparecem
- `refreshExperiments()` não surte efeito

**Soluções:**

```swift
// 1. Forçar atualização
sdk.refreshExperiments()

// 2. Limpar cache e recarregar
sdk.clearCache()
sdk.refreshExperiments()

// 3. Garantir que está inicializado
if sdk.isInitialized() {
    sdk.refreshExperiments()
} else {
    print("GoAB: SDK não inicializado")
}
```

## Problemas de valores

### Valores incorretos ou tipo errado

**Sintomas:**
- Tipo errado (String em vez de Bool)
- Valores inesperados
- Crash ao fazer cast

**Soluções:**

```swift
// 1. Ler valor e fazer cast seguro
func getValueSafely(key: String, defaultValue: Any) -> Any {
    let value = sdk.getValue(key, defaultValue: defaultValue)
    print("GoAB: \(key) = \(value) (\(type(of: value))")
    return value
}

// 2. Converter tipos explicitamente
func getBooleanValue(key: String, defaultValue: Bool) -> Bool {
    let value = sdk.getValue(key, defaultValue: defaultValue)
    if let b = value as? Bool { return b }
    if let s = value as? String { return s.lowercased() == "true" }
    return defaultValue
}

// 3. Usar valor padrão seguro
let buttonText = sdk.getValue("button_text", defaultValue: "Clique Aqui") as? String ?? "Clique Aqui"
```

### Sempre retorna valor padrão

**Sintomas:**
- Experimentos não aplicam
- Sempre o default
- Alterações no servidor não refletem

**Possíveis causas:**
1. SDK não inicializado
2. Chave do experimento errada
3. Usuário fora do experimento
4. Rede

**Soluções:**

```swift
// 1. Verificar inicialização
guard sdk.isInitialized() else {
    print("GoAB: SDK não inicializado")
    return
}

// 2. Conferir chave
let value = sdk.getValue("button_color", defaultValue: "#FF0000")
print("GoAB: Valor obtido: \(value)")

// 3. Inicializar e aguardar um pouco
Task {
    try? await sdk.initialize()
    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1s
    let value = sdk.getValue("button_color", defaultValue: "#FF0000")
    print("GoAB: Após init: \(value)")
}
```

## Problemas de performance

### SDK lento

**Sintomas:**
- App lento
- UI trava na inicialização
- Timeout em operações

**Soluções:**

```swift
// 1. Inicializar em background
Task.detached(priority: .utility) {
    try? await sdk.initialize()
}

// 2. getValue usa cache quando disponível
let value = sdk.getValue("key", defaultValue: "default")

// 3. Timeout menor em dev
let sdk = GoABSDKFactory.create(
    accountId: 12345,
    apiToken: "your-api-token",
    timeoutSeconds: 10
)
```

### Uso alto de memória

**Sintomas:**
- App consome muita memória
- Possível warning de memória
- Performance pior

**Soluções:**

```swift
// 1. Limpar cache periodicamente
Task {
    try? await Task.sleep(nanoseconds: 24 * 60 * 60 * 1_000_000_000) // 24h
    sdk.clearCache()
}

// 2. Evitar requisições desnecessárias
let value = sdk.getValue("key", defaultValue: "default")
if (value as? String) == "default" {
    // Usar default sem novas chamadas
}
```

## Problemas de usuário

### setUserId não atualiza experimentos

**Sintomas:**
- `setUserId` não muda experimentos
- Valores antigos permanecem
- Usuário parece não mudar

**Soluções:**

```swift
// 1. Verificar se SDK está inicializado
guard sdk.isInitialized() else { return }

// 2. Atualizar e aguardar
Task {
    await sdk.setUserId("new_user_id")
    try? await Task.sleep(nanoseconds: 1_000_000_000)
    let current = sdk.getCurrentUserId()
    print("GoAB: Usuário atual: \(current ?? "nil")")
}

// 3. Limpar e definir novo usuário
Task {
    await sdk.clearActiveUsers()
    await sdk.setUserId("new_user_id")
}
```

### Usuário não persiste

**Sintomas:**
- Usuário some ao reiniciar
- `getCurrentUserId()` retorna `nil`
- Experimentos não carregam

**Soluções:**

```swift
// 1. Garantir que o usuário foi salvo
Task {
    await sdk.setUserId("user123")
    let saved = await sdk.getUserId()
    print("GoAB: Usuário salvo: \(saved ?? "nil")")
}

// 2. Definir userId na configuração (se o SDK suportar AppContext)
let config = GoABConfig(
    accountId: 12345,
    apiToken: "your-api-token",
    timeoutSeconds: 30,
    appContext: AppContext(userId: "user123")
)
```

## Logs e debug

### Ver logs no Xcode

- Use **Console** (View → Debug Area → Activate Console).
- Filtre por "GoAB" ou pelo nome do seu app.

### Debug de valores

```swift
func debugExperimentValues() {
    let keys = ["button_color", "show_banner", "max_retries"]
    for key in keys {
        let value = sdk.getValue(key, defaultValue: NSNull())
        print("GoAB: \(key) = \(value) (\(type(of: value)))")
    }
}
```

## Exemplo de configuração para debug

```swift
class DebugGoABManager {
    let sdk: GoABSDK
    
    init() {
        sdk = GoABSDKFactory.create(
            accountId: 12345,
            apiToken: "debug-token",
            timeoutSeconds: 60
        )
    }
    
    func initializeWithDebug() async {
        print("DebugGoAB: Iniciando inicialização...")
        do {
            try await sdk.initialize()
            while !sdk.isInitialized() {
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
            print("DebugGoAB: SDK inicializado")
            testExperimentValues()
        } catch {
            print("DebugGoAB: Erro - \(error)")
        }
    }
    
    private func testExperimentValues() {
        let keys = ["test_key_1", "test_key_2", "test_key_3"]
        for key in keys {
            let value = sdk.getValue(key, defaultValue: "default_value")
            print("DebugGoAB: \(key) = \(value)")
        }
    }
}
```

## Contato e suporte

Se o problema continuar:

1. Confira os logs no Xcode
2. Teste com configuração mínima (accountId, apiToken)
3. Verifique rede e URL da API
4. Entre em contato com o suporte técnico
