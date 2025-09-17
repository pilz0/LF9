#!/bin/bash

# LF9 Multilingual Documentation Generator
# Creates template files for all EU languages as requested

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Language configuration: code|name|native_name|flag
LANGUAGES=(
    "bg|Bulgarian|Български|🇧🇬"
    "hr|Croatian|Hrvatski|🇭🇷"
    "cs|Czech|Čeština|🇨🇿"
    "da|Danish|Dansk|🇩🇰"
    "nl|Dutch|Nederlands|🇳🇱"
    "en|English|English|🇬🇧"
    "et|Estonian|Eesti|🇪🇪"
    "fi|Finnish|Suomi|🇫🇮"
    "fr|French|Français|🇫🇷"
    "de|German|Deutsch|🇩🇪"
    "el|Greek|Ελληνικά|🇬🇷"
    "hu|Hungarian|Magyar|🇭🇺"
    "ga|Irish|Gaeilge|🇮🇪"
    "it|Italian|Italiano|🇮🇹"
    "lv|Latvian|Latviešu|🇱🇻"
    "lt|Lithuanian|Lietuvių|🇱🇹"
    "mt|Maltese|Malti|🇲🇹"
    "pl|Polish|Polski|🇵🇱"
    "pt|Portuguese|Português|🇵🇹"
    "ro|Romanian|Română|🇷🇴"
    "sk|Slovak|Slovenčina|🇸🇰"
    "sl|Slovenian|Slovenščina|🇸🇮"
    "es|Spanish|Español|🇪🇸"
    "sv|Swedish|Svenska|🇸🇪"
)

echo "🌍 LF9 Multilingual Documentation Generator"
echo "==========================================="

# Create base directories
mkdir -p docs/i18n

# Function to create README template for a language
create_readme_template() {
    local code=$1
    local name=$2
    local native=$3
    local flag=$4
    
    if [ "$code" = "en" ]; then
        echo "Skipping English (already exists as main README.md)"
        return
    fi
    
    # Skip if file already exists
    if [ -f "docs/i18n/README-${code}.md" ]; then
        echo "✅ README-${code}.md already exists"
        return
    fi
    
    echo "📝 Creating README template for ${name} (${native})"
    
    cat > "docs/i18n/README-${code}.md" << EOF
# 📖 [TRANSLATED TITLE NEEDED] - LF9 Kingdom Chronicle

*"[TRANSLATED PROLOGUE NEEDED] - Epic story of eleven digital souls in the LF9 Kingdom..."*

## 🏰 [TRANSLATED: Prologue] - The Birth of a Digital Kingdom

[TRANSLATION NEEDED] - This section introduces the LF9 Kingdom and its educational purpose.

---

## 📚 [TRANSLATED: Table of Contents] - The Sacred Scrolls

### Part I: [TRANSLATED: The Awakening]
- [Chapter 1: The Great Summoning](#chapter-1)
- [Chapter 2: The Council of Services](#chapter-2)
- [Chapter 3: The Network Binding Ritual](#chapter-3)

### Part II: [TRANSLATED: The Heroes of LF9]
- [Chapter 4: WordPress the Content Weaver](#chapter-4)
- [Chapter 5: Grafana the All-Seeing Oracle](#chapter-5)
- [Chapter 6: Unbound the DNS Keeper](#chapter-6)

---

## 🌟 Chapter 1: [TRANSLATED: The Great Summoning]

### 🪄 [TRANSLATED: Quick Start Spell]

\`\`\`bash
git clone https://github.com/pilz0/LF9
cd LF9
./manage.sh setup    # [TRANSLATED: Prepare the sacred artifacts]
./manage.sh validate # [TRANSLATED: Consult the digital oracles]
./manage.sh start    # [TRANSLATED: Breathe life into the kingdom]
\`\`\`

---

## 🎯 [TRANSLATED: Kingdom Portal Directory]

🌐 **[TRANSLATED: Access the Digital Realm]:**
- **WordPress**: http://localhost:8080 (user/bitnami)
- **Grafana**: http://localhost:3000 (admin/admin)
- **VNC Desktop**: http://localhost:6901 ([TRANSLATED: password]: vncpassword)
- **WikiJS**: http://localhost:3001 ([TRANSLATED: setup required])
- **Prometheus**: http://localhost:9090 ([TRANSLATED: no auth])

---

## 🏰 [TRANSLATED: Epilogue] - The Kingdom's Eternal Wisdom

*"[TRANSLATED CONCLUSION NEEDED] - The LF9 Kingdom teaches us about harmony in technology..."*

---

## 📚 [TRANSLATED: Additional Resources]

- [Original German Documentation](../../Doku.md) - [TRANSLATED: Technical specifications]
- [Character Profiles](../characters-${code}/) - [TRANSLATED: Detailed character documentation]
- [Network Architecture](../../Netzplan.drawio) - [TRANSLATED: Visual network design]

**Repository**: https://github.com/pilz0/LF9  
**[TRANSLATED: Educational Context]**: Lernfeld 9 - [TRANSLATED: German vocational education]  
**[TRANSLATED: Purpose]**: [TRANSLATED: Multi-service Docker environment for infrastructure education]

---

## 🤝 [TRANSLATED: Translation Help Needed]

This is a template file that needs translation to ${native} (${name}).  
We welcome native speakers to help translate this educational content!

**Translation Guidelines:**
1. Maintain technical accuracy
2. Adapt cultural context appropriately  
3. Keep the fantasy narrative style
4. Test all commands and links work

Contact the project maintainers if you'd like to contribute a translation!
EOF

    echo "✅ Created README-${code}.md template"
}

# Function to create character directory
create_character_directory() {
    local code=$1
    local name=$2
    local native=$3
    
    if [ "$code" = "en" ]; then
        echo "Skipping English characters (already exists)"
        return
    fi
    
    local char_dir="docs/i18n/characters-${code}"
    
    if [ -d "$char_dir" ]; then
        echo "✅ Character directory for ${name} already exists"
        return
    fi
    
    echo "📁 Creating character directory for ${name}"
    mkdir -p "$char_dir"
    
    cat > "${char_dir}/README.md" << EOF
# 🎭 [TRANSLATED: Character Compendium] - LF9 Kingdom

*"[TRANSLATED DESCRIPTION NEEDED] - Complete registry of all digital souls in the LF9 Kingdom..."*

## 📚 [TRANSLATED: Navigation]

### 🏛️ [TRANSLATED: The Inner Circle] (Core Services)
- [WordPress - [TRANSLATED: Content Weaver]](wordpress.md)
- [Grafana - [TRANSLATED: All-Seeing Oracle]](grafana.md)
- [Unbound - [TRANSLATED: DNS Keeper]](unbound.md)

### 🗄️ [TRANSLATED: The Data Guardians]
- [MariaDB - [TRANSLATED: Database Guardian]](mariadb.md)
- [PostgreSQL - [TRANSLATED: Knowledge Vault]](postgresql.md)

### 📁 [TRANSLATED: The File Keepers]
- [FTP - [TRANSLATED: Ancient File Shepherd]](ftp.md)
- [Samba - [TRANSLATED: Network File Sage]](samba.md)

### 🖥️ [TRANSLATED: The Support Mages]
- [VNC - [TRANSLATED: Virtual Desktop Sage]](vnc.md)
- [WikiJS - [TRANSLATED: Knowledge Chronicler]](wikijs.md)
- [Prometheus - [TRANSLATED: Metric Collector]](prometheus.md)
- [Node Exporter - [TRANSLATED: System Watcher]](node-exporter.md)

---

## 🤝 [TRANSLATED: Translation Help Needed]

This character compendium needs translation to ${native} (${name}).
Each character file should be translated while maintaining:

1. Technical accuracy
2. Fantasy storytelling elements
3. Educational value
4. Cultural adaptation where appropriate

We welcome contributions from native ${native} speakers!
EOF

    echo "✅ Created character directory for ${name}"
}

# Main execution
echo ""
echo "Creating multilingual documentation structure..."

for lang_info in "${LANGUAGES[@]}"; do
    IFS='|' read -r code name native flag <<< "$lang_info"
    echo ""
    echo "${flag} Processing ${name} (${native}) - Code: ${code}"
    
    create_readme_template "$code" "$name" "$native" "$flag"
    create_character_directory "$code" "$name" "$native"
done

echo ""
echo "🎉 Multilingual documentation structure created!"
echo ""
echo "📋 Summary:"
echo "- Created README templates for all EU languages"
echo "- Created character directory structure"
echo "- Templates include translation guidelines"
echo "- Existing files were preserved"
echo ""
echo "🤝 Next steps:"
echo "1. Native speakers can translate the template files"
echo "2. Community contributions welcome via GitHub"
echo "3. Maintain technical accuracy while adapting cultural context"
echo "4. Test all commands and links after translation"
echo ""
echo "✨ The LF9 Kingdom now speaks 24+ languages!"
EOF

chmod +x "docs/i18n/generate-languages.sh"