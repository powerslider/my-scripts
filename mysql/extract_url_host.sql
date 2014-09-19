
select distinct 
        substring_index(
                (substring_index(
                        (substring_index(url, '://', -1)
                ), '/', 1)
        ), '.', -2) as domain 
from temp_vacancy tv, jobboard j
where j.board_name <>
order by domain;
