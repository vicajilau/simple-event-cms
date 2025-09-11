# Sistema de Navegación Unificado con GoRouter

## Descripción
Se ha implementado un sistema de navegación unificado que combina la aplicación de eventos y el panel de administración en una sola aplicación usando GoRouter.

## Rutas Disponibles

### Rutas Públicas
- `/` - Pantalla principal (eventos)
- `/events` - Lista de eventos (misma que la principal)

### Rutas de Administración
- `/admin` - Panel de administración (requiere acceso especial)
- `/admin/login` - Pantalla de login con GitHub

## Formas de Acceder al Panel de Administración

### 1. Gesto Oculto (Recomendado para producción)
- Hacer **5 taps rápidos** en el título de la organización en la barra superior
- El contador se resetea automáticamente después de 3 segundos
- Método discreto que no es visible para usuarios finales

### 2. URL Directa (Para desarrollo)
- Navegar directamente a `/admin` en el navegador
- Útil durante el desarrollo y testing

### 3. Parámetro de Query (Futuro)
- Se podría implementar `/?admin=true` para acceso directo
- No implementado actualmente, pero fácil de agregar

## Estructura de la Aplicación

```
UnifiedApp (MaterialApp.router)
├── AppRouter (GoRouter)
│   ├── / → HomeScreen → EventsWrapperScreen
│   ├── /events → EventsWrapperScreen
│   ├── /admin → AdminScreen
│   └── /admin/login → LoginPage
```

## Beneficios del Nuevo Sistema

1. **Una sola aplicación**: No más MaterialApps duplicadas
2. **Navegación basada en URL**: Soporte para deep linking
3. **Fácil mantenimiento**: Un solo punto de configuración para routing
4. **Acceso discreto**: Gesto oculto para el panel de admin
5. **Escalabilidad**: Fácil agregar nuevas rutas en el futuro

## Migración de Código Anterior

### Antes
```dart
// main.dart
runApp(MyApp()); // o AdminApp()

// Navegación manual con Navigator.push
Navigator.push(context, MaterialPageRoute(...));
```

### Después
```dart
// main.dart
runApp(const UnifiedApp());

// Navegación declarativa con GoRouter
context.go('/admin');
context.go('/events');
```

## Configuración de Tema

El tema se aplica globalmente en `UnifiedApp` y se puede personalizar dinámicamente basado en la configuración de la organización cargada en `EventsWrapperScreen`.

## Desarrollo Futuro

1. **Autenticación persistente**: Mantener estado de login entre sesiones
2. **Protección de rutas**: Middleware para proteger rutas admin
3. **Parámetros de query**: `/?mode=admin` para acceso alternativo
4. **Lazy loading**: Cargar pantallas de admin solo cuando sea necesario
5. **Breadcrumbs**: Navegación contextual en el admin
