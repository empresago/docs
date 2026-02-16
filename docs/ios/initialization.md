---
sidebar_position: 3
---

# Inicialização

Configure e inicialize o GoAB SDK com todas as opções disponíveis.

## Configuração simplificada

### Factory

O SDK usa uma factory que preenche automaticamente as informações do dispositivo:

```swift
let sdk = GoABSDKFactory.create(
    accountId: 12345,
    apiToken: "your-token",
    timeoutSeconds: 30
)
```

### Parâmetros obrigatórios

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `accountId` | Int | ID da sua conta no GoAB |
| `apiToken` | String | Token de autenticação |

### Parâmetros opcionais

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|--------|-----------|
| `timeoutSeconds` | Int | 30 | Timeout das requisições em segundos |

## Configuração automática

O SDK preenche automaticamente as informações do dispositivo e do app:

### Informações preenchidas automaticamente

| Campo | Fonte | Exemplo |
|-------|-------|---------|
| `bundleIdentifier` | `Bundle.main.bundleIdentifier` | `com.yourapp.ios` |
| `appVersion` | `Bundle.main.infoDictionary` | `1.0.0` |
| `deviceId` | Identificador do dispositivo | `abc123...` |
| `deviceModel` | `utsname` | `iPhone14,2` |
| `osVersion` | `UIDevice.current.systemVersion` | `17.0` |
| `timezone` | `TimeZone.current` | `America/Sao_Paulo` |
| `country` | `Locale.current.regionCode` | `BR` |
| `language` | `Locale.current.languageCode` | `pt` |

## Inicialização

### Método 1: Factory (recomendado)

```swift
import GoABSDK

let sdk = GoABSDKFactory.create(
    accountId: 12345,
    apiToken: "your-api-token",
    timeoutSeconds: 30
)

Task {
    try? await sdk.initialize()
}
```

### Método 2: Com GoABConfig

```swift
let config = GoABConfig(
    accountId: 12345,
    apiToken: "your-api-token",
    timeoutSeconds: 30
)
let sdk = GoABSDKFactory.create(config: config)

Task {
    try? await sdk.initialize()
}
```

### Método 3: Injeção de dependência

Se você usa um container de DI (ex.: Swinject, manual):

```swift
// Exemplo com propriedade estática ou ambiente
enum DIContainer {
    static let sdk: GoABSDK = {
        GoABSDKFactory.create(
            accountId: 12345,
            apiToken: "your-api-token",
            timeoutSeconds: 30
        )
    }()
}
```

## Configurações avançadas

### Desenvolvimento

```swift
let sdk = GoABSDKFactory.create(
    accountId: 12345,
    apiToken: "dev-api-token",
    timeoutSeconds: 10
)
```

### Produção

```swift
let sdk = GoABSDKFactory.create(
    accountId: 12345,
    apiToken: "prod-api-token",
    timeoutSeconds: 30
)
```

### Timeout maior

```swift
let sdk = GoABSDKFactory.create(
    accountId: 12345,
    apiToken: "your-api-token",
    timeoutSeconds: 60
)
```

## Verificação de inicialização

### Status

```swift
if sdk.isInitialized() {
    let value = sdk.getValue("key", defaultValue: "default") as? String ?? "default"
} else {
    print("GoAB: SDK ainda não inicializado")
}
```

### Aguardar inicialização

```swift
Task {
    try? await sdk.initialize()
    
    while !sdk.isInitialized() {
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
    }
    
    await MainActor.run { applyExperiments() }
}
```

## Tratamento de erros

### Try/catch na inicialização

```swift
Task {
    do {
        try await sdk.initialize()
        print("GoAB: SDK inicializado com sucesso")
    } catch {
        print("GoAB: Erro ao inicializar - \(error)")
        applyDefaultValues()
    }
}
```

### Validação de parâmetros

```swift
func validateParams(accountId: Int, apiToken: String) -> Bool {
    accountId > 0 && !apiToken.isEmpty
}

if validateParams(accountId: 12345, apiToken: "your-api-token") {
    let sdk = GoABSDKFactory.create(
        accountId: 12345,
        apiToken: "your-api-token",
        timeoutSeconds: 30
    )
    Task { try? await sdk.initialize() }
} else {
    print("GoAB: Parâmetros inválidos")
}
```

## Exemplo completo

```swift
class MainViewController: UIViewController {
    private let sdk = GoABSDKFactory.create(
        accountId: 12345,
        apiToken: "your-api-token",
        timeoutSeconds: 30
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSDK()
    }
    
    private func setupSDK() {
        Task {
            do {
                try await sdk.initialize()
                await MainActor.run { applyExperiments() }
            } catch {
                print("GoAB: Erro ao inicializar - \(error)")
                await MainActor.run { applyDefaultValues() }
            }
        }
    }
    
    private func applyExperiments() {
        let buttonText = sdk.getValue("button_text", defaultValue: "Clique Aqui") as? String ?? "Clique Aqui"
        button.setTitle(buttonText, for: .normal)
    }
    
    private func applyDefaultValues() {
        button.setTitle("Clique Aqui", for: .normal)
    }
}
```

## Próximos passos

- [API Reference](./api-reference) - Métodos disponíveis
- [Casos de Uso](./use-cases) - Exemplos práticos
- [Troubleshooting](./troubleshooting) - Resolução de problemas
