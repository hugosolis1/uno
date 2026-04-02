# 🔮 Planetary Ephemeris

App iOS de efemérides planetarias reales usando **Swiss Ephemeris**. Calcula posiciones exactas de todos los planetas, casas astrales (Placidus), y permite búsqueda por grado en rangos de fechas.

## ✨ Funcionalidades

- **Efemérides reales** usando Swiss Ephemeris (JPL DE430)
- **10 cuerpos celestes**: Sol, Luna, Mercurio, Venus, Marte, Júpiter, Saturno, Urano, Neptuno, Plutón + Nodo Norte
- **Modo Geocéntrico** (visto desde la Tierra) y **Heliocéntrico** (visto desde el Sol)
- **12 Casas Astrales** completas con sistema Placidus (también Koch, Porfirio, Igual, Signo Entero)
- **Puntos angulares**: Ascendente (ASC), Descendente (DSC), Medio Cielo (MC), Fondo de Cielo (IC), Vértex
- **Búsqueda por grado**: Encuentra cuándo los planetas alcanzaron un grado específico en un rango de fechas
- **Retrogradaciones** marcadas visualmente (Rx en rojo)
- **Rueda astral gráfica** con posiciones planetarias y divisiones de casas
- **Coordenadas Greenwich** (51.5074°N, 0.1278°W) como ubicación fija
- **Selector UTC** (-12 a +14)
- **Tema oscuro** con acentos azules

## 📦 Datos por Planeta

| Dato | Descripción |
|------|-------------|
| Longitud eclíptica | Posición en grados (0° - 360°) con signo zodiacal |
| Latitud eclíptica | Distancia del plano eclíptico |
| Ascensión Recta | Posición en coordenadas ecuatoriales |
| Declinación | Posición norte/sur del ecuador celeste |
| Distancia | En UA (Unidades Astronómicas) |
| Velocidad | Grados por día (positiva = directo, negativa = retrógrado) |

## 🛠️ Estructura del Proyecto

```
PlanetaryEphemeris/
├── Sources/PlanetaryEphemeris/
│   ├── App/                          # Entry point
│   ├── Models/                       # Modelos de datos
│   ├── Services/                     # Swiss Ephemeris bridge + búsquedas
│   ├── Views/                        # SwiftUI views
│   │   ├── Components/               # Componentes reutilizables
│   │   ├── ContentView.swift         # TabView principal
│   │   ├── EphemerisTabView.swift    # Tab de efemérides
│   │   ├── EphemerisResultView.swift # Resultados
│   │   └── SearchTabView.swift       # Búsqueda por grado
│   ├── PlanetaryEphemeris-Bridging-Header.h
│   └── Info.plist
├── Vendor/swisseph/                  # Swiss Ephemeris (git submodule)
├── Resources/ephe/                   # Datos de efemérides (.se1)
├── scripts/
│   └── setup_ephemeris.sh            # Descarga datos de efemérides
├── project.yml                       # XcodeGen config
├── codemagic.yaml                    # Codemagic CI/CD
├── Makefile                          # Comandos de build
├── Gemfile
├── .gitmodules
└── .gitignore
```

## 🚀 Configuración

### Requisitos
- macOS con Xcode 15+
- XcodeGen (`brew install xcodegen`)
- Git

### Setup Local

```bash
# 1. Clonar con submódulos
git clone --recursive https://github.com/TU_USUARIO/PlanetaryEphemeris.git
cd PlanetaryEphemeris

# 2. Descargar datos de efemérides (~15 MB)
chmod +x scripts/setup_ephemeris.sh
./scripts/setup_ephemeris.sh

# 3. Generar proyecto Xcode
xcodegen generate

# 4. Abrir en Xcode
open PlanetaryEphemeris.xcodeproj

# O build desde línea de comandos:
make ipa
```

### Build sin firmar (IPA)

```bash
# Build completo
make ipa

# Esto genera: PlanetaryEphemeris_unsigned.ipa
```

## 📱 Codemagic CI/CD

El proyecto está configurado para construir automáticamente en Codemagic:

1. Conecta tu repositorio de GitHub a Codemagic
2. Codemagic automáticamente:
   - Inicializa el git submodule (Swiss Ephemeris)
   - Descarga los datos de efemérides
   - Genera el proyecto con XcodeGen
   - Compila sin firmar
   - Genera el `.ipa` sin firmar

El archivo `codemagic.yaml` contiene toda la configuración necesaria.

## 📋 Créditos

- **Swiss Ephemeris** por Astrodienst (https://www.astro.com/swisseph/)
- Datos basados en JPL DE430/DE431
- Algoritmos de casas: Placidus, Koch, Porfirio, Igual, Signo Entero

## 📄 Licencia

Proyecto de código abierto para uso personal y educativo.
