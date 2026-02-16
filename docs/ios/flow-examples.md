---
sidebar_position: 7
---

# Exemplos reativos (Combine e async/await)

Exemplos de como usar o GoAB SDK de forma reativa no iOS com **Combine** e **async/await**.

## Configuração com Combine

### Setup básico

```swift
import Combine
import SwiftUI

class ExperimentViewModel: ObservableObject {
    let sdk = GoABSDKFactory.create(
        accountId: 12345,
        apiToken: "your-api-token",
        timeoutSeconds: 30
    )
    
    @Published var experimentValues: [String: Any] = [:]
    @Published var isLoading = false
    
    func initialize() {
        isLoading = true
        Task {
            try? await sdk.initialize()
            await MainActor.run {
                loadExperiments()
                isLoading = false
            }
        }
    }
    
    private func loadExperiments() {
        experimentValues = [
            "button_text": sdk.getValue("button_text", defaultValue: "Clique Aqui"),
            "show_banner": sdk.getValue("show_banner", defaultValue: true),
            "button_color": sdk.getValue("button_color", defaultValue: "#FF0000")
        ]
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ExperimentViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                Text(viewModel.experimentValues["button_text"] as? String ?? "Clique Aqui")
                if viewModel.experimentValues["show_banner"] as? Bool == true {
                    Text("Banner").padding()
                }
            }
        }
        .onAppear { viewModel.initialize() }
    }
}
```

## ViewModel com @Published

### ExperimentViewModel completo

```swift
import Combine

class ExperimentViewModel: ObservableObject {
    let sdk = GoABSDKFactory.create(
        accountId: 12345,
        apiToken: "your-api-token",
        timeoutSeconds: 30
    )
    
    @Published var experiments: [String: Any] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func initialize() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                try await sdk.initialize()
                await MainActor.run { loadExperiments() }
            } catch {
                await MainActor.run {
                    errorMessage = "Erro ao inicializar: \(error.localizedDescription)"
                }
            }
            await MainActor.run { isLoading = false }
        }
    }
    
    private func loadExperiments() {
        experiments = [
            "button_text": sdk.getValue("button_text", defaultValue: "Clique Aqui"),
            "show_banner": sdk.getValue("show_banner", defaultValue: true),
            "button_color": sdk.getValue("button_color", defaultValue: "#FF0000"),
            "max_retries": sdk.getValue("max_retries", defaultValue: 3),
            "api_endpoint": sdk.getValue("api_endpoint", defaultValue: "https://api.prod.com")
        ]
    }
    
    func refreshExperiments() {
        isLoading = true
        Task {
            sdk.refreshExperiments()
            await MainActor.run { loadExperiments() }
            await MainActor.run { isLoading = false }
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}
```

### Uso na View

```swift
struct MainView: View {
    @StateObject private var viewModel = ExperimentViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            }
            
            Text(viewModel.experiments["button_text"] as? String ?? "Clique Aqui")
            
            if viewModel.experiments["show_banner"] as? Bool == true {
                Text("Banner").padding()
            }
            
            if let error = viewModel.errorMessage {
                Text(error).foregroundColor(.red)
                Button("OK") { viewModel.clearError() }
            }
            
            Button("Atualizar") { viewModel.refreshExperiments() }
        }
        .onAppear { viewModel.initialize() }
    }
}
```

## Combine com transformações

### ExperimentPublisherManager

```swift
import Combine

class ExperimentPublisherManager {
    private let sdk: GoABSDK
    
    init(sdk: GoABSDK) {
        self.sdk = sdk
    }
    
    func buttonTextPublisher() -> AnyPublisher<String, Never> {
        Just(sdk.getValue("button_text", defaultValue: "Clique Aqui") as? String ?? "Clique Aqui")
            .eraseToAnyPublisher()
    }
    
    func showBannerPublisher() -> AnyPublisher<Bool, Never> {
        Just(sdk.getValue("show_banner", defaultValue: true) as? Bool ?? true)
            .eraseToAnyPublisher()
    }
    
    func buttonColorPublisher() -> AnyPublisher<String, Never> {
        Just(sdk.getValue("button_color", defaultValue: "#FF0000") as? String ?? "#FF0000")
            .eraseToAnyPublisher()
    }
    
    func allExperimentsPublisher() -> AnyPublisher<[String: Any], Never> {
        Publishers.CombineLatest3(
            buttonTextPublisher(),
            showBannerPublisher(),
            buttonColorPublisher()
        )
        .map { buttonText, showBanner, buttonColor in
            [
                "button_text": buttonText,
                "show_banner": showBanner,
                "button_color": buttonColor
            ]
        }
        .eraseToAnyPublisher()
    }
    
    func buttonTextWithPrefix() -> AnyPublisher<String, Never> {
        buttonTextPublisher()
            .map { "🔘 \($0)" }
            .eraseToAnyPublisher()
    }
}
```

### Uso com transformações

```swift
class MainViewController: UIViewController {
    private let sdk = GoABSDKFactory.create(...)
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let manager = ExperimentPublisherManager(sdk: sdk)
        
        Task {
            try? await sdk.initialize()
            await MainActor.run { observeExperiments(manager: manager) }
        }
    }
    
    private func observeExperiments(manager: ExperimentPublisherManager) {
        manager.buttonTextWithPrefix()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                self?.button.setTitle(text, for: .normal)
            }
            .store(in: &cancellables)
        
        manager.buttonColorPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hex in
                self?.button.backgroundColor = UIColor(hex: hex)
            }
            .store(in: &cancellables)
        
        manager.allExperimentsPublisher()
            .receive(on: DispatchQueue.main)
            .sink { experiments in
                print("Experimentos: \(experiments)")
            }
            .store(in: &cancellables)
    }
}
```

## Cache e refresh com CurrentValueSubject

### CachedExperimentManager

```swift
import Combine

class CachedExperimentManager: ObservableObject {
    private let sdk: GoABSDK
    
    @Published var experiments: [String: Any] = [:]
    @Published var isRefreshing = false
    @Published var lastRefresh: Date?
    
    init(sdk: GoABSDK) {
        self.sdk = sdk
    }
    
    func loadExperiments() {
        experiments = [
            "button_text": sdk.getValue("button_text", defaultValue: "Clique Aqui"),
            "show_banner": sdk.getValue("show_banner", defaultValue: true),
            "button_color": sdk.getValue("button_color", defaultValue: "#FF0000"),
            "max_retries": sdk.getValue("max_retries", defaultValue: 3),
            "api_endpoint": sdk.getValue("api_endpoint", defaultValue: "https://api.prod.com")
        ]
        lastRefresh = Date()
    }
    
    func refreshExperiments() {
        isRefreshing = true
        sdk.refreshExperiments()
        loadExperiments()
        isRefreshing = false
    }
    
    func getExperimentValue(key: String, defaultValue: Any) -> Any {
        experiments[key] ?? defaultValue
    }
}
```

### Uso com cache

```swift
struct CachedExperimentsView: View {
    private let sdk: GoABSDK
    @StateObject private var experimentManager: CachedExperimentManager
    
    init() {
        let sdk = GoABSDKFactory.create(
            accountId: 12345,
            apiToken: "your-api-token",
            timeoutSeconds: 30
        )
        self.sdk = sdk
        _experimentManager = StateObject(wrappedValue: CachedExperimentManager(sdk: sdk))
    }
    
    var body: some View {
        VStack {
            Text(experimentManager.experiments["button_text"] as? String ?? "Clique Aqui")
            
            if experimentManager.isRefreshing {
                ProgressView()
            }
            
            if let last = experimentManager.lastRefresh {
                Text("Última atualização: \(last, style: .relative) atrás")
            }
            
            Button("Atualizar") { experimentManager.refreshExperiments() }
        }
        .task {
            try? await sdk.initialize()
            experimentManager.loadExperiments()
        }
    }
}
```

## Tratamento de erros com Result

### SafeExperimentManager

```swift
class SafeExperimentManager {
    private let sdk: GoABSDK
    
    init(sdk: GoABSDK) {
        self.sdk = sdk
    }
    
    func getExperiment(key: String, defaultValue: Any) -> Result<Any, Error> {
        do {
            let value = sdk.getValue(key, defaultValue: defaultValue)
            return .success(value)
        } catch {
            return .failure(error)
        }
    }
    
    func getAllExperiments() -> Result<[String: Any], Error> {
        do {
            let experiments: [String: Any] = [
                "button_text": sdk.getValue("button_text", defaultValue: "Clique Aqui"),
                "show_banner": sdk.getValue("show_banner", defaultValue: true),
                "button_color": sdk.getValue("button_color", defaultValue: "#FF0000")
            ]
            return .success(experiments)
        } catch {
            return .failure(error)
        }
    }
    
    func getExperimentWithRetry(key: String, defaultValue: Any, maxRetries: Int = 3) async -> Result<Any, Error> {
        var retries = 0
        while retries < maxRetries {
            let result = getExperiment(key: key, defaultValue: defaultValue)
            if case .success = result { return result }
            retries += 1
            try? await Task.sleep(nanoseconds: UInt64(retries) * 1_000_000_000)
        }
        return getExperiment(key: key, defaultValue: defaultValue)
    }
}
```

### Uso com tratamento de erro

```swift
struct SafeExperimentsView: View {
    private let sdk: GoABSDK
    private let safeManager: SafeExperimentManager
    
    init() {
        let sdk = GoABSDKFactory.create(
            accountId: 12345,
            apiToken: "your-api-token",
            timeoutSeconds: 30
        )
        self.sdk = sdk
        safeManager = SafeExperimentManager(sdk: sdk)
    }
    
    var body: some View {
        VStack {
            Text(buttonText)
            if showBanner { Text("Banner") }
        }
        .task { await loadSafe() }
    }
    
    @State private var buttonText = "Clique Aqui"
    @State private var showBanner = true
    
    private func loadSafe() async {
        try? await sdk.initialize()
        
        switch safeManager.getExperiment(key: "button_text", defaultValue: "Clique Aqui") {
        case .success(let value):
            await MainActor.run { buttonText = value as? String ?? "Clique Aqui" }
        case .failure(let error):
            print("Erro: \(error)")
            await MainActor.run { buttonText = "Clique Aqui" }
        }
        
        switch safeManager.getExperiment(key: "show_banner", defaultValue: true) {
        case .success(let value):
            await MainActor.run { showBanner = value as? Bool ?? true }
        case .failure:
            await MainActor.run { showBanner = true }
        }
    }
}
```

## Async/await direto (sem Combine)

Para fluxos simples, async/await pode ser suficiente:

```swift
struct SimpleExperimentsView: View {
    @State private var buttonText = "Clique Aqui"
    @State private var showBanner = true
    
    private let sdk = GoABSDKFactory.create(
        accountId: 12345,
        apiToken: "your-api-token",
        timeoutSeconds: 30
    )
    
    var body: some View {
        VStack {
            Text(buttonText)
            if showBanner { Text("Banner") }
        }
        .task { await loadExperiments() }
    }
    
    private func loadExperiments() async {
        try? await sdk.initialize()
        await MainActor.run {
            buttonText = sdk.getValue("button_text", defaultValue: "Clique Aqui") as? String ?? "Clique Aqui"
            showBanner = sdk.getValue("show_banner", defaultValue: true) as? Bool ?? true
        }
    }
}
```

## Próximos passos

- [API Reference](./api-reference) - Documentação completa da API
- [Casos de Uso](./use-cases) - Exemplos práticos
- [Troubleshooting](./troubleshooting) - Resolução de problemas
