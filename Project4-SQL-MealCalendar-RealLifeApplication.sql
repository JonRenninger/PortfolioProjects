

with cte as (
SELECT [mealName]
      ,[mealType]
      ,[preferredDay]
	  ,ROW_NUMBER() over (partition by preferredDay order by mealname) as number
  FROM [MealCalendar].[dbo].[meal_schedule]
),
cte2 as (
select cast(rand()*max(number)+1 as int) as randomNumber
from cte
where preferredday = ''
)

select mealName
from cte
join cte2 on cte2.randomNumber = cte.number
where cte.preferredday = ''
