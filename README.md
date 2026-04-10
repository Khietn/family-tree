# Family Tree Database Model

A relational database schema for storing multi-generational family tree data, with an interactive web visualization.

## Schema Overview

| Table | Purpose |
|-------|---------|
| **persons** | Individuals — name, gender, birth/death, bio, photo |
| **relationships** | Links two persons (parent→child, spouse, sibling, adopted) |
| **events** | Life events (birth, death, marriage, graduation, etc.) |
| **media** | Photos, documents, videos attached to a person |

## Relationship Model

```
persons  1 ──── ∞  relationships  (person1_id, person2_id)
persons  1 ──── ∞  events         (person_id)
persons  1 ──── ∞  media          (person_id)
```

- **parent_child**: `person1_id` = parent, `person2_id` = child
- **spouse**: `person1_id` & `person2_id` are partners

## Files

- `schema.sql` — Full DDL + sample data (SQLite-compatible)
- `index.html` — Interactive web visualization (open in browser)

## Usage

```bash
# Create the database (SQLite)
sqlite3 family_tree.db < schema.sql

# View the visualization
open index.html
```
