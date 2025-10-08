---
sidebar_position: 4
---

# API Reference

Documentação completa da API do GoAB SDK.

## GoABSDK

Classe principal do SDK que fornece a interface para interagir com experimentos e configurações remotas.

### Construtor

```kotlin
class GoABSDK(
    private val goabRemoteConfig: GoABRemoteConfig
)
```

### Métodos

#### `initialize(config: GoABConfig)`

Inicializa o SDK com a configuração fornecida.

**Parâmetros:**
- `config: GoABConfig` - Configuração do SDK

**Exemplo:**
```kotlin
lifecycleScope.launch {
    sdk.initialize(config)
}
```

#### `getValue(key: String, defaultValue: Any): Any`

Obtém o valor de uma chave de experimento.

**Parâmetros:**
- `key: String` - Chave do experimento
- `defaultValue: Any` - Valor padrão se a chave não for encontrada (obrigatório)

**Retorna:**
- `Any` - Valor do experimento ou valor padrão

**Exemplo:**
```kotlin
// String
val buttonText = sdk.getValue("button_text", "Clique Aqui")

// Boolean
val showFeature = sdk.getValue("show_new_feature", false)

// Number
val maxRetries = sdk.getValue("max_retries", 3)
```

#### `sendEvent(eventName: String, props: Map<String, Any> = emptyMap())`

Envia um evento para analytics.

**Parâmetros:**
- `eventName: String` - Nome do evento
- `props: Map<String, Any>` - Propriedades do evento

**Exemplo:**
```kotlin
// Evento simples
sdk.sendEvent("button_clicked")

// Evento com propriedades
sdk.sendEvent("purchase_completed", mapOf(
    "product_id" to "prod_123",
    "price" to 29.99,
    "currency" to "BRL"
))
```

#### `refreshExperiments()`

Força a atualização dos experimentos do servidor.

**Exemplo:**
```kotlin
sdk.refreshExperiments()
```

#### `clearCache()`

Limpa o cache de experimentos.

**Exemplo:**
```kotlin
sdk.clearCache()
```

#### `isInitialized(): Boolean`

Verifica se o SDK está inicializado.

**Retorna:**
- `Boolean` - true se inicializado, false caso contrário

**Exemplo:**
```kotlin
if (sdk.isInitialized()) {
    // SDK pronto para uso
}
```

#### `setUserId(newUserId: String)`

Atualiza o ID do usuário atual e recarrega os experimentos.

**Parâmetros:**
- `newUserId: String` - Novo ID do usuário

**Exemplo:**
```kotlin
lifecycleScope.launch {
    sdk.setUserId("new_user_123")
}
```

#### `getCurrentUserId(): String?`

Obtém o ID do usuário atual.

**Retorna:**
- `String?` - ID do usuário atual ou null

**Exemplo:**
```kotlin
val userId = sdk.getCurrentUserId()
```

#### `clearActiveUsers()`

Limpa os experimentos ativos.

**Exemplo:**
```kotlin
lifecycleScope.launch {
    sdk.clearActiveUsers()
}
```

#### `getUserId(): String?`

Obtém o ID do usuário do repositório.

**Retorna:**
- `String?` - ID do usuário ou null

**Exemplo:**
```kotlin
lifecycleScope.launch {
    val userId = sdk.getUserId()
}
```

## GoABSDKFactory

Factory para criar instâncias do SDK.

### Métodos Estáticos

#### `create(context: Context, accountId: Int, apiToken: String, timeoutSeconds: Int): GoABSDK`

Cria uma nova instância do SDK.

**Parâmetros:**
- `context: Context` - Contexto Android
- `accountId: Int` - ID da conta
- `apiToken: String` - Token de autenticação
- `timeoutSeconds: Int` - Timeout das requisições em segundos

**Retorna:**
- `GoABSDK` - Instância do SDK

**Exemplo:**
```kotlin
val sdk = GoABSDKFactory.create(
    context = this,
    accountId = 12345,
    apiToken = "your-api-token",
    timeoutSeconds = 30
)
```

## GoABConfig

Classe de configuração do SDK (usada internamente).

### Construtor

```kotlin
data class GoABConfig(
    val accountId: Int,
    val apiToken: String,
    val baseUrl: String,
    val timeoutSeconds: Int = 30,
    val appContext: AppContext? = null
)
```

### Propriedades

| Propriedade | Tipo | Obrigatório | Descrição |
|-------------|------|-------------|-----------|
| `accountId` | Int | Sim | ID da conta |
| `apiToken` | String | Sim | Token de autenticação |
| `baseUrl` | String | Sim | URL base da API |
| `timeoutSeconds` | Int | Não | Timeout em segundos (padrão: 30) |
| `appContext` | AppContext? | Não | Contexto da aplicação (preenchido automaticamente) |

## GoABConfig.AppContext

Contexto da aplicação com informações do dispositivo e usuário.

### Construtor

```kotlin
data class AppContext(
    val userId: String? = null,
    val apiToken: String? = null,
    val packageName: String? = null,
    val packageVersion: String? = null,
    val deviceId: String? = null,
    val deviceModel: String? = null,
    val osVersion: String? = null,
    val appVersion: String? = null,
    val screenResolution: String? = null,
    val networkType: String? = null,
    val timezone: String? = null,
    val country: String? = null,
    val language: String? = null
)
```

### Propriedades

| Propriedade | Tipo | Obrigatório | Descrição |
|-------------|------|-------------|-----------|
| `userId` | String? | Não | ID do usuário (gerado automaticamente se não fornecido) |
| `apiToken` | String? | Não | Token de autenticação |
| `packageName` | String? | Não | Nome do pacote (preenchido automaticamente) |
| `packageVersion` | String? | Não | Versão do pacote (preenchido automaticamente) |
| `deviceId` | String? | Não | ID do dispositivo (preenchido automaticamente) |
| `deviceModel` | String? | Não | Modelo do dispositivo (preenchido automaticamente) |
| `osVersion` | String? | Não | Versão do Android (preenchido automaticamente) |
| `appVersion` | String? | Não | Versão da aplicação (preenchido automaticamente) |
| `screenResolution` | String? | Não | Resolução da tela (preenchido automaticamente) |
| `networkType` | String? | Não | Tipo de rede (preenchido automaticamente) |
| `timezone` | String? | Não | Fuso horário (preenchido automaticamente) |
| `country` | String? | Não | País (preenchido automaticamente) |
| `language` | String? | Não | Idioma (preenchido automaticamente) |

## MobileInfo

Informações do dispositivo móvel.

### Construtor

```kotlin
data class MobileInfo(
    val deviceId: String,
    val deviceModel: String,
    val deviceBrand: String,
    val deviceManufacturer: String,
    val osName: String,
    val osVersion: String,
    val screenWidth: Int,
    val screenHeight: Int,
    val screenDensity: Double,
    val screenOrientation: String,
    val appVersion: String,
    val appBuild: String,
    val packageName: String,
    val networkType: String,
    val carrier: String?,
    val timezone: String,
    val country: String,
    val language: String,
    val isConnected: Boolean,
    val isOnline: Boolean
)
```

## Exemplos de Uso

### Configuração Simplificada

```kotlin
// Configuração simplificada - o SDK preenche automaticamente as informações
val sdk = GoABSDKFactory.create(
    context = this,
    accountId = 12345,
    apiToken = "your-api-token",
    timeoutSeconds = 30
)
```

### Uso Básico

```kotlin
class MainActivity : AppCompatActivity() {
    private lateinit var sdk: GoABSDK
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // Criar SDK
        sdk = GoABSDKFactory.create(
            context = this,
            accountId = 12345,
            apiToken = "your-api-token",
            timeoutSeconds = 30
        )
        
        // Inicializar
        lifecycleScope.launch {
            sdk.initialize()
            setupUI()
        }
    }
    
    private fun setupUI() {
        // Obter valores dos experimentos
        val buttonText = sdk.getValue("button_text", "Clique Aqui")
        val showBanner = sdk.getValue("show_banner", true)
        
        // Aplicar na UI
        findViewById<Button>(R.id.button).text = buttonText.toString()
        findViewById<View>(R.id.banner).visibility = 
            if (showBanner as Boolean) View.VISIBLE else View.GONE
    }
    
    private fun onButtonClick() {
        // Enviar evento
        sdk.sendEvent("button_clicked", mapOf(
            "button_id" to "main_button"
        ))
    }
}
```

### Gerenciamento de Usuário

```kotlin
// Atualizar usuário
lifecycleScope.launch {
    sdk.setUserId("new_user_123")
}

// Obter usuário atual
val currentUserId = sdk.getCurrentUserId()

// Limpar experimentos ativos
lifecycleScope.launch {
    sdk.clearActiveUsers()
}
```

### Tratamento de Erros

```kotlin
lifecycleScope.launch {
    try {
        sdk.initialize(config)
        // SDK inicializado com sucesso
    } catch (e: Exception) {
        Log.e("GoAB", "Erro ao inicializar SDK", e)
        // Usar valores padrão
    }
}
```

## Próximos Passos

- [Casos de Uso](./use-cases) - Exemplos práticos
- [Troubleshooting](./troubleshooting) - Resolução de problemas
- [Guia de Início Rápido](./getting-started) - Setup básico
