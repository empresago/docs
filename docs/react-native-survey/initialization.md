---
sidebar_position: 3
---

# Inicialização

Configure o Survey SDK na sua app.

## Criar instância

```tsx
import { SurveySdkFactory } from '@goab_ltda/survey-sdk-react-native';

const surveySdk = SurveySdkFactory.create({
  accountId: 2,
  apiToken: 'your-api-token',
  timeoutMillis: 30_000,
});
```

## Ordem recomendada de setup

```tsx
import { useEffect } from 'react';
import { SurveySdkFactory, SurveyHost } from '@goab_ltda/survey-sdk-react-native';

// 1. Criar instância (uma vez, fora do componente ou num módulo próprio)
const surveySdk = SurveySdkFactory.create({
  accountId: 2,
  apiToken: 'your-api-token',
});

export default function App() {
  useEffect(() => {
    // 2. Usuário (se já conhecido)
    surveySdk.setUserId(getLoggedInUserId());
    surveySdk.setUserAttributes(getUserAttributes());

    // 3. Preparar o SDK
    surveySdk.initialize();
  }, []);

  return (
    <>
      <Navegacao />
      {/* 4. Onde a pesquisa pode aparecer na tela — montado uma vez, por último na raiz */}
      <SurveyHost sdk={surveySdk} />
    </>
  );
}
```

## O que `initialize()` faz

Prepara o SDK para receber eventos e exibir pesquisas: carrega as configurações salvas localmente, inicia uma nova sessão analítica e reenvia qualquer evento que tenha ficado pendente (ver abaixo). Deve ser chamado **uma vez**, depois de criar a instância.

`initialize()` retorna uma `Promise`, mas não é preciso esperá-la para usar o SDK — veja a seguir.

## Eventos antes do `initialize()` terminar

Chamar [`sendEvent`](./api-reference#sendevent) antes do `initialize()` concluir **não é ignorado**: o evento fica guardado (até 20 eventos, descartando o mais antigo quando a fila enche) e é reenviado automaticamente assim que o SDK ficar pronto — desde que tenha menos de 30 segundos quando o reenvio acontecer. Trocar o usuário com [`setUserId`](./api-reference#setuserid) ou chamar [`disposeSurvey`](./api-reference#disposesurvey) descarta os eventos guardados.

Isso quer dizer que você pode chamar `surveySdk.initialize()` e já disparar eventos de tela/ação em seguida, sem precisar encadear no `.then()`.

## Verificar estado

```tsx
if (surveySdk.isInitialized()) {
  surveySdk.sendEvent('app_ready');
} else {
  console.warn('Survey SDK ainda não inicializado');
}
```

## O `<SurveyHost>`

O `<SurveyHost>` é quem apresenta a pesquisa na tela — equivalente ao `setPresentationHost` dos SDKs nativos. Monte-o **uma única vez**, como último filho da raiz do app (acima de tudo que deve ficar por baixo da pesquisa quando ela aparece):

```tsx
<SurveyHost sdk={surveySdk} bottomInset={insets.bottom} />
```

| Prop | Tipo | Obrigatório | Descrição |
|------|------|-------------|-----------|
| `sdk` | `SurveySdk` | Sim | A instância criada por `SurveySdkFactory.create` |
| `bottomInset` | number | Não | Espaço extra abaixo da barra minimizada (ex.: a área segura inferior do aparelho) |

Se uma pesquisa for decidida sem o `<SurveyHost>` montado, o SDK registra um aviso e não exibe nada — não há erro nem crash, mas a pesquisa também não aparece.

## Tratamento de erros

```tsx
useEffect(() => {
  surveySdk.initialize().catch((erro) => {
    console.error('Falha na inicialização do Survey SDK', erro);
  });
}, []);
```

Se a inicialização falhar, trate o erro na app e tente novamente quando fizer sentido (ex.: após o usuário recuperar conexão).

## Próximos passos

- [API Reference](./api-reference) — referência completa da API pública
- [Eventos de Survey](./events) — tipagem e exemplos do listener de eventos
