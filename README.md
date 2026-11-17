# DesCuento!

Aplicación móvil de e-commerce hecha con **Flutter**, conectada a una **API REST** con autenticación **JWT**, catálogo por secciones, carrito de compras y compra simulada.

Repositorio frontend: [Brajanvvs/fron_app_movil](https://github.com/Brajanvvs/fron_app_movil)

API base: `https://ecommerce-api-yg2c.onrender.com`  
Swagger: `https://ecommerce-api-yg2c.onrender.com/swagger-ui.html`  
Usuario de prueba: `demo` / `Demo12345`

> La primera petición puede tardar hasta 1 minuto porque Render despierta el servidor. El cliente usa timeout de 60 s.

---

## Objetivo del taller

Desarrollar una app de comercio electrónico donde el usuario pueda:

- Registrarse e iniciar sesión
- Recuperar / restablecer contraseña
- Ver productos, filtrarlos y buscarlos
- Ver detalle y agregar al carrito
- Simular una compra
- Ver / editar perfil y consultar pedidos

---

## Tecnologías

| Capa | Tecnología |
|------|------------|
| Frontend | Flutter 3.44 / Dart 3.12 |
| Estado | `provider` |
| HTTP | `http` |
| Sesión local | `shared_preferences` |
| UI | Material 3 |
| Backend | API REST externa (JWT Bearer) |

Dependencias principales en `pubspec.yaml`:

- `http` → llamadas REST
- `provider` → estado reactivo de auth y carrito
- `shared_preferences` → guardar JWT y usuario entre sesiones
- `flutter_lints` → reglas de calidad

---

## Cómo ejecutar

```bash
flutter pub get
flutter run
```

Para Android release (APK instalable):

```bash
flutter build apk --release
```

El APK queda en:

`build/app/outputs/flutter-apk/app-release.apk`

En el teléfono hay que permitir instalar apps de fuentes desconocidas.

---

## Estructura del proyecto

```text
lib/
├── main.dart                 # Entrada de la app
├── app.dart                  # MaterialApp + providers + rutas por sesión
├── core/                     # Infraestructura transversal
│   ├── api_client.dart       # Cliente HTTP + Bearer + errores
│   ├── api_exception.dart    # Excepción tipada (status, message, fieldErrors)
│   ├── theme.dart            # Paleta estilo Alkosto (azul/naranja)
│   ├── validators.dart       # Validaciones de formularios
│   ├── format.dart           # Dinero y fechas
│   └── feedback.dart         # SnackBars de error/éxito
├── data/
│   └── showcase_catalog.dart # Vitrina ~50 productos + banners + secciones
├── models/                   # Modelos de dominio
├── services/
│   ├── shop_api.dart         # Endpoints de la API
│   └── session_store.dart    # Persistencia del JWT
├── state/
│   ├── auth_controller.dart  # Login, registro, logout, perfil
│   └── cart_controller.dart  # Carrito y checkout
├── screens/                  # Pantallas completas
└── widgets/                  # Componentes reutilizables
```

Se separó la app en capas para que cada archivo tenga una responsabilidad clara: red, estado, UI y datos de vitrina.

---

## Pantallas implementadas

### Autenticación
- **Login** → username/correo + contraseña con mostrar/ocultar
- **Registro** → nombre, apellidos, username, email, contraseñas
- **Olvidé mi contraseña** → solicita enlace por correo
- **Restablecer contraseña** → token/enlace + nueva contraseña

### Tienda
- **Home** → estilo Alkosto: franja promo, banners, categorías, rieles por sección
- **Detalle de producto** → imagen, marca, precio, descuento, cantidad, agregar
- **Carrito** → ítems, IVA 19 %, envío, total y checkout simulado
- **Perfil** → avatar, datos editables y cambio de contraseña
- **Mis pedidos** / **Detalle de pedido** → historial desde el drawer

### Navegación
- `Drawer` lateral: Inicio, Mis pedidos, Perfil, Cerrar sesión
- `NavigationBar` inferior: Home, Carrito, Perfil
- Si no hay sesión → Login; si hay JWT válido → `MainShell`

---

## Integración con la API

### Autenticación
| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/auth/register` | Crear cuenta (no devuelve token) |
| POST | `/auth/login` | Devuelve JWT + usuario |
| POST | `/auth/logout` | Cierra sesión en servidor |
| GET | `/auth/check-username` | Disponibilidad de username |
| GET | `/auth/check-email` | Disponibilidad de email |
| POST | `/auth/forgot-password` | Envía enlace al correo |
| POST | `/auth/reset-password` | Cambia contraseña con token |

### Perfil
| Método | Ruta |
|--------|------|
| GET/PUT | `/users/me` |
| PUT | `/users/me/password` |

### Catálogo / Carrito / Pedidos
| Método | Ruta |
|--------|------|
| GET | `/banners`, `/categories`, `/products` |
| GET | `/products/{id}` |
| GET/POST/PATCH/DELETE | `/cart`, `/cart/items...` |
| POST | `/orders/checkout` |
| GET | `/orders`, `/orders/{id}` |

Errores de la API:

```json
{
  "status": 400,
  "message": "...",
  "fieldErrors": { "email": "..." }
}
```

- `fieldErrors` se muestran debajo de cada campo
- `message` se muestra en un SnackBar
- `401` limpia la sesión y vuelve al Login

### Vitrina local vs API

La API trae ~20 productos reales. Para que el Home se vea como una tienda grande (estilo Alkosto), se armó una **vitrina local de 50 productos** en `showcase_catalog.dart`, con:

- Imágenes de Unsplash coordinadas al título
- Precio tachado y % de descuento
- Secciones horizontales (celulares, TV, portátiles, hogar, etc.)

Al agregar al carrito se usa un `remoteProductId` válido de la API, así el carrito y el checkout siguen siendo reales.

---

## Por qué se usaron estos widgets (y para qué)

### Widgets de Flutter / Material

| Widget | Dónde / por qué |
|--------|------------------|
| `MaterialApp` | Tema global, título y pantalla raíz según sesión |
| `Scaffold` | Estructura base: AppBar, body, drawer, bottom bar |
| `AppBar` | Header azul con logo **DesCuento!**, buscador y accesos |
| `Drawer` | Menú lateral de cuenta / pedidos / logout |
| `NavigationBar` | Navegación inferior Home–Carrito–Perfil |
| `Form` + `TextFormField` | Formularios con validación por campo |
| `GlobalKey<FormState>` | Disparar `validate()` al enviar |
| `FilledButton` / `TextButton` | Acciones principales y links |
| `ListView` / `CustomScrollView` + `Sliver*` | Home largo con scroll fluido |
| `ListView` horizontal | Rieles de productos y categorías |
| `GridView` / `SliverGrid` | Resultados de búsqueda en 2 columnas |
| `PageView` | Carrusel de banners con auto-scroll |
| `Card` / `Material` + `InkWell` | Tarjetas tocables con ripple |
| `Hero` | Transición de imagen al detalle |
| `Image.network` | Fotos remotas con loading/error |
| `CircleAvatar` / `Badge` | Avatar de usuario y contador del carrito |
| `FilterChip` / `ChoiceChip` | Categorías y método de pago |
| `RefreshIndicator` | Pull-to-refresh en Home y pedidos |
| `AlertDialog` / `showModalBottomSheet` | Confirmación de compra y checkout |
| `SnackBar` | Feedback de errores y éxitos |
| `IndexedStack` | Conserva el estado de las pestañas al cambiar |
| `SafeArea` | Respeta notch / barras del sistema |
| `ValueListenableBuilder` | Reaccionar al texto del buscador sin setState global |

### Widgets propios (`lib/widgets/`)

Se crearon widgets reutilizables para no repetir UI y mantener pantallas más limpias:

| Widget | Motivo |
|--------|--------|
| `ProductCard` | Misma tarjeta en grilla y en riel horizontal (precio, descuento, botón carrito) |
| `PromoCarousel` | Carrusel con timer, indicadores y estilo de banners |
| `PasswordField` | Campo de contraseña con toggle mostrar/ocultar reutilizable |
| `SubmitButton` | Botón con estado de carga (spinner) para login, registro, carrito, etc. |
| `RemoteImage` | Imagen de red con placeholder y manejo de error |
| `UserAvatar` | Avatar con foto o iniciales |
| `AppDrawer` | Drawer con header del usuario autenticado |

### Estado y arquitectura (no son widgets, pero se apoyan en ellos)

| Pieza | Motivo |
|-------|--------|
| `ChangeNotifier` + `Provider` | La UI se reconstruye cuando cambia auth o carrito |
| `AuthController` | Centraliza login, JWT, perfil y logout |
| `CartController` | Centraliza carrito, cantidades y checkout |
| `ApiClient` | Un solo lugar para headers, timeout y parseo de errores |
| `SessionStore` | Persiste token para no pedir login cada vez |

---

## Validaciones implementadas

### Login
- Campo no vacío
- Si parece email → formato válido
- Contraseña mínimo 6 caracteres
- Errores inline + SnackBar

### Registro
- Ningún campo vacío
- Email válido
- Username 3–40, patrón permitido
- Username/email únicos (check al backend)
- Contraseña mínimo 8 y confirmación igual

### Perfil
- Nombre / apellidos / username editables
- Email solo lectura
- Cambio de contraseña con contraseña actual

---

## Diseño visual

Inspirado en **Alkosto**:

- Azul navy de header (`#003B7A`)
- Naranja de ofertas / CTA (`#FF6A00`)
- Fondo gris claro y tarjetas blancas
- Franja promo, grilla de categorías, rieles por sección
- Badges de descuento y precios tachados

Marca de la app: **DesCuento!**

---

## Flujo de sesión

1. `SplashScreen` mientras se lee el token guardado
2. Si hay token → se valida con `/users/me`
3. Si es válido → Home (`MainShell`)
4. Si falla o no hay token → `LoginScreen`
5. Logout llama `/auth/logout`, borra preferencias y vuelve al login
6. Cualquier `401` en rutas protegidas fuerza cierre de sesión

---

## Tests

```bash
flutter test
flutter analyze
```

Hay pruebas de:

- Formato de dinero / porcentajes
- Validadores de login y registro
- Parseo de modelos
- Widget de Login (errores inline en campos vacíos)

---

## Entregables cubiertos

- [x] App Flutter completa
- [x] Autenticación JWT (registro, login, logout, forgot/reset)
- [x] Pantallas: Login, Registro, Home, Detalle, Carrito, Perfil
- [x] Drawer + BottomNavigationBar
- [x] Banners, búsqueda, filtros/categorías, grilla/rieles de productos
- [x] Carrito con subtotal, IVA, envío y total
- [x] Checkout simulado y mis pedidos
- [x] Consumo de API REST
- [x] README con explicación técnica y de widgets

---

## Autor / curso

Proyecto final de **Aplicaciones Móviles** — Uniminuto.  
Frontend Flutter: este repositorio.  
Backend REST: API desplegada en Render.
