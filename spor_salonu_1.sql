-- değişken türlerini uygun hale getir
ALTER TABLE sport.sport
    ALTER COLUMN start_date TYPE DATE USING start_date::DATE,
    ALTER COLUMN end_date TYPE DATE USING end_date::DATE,
    ALTER COLUMN birth_date TYPE DATE USING birth_date::DATE;


-- kayıtlı müşterileri aktif pasif olarak etiketle
SELECT *,
       CASE
           WHEN end_date > now() THEN 'AKTIVE'
           ELSE 'PASIVE'
           END AS STATUS
FROM sport.sport;


--  güncel yaş bilgisini oluşur
SELECT *, extract(years from age(birth_date)) as AGE
FROM sport.sport;


-- üyelik paketi sınıf bilgisini oluştur
SELECT *,
       CASE
           WHEN EXTRACT(DAYS FROM AGE(end_date, start_date)) > 25
               THEN EXTRACT(MONTHS FROM AGE(end_date, start_date)) + 1
           WHEN EXTRACT(YEARS FROM AGE(end_date, start_date)) > 0
               THEN EXTRACT(YEARS FROM AGE(end_date, start_date)) * 12
           ELSE EXTRACT(MONTHS FROM AGE(end_date, start_date))
           END AS MEMBERSHIP_PACKAGE_M
FROM sport.sport;


-- an itibari ile üyeliği sonlanan kişileri bul
SELECT id
from sport.sport
WHERE end_date > now();

SELECT count(id)
FROM sport.sport
WHERE end_date > NOW();

-- yaş ve cinsiyet kırılımında üye sayısı bilgisini elde et
select count(distinct extract(years from age(birth_date))) as number_of_age_uniq
from sport.sport
CREATE EXTENSION tablefunc;

select *, extract(years from age(birth_date)) as age
from sport.sport
order by sex asc, age asc

with cte as (select sex,
                    extract(years from age(birth_date)) as age,
                    count(id)
             from sport.sport
             group by sex, extract(years from age(birth_date))
             order by 1, 2)
select *
from crosstab(
             ''
         ) as ct("sex" int, "age" int, "count" int);


select *
from (select sex,
             extract(years from age(birth_date)) as age,
             count(id)
      from sport.sport
      group by sex, extract(years from age(birth_date))) as sub
order by age asc, sex asc

select *
from crosstab(
             'select * from (select sex,extract(years from age(birth_date)) as age,
                count(id) as adet
                from sport.sport
         group by sex,extract(years from age(birth_date))) as sub
         order by age asc,sex asc',
             $$VALUES (0 :: int),(1 :: int)$$
         ) as ct ("age" int, "kadin" int, "erkek" int)


-- hangi üyelik paketinden kaç kişi an itibari ile var
with cte as (SELECT *,
                    CASE
                        WHEN EXTRACT(DAYS FROM AGE(end_date, start_date)) > 25
                            THEN EXTRACT(MONTHS FROM AGE(end_date, start_date)) + 1
                        WHEN EXTRACT(YEARS FROM AGE(end_date, start_date)) > 0
                            THEN EXTRACT(YEARS FROM AGE(end_date, start_date)) * 12
                        ELSE EXTRACT(MONTHS FROM AGE(end_date, start_date))
                        END AS MEMBERSHIP_PACKAGE_M
             FROM sport.sport)

select MEMBERSHIP_PACKAGE_M, count(MEMBERSHIP_PACKAGE_M) as num_of_member
from cte
group by MEMBERSHIP_PACKAGE_M
order by MEMBERSHIP_PACKAGE_M asc;


-- 3 aydir kayıt yenilememiş kişiler
select id,
       extract(years from age(now(), end_date))  as date_diff_Y,
       extract(months from age(now(), end_date)) as date_diff_M
from sport.sport
where extract(years from age(now(), end_date)) >= 0
  and extract(months from age(now(), end_date)) = 3;


-- 3-6 aydır kayıt yenilememiş kişiler
select id,
       extract(years from age(now(), end_date))  as date_diff_Y,
       extract(months from age(now(), end_date)) as date_diff_M
from sport.sport
where extract(years from age(now(), end_date)) >= 0
  and extract(months from age(now(), end_date)) between 3 and 6;


-- 6 aydan fazladır kayıt yenilememiş kişiler
select id,
       extract(years from age(now(), end_date))  as date_diff_Y,
       extract(months from age(now(), end_date)) as date_diff_M
from sport.sport
where extract(years from age(now(), end_date)) >= 0
  and extract(months from age(now(), end_date)) > 6;


-- 1 aylık kaydı bitmiş 1 aydır kayıt güncellememiş kişiler
with cte as (SELECT *,
                    extract(years from age(now(), end_date))  as date_diff_Y,
                    extract(months from age(now(), end_date)) as date_diff_M,
                    CASE
                        WHEN EXTRACT(DAYS FROM AGE(end_date, start_date)) > 25
                            THEN EXTRACT(MONTHS FROM AGE(end_date, start_date)) + 1
                        WHEN EXTRACT(YEARS FROM AGE(end_date, start_date)) > 0
                            THEN EXTRACT(YEARS FROM AGE(end_date, start_date)) * 12
                        ELSE EXTRACT(MONTHS FROM AGE(end_date, start_date))
                        END                                   AS MEMBERSHIP_PACKAGE_M
             FROM sport.sport)

SELECT distinct id,
                MEMBERSHIP_PACKAGE_M,
                date_diff_Y,
                date_diff_M
FROM cte
WHERE MEMBERSHIP_PACKAGE_M = 1
  and date_diff_Y = 0
  and date_diff_M = 1;


-- 3 aylık kaydı bitmiş 1 aydır kayıt güncellememiş kişiler
with cte as (SELECT *,
                    extract(years from age(now(), end_date))  as date_diff_Y,
                    extract(months from age(now(), end_date)) as date_diff_M,
                    CASE
                        WHEN EXTRACT(DAYS FROM AGE(end_date, start_date)) > 25
                            THEN EXTRACT(MONTHS FROM AGE(end_date, start_date)) + 1
                        WHEN EXTRACT(YEARS FROM AGE(end_date, start_date)) > 0
                            THEN EXTRACT(YEARS FROM AGE(end_date, start_date)) * 12
                        ELSE EXTRACT(MONTHS FROM AGE(end_date, start_date))
                        END                                   AS MEMBERSHIP_PACKAGE_M
             FROM sport.sport)

SELECT distinct id,
                MEMBERSHIP_PACKAGE_M,
                date_diff_Y,
                date_diff_M
FROM cte
WHERE MEMBERSHIP_PACKAGE_M = 3
  and date_diff_Y = 0
  and date_diff_M = 1;


-- 6 aylık kaydı bitmiş 1 aydır kayıt güncellemeyen kişiler
with cte as (SELECT *,
                    extract(years from age(now(), end_date))  as date_diff_Y,
                    extract(months from age(now(), end_date)) as date_diff_M,
                    CASE
                        WHEN EXTRACT(DAYS FROM AGE(end_date, start_date)) > 25
                            THEN EXTRACT(MONTHS FROM AGE(end_date, start_date)) + 1
                        WHEN EXTRACT(YEARS FROM AGE(end_date, start_date)) > 0
                            THEN EXTRACT(YEARS FROM AGE(end_date, start_date)) * 12
                        ELSE EXTRACT(MONTHS FROM AGE(end_date, start_date))
                        END                                   AS MEMBERSHIP_PACKAGE_M
             FROM sport.sport)

SELECT distinct id,
                MEMBERSHIP_PACKAGE_M,
                date_diff_Y,
                date_diff_M
FROM cte
WHERE MEMBERSHIP_PACKAGE_M = 6
  and date_diff_Y = 0
  and date_diff_M = 1;

-- oluştrulan tabloları json, csv, xml herhangi bir şekilde dışarı aktar
-- csv olarak exporta örnek
COPY (with cte as (SELECT *,
                    CASE
                        WHEN EXTRACT(DAYS FROM AGE(end_date, start_date)) > 25
                            THEN EXTRACT(MONTHS FROM AGE(end_date, start_date)) + 1
                        WHEN EXTRACT(YEARS FROM AGE(end_date, start_date)) > 0
                            THEN EXTRACT(YEARS FROM AGE(end_date, start_date)) * 12
                        ELSE EXTRACT(MONTHS FROM AGE(end_date, start_date))
                        END AS MEMBERSHIP_PACKAGE_M
             FROM sport.sport)

select MEMBERSHIP_PACKAGE_M, count(MEMBERSHIP_PACKAGE_M) as num_of_member
from cte
group by MEMBERSHIP_PACKAGE_M
order by MEMBERSHIP_PACKAGE_M asc) TO 'D:/sql_result1.csv' WITH DELIMITER ',' HEADER

-- json olarak exporta örnek
COPY (
    SELECT *,
       CASE
           WHEN EXTRACT(DAYS FROM AGE(end_date, start_date)) > 25
               THEN EXTRACT(MONTHS FROM AGE(end_date, start_date)) + 1
           WHEN EXTRACT(YEARS FROM AGE(end_date, start_date)) > 0
               THEN EXTRACT(YEARS FROM AGE(end_date, start_date)) * 12
           ELSE EXTRACT(MONTHS FROM AGE(end_date, start_date))
           END AS MEMBERSHIP_PACKAGE_M
FROM sport.sport
    ) TO 'D:/sql_result2.json';