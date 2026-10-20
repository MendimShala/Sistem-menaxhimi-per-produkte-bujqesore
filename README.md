# Sistemi për Menaxhimin e Produkteve Bujqësore

Aplikacion web ku regjistrohen fermerët, katalogu i produkteve bujqësore, prodhimi, ofertat për shitje dhe porositë e blerësve.

**Lënda:** Projekt – Praktikë Profesionale | Semestri V  
**Studenti:** Mendim Shala  
**Email:** 240329048.b@uni-prizren.com  
**Repository:** [https://github.com/MendimShala/Sistem-menaxhimi-per-produkte-bujqesore](https://github.com/MendimShala/Sistem-menaxhimi-per-produkte-bujqesore)


## Struktura

```
├── backend/                 Spring Boot (Java 17) – REST API
├── frontend/                React – ndërfaqja
├── database/schema.sql      Fermer, produkt, prodhim, ofertë, porosi
└── docs/
    ├── RAPORTI_TEKNIK_1.md
    └── prezantim.html
```

## Stack

| Shtresa   | Teknologjia       | Arsyeja |
|-----------|-------------------|---------|
| Frontend  | React             | Katalog, oferta, porosi |
| Komunikim | HTTPS / REST JSON | Ndarje klient–server |
| Backend   | Java Spring Boot  | REST, validim, JWT |
| Databaza  | MySQL             | Relacione PK/FK |

