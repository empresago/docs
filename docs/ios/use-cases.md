---
sidebar_position: 5
---

# Casos de Uso

Exemplos práticos de como usar o GoAB SDK em diferentes cenários.

## 1. Teste A/B de Interface

### Cenário: Testar diferentes cores de botão

```kotlin
class MainActivity : AppCompatActivity() {
    private lateinit var sdk: GoABSDK
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        setupSDK()
    }
    
    private fun setupSDK() {
        sdk = GoABSDKFactory.create(this, config)
        lifecycleScope.launch {
            sdk.initialize(config)
            applyButtonExperiment()
        }
    }
    
    private fun applyButtonExperiment() {
        val button = findViewById<Button>(R.id.main_button)
        
        // Obter cor do experimento
        val buttonColor = sdk.getValue("button_color", "#FF0000")
        
        // Aplicar cor
        button.setBackgroundColor(Color.parseColor(buttonColor.toString()))
        
        // Enviar evento de visualização
        sdk.sendEvent("button_color_experiment_viewed", mapOf(
            "color" to buttonColor,
            "experiment_key" to "button_color"
        ))
    }
    
    private fun onButtonClick() {
        // Enviar evento de clique
        sdk.sendEvent("button_clicked", mapOf(
            "button_id" to "main_button",
            "experiment_key" to "button_color"
        ))
    }
}
```

## 2. Feature Flags

### Cenário: Controlar exibição de funcionalidades

```kotlin
class FeatureManager(private val sdk: GoABSDK) {
    
    fun shouldShowNewFeature(): Boolean {
        return sdk.getValue("show_new_feature", false) as Boolean
    }
    
    fun getMaxRetries(): Int {
        return sdk.getValue("max_retries", 3) as Int
    }
    
    fun getApiEndpoint(): String {
        return sdk.getValue("api_endpoint", "https://api.prod.com") as String
    }
}

// Uso
class MainActivity : AppCompatActivity() {
    private lateinit var featureManager: FeatureManager
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        val sdk = GoABSDKFactory.create(this, config)
        featureManager = FeatureManager(sdk)
        
        lifecycleScope.launch {
            sdk.initialize(config)
            setupFeatures()
        }
    }
    
    private fun setupFeatures() {
        // Controlar exibição de funcionalidade
        val showNewFeature = featureManager.shouldShowNewFeature()
        findViewById<View>(R.id.new_feature).visibility = 
            if (showNewFeature) View.VISIBLE else View.GONE
        
        // Configurar retry
        val maxRetries = featureManager.getMaxRetries()
        // Usar maxRetries na lógica de retry
        
        // Configurar endpoint
        val apiEndpoint = featureManager.getApiEndpoint()
        // Usar apiEndpoint nas chamadas de API
    }
}
```

## 3. Personalização de Conteúdo

### Cenário: Personalizar conteúdo baseado no usuário

```kotlin
class ContentManager(private val sdk: GoABSDK) {
    
    fun getWelcomeMessage(): String {
        return sdk.getValue("welcome_message", "Bem-vindo!") as String
    }
    
    fun getRecommendedItems(): List<String> {
        val itemsJson = sdk.getValue("recommended_items", "[]") as String
        return try {
            // Parse JSON para lista
            Gson().fromJson(itemsJson, Array<String>::class.java).toList()
        } catch (e: Exception) {
            emptyList()
        }
    }
    
    fun getDiscountPercentage(): Int {
        return sdk.getValue("discount_percentage", 0) as Int
    }
}

// Uso
class HomeActivity : AppCompatActivity() {
    private lateinit var contentManager: ContentManager
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_home)
        
        val sdk = GoABSDKFactory.create(this, config)
        contentManager = ContentManager(sdk)
        
        lifecycleScope.launch {
            sdk.initialize(config)
            loadPersonalizedContent()
        }
    }
    
    private fun loadPersonalizedContent() {
        // Carregar mensagem personalizada
        val welcomeMessage = contentManager.getWelcomeMessage()
        findViewById<TextView>(R.id.welcome_text).text = welcomeMessage
        
        // Carregar itens recomendados
        val recommendedItems = contentManager.getRecommendedItems()
        setupRecommendedItems(recommendedItems)
        
        // Aplicar desconto
        val discountPercentage = contentManager.getDiscountPercentage()
        if (discountPercentage > 0) {
            showDiscountBanner(discountPercentage)
        }
    }
}
```

## 4. Analytics e Métricas

### Cenário: Coletar métricas de uso

```kotlin
class AnalyticsManager(private val sdk: GoABSDK) {
    
    fun trackScreenView(screenName: String) {
        sdk.sendEvent("screen_view", mapOf(
            "screen_name" to screenName,
            "timestamp" to System.currentTimeMillis()
        ))
    }
    
    fun trackUserAction(action: String, properties: Map<String, Any> = emptyMap()) {
        sdk.sendEvent("user_action", mapOf(
            "action" to action,
            "timestamp" to System.currentTimeMillis()
        ) + properties)
    }
    
    fun trackPurchase(productId: String, price: Double, currency: String) {
        sdk.sendEvent("purchase", mapOf(
            "product_id" to productId,
            "price" to price,
            "currency" to currency,
            "timestamp" to System.currentTimeMillis()
        ))
    }
}

// Uso
class ProductActivity : AppCompatActivity() {
    private lateinit var analytics: AnalyticsManager
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_product)
        
        val sdk = GoABSDKFactory.create(this, config)
        analytics = AnalyticsManager(sdk)
        
        lifecycleScope.launch {
            sdk.initialize(config)
            analytics.trackScreenView("product_detail")
        }
    }
    
    private fun onAddToCart() {
        analytics.trackUserAction("add_to_cart", mapOf(
            "product_id" to productId,
            "product_name" to productName
        ))
    }
    
    private fun onPurchase() {
        analytics.trackPurchase(productId, price, "BRL")
    }
}
```

## 5. Configuração Dinâmica

### Cenário: Configurar parâmetros da aplicação

```kotlin
class AppConfigManager(private val sdk: GoABSDK) {
    
    fun getApiTimeout(): Int {
        return sdk.getValue("api_timeout_seconds", 30) as Int
    }
    
    fun getMaxCacheSize(): Long {
        return sdk.getValue("max_cache_size_mb", 100) as Long
    }
    
    fun getRefreshInterval(): Int {
        return sdk.getValue("refresh_interval_minutes", 60) as Int
    }
    
    fun isDebugMode(): Boolean {
        return sdk.getValue("debug_mode", false) as Boolean
    }
}

// Uso
class App : Application() {
    private lateinit var configManager: AppConfigManager
    
    override fun onCreate() {
        super.onCreate()
        
        val sdk = GoABSDKFactory.create(this, config)
        configManager = AppConfigManager(sdk)
        
        // Inicializar em background
        CoroutineScope(Dispatchers.IO).launch {
            sdk.initialize(config)
            applyAppConfiguration()
        }
    }
    
    private fun applyAppConfiguration() {
        // Configurar timeout da API
        val apiTimeout = configManager.getApiTimeout()
        // Aplicar timeout nas chamadas de API
        
        // Configurar cache
        val maxCacheSize = configManager.getMaxCacheSize()
        // Configurar tamanho máximo do cache
        
        // Configurar intervalo de refresh
        val refreshInterval = configManager.getRefreshInterval()
        // Configurar job de refresh
        
        // Configurar modo debug
        val debugMode = configManager.isDebugMode()
        // Habilitar/desabilitar logs baseado no modo debug
    }
}
```

## 6. Segmentação de Usuários

### Cenário: Direcionar experimentos para usuários específicos

```kotlin
class UserSegmentManager(private val sdk: GoABSDK) {
    
    fun getUserSegment(): String {
        return sdk.getValue("user_segment", "default") as String
    }
    
    fun getPersonalizedContent(): Map<String, Any> {
        val contentJson = sdk.getValue("personalized_content", "{}") as String
        return try {
            Gson().fromJson(contentJson, Map::class.java) as Map<String, Any>
        } catch (e: Exception) {
            emptyMap()
        }
    }
    
    fun getTargetedOffers(): List<Map<String, Any>> {
        val offersJson = sdk.getValue("targeted_offers", "[]") as String
        return try {
            Gson().fromJson(offersJson, Array<Map<String, Any>>::class.java).toList()
        } catch (e: Exception) {
            emptyList()
        }
    }
}

// Uso
class MainActivity : AppCompatActivity() {
    private lateinit var segmentManager: UserSegmentManager
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        val sdk = GoABSDKFactory.create(this, config)
        segmentManager = UserSegmentManager(sdk)
        
        lifecycleScope.launch {
            sdk.initialize(config)
            applyUserSegmentation()
        }
    }
    
    private fun applyUserSegmentation() {
        // Obter segmento do usuário
        val userSegment = segmentManager.getUserSegment()
        
        // Aplicar conteúdo personalizado
        val personalizedContent = segmentManager.getPersonalizedContent()
        applyPersonalizedContent(personalizedContent)
        
        // Aplicar ofertas direcionadas
        val targetedOffers = segmentManager.getTargetedOffers()
        showTargetedOffers(targetedOffers)
        
        // Enviar evento de segmentação
        sdk.sendEvent("user_segmented", mapOf(
            "segment" to userSegment,
            "user_id" to sdk.getCurrentUserId()
        ))
    }
}
```

## 7. Gerenciamento de Estado

### Cenário: Sincronizar estado entre telas

```kotlin
class ExperimentStateManager(private val sdk: GoABSDK) {
    
    private val experimentValues = mutableMapOf<String, Any?>()
    
    suspend fun refreshExperiments() {
        // Forçar atualização dos experimentos
        sdk.refreshExperiments()
        
        // Recarregar valores
        loadExperimentValues()
    }
    
    private fun loadExperimentValues() {
        // Carregar valores dos experimentos
        val keys = listOf("button_color", "show_banner", "max_retries")
        
        keys.forEach { key ->
            val value = sdk.getValue(key, "default_value")
            experimentValues[key] = value
        }
    }
    
    fun getExperimentValue(key: String, defaultValue: Any? = null): Any? {
        return experimentValues[key] ?: defaultValue
    }
    
    suspend fun clearCache() {
        sdk.clearCache()
        experimentValues.clear()
    }
}

// Uso
class MainActivity : AppCompatActivity() {
    private lateinit var stateManager: ExperimentStateManager
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        val sdk = GoABSDKFactory.create(this, config)
        stateManager = ExperimentStateManager(sdk)
        
        lifecycleScope.launch {
            sdk.initialize(config)
            stateManager.refreshExperiments()
            applyExperiments()
        }
    }
    
    private fun applyExperiments() {
        // Aplicar experimentos usando o state manager
        val buttonColor = stateManager.getExperimentValue("button_color", "#FF0000")
        val showBanner = stateManager.getExperimentValue("show_banner", true)
        
        // Aplicar na UI
        findViewById<Button>(R.id.button).setBackgroundColor(
            Color.parseColor(buttonColor.toString())
        )
        
        findViewById<View>(R.id.banner).visibility = 
            if (showBanner as Boolean) View.VISIBLE else View.GONE
    }
}
```

## 8. Tratamento de Erros

### Cenário: Fallback para valores padrão

```kotlin
class SafeExperimentManager(private val sdk: GoABSDK) {
    
    fun getValueSafely(key: String, defaultValue: Any): Any {
        return try {
            sdk.getValue(key, defaultValue)
        } catch (e: Exception) {
            Log.w("SafeExperimentManager", "Erro ao obter valor para $key", e)
            defaultValue
        }
    }
    
    fun getStringValue(key: String, defaultValue: String): String {
        val value = getValueSafely(key, defaultValue)
        return value.toString()
    }
    
    fun getBooleanValue(key: String, defaultValue: Boolean): Boolean {
        val value = getValueSafely(key, defaultValue)
        return when (value) {
            is Boolean -> value
            is String -> value.toBooleanStrictOrNull() ?: defaultValue
            else -> defaultValue
        }
    }
    
    fun getIntValue(key: String, defaultValue: Int): Int {
        val value = getValueSafely(key, defaultValue)
        return when (value) {
            is Int -> value
            is String -> value.toIntOrNull() ?: defaultValue
            is Double -> value.toInt()
            else -> defaultValue
        }
    }
}

// Uso
class MainActivity : AppCompatActivity() {
    private lateinit var safeManager: SafeExperimentManager
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        val sdk = GoABSDKFactory.create(this, config)
        safeManager = SafeExperimentManager(sdk)
        
        lifecycleScope.launch {
            try {
                sdk.initialize(config)
                applySafeExperiments()
            } catch (e: Exception) {
                Log.e("MainActivity", "Erro ao inicializar SDK", e)
                applyDefaultValues()
            }
        }
    }
    
    private fun applySafeExperiments() {
        // Usar métodos seguros
        val buttonText = safeManager.getStringValue("button_text", "Clique Aqui")
        val showBanner = safeManager.getBooleanValue("show_banner", true)
        val maxRetries = safeManager.getIntValue("max_retries", 3)
        
        // Aplicar valores
        findViewById<Button>(R.id.button).text = buttonText
        findViewById<View>(R.id.banner).visibility = 
            if (showBanner) View.VISIBLE else View.GONE
    }
    
    private fun applyDefaultValues() {
        // Valores padrão quando SDK não está disponível
        findViewById<Button>(R.id.button).text = "Clique Aqui"
        findViewById<View>(R.id.banner).visibility = View.GONE
    }
}
```

## Próximos Passos

- [API Reference](./api-reference) - Documentação completa da API
- [Troubleshooting](./troubleshooting) - Resolução de problemas
- [Guia de Início Rápido](./getting-started) - Setup básico
