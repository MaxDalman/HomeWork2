/*
*   Д\з №2: SQL-запросы
*  Цель №1: Найти запрос который возвращает список таблиц в Postgres.
*/

SELECT table_name                                                   -- Выбираем столбец с наименованием таблицы.
  FROM information_schema.tables                                    -- Выбираем из таблицы, предоставляющей информацию по всем таблицам БД, включая системные.
 WHERE table_schema NOT IN ('information_schema','pg_catalog');     -- Фильтруем схемы, чтобы остались только таблицы из схемы public.


/* Цель №1.1: Вывести 3 колонки - имя таблицы, имя схемы, комментарий к таблице */

   SELECT table_schema, table_name, obj_description(oid)            -- Выбираем столбцы: имя таблицы, имя схемы и форма, возвращающую комментарий по OID.
     FROM information_schema.tables                                 -- Выбираем из таблицы, предоставляющей информацию по всем таблицам БД, включая системные.
LEFT JOIN pg_class                                                  -- Выбираем таблицу(каталог), где содержатся комментарии по объектам в БД.
       ON information_schema.tables.table_name = pg_class.relname   -- Присоединяем таблицу(каталог) к таблице с данными по таблицам БД по столбцам table_name и relname.
    WHERE table_schema NOT IN ('information_schema','pg_catalog')   -- Фильтруем таблицу от системных таблиц.
      AND pg_class.relkind = 'r';                                   -- Фильтруем таблицу(каталог), где задаём связь соединения 'r'. В данном случае, отношение записи к таблице.


/* Цель №1.2: Вывести все таблицы без комментария. */

   SELECT table_schema, table_name, obj_description(oid)              -- Выбираем столбцы: имя таблицы, имя схемы и форма, возвращающую комментарий по OID.
     FROM information_schema.tables                                   -- Выбираем таблицу, где имена схем и таблиц.
LEFT JOIN pg_class                                                    -- Выбираем таблицу(каталог), где содержатся комментарии по объектам в БД.
       ON information_schema.tables.table_name = pg_class.relname     -- Присоединяем таблицу(каталог) к таблице с данными по таблицам БД по столбцам table_name и relname.
    WHERE table_schema 
   NOT IN ('information_schema','pg_catalog')                         -- Фильтруем таблицу от системных таблиц.
      AND pg_class.relkind = 'r'                                      -- Фильтруем таблицу(каталог), где задаём связь соединения 'r'. В данном случае, отношение записи к таблице.
      AND obj_description(oid) IS NULL;                               -- Выводим результат, где комментарий отсутствует.



/* Цель №1.3: Вывести таблицы у которых вторая буква в наименовании A или a (английская A без учёта регистра). */

 SELECT table_name                             -- Выбираем колонку с наименованием таблиц.
   FROM information_schema.tables              -- Выбираем используемую таблицу из схемы.
  WHERE table_schema                           -- Фильтруем колонки из таблицы по:
 NOT IN ('information_schema','pg_catalog')    --    - отбрасыванию системных схем
    AND table_name ILIKE '_a%';                --    - ILIKE, чтобы поиск был регистр-независимым с учётом текущей языковой среды 


/* Цель №1.4: Посчитать количество таблиц в каждой схеме с комментариями и без. */

   SELECT COUNT(table_name) AS with_commentary,                         -- Выбираем столбец с наименованием таблицы и ставим на неё счётчик.
                                        (SELECT COUNT(table_name)       -- Создаём вложенный запрос с кол-вом таблиц без комментариев (подзапрос быстрее, чем через IF, SUM).
                                           FROM information_schema.tables                                      
                                           LEFT JOIN pg_class                                                       
                                             ON information_schema.tables.table_name = pg_class.relname        
                                          WHERE pg_class.relkind = 'r'                                         
                                            AND obj_description(oid) IS NULL) AS without_commentary                                            
     FROM information_schema.tables                                     -- Выбираем из таблицы, предоставляющей информацию по всем таблицам БД, включая системные.
LEFT JOIN pg_class                                                      -- Выбираем таблицу(каталог), где содержатся комментарии по объектам в БД.
       ON information_schema.tables.table_name = pg_class.relname       -- Присоединяем таблицу(каталог) к таблице с данными по таблицам БД по столбцам table_name и relname.
    WHERE pg_class.relkind = 'r'                                        -- Фильтруем таблицу(каталог), где задаём связь соединения 'r'. В данном случае, отношение записи к таблице.
      AND obj_description(oid) IS NOT NULL;                             -- Добавляем фильтр на присутствие комментария.
