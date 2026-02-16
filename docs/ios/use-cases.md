---
sidebar_position: 5
---

# Casos de Uso

Exemplos práticos de como usar o GoAB SDK em diferentes cenários (Swift).

## 1. Teste A/B de interface

### Cenário: testar diferentes cores de botão

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
            await MainActor.run { applyButtonExperiment() }
        }
    }
    
    private func applyButtonExperiment() {
        let colorHex = sdk.getValue("button_color", defaultValue: "#FF0000") as? String ?? "#FF0000"
        mainButton.backgroundColor = UIColor(hex: colorHex)
        
        sdk.sendEvent("button_color_experiment_viewed", props: [
            "color": colorHex,
            "experiment_key": "button_color"
        ])
    }
    
    @objc private func onButtonTap() {
        sdk.sendEvent("button_clicked", props: [
            "button_id": "main_button",
            "experiment_key": "button_color"
        ])
    }
}
```

## 2. Feature flags

### Cenário: controlar exibição de funcionalidades

```swift
class FeatureManager {
    private let sdk: GoABSDK
    
    init(sdk: GoABSDK) {
        self.sdk = sdk
    }
    
    func shouldShowNewFeature() -> Bool {
        sdk.getValue("show_new_feature", defaultValue: false) as? Bool ?? false
    }
    
    func getMaxRetries() -> Int {
        sdk.getValue("max_retries", defaultValue: 3) as? Int ?? 3
    }
    
    func getApiEndpoint() -> String {
        sdk.getValue("api_endpoint", defaultValue: "https://api.prod.com") as? String ?? "https://api.prod.com"
    }
}

// Uso
class MainViewController: UIViewController {
    private var featureManager: FeatureManager!
    private let sdk = GoABSDKFactory.create(
        accountId: 12345,
        apiToken: "your-api-token",
        timeoutSeconds: 30
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        featureManager = FeatureManager(sdk: sdk)
        Task {
            try? await sdk.initialize()
            await MainActor.run { setupFeatures() }
        }
    }
    
    private func setupFeatures() {
        let showNewFeature = featureManager.shouldShowNewFeature()
        newFeatureView.isHidden = !showNewFeature
        
        let maxRetries = featureManager.getMaxRetries()
        let apiEndpoint = featureManager.getApiEndpoint()
        // Usar maxRetries e apiEndpoint na lógica do app
    }
}
```

## 3. Personalização de conteúdo

### Cenário: personalizar conteúdo por usuário

```swift
class ContentManager {
    private let sdk: GoABSDK
    
    init(sdk: GoABSDK) {
        self.sdk = sdk
    }
    
    func getWelcomeMessage() -> String {
        sdk.getValue("welcome_message", defaultValue: "Bem-vindo!") as? String ?? "Bem-vindo!"
    }
    
    func getRecommendedItems() -> [String] {
        let json = sdk.getValue("recommended_items", defaultValue: "[]") as? String ?? "[]"
        (try? JSONDecoder().decode([String].self, from: json.data(using: .utf8)!)) ?? []
    }
    
    func getDiscountPercentage() -> Int {
        sdk.getValue("discount_percentage", defaultValue: 0) as? Int ?? 0
    }
}

// Uso em SwiftUI
struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.welcomeMessage)
            List(viewModel.recommendedItems, id: \.self) { item in
                Text(item)
            }
            if viewModel.discountPercentage > 0 {
                Text("Desconto: \(viewModel.discountPercentage)%")
            }
        }
        .task { await viewModel.load() }
    }
}

class HomeViewModel: ObservableObject {
    @Published var welcomeMessage = "Bem-vindo!"
    @Published var recommendedItems: [String] = []
    @Published var discountPercentage = 0
    
    private let sdk: GoABSDK
    private lazy var contentManager = ContentManager(sdk: sdk)
    
    init(sdk: GoABSDK) {
        self.sdk = sdk
    }
    
    func load() async {
        try? await sdk.initialize()
        await MainActor.run {
            welcomeMessage = contentManager.getWelcomeMessage()
            recommendedItems = contentManager.getRecommendedItems()
            discountPercentage = contentManager.getDiscountPercentage()
        }
    }
}
```

## 4. Analytics e métricas

### Cenário: coletar métricas de uso

```swift
class AnalyticsManager {
    private let sdk: GoABSDK
    
    init(sdk: GoABSDK) {
        self.sdk = sdk
    }
    
    func trackScreenView(screenName: String) {
        sdk.sendEvent("screen_view", props: [
            "screen_name": screenName,
            "timestamp": Int(Date().timeIntervalSince1970 * 1000)
        ])
    }
    
    func trackUserAction(action: String, properties: [String: Any] = [:]) {
        var props: [String: Any] = ["action": action, "timestamp": Int(Date().timeIntervalSince1970 * 1000)]
        properties.forEach { props[$0.key] = $0.value }
        sdk.sendEvent("user_action", props: props)
    }
    
    func trackPurchase(productId: String, price: Double, currency: String) {
        sdk.sendEvent("purchase", props: [
            "product_id": productId,
            "price": price,
            "currency": currency,
            "timestamp": Int(Date().timeIntervalSince1970 * 1000)
        ])
    }
}

// Uso
struct ProductView: View {
    @EnvironmentObject var analytics: AnalyticsManager
    
    var body: some View {
        ProductDetailView()
            .onAppear { analytics.trackScreenView(screenName: "product_detail") }
    }
    
    func onAddToCart(productId: String, productName: String) {
        analytics.trackUserAction("add_to_cart", properties: [
            "product_id": productId,
            "product_name": productName
        ])
    }
    
    func onPurchase(productId: String, price: Double) {
        analytics.trackPurchase(productId: productId, price: price, currency: "BRL")
    }
}
```

## 5. Configuração dinâmica

### Cenário: configurar parâmetros da aplicação

```swift
class AppConfigManager {
    private let sdk: GoABSDK
    
    init(sdk: GoABSDK) {
        self.sdk = sdk
    }
    
    func getApiTimeout() -> Int {
        sdk.getValue("api_timeout_seconds", defaultValue: 30) as? Int ?? 30
    }
    
    func getMaxCacheSizeMB() -> Int {
        sdk.getValue("max_cache_size_mb", defaultValue: 100) as? Int ?? 100
    }
    
    func getRefreshIntervalMinutes() -> Int {
        sdk.getValue("refresh_interval_minutes", defaultValue: 60) as? Int ?? 60
    }
    
    func isDebugMode() -> Bool {
        sdk.getValue("debug_mode", defaultValue: false) as? Bool ?? false
    }
}

// Uso no AppDelegate ou @main
@main
struct MyApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .task {
                    try? await appState.sdk.initialize()
                    appState.applyAppConfiguration()
                }
        }
    }
}

class AppState: ObservableObject {
    let sdk = GoABSDKFactory.create(
        accountId: 12345,
        apiToken: "your-api-token",
        timeoutSeconds: 30
    )
    private lazy var configManager = AppConfigManager(sdk: sdk)
    
    func applyAppConfiguration() {
        let apiTimeout = configManager.getApiTimeout()
        let maxCacheSize = configManager.getMaxCacheSizeMB()
        let refreshInterval = configManager.getRefreshIntervalMinutes()
        let debugMode = configManager.isDebugMode()
        // Aplicar na configuração do app
    }
}
```

## 6. Segmentação de usuários

### Cenário: direcionar experimentos para usuários específicos

```swift
class UserSegmentManager {
    private let sdk: GoABSDK
    
    init(sdk: GoABSDK) {
        self.sdk = sdk
    }
    
    func getUserSegment() -> String {
        sdk.getValue("user_segment", defaultValue: "default") as? String ?? "default"
    }
    
    func getPersonalizedContent() -> [String: Any] {
        let json = sdk.getValue("personalized_content", defaultValue: "{}") as? String ?? "{}"
        (try? JSONSerialization.jsonObject(with: json.data(using: .utf8)!) as? [String: Any]) ?? [:]
    }
}

// Uso
Task {
    try? await sdk.initialize()
    let segment = segmentManager.getUserSegment()
    let content = segmentManager.getPersonalizedContent()
    // Aplicar conteúdo
    sdk.sendEvent("user_segmented", props: [
        "segment": segment,
        "user_id": sdk.getCurrentUserId() ?? ""
    ])
}
```

## 7. Gerenciamento de estado

### Cenário: sincronizar estado entre telas

```swift
class ExperimentStateManager {
    private let sdk: GoABSDK
    private var experimentValues: [String: Any] = [:]
    
    init(sdk: GoABSDK) {
        self.sdk = sdk
    }
    
    func refreshExperiments() async {
        sdk.refreshExperiments()
        loadExperimentValues()
    }
    
    private func loadExperimentValues() {
        let keys = ["button_color", "show_banner", "max_retries"]
        experimentValues = Dictionary(uniqueKeysWithValues: keys.map { key in
            (key, sdk.getValue(key, defaultValue: "default_value"))
        })
    }
    
    func getExperimentValue(key: String, defaultValue: Any? = nil) -> Any? {
        experimentValues[key] ?? defaultValue
    }
    
    func clearCache() {
        sdk.clearCache()
        experimentValues.removeAll()
    }
}

// Uso
class MainViewController: UIViewController {
    private let sdk = GoABSDKFactory.create(...)
    private lazy var stateManager = ExperimentStateManager(sdk: sdk)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            try? await sdk.initialize()
            await stateManager.refreshExperiments()
            await MainActor.run { applyExperiments() }
        }
    }
    
    private func applyExperiments() {
        let buttonColor = stateManager.getExperimentValue(key: "button_color", defaultValue: "#FF0000")
        let showBanner = stateManager.getExperimentValue(key: "show_banner", defaultValue: true)
        // Aplicar na UI
    }
}
```

## 8. Tratamento de erros

### Cenário: fallback para valores padrão

```swift
class SafeExperimentManager {
    private let sdk: GoABSDK
    
    init(sdk: GoABSDK) {
        self.sdk = sdk
    }
    
    func getValueSafely(key: String, defaultValue: Any) -> Any {
        (try? sdk.getValue(key, defaultValue: defaultValue)) ?? defaultValue
    }
    
    func getStringValue(key: String, defaultValue: String) -> String {
        let value = getValueSafely(key: key, defaultValue: defaultValue)
        return value as? String ?? defaultValue
    }
    
    func getBooleanValue(key: String, defaultValue: Bool) -> Bool {
        let value = getValueSafely(key: key, defaultValue: defaultValue)
        if let b = value as? Bool { return b }
        if let s = value as? String { return s.lowercased() == "true" }
        return defaultValue
    }
    
    func getIntValue(key: String, defaultValue: Int) -> Int {
        let value = getValueSafely(key: key, defaultValue: defaultValue)
        if let i = value as? Int { return i }
        if let s = value as? String, let i = Int(s) { return i }
        if let d = value as? Double { return Int(d) }
        return defaultValue
    }
}

// Uso
class MainViewController: UIViewController {
    private let sdk = GoABSDKFactory.create(...)
    private lazy var safeManager = SafeExperimentManager(sdk: sdk)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            do {
                try await sdk.initialize()
                await MainActor.run { applySafeExperiments() }
            } catch {
                applyDefaultValues()
            }
        }
    }
    
    private func applySafeExperiments() {
        let buttonText = safeManager.getStringValue(key: "button_text", defaultValue: "Clique Aqui")
        let showBanner = safeManager.getBooleanValue(key: "show_banner", defaultValue: true)
        let maxRetries = safeManager.getIntValue(key: "max_retries", defaultValue: 3)
        // Aplicar na UI
    }
    
    private func applyDefaultValues() {
        button.setTitle("Clique Aqui", for: .normal)
        bannerView.isHidden = true
    }
}
```

## Próximos passos

- [API Reference](./api-reference) - Documentação completa da API
- [Troubleshooting](./troubleshooting) - Resolução de problemas
- [Guia de Início Rápido](./getting-started) - Setup básico
