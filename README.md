# DB_GRUPO_2_PEDIDOS_YA
/DB
-/ORACLE_10G
/FRONT-END
/BACK-END


# DB_GRUPO_2
## Subtítulo
### Título más pequeño




Para saltar de línea, deja dos espacios al final de esta frase.  
Y el texto continuará abajo. También puedes usar una etiqueta<br>para forzar el salto.

**Texto en negrita**
*Texto en cursiva*

- Elemento de lista
- Otro elemento
  - Sub-elemento (con dos espacios al inicio)

1. Paso uno numerado
2. Paso dos numerado

[Texto del enlace que se puede hacer clic](https://ejemplo.com)

Para resaltar un comando en el texto usa `npm install`.

Para un bloque de código completo:


## 📂 Estructura del Proyecto

Así es como están organizados los archivos:

```text
REPO/
├── docker-compose.yml          <-- Orquesta Frontend, Backend y MySQL,etc
├── frontend/                   <-- Todo lo del frontend
│   ├── #.#
│   └── #/
├── backend/                    <-- TODO lo del backend
│   ├── #.#
│   └── #/
└── database/                   <-- Todo el manejo de bases de datos
    ├── oracle_10g/             <-- Tus scripts y data originales (solo de referencia)
    │   ├── routines/           (procedimientos, triggers, cursores de Oracle)
    │   │   ├── triggers.sql
    │   │   ├── funciones.sql
    │   │   ├── procedimientos.sql
    │   │   ├── cursores.sql
    │   │   └── triggers.sql
    │   └── #.sql      
    │
    └── mysql/      <-- Scripts ya migrados a sintaxis MySQL
        ├── routines/           (procedimientos, triggers, cursores de Oracle)
        │   ├── triggers.sql
        │   ├── funciones.sql
        │   ├── procedimientos.sql
        │   ├── cursores.sql
        │   └── triggers.sql
        └── #.sql     
