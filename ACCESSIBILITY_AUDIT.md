# Auditoria de Acessibilidade (a11y) — StreamPlayerApp

> Gerado em: 2026-04-11
> Padrão de referência: WCAG 2.1 AA

O app apresenta falhas em diversas verificações de acessibilidade, impactando usuários de TalkBack, leitores de tela e pessoas com baixa visão. A análise identificou 3 categorias principais: elementos sem semântica adequada para leitores de tela, contraste de cores insuficiente e tamanhos de toque abaixo do mínimo recomendado.

---

## Prioridade 1 — Crítico (bloqueadores de acessibilidade)

### 1.1 `BasicToolbar.kt` — Botão voltar invisível para TalkBack
**Arquivo:** `core-shared-ui/src/commonMain/.../widget/BasicToolbar.kt:29`

O `Icon` do botão "Voltar" tem `contentDescription = null`. Por ser o único elemento de navegação na barra, o TalkBack não consegue anunciá-lo.

**Fix:** Substituir `contentDescription = null` por um string resource descritivo (ex: `stringResource(SharedRes.string.icon_back)` — verificar se já existe em `core-shared-ui`; criar se necessário).

---

### 1.2 `DetailStreamImagePreview.kt` — Ícone de play clicável sem descrição
**Arquivo:** `feature-detail/src/commonMain/.../widget/DetailStreamImagePreview.kt:64-72`

`Icon` de play é **clicável** (`.clickable { onPlayEvent() }`) com `contentDescription = null`. TalkBack não anuncia nem identifica como botão.

**Fix:**
- Adicionar `contentDescription = stringResource(Res.string.detail_stream_play)` (criar a string)
- Adicionar `Modifier.semantics { role = Role.Button }` antes do `.clickable`

---

### 1.3 `SearchStreamCard.kt` — `contentDescription = ""` (pior que null)
**Arquivo:** `feature-search/src/commonMain/.../widgets/SearchStreamCard.kt`

- **Linha 85** (`WebImage`): `contentDescription = ""` — TalkBack anuncia "sem rótulo". Deve usar o título do filme.
- **Linha 104** (`Icon` PlayArrow): `contentDescription = ""` — deve ser `null` (decorativo dentro de `Row` clicável) ou ter texto descritivo.

**Fix:**
- Linha 85: `contentDescription = content.title` — o `content` já está disponível no escopo; passar para `ImageStream` via parâmetro
- Linha 104: `contentDescription = null` (ícone decorativo; o `Row` pai já é clicável e tem texto)

---

## Prioridade 2 — Alto (impacta usuários de leitores de tela)

### 2.1 Elementos `clickable` sem `role = Role.Button`

Todos os elementos abaixo usam `.clickable {}` mas não informam ao TalkBack que são botões. O sistema assistivo não os anuncia como interativos.

**Fix em cada arquivo:** adicionar `.semantics { role = Role.Button }` imediatamente **antes** de `.clickable`:

| Arquivo | Linha | Elemento |
|---|---|---|
| `core-shared-ui/.../widget/StreamsCard.kt` | 30 | `Card` com poster do filme |
| `core-shared-ui/.../widget/IconWithText.kt` | 32 | `Column` com ícone + texto (usado em feature-detail) |
| `core-shared-ui/.../widget/SharingStreamPlatform.kt` | ~42, ~54, ~66, ~78 | 4× `Row` de opções de compartilhamento |
| `feature-search/.../widgets/SearchStreamCard.kt` | 42 | `Row` com resultado de busca |
| `feature-profile/.../widget/ProfilePickerProfilesGrid.kt` | ~108 | `WebImage` de seleção de perfil |

Padrão de correção:
```kotlin
// Antes
.clickable { ... }

// Depois
.semantics { role = Role.Button }
.clickable { ... }
```

---

### 2.2 `Colors.kt` — Contraste de `onSurfaceVariant` insuficiente sobre `surface`
**Arquivo:** `core-shared-ui/src/commonMain/.../resources/Colors.kt:21,31`

`onSurfaceVariant = Color(0xFF7b7b7b)` sobre `surface = Color(0xFF121212)` → contraste **~4.25:1** (falha WCAG AA que exige 4.5:1 para texto normal).

**Fix:** Aumentar para `Color(0xFF909090)` (contraste ~5.68:1 sobre #121212), aplicado em ambos `LightColors` e `DarkColors`.

---

### 2.3 `SearchStreams.kt` — Placeholder invisível no campo de busca
**Arquivo:** `feature-search/src/commonMain/.../widgets/SearchStreams.kt`

Placeholder com `Color.Gray` (#808080) sobre `Colors.Gray100` (#2C2C2C) → contraste **~3.53:1** (falha WCAG AA).

**Fix:** Substituir `Color.Gray` no placeholder por `Color.White.copy(alpha = 0.6f)` → contraste ~5.8:1 sobre #2C2C2C.

---

## Prioridade 3 — Médio (legibilidade e usabilidade)

### 3.1 `HighlightBanner.kt` — Fonte de 10sp abaixo do mínimo recomendado
**Arquivo:** `feature-list-streams/src/commonMain/.../widgets/HighlightBanner.kt:203,225`

`AddToListButton` e `InfoButton` usam `fontSize = 10.sp`. WCAG recomenda mínimo de 12sp.

**Fix:** Alterar `fontSize = 10.sp` → `fontSize = 12.sp` nas duas funções.

---

### 3.2 `HighlightBanner.kt` — Botão Play com área de toque abaixo de 48dp
**Arquivo:** `feature-list-streams/src/commonMain/.../widgets/HighlightBanner.kt`

`PlayButton` usa `defaultMinSize(minWidth = 28.dp, minHeight = 28.dp)`, sobrescrevendo o mínimo do Material3 (48dp).

**Fix:** Remover o `defaultMinSize` ou alterar para `defaultMinSize(minWidth = 120.dp, minHeight = 48.dp)` para manter o tamanho visual mas garantir a área de toque mínima.

---

### 3.3 `ProfilePickerStreamToolbar.kt` — Ícone de editar sem descrição
**Arquivo:** `feature-profile/src/commonMain/.../widget/ProfilePickerStreamToolbar.kt:47`

`Icon` de edição (lápis) com `contentDescription = null` dentro de elemento interativo.

**Fix:** Adicionar `contentDescription = stringResource(Res.string.profile_edit_icon)` (criar string) e `semantics { role = Role.Button }` no elemento pai clicável.

---

### 3.4 `ImagePickerCameraGallery.kt` — Ícone de compartilhar sem descrição
**Arquivo:** `feature-news/src/commonMain/.../widget/ImagePickerCameraGallery.kt:50`

`Icon` de compartilhamento com `contentDescription = null`.

**Fix:** `contentDescription = stringResource(Res.string.news_share_icon)` (criar string).

---

## Arquivos verificados — sem problemas (não alterar)

| Arquivo | Motivo |
|---|---|
| `DetailStreamRowHeader.kt:34` | Logo Netflix decorativo, sem função interativa → `null` correto |
| `DetailStreamButtonAction.kt:44` | `Icon` dentro de `Button` com `Text` label → decorativo, `null` correto |
| `HighlightBanner.kt` (AddToList/InfoButton) | `IconButton` com `contentDescription` correto no `Icon` interno |
| `StreamPlayerBottomNavigation.kt` | Bem estruturado — labels e `contentDescription` corretos em todos os itens |

---

## Como verificar as correções

1. **TalkBack manual** — Ativar TalkBack no device, navegar pela tela principal, tela de detalhe e busca. Verificar que todos os elementos interativos são anunciados com nome e role ("botão").
2. **Lint** — `./gradlew :composeApp:lintDebug` — verificar `AccessibilityIssue` warnings.
3. **Contraste** — Usar a ferramenta [Accessibility Scanner](https://play.google.com/store/apps/details?id=com.google.android.apps.accessibility.auditor) (Google) no device para validar os pares de cor corrigidos.
4. **Tamanho de toque** — No Android Developer Options, ativar "Show tap circles" e verificar se todos os botões na tela de banner têm área ≥ 48dp.
