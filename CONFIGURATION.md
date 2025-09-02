# Event Configuration Guide

This guide explains how to configure your event using the JSON files in the `events/` directory. The template uses a year-based structure that allows you to manage multiple event editions.

## 📁 Directory Structure

```
events/
└── 2025/                    # Year-based event directory
    ├── config/
    │   ├── site.json       # Main event configuration
    │   └── agenda.json     # Event schedule and sessions
    ├── speakers/
    │   └── speakers.json   # Speaker profiles and information
    └── sponsors/
        └── sponsors.json   # Sponsor information and tiers
```

## 🔧 Configuration Files

### 1. Site Configuration (`events/2025/config/site.json`)

Main event configuration including basic information, dates, venue, and theming:

```json
{
  "eventName": "DevFest Spain 2025",
  "year": "2025",
  "baseUrl": "https://vicajilau.github.io/event_flutter_template",
  "primaryColor": "#4285F4",
  "secondaryColor": "#34A853",
  "eventDates": {
    "startDate": "2025-03-15",
    "endDate": "2025-03-15",
    "timezone": "Europe/Madrid"
  },
  "venue": {
    "name": "Palacio de Congresos",
    "address": "Madrid, España",
    "city": "Madrid"
  },
  "description": "El evento tecnológico más importante de España para desarrolladores"
}
```

#### Configuration Fields

| Field                  | Type   | Description                                  |
|------------------------|--------|----------------------------------------------|
| `eventName`            | string | Name of your event                           |
| `year`                 | string | Event year (matches directory name)          |
| `baseUrl`              | string | Base URL for deployment (GitHub Pages, etc.) |
| `primaryColor`         | string | Primary theme color (hex format)             |
| `secondaryColor`       | string | Secondary theme color (hex format)           |
| `eventDates.startDate` | string | Event start date (ISO format)                |
| `eventDates.endDate`   | string | Event end date (ISO format)                  |
| `eventDates.timezone`  | string | Event timezone                               |
| `venue.name`           | string | Venue name                                   |
| `venue.address`        | string | Venue address                                |
| `venue.city`           | string | Venue city                                   |
| `description`          | string | Event description                            |

### 2. Agenda Configuration (`events/2025/config/agenda.json`)

Event schedule with multi-day and multi-track support:

```json
{
  "days": [
    {
      "date": "2025-03-15",
      "tracks": [
        {
          "name": "Sala Principal",
          "color": "#4285F4",
          "sessions": [
            {
              "title": "Apertura y Keynote",
              "time": "09:00 - 09:30",
              "speaker": "Equipo organizador",
              "description": "Bienvenida al DevFest 2025",
              "type": "keynote"
            },
            {
              "title": "Google Summer of Code y Becas Google",
              "time": "09:30 - 10:15",
              "speaker": "Irene Ruiz Pozo",
              "description": "Tu puerta de entrada al mundo tech",
              "type": "talk"
            }
          ]
        }
      ]
    }
  ]
}
```

#### Session Types

- **`keynote`**: Main presentations
- **`talk`**: Regular presentations
- **`workshop`**: Hands-on sessions
- **`networking`**: Networking sessions
- **`break`**: Coffee breaks

### 3. Speakers Configuration (`events/2025/speakers/speakers.json`)

Speaker profiles with social media links:

```json
[
  {
    "name": "Irene Ruiz Pozo",
    "bio": "DevRel Intern at Open Gateway (Telefónica) | Developer Advocate | Google Developer Groups Lead and Women Techmakers Ambassador at Google Developers",
    "image": "https://media.licdn.com/dms/image/v2/C5603AQF7fzq6u-G5-w/profile-displayphoto-shrink_800_800/profile-displayphoto-shrink_800_800/0/1576055966928",
    "social": {
      "linkedin": "https://www.linkedin.com/in/ireneruizpozo/"
    }
  },
  {
    "name": "Alfredo Bautista Santos",
    "bio": "Software Developer | GDE Flutter & Dart",
    "image": "https://media.licdn.com/dms/image/v2/D4D03AQGzFgA66uZ-SQ/profile-displayphoto-shrink_800_800/profile-displayphoto-shrink_800_800/0/1701780829719",
    "social": {
      "linkedin": "https://www.linkedin.com/in/alfredo-bautista-santos-179b2b105/",
      "website": "https://alfredo.dev",
      "twitter": "https://x.com/alfredobs97"
    }
  }
]
```

#### Supported Social Media

- `linkedin` - LinkedIn profile
- `twitter` - Twitter/X profile
- `website` - Personal website
- `github` - GitHub profile

### 4. Sponsors Configuration (`events/2025/sponsors/sponsors.json`)

Sponsor information with different tiers:

```json
[
  {
    "name": "Google",
    "type": "Patrocinador Principal",
    "logo": "https://logo.clearbit.com/google.com",
    "website": "https://google.com"
  },
  {
    "name": "Microsoft",
    "type": "Patrocinador Principal",
    "logo": "https://logo.clearbit.com/microsoft.com",
    "website": "https://microsoft.com"
  },
  {
    "name": "Firebase",
    "type": "Patrocinador Gold",
    "logo": "https://cdn.worldvectorlogo.com/logos/firebase-1.svg",
    "website": "https://firebase.google.com"
  }
]
```

#### Sponsor Tiers

Common sponsor types:

- **`Patrocinador Principal`** - Main sponsors
- **`Patrocinador Gold`** - Gold tier sponsors
- **`Patrocinador Silver`** - Silver tier sponsors
- **`Patrocinador Bronce`** - Bronze tier sponsors
- **`Colaborador`** - Collaborators

## 🚀 Quick Setup Guide

### Step 1: Create Your Event Year

1. Copy the `events/2025/` directory to `events/YYYY/` (your event year)
2. Update the `year` field in `config/site.json`

### Step 2: Configure Basic Information

Edit `events/YYYY/config/site.json`:

```json
{
  "eventName": "Your Event Name",
  "year": "YYYY",
  "baseUrl": "https://yourusername.github.io/your-repo",
  "eventDates": {
    "startDate": "YYYY-MM-DD",
    "endDate": "YYYY-MM-DD",
    "timezone": "Your/Timezone"
  },
  "venue": {
    "name": "Your Venue",
    "address": "Your Address",
    "city": "Your City"
  }
}
```

### Step 3: Add Your Speakers

Edit `events/YYYY/speakers/speakers.json`:

1. Replace with your speakers' information
2. Use high-quality images (square format recommended)
3. Include relevant social media links

### Step 4: Configure Your Agenda

Edit `events/YYYY/config/agenda.json`:

1. Set your event dates
2. Configure tracks (rooms/spaces)
3. Add sessions with speakers and times
4. Use appropriate session types

### Step 5: Add Your Sponsors

Edit `events/YYYY/sponsors/sponsors.json`:

1. Add sponsor information
2. Use high-quality logos (SVG or PNG)
3. Organize by sponsor tiers

## 🎨 Theming and Customization

### Colors

Update `primaryColor` for theme color and `secondaryColor` for accent color in `site.json`:

```json
{
  "primaryColor": "#4285F4",
  "secondaryColor": "#34A853"
}
```

### Recommended Color Schemes

| Event Type       | Primary   | Secondary |
|------------------|-----------|-----------|
| Google Events    | `#4285F4` | `#34A853` |
| Microsoft Events | `#0078D4` | `#00BCF2` |
| Flutter Events   | `#02569B` | `#13B9FD` |
| General Tech     | `#6366F1` | `#8B5CF6` |

## 🌍 Multi-Year Support

The template supports multiple event editions:

```
events/
├── 2024/           # Previous event
├── 2025/           # Current event
└── 2026/           # Future event
```

Each year maintains its own:

- Configuration
- Speakers
- Agenda
- Sponsors

## 📱 Environment Configuration

The template supports different environments:

| Environment | Data Source           | Use Case    |
|-------------|-----------------------|-------------|
| **dev**     | Local `events/` files | Development |
| **pre**     | GitHub raw files      | Testing     |
| **pro**     | GitHub Pages          | Production  |

## 🔄 Data Loading

The app automatically loads data based on:

1. **Current environment** (dev/pre/pro)
2. **Selected year** (from URL or default)
3. **File structure** in `events/YYYY/`

## 📝 Best Practices

### Images

- Use HTTPS URLs for all images
- Prefer square format for speaker photos
- Use vector logos (SVG) for sponsors when possible

### Content

- Keep speaker bios concise but informative
- Use consistent time formats in agenda
- Organize sessions logically by track

### URLs

- Use clean, permanent URLs for social media
- Test all external links before deployment
- Use shortlinks for complex URLs

### Performance

- Optimize image sizes (compress before uploading)
- Use CDN URLs when possible
- Keep JSON files well-formatted and minified for production

This configuration system allows you to easily manage your event content while maintaining a professional, scalable structure.
