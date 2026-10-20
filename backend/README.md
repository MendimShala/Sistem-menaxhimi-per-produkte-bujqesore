# Backend (Spring Boot)

API REST për Sistemin e Menaxhimit të Fermerëve dhe Produkteve Bujqësore.

Në Raportin 1 kjo është struktura fillestare. Endpoint-i i vetëm demonstrues:

`GET /api/shendeti`

## Kërkesat lokale

- Java 17+
- Maven
- MySQL 8, databaza `sistem_fermeret_produkte` (importo `../database/schema.sql`)

Kredencialet e DB janë te `src/main/resources/application.properties`.
