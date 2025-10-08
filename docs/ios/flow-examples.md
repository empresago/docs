---
sidebar_position: 7
---

# Exemplos com Flow

Exemplos práticos de como usar o GoAB SDK com Kotlin Flow para reatividade.

## Configuração com Flow

### Setup Básico

```kotlin
class MainActivity : AppCompatActivity() {
    private lateinit var goabSDK: GoABSDK
    private val _experimentValues = MutableStateFlow<Map<String, Any>>(emptyMap())
    val experimentValues: StateFlow<Map<String, Any>> = _experimentValues.asStateFlow()
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        setupSDK()
        observeExperiments()
    }
    
    private fun setupSDK() {
        goabSDK = GoABSDKFactory.create(
            context = this,
            accountId = 12345,
            apiToken = "your-api-token",
            timeoutSeconds = 30
        )
        
        lifecycleScope.launch {
            goabSDK.initialize()
            loadExperiments()
        }
    }
    
    private fun loadExperiments() {
        val experiments = mapOf(
            "button_text" to goabSDK.getValue("button_text", "Clique Aqui"),
            "show_banner" to goabSDK.getValue("show_banner", true),
            "button_color" to goabSDK.getValue("button_color", "#FF0000")
        )
        _experimentValues.value = experiments
    }
    
    private fun observeExperiments() {
        lifecycleScope.launch {
            experimentValues.collect { experiments ->
                applyExperiments(experiments)
            }
        }
    }
    
    private fun applyExperiments(experiments: Map<String, Any>) {
        // Aplicar experimentos na UI
        findViewById<Button>(R.id.button).text = experiments["button_text"].toString()
        findViewById<Button>(R.id.button).setBackgroundColor(
            Color.parseColor(experiments["button_color"].toString())
        )
        findViewById<View>(R.id.banner).visibility = 
            if (experiments["show_banner"] as Boolean) View.VISIBLE else View.GONE
    }
}
```

## ViewModel com Flow

### ExperimentViewModel

```kotlin
class ExperimentViewModel(application: Application) : AndroidViewModel(application) {
    private val goabSDK: GoABSDK by lazy {
        GoABSDKFactory.create(
            context = application,
            accountId = 12345,
            apiToken = "your-api-token",
            timeoutSeconds = 30
        )
    }
    
    private val _experiments = MutableStateFlow<Map<String, Any>>(emptyMap())
    val experiments: StateFlow<Map<String, Any>> = _experiments.asStateFlow()
    
    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()
    
    private val _error = MutableStateFlow<String?>(null)
    val error: StateFlow<String?> = _error.asStateFlow()
    
    init {
        initializeSDK()
    }
    
    private fun initializeSDK() {
        viewModelScope.launch {
            try {
                _isLoading.value = true
                goabSDK.initialize()
                loadExperiments()
            } catch (e: Exception) {
                _error.value = "Erro ao inicializar SDK: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }
    
    private fun loadExperiments() {
        val experiments = mapOf(
            "button_text" to goabSDK.getValue("button_text", "Clique Aqui"),
            "show_banner" to goabSDK.getValue("show_banner", true),
            "button_color" to goabSDK.getValue("button_color", "#FF0000"),
            "max_retries" to goabSDK.getValue("max_retries", 3),
            "api_endpoint" to goabSDK.getValue("api_endpoint", "https://api.prod.com")
        )
        _experiments.value = experiments
    }
    
    fun refreshExperiments() {
        viewModelScope.launch {
            try {
                _isLoading.value = true
                goabSDK.refreshExperiments()
                loadExperiments()
            } catch (e: Exception) {
                _error.value = "Erro ao atualizar experimentos: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }
    
    fun clearError() {
        _error.value = null
    }
}
```

### Uso na Activity

```kotlin
class MainActivity : AppCompatActivity() {
    private lateinit var viewModel: ExperimentViewModel
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        viewModel = ViewModelProvider(this)[ExperimentViewModel::class.java]
        observeViewModel()
    }
    
    private fun observeViewModel() {
        // Observar experimentos
        lifecycleScope.launch {
            viewModel.experiments.collect { experiments ->
                applyExperiments(experiments)
            }
        }
        
        // Observar estado de carregamento
        lifecycleScope.launch {
            viewModel.isLoading.collect { isLoading ->
                findViewById<ProgressBar>(R.id.progress_bar).visibility = 
                    if (isLoading) View.VISIBLE else View.GONE
            }
        }
        
        // Observar erros
        lifecycleScope.launch {
            viewModel.error.collect { error ->
                error?.let {
                    Toast.makeText(this, it, Toast.LENGTH_LONG).show()
                    viewModel.clearError()
                }
            }
        }
    }
    
    private fun applyExperiments(experiments: Map<String, Any>) {
        // Aplicar experimentos na UI
        findViewById<Button>(R.id.button).text = experiments["button_text"].toString()
        findViewById<Button>(R.id.button).setBackgroundColor(
            Color.parseColor(experiments["button_color"].toString())
        )
        findViewById<View>(R.id.banner).visibility = 
            if (experiments["show_banner"] as Boolean) View.VISIBLE else View.GONE
    }
    
    private fun onRefreshClick() {
        viewModel.refreshExperiments()
    }
}
```

## Flow com Transformações

### ExperimentFlowManager

```kotlin
class ExperimentFlowManager(private val goabSDK: GoABSDK) {
    
    // Flow de experimentos individuais
    fun getButtonTextFlow(): Flow<String> = flow {
        emit(goabSDK.getValue("button_text", "Clique Aqui") as String)
    }
    
    fun getShowBannerFlow(): Flow<Boolean> = flow {
        emit(goabSDK.getValue("show_banner", true) as Boolean)
    }
    
    fun getButtonColorFlow(): Flow<String> = flow {
        emit(goabSDK.getValue("button_color", "#FF0000") as String)
    }
    
    // Flow combinado de todos os experimentos
    fun getAllExperimentsFlow(): Flow<Map<String, Any>> = combine(
        getButtonTextFlow(),
        getShowBannerFlow(),
        getButtonColorFlow()
    ) { buttonText, showBanner, buttonColor ->
        mapOf(
            "button_text" to buttonText,
            "show_banner" to showBanner,
            "button_color" to buttonColor
        )
    }
    
    // Flow com transformações
    fun getButtonTextWithPrefix(): Flow<String> = getButtonTextFlow()
        .map { text -> "🔘 $text" }
        .distinctUntilChanged()
    
    fun getButtonColorAsColor(): Flow<Int> = getButtonColorFlow()
        .map { colorString -> Color.parseColor(colorString) }
        .distinctUntilChanged()
    
    // Flow com filtros
    fun getBannerVisibilityFlow(): Flow<Int> = getShowBannerFlow()
        .map { showBanner -> if (showBanner) View.VISIBLE else View.GONE }
        .distinctUntilChanged()
}
```

### Uso com Transformações

```kotlin
class MainActivity : AppCompatActivity() {
    private lateinit var goabSDK: GoABSDK
    private lateinit var experimentManager: ExperimentFlowManager
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        setupSDK()
        observeExperiments()
    }
    
    private fun setupSDK() {
        goabSDK = GoABSDKFactory.create(
            context = this,
            accountId = 12345,
            apiToken = "your-api-token",
            timeoutSeconds = 30
        )
        
        experimentManager = ExperimentFlowManager(goabSDK)
        
        lifecycleScope.launch {
            goabSDK.initialize()
        }
    }
    
    private fun observeExperiments() {
        // Observar texto do botão com prefixo
        lifecycleScope.launch {
            experimentManager.getButtonTextWithPrefix()
                .collect { buttonText ->
                    findViewById<Button>(R.id.button).text = buttonText
                }
        }
        
        // Observar cor do botão
        lifecycleScope.launch {
            experimentManager.getButtonColorAsColor()
                .collect { buttonColor ->
                    findViewById<Button>(R.id.button).setBackgroundColor(buttonColor)
                }
        }
        
        // Observar visibilidade do banner
        lifecycleScope.launch {
            experimentManager.getBannerVisibilityFlow()
                .collect { visibility ->
                    findViewById<View>(R.id.banner).visibility = visibility
                }
        }
        
        // Observar todos os experimentos
        lifecycleScope.launch {
            experimentManager.getAllExperimentsFlow()
                .collect { experiments ->
                    Log.d("Experiments", "Experimentos atualizados: $experiments")
                }
        }
    }
}
```

## Flow com Cache e Refresh

### CachedExperimentManager

```kotlin
class CachedExperimentManager(private val goabSDK: GoABSDK) {
    private val _experiments = MutableStateFlow<Map<String, Any>>(emptyMap())
    val experiments: StateFlow<Map<String, Any>> = _experiments.asStateFlow()
    
    private val _isRefreshing = MutableStateFlow(false)
    val isRefreshing: StateFlow<Boolean> = _isRefreshing.asStateFlow()
    
    private val _lastRefresh = MutableStateFlow<Long?>(null)
    val lastRefresh: StateFlow<Long?> = _lastRefresh.asStateFlow()
    
    suspend fun loadExperiments() {
        val experiments = mapOf(
            "button_text" to goabSDK.getValue("button_text", "Clique Aqui"),
            "show_banner" to goabSDK.getValue("show_banner", true),
            "button_color" to goabSDK.getValue("button_color", "#FF0000"),
            "max_retries" to goabSDK.getValue("max_retries", 3),
            "api_endpoint" to goabSDK.getValue("api_endpoint", "https://api.prod.com")
        )
        _experiments.value = experiments
        _lastRefresh.value = System.currentTimeMillis()
    }
    
    suspend fun refreshExperiments() {
        _isRefreshing.value = true
        try {
            goabSDK.refreshExperiments()
            loadExperiments()
        } catch (e: Exception) {
            Log.e("CachedExperimentManager", "Erro ao atualizar experimentos", e)
        } finally {
            _isRefreshing.value = false
        }
    }
    
    fun getExperimentValue(key: String, defaultValue: Any): Any {
        return _experiments.value[key] ?: defaultValue
    }
    
    // Flow que emite quando experimentos específicos mudam
    fun getExperimentFlow(key: String, defaultValue: Any): Flow<Any> = experiments
        .map { it[key] ?: defaultValue }
        .distinctUntilChanged()
    
    // Flow que emite quando qualquer experimento muda
    fun getAnyExperimentChangeFlow(): Flow<Map<String, Any>> = experiments
        .distinctUntilChanged()
}
```

### Uso com Cache

```kotlin
class MainActivity : AppCompatActivity() {
    private lateinit var goabSDK: GoABSDK
    private lateinit var experimentManager: CachedExperimentManager
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        setupSDK()
        observeExperiments()
    }
    
    private fun setupSDK() {
        goabSDK = GoABSDKFactory.create(
            context = this,
            accountId = 12345,
            apiToken = "your-api-token",
            timeoutSeconds = 30
        )
        
        experimentManager = CachedExperimentManager(goabSDK)
        
        lifecycleScope.launch {
            goabSDK.initialize()
            experimentManager.loadExperiments()
        }
    }
    
    private fun observeExperiments() {
        // Observar mudanças em experimentos específicos
        lifecycleScope.launch {
            experimentManager.getExperimentFlow("button_text", "Clique Aqui")
                .collect { buttonText ->
                    findViewById<Button>(R.id.button).text = buttonText.toString()
                }
        }
        
        lifecycleScope.launch {
            experimentManager.getExperimentFlow("show_banner", true)
                .collect { showBanner ->
                    findViewById<View>(R.id.banner).visibility = 
                        if (showBanner as Boolean) View.VISIBLE else View.GONE
                }
        }
        
        // Observar estado de refresh
        lifecycleScope.launch {
            experimentManager.isRefreshing.collect { isRefreshing ->
                findViewById<ProgressBar>(R.id.refresh_progress).visibility = 
                    if (isRefreshing) View.VISIBLE else View.GONE
            }
        }
        
        // Observar última atualização
        lifecycleScope.launch {
            experimentManager.lastRefresh.collect { lastRefresh ->
                lastRefresh?.let {
                    val timeAgo = System.currentTimeMillis() - it
                    findViewById<TextView>(R.id.last_update).text = 
                        "Última atualização: ${timeAgo / 1000}s atrás"
                }
            }
        }
    }
    
    private fun onRefreshClick() {
        lifecycleScope.launch {
            experimentManager.refreshExperiments()
        }
    }
}
```

## Flow com Error Handling

### SafeExperimentFlowManager

```kotlin
class SafeExperimentFlowManager(private val goabSDK: GoABSDK) {
    
    fun getExperimentFlow(key: String, defaultValue: Any): Flow<Result<Any>> = flow {
        try {
            val value = goabSDK.getValue(key, defaultValue)
            emit(Result.success(value))
        } catch (e: Exception) {
            emit(Result.failure(e))
        }
    }
    
    fun getAllExperimentsFlow(): Flow<Result<Map<String, Any>>> = flow {
        try {
            val experiments = mapOf(
                "button_text" to goabSDK.getValue("button_text", "Clique Aqui"),
                "show_banner" to goabSDK.getValue("show_banner", true),
                "button_color" to goabSDK.getValue("button_color", "#FF0000")
            )
            emit(Result.success(experiments))
        } catch (e: Exception) {
            emit(Result.failure(e))
        }
    }
    
    fun getExperimentWithRetry(key: String, defaultValue: Any, maxRetries: Int = 3): Flow<Result<Any>> = flow {
        var retries = 0
        while (retries < maxRetries) {
            try {
                val value = goabSDK.getValue(key, defaultValue)
                emit(Result.success(value))
                return@flow
            } catch (e: Exception) {
                retries++
                if (retries >= maxRetries) {
                    emit(Result.failure(e))
                    return@flow
                }
                delay(1000 * retries) // Backoff exponencial
            }
        }
    }
}
```

### Uso com Error Handling

```kotlin
class MainActivity : AppCompatActivity() {
    private lateinit var goabSDK: GoABSDK
    private lateinit var experimentManager: SafeExperimentFlowManager
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        setupSDK()
        observeExperiments()
    }
    
    private fun setupSDK() {
        goabSDK = GoABSDKFactory.create(
            context = this,
            accountId = 12345,
            apiToken = "your-api-token",
            timeoutSeconds = 30
        )
        
        experimentManager = SafeExperimentFlowManager(goabSDK)
        
        lifecycleScope.launch {
            goabSDK.initialize()
        }
    }
    
    private fun observeExperiments() {
        // Observar experimentos com tratamento de erro
        lifecycleScope.launch {
            experimentManager.getExperimentFlow("button_text", "Clique Aqui")
                .collect { result ->
                    result.fold(
                        onSuccess = { buttonText ->
                            findViewById<Button>(R.id.button).text = buttonText.toString()
                        },
                        onFailure = { error ->
                            Log.e("MainActivity", "Erro ao obter button_text", error)
                            findViewById<Button>(R.id.button).text = "Clique Aqui"
                        }
                    )
                }
        }
        
        // Observar experimentos com retry
        lifecycleScope.launch {
            experimentManager.getExperimentWithRetry("show_banner", true, maxRetries = 3)
                .collect { result ->
                    result.fold(
                        onSuccess = { showBanner ->
                            findViewById<View>(R.id.banner).visibility = 
                                if (showBanner as Boolean) View.VISIBLE else View.GONE
                        },
                        onFailure = { error ->
                            Log.e("MainActivity", "Erro ao obter show_banner após retry", error)
                            findViewById<View>(R.id.banner).visibility = View.GONE
                        }
                    )
                }
        }
        
        // Observar todos os experimentos
        lifecycleScope.launch {
            experimentManager.getAllExperimentsFlow()
                .collect { result ->
                    result.fold(
                        onSuccess = { experiments ->
                            applyExperiments(experiments)
                        },
                        onFailure = { error ->
                            Log.e("MainActivity", "Erro ao obter experimentos", error)
                            applyDefaultValues()
                        }
                    )
                }
        }
    }
    
    private fun applyExperiments(experiments: Map<String, Any>) {
        // Aplicar experimentos na UI
        findViewById<Button>(R.id.button).text = experiments["button_text"].toString()
        findViewById<Button>(R.id.button).setBackgroundColor(
            Color.parseColor(experiments["button_color"].toString())
        )
        findViewById<View>(R.id.banner).visibility = 
            if (experiments["show_banner"] as Boolean) View.VISIBLE else View.GONE
    }
    
    private fun applyDefaultValues() {
        // Valores padrão quando há erro
        findViewById<Button>(R.id.button).text = "Clique Aqui"
        findViewById<Button>(R.id.button).setBackgroundColor(Color.parseColor("#FF0000"))
        findViewById<View>(R.id.banner).visibility = View.GONE
    }
}
```

## Próximos Passos

- [API Reference](./api-reference) - Documentação completa da API
- [Casos de Uso](./use-cases) - Exemplos práticos
- [Troubleshooting](./troubleshooting) - Resolução de problemas

