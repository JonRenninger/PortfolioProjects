




drop table if exists #NewMealMonth
create table #NewMealMonth (
	[year] [int] NULL,
	[month] [int] NULL,
	[day] [int] NULL,
	[day_of_the_week] [varchar](50) NULL,
	[mealName] [varchar](200) NULL,
	[number] int
	);
with cte as (
SELECT [year]
      ,[month]
      ,[day]
      ,[day_of_the_week]
	  ,[mealName]
FROM [MealCalendar].[dbo].[calendar] cal
left join [MealCalendar].[dbo].[meal_schedule] meal
on cal.day_of_the_week = meal.preferredDay
where cal.year = 2024
and cal.month = 2
),
cte2 as (
select [year]
      ,[month]
      ,[day]
      ,[day_of_the_week]
	  ,[mealName]
	  ,ROW_NUMBER() over (partition by mealName order by day) as number
from cte 
)
insert into #NewMealMonth
select *
from cte2






declare @i int
set @i = 1
while @i < (select max(number)+1 from #NewMealMonth)
begin


drop table if exists #RandomMeal
create table #RandomMeal (
[mealName] [varchar](200) NOT NULL
);


-------------------------------------------------------------------------------------------------
-- This entire section's purpose is to generate a random meal that does not have a preferred day
-------------------------------------------------------------------------------------------------
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
),
cte3 as (
select mealName
from cte
join cte2 on cte2.randomNumber = cte.number
where cte.preferredday = ''
)
insert into #RandomMeal
select mealName
from cte3


update #NewMealMonth
set mealName = (select mealName from #RandomMeal)
where mealName is NULL
and number = @i


set @i = @i + 1

end
go



select [year]
      ,[month]
      ,[day]
      ,[day_of_the_week]
	  ,[mealName]
from #NewMealMonth
order by day


