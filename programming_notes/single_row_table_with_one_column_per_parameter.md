# Single-row table with one column per parameter

---

TL;DR
This is a perfectly valid and common pattern for storing global settings, especially when:

- the set of parameters is fixed or changes rarely;
- you prefer strong typing (each column can have a proper type);
- you want simpler queries (no joins, no parsing);
- you want better schema validation and editor support in DB admin tools.

---

## Example schema (Firebird SQL style, requires v3.0 or newer)

```sql
create table GLOBAL_CONFIG(
  ID smallint not null check (ID = 1),
  MAX_THREADS integer default 4 not null,
  LOG_LEVEL varcgar(20) default 'info' not null,
  ENABLE_CACHE boolean default true not null,
  DEFAULT_TIMEOUT double precisione default 2.5 not null,
  constraint PK_GLOBAL_CONFIG primary key (ID)
);

You'd then insert a single row:

```sql
insert into GLOBAL_CONFIG(ID, MAX_THREADS, LOG_LEVEL, ENABLE_CACHE, DEFAULT_TIMEOUT)
values                   ( 1,           8,   'debug',         true,             5.0);
```

To query or update:

```sql
-- Get a config value
select MAX_THREADS from GLOBAL_CONFIG WHERE ID = 1;

-- Update a config value
update GLOBAL_CONFIG set LOG_LEVEL = 'warning' where ID = 1;
```


## Pros

- Clean and type-safe.
- No need to parse values.
- Easy to read and maintain.
- Straightforward SQL and API access.
- Works very well with ORMs (maps to a config object).


## Cons

- Schema changes required for each new setting.
- Doesn't support dynamic keys (e.g. plugin-defined config).
- Not ideal if you need to group settings (e.g. by category or module).


## View-only fallback / access interface

To abstract away the `where ID = 1` condition and provide read-only access, define a view:

```sql
create view GLOBAL_CONFIG_VIEW as
select MAX_THREADS,
       LOG_LEVEL,
       ENABLE_CACHE,
       DEFAULT_TIMEOUT
from   GLOBAL_CONFIG
where  ID = 1;
```

Now you can read the configuration like this:

```sql
select * from GLOBAL_CONFIG_VIEW;
```


## Alternatives

If you need a more flexible or dynamic structure, you can model a key-value store in SQL:

```sql
create table GLOBAL_CONFIG_KV (
  KEY varchar(64) primary key,
  VALUE varchar(128) not null,
  TYPE varchar(16) default 'string',
  DESCRIPTION varchar(256)
);
```

Columns:

- `key`: the name of the parameter (e.g. `max_threads`, `log_level`);
- `value`: the stringified value (you parse it appropriately in your app);
- `type`: optional, useful to document the expected type (`int`, `bool`, `float`, `string`...);
- `description`: optional, useful for admin UIs or documentation.
