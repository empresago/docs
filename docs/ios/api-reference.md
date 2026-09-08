---
sidebar_position: 4
---

# API Reference

Documentação completa da API do GoAB SDK para iOS (Swift).

## GoABSDK

Classe principal do SDK que fornece a interface para interagir com experimentos e configurações remotas.

### Inicialização

O SDK é obtido através da factory. Não há construtor público.

### Métodos

#### `initialize(config: GoABConfig)` ou `initialize()`

Inicializa o SDK com a configuração fornecida (ou com a config usada na criação).

**Parâmetros (quando aplicável):**
- `config: GoABConfig` - Configuração do SDK

**Exemplo (async/await):**
```swift
Task {
    try await sdk.initialize()
    await MainActor.run { setupUI() }
}
```

**Exemplo (completion handler):**
```swift
sdk.initialize { result in
    switch result {
    case .success:
        DispatchQueue.main.async { self.setupUI() }
    case .failure(let error):
        print("GoAB init error: \(error)")
    }
}
```

#### `getValue(key: String, defaultValue: Any) -> Any`

Obtém o valor de uma chave de experimento.

**Parâmetros:**
- `key: String` - Chave do experimento
- `defaultValue: Any` - Valor padrão se a chave não for encontrada (obrigatório)

**Retorna:**
- `Any` - Valor da chave, resolvido pelo backend

**Ordem de resolução do valor** (o backend resolve tudo e o SDK só repassa):

1. **Override da variante** — se o usuário está na amostra de um experimento ativo que referencia a chave, vale o valor definido para a variante sorteada (o grupo de controle também pode ter override).
2. **Default da conta** — o valor cadastrado para a chave no registro de Remote Config da conta (vale para todos os apps).
3. **`defaultValue` do código** — usado **somente** se a chave não existe no registro da conta.

As chaves de Remote Config são um **registro por conta**: são cadastradas uma vez (nome, tipo e default) e valem para todos os apps; um experimento apenas referencia chaves existentes e sobrescreve o valor por variante.

**Exemplo:**
```swift
// String
let buttonText = sdk.getValue("button_text", defaultValue: "Clique Aqui") as? String ?? "Clique Aqui"

// Bool
let showFeature = sdk.getValue("show_new_feature", defaultValue: false) as? Bool ?? false

// Number
let maxRetries = sdk.getValue("max_retries", defaultValue: 3) as? Int ?? 3
```

#### `sendEvent(eventName: String, props: [String: Any] = [:])`

Envia um evento para analytics.

**Parâmetros:**
- `eventName: String` - Nome do evento
- `props: [String: Any]` - Propriedades do evento (opcional)

**Exemplo:**
```swift
// Evento simples
sdk.sendEvent("button_clicked")

// Evento com propriedades
sdk.sendEvent("purchase_completed", props: [
    "product_id": "prod_123",
    "price": 29.99,
    "currency": "BRL"
])
```

#### `refreshExperiments()`

Força a atualização dos experimentos do servidor.

**Exemplo:**
```swift
sdk.refreshExperiments()
```

#### `clearCache()`

Limpa o cache de experimentos.

**Exemplo:**
```swift
sdk.clearCache()
```

#### `isInitialized() -> Bool`

Verifica se o SDK está inicializado.

**Retorna:**
- `Bool` - `true` se inicializado, `false` caso contrário

**Exemplo:**
```swift
if sdk.isInitialized() {
    // SDK pronto para uso
}
```

#### `setUserId(_ newUserId: String)`

Atualiza o ID do usuário atual e recarrega os experimentos.

**Parâmetros:**
- `newUserId: String` - Novo ID do usuário

**Exemplo (async):**
```swift
Task {
    await sdk.setUserId("new_user_123")
}
```

#### `getCurrentUserId() -> String?`

Obtém o ID do usuário atual.

**Retorna:**
- `String?` - ID do usuário atual ou `nil`

**Exemplo:**
```swift
let userId = sdk.getCurrentUserId()
```

#### `clearActiveUsers()`

Limpa os experimentos ativos.

**Exemplo:**
```swift
Task {
    await sdk.clearActiveUsers()
}
```

#### `getUserId() -> String?`

Obtém o ID do usuário do repositório.

**Retorna:**
- `String?` - ID do usuário ou `nil`

**Exemplo:**
```swift
Task {
    let userId = await sdk.getUserId()
}
```

## GoABSDKFactory

Factory para criar instâncias do SDK.

### Métodos estáticos

#### `create(accountId: Int, apiToken: String, timeoutSeconds: Int) -> GoABSDK`

Cria uma nova instância do SDK.

**Parâmetros:**
- `accountId: Int` - ID da conta
- `apiToken: String` - Token de autenticação
- `timeoutSeconds: Int` - Timeout das requisições em segundos

**Retorna:**
- `GoABSDK` - Instância do SDK

**Exemplo:**
```swift
let sdk = GoABSDKFactory.create(
    accountId: 12345,
    apiToken: "your-api-token",
    timeoutSeconds: 30
)
```

#### `create(config: GoABConfig) -> GoABSDK`

Cria uma nova instância do SDK a partir de uma configuração.

**Parâmetros:**
- `config: GoABConfig` - Configuração do SDK

**Retorna:**
- `GoABSDK` - Instância do SDK

**Exemplo:**
```swift
let config = GoABConfig(
    accountId: 12345,
    apiToken: "your-api-token",
    timeoutSeconds: 30
)
let sdk = GoABSDKFactory.create(config: config)
```

## GoABConfig

Estrutura de configuração do SDK.

### Propriedades

| Propriedade | Tipo | Obrigatório | Descrição |
|-------------|------|-------------|-----------|
| `accountId` | Int | Sim | ID da conta |
| `apiToken` | String | Sim | Token de autenticação |
| `timeoutSeconds` | Int | Não | Timeout em segundos (padrão: 30) |
| `appContext` | AppContext? | Não | Contexto da aplicação (preenchido automaticamente) |

### Exemplo

```swift
struct GoABConfig {
    let accountId: Int
    let apiToken: String
    let timeoutSeconds: Int
    let appContext: AppContext?
}
```

## GoABConfig.AppContext

Contexto da aplicação com informações do dispositivo e usuário.

### Propriedades

| Propriedade | Tipo | Obrigatório | Descrição |
|-------------|------|-------------|-----------|
| `userId` | String? | Não | ID do usuário (gerado automaticamente se não fornecido) |
| `apiToken` | String? | Não | Token de autenticação |
| `bundleIdentifier` | String? | Não | Bundle ID do app (preenchido automaticamente) |
| `appVersion` | String? | Não | Versão do app (preenchido automaticamente) |
| `deviceId` | String? | Não | ID do dispositivo (preenchido automaticamente) |
| `deviceModel` | String? | Não | Modelo do dispositivo (preenchido automaticamente) |
| `osVersion` | String? | Não | Versão do iOS (preenchido automaticamente) |
| `screenResolution` | String? | Não | Resolução da tela (preenchido automaticamente) |
| `timezone` | String? | Não | Fuso horário (preenchido automaticamente) |
| `country` | String? | Não | País (preenchido automaticamente) |
| `language` | String? | Não | Idioma (preenchido automaticamente) |

### Exemplo

```swift
struct AppContext {
    var userId: String?
    var apiToken: String?
    var bundleIdentifier: String?
    var appVersion: String?
    var deviceId: String?
    var deviceModel: String?
    var osVersion: String?
    var screenResolution: String?
    var timezone: String?
    var country: String?
    var language: String?
}
```

## Exemplos de Uso

### Configuração simplificada

```swift
// O SDK preenche automaticamente as informações do dispositivo e do app
let sdk = GoABSDKFactory.create(
    accountId: 12345,
    apiToken: "your-api-token",
    timeoutSeconds: 30
)
```

### Uso básico (SwiftUI)

```swift
import SwiftUI

@main
struct MyApp: App {
    @StateObject private var sdkHolder = SDKHolder()
    
    var body: some Scene {
        WindowGroup {
            ContentView(sdk: sdkHolder.sdk)
                .task { await sdkHolder.initialize() }
        }
    }
}

class SDKHolder: ObservableObject {
    let sdk = GoABSDKFactory.create(
        accountId: 12345,
        apiToken: "your-api-token",
        timeoutSeconds: 30
    )
    
    func initialize() async {
        try? await sdk.initialize()
    }
}

struct ContentView: View {
    let sdk: GoABSDK
    
    var body: some View {
        VStack {
            Text(sdk.getValue("button_text", defaultValue: "Clique Aqui") as? String ?? "Clique Aqui")
            if sdk.getValue("show_banner", defaultValue: true) as? Bool == true {
                BannerView()
            }
        }
        .onTapGesture {
            sdk.sendEvent("button_clicked", props: ["button_id": "main_button"])
        }
    }
}
```

### Uso básico (UIKit)

```swift
import UIKit

class MainViewController: UIViewController {
    private let sdk = GoABSDKFactory.create(
        accountId: 12345,
        apiToken: "your-api-token",
        timeoutSeconds: 30
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            try? await sdk.initialize()
            await MainActor.run { setupUI() }
        }
    }
    
    private func setupUI() {
        let buttonText = sdk.getValue("button_text", defaultValue: "Clique Aqui") as? String ?? "Clique Aqui"
        let showBanner = sdk.getValue("show_banner", defaultValue: true) as? Bool ?? true
        
        button.setTitle(buttonText, for: .normal)
        bannerView.isHidden = !showBanner
    }
    
    @objc private func onButtonTap() {
        sdk.sendEvent("button_clicked", props: ["button_id": "main_button"])
    }
}
```

### Gerenciamento de usuário

```swift
// Atualizar usuário
Task {
    await sdk.setUserId("new_user_123")
}

// Obter usuário atual
let currentUserId = sdk.getCurrentUserId()

// Limpar experimentos ativos
Task {
    await sdk.clearActiveUsers()
}
```

### Tratamento de erros

```swift
Task {
    do {
        try await sdk.initialize()
        // SDK inicializado com sucesso
    } catch {
        print("GoAB: Erro ao inicializar SDK - \(error)")
        // Usar valores padrão
    }
}
```

## Próximos passos

- [Casos de Uso](./use-cases) - Exemplos práticos
- [Troubleshooting](./troubleshooting) - Resolução de problemas
- [Guia de Início Rápido](./getting-started) - Setup básico
