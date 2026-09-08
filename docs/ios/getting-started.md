---
sidebar_position: 2
---

# Guia de Início Rápido

Configure o GoAB SDK em sua aplicação iOS em poucos minutos.

## Pré-requisitos

- Xcode 14+
- iOS 13+
- Swift 5.7+

## 1. Adicionar o SDK

O pacote iOS do GoAB está disponível no GitHub: [empresago/goab-ios-releases](https://github.com/empresago/goab-ios-releases).

### Swift Package Manager (recomendado)

1. No Xcode: **File → Add Package Dependencies...**
2. Cole a URL do repositório:
   ```
   https://github.com/empresago/goab-ios-releases
   ```
3. Selecione a regra de dependência (ex.: **Up to Next Major Version**) e a versão desejada.
4. Adicione o produto **GoABSDK** ao target do seu app.

Se o seu projeto usa `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/empresago/goab-ios-releases", from: "1.1.0")
]
```

### CocoaPods

No `Podfile`, use o repositório no GitHub:

```ruby
pod 'GoABSDK', :git => 'https://github.com/empresago/goab-ios-releases.git'
```

Ou, se o pacote estiver publicado no CocoaPods trunk:

```ruby
pod 'GoABSDK', '~> 1.1'
```

Depois execute:

```bash
pod install
```

## 2. Configuração simplificada

O SDK preenche automaticamente as informações do dispositivo e do app. Você só precisa dos parâmetros essenciais:

```swift
import GoABSDK

// Configuração simplificada - o SDK preenche automaticamente:
// - bundleIdentifier, appVersion (do app)
// - deviceId, deviceModel, osVersion (do dispositivo)
// - timezone, country, language (do sistema)
let sdk = GoABSDKFactory.create(
    accountId: 12345,
    apiToken: "your-api-token",
    timeoutSeconds: 30
)
```

## 3. Inicializar o SDK

### Em SwiftUI

```swift
import SwiftUI

@main
struct MyApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .task { await appState.initializeSDK() }
        }
    }
}

class AppState: ObservableObject {
    let sdk = GoABSDKFactory.create(
        accountId: 12345,
        apiToken: "your-api-token",
        timeoutSeconds: 30
    )
    
    func initializeSDK() async {
        try? await sdk.initialize()
    }
}
```

### Em UIKit

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
        // Configurar UI após inicialização
    }
}
```

## 4. Usar valores dos experimentos

### Obter valores

```swift
// String
let buttonText = sdk.getValue("button_text", defaultValue: "Clique Aqui") as? String ?? "Clique Aqui"

// Bool
let showFeature = sdk.getValue("show_new_feature", defaultValue: false) as? Bool ?? false

// Int
let maxRetries = sdk.getValue("max_retries", defaultValue: 3) as? Int ?? 3

// JSON (como String)
let configJson = sdk.getValue("feature_config", defaultValue: "{}") as? String ?? "{}"
```

### Em SwiftUI

```swift
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Text(appState.buttonText)
            if appState.showBanner {
                BannerView()
            }
        }
        .onTapGesture {
            appState.sdk.sendEvent("button_clicked", props: ["button_id": "main"])
        }
    }
}

// No AppState, adicione:
var buttonText: String {
    appState.sdk.getValue("button_text", defaultValue: "Clique Aqui") as? String ?? "Clique Aqui"
}
var showBanner: Bool {
    appState.sdk.getValue("show_banner", defaultValue: true) as? Bool ?? true
}
```

### Em UIKit

```swift
private func setupUI() {
    let buttonText = sdk.getValue("button_text", defaultValue: "Clique Aqui") as? String ?? "Clique Aqui"
    let showBanner = sdk.getValue("show_banner", defaultValue: true) as? Bool ?? true
    
    button.setTitle(buttonText, for: .normal)
    bannerView.isHidden = !showBanner
}
```

## 5. Enviar eventos

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

## 6. Verificar status

```swift
// Verificar se está inicializado
if sdk.isInitialized() {
    // SDK pronto para uso
}

// Obter userId atual
let currentUserId = sdk.getCurrentUserId()
```

## Próximos passos

- [Inicialização](./initialization) - Configurações detalhadas
- [API Reference](./api-reference) - Todos os métodos disponíveis
- [Casos de Uso](./use-cases) - Exemplos práticos
- [Troubleshooting](./troubleshooting) - Resolução de problemas

## Exemplo completo (SwiftUI)

```swift
@main
struct MyApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .task { await appState.initializeSDK() }
        }
    }
}

class AppState: ObservableObject {
    let sdk = GoABSDKFactory.create(
        accountId: 12345,
        apiToken: "your-api-token",
        timeoutSeconds: 30
    )
    
    func initializeSDK() async {
        try? await sdk.initialize()
    }
    
    var buttonText: String {
        sdk.getValue("button_text", defaultValue: "Clique Aqui") as? String ?? "Clique Aqui"
    }
    
    var showBanner: Bool {
        sdk.getValue("show_banner", defaultValue: true) as? Bool ?? true
    }
}

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Button(appState.buttonText) {
                appState.sdk.sendEvent("button_clicked", props: ["button_id": "main_button"])
            }
            if appState.showBanner {
                Text("Banner")
                    .padding()
            }
        }
    }
}
```
