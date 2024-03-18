
--ดูข้อมูลทุกอย่างใน database

	Select *
		From portfolio..CovidDeaths$
		Where continent is not null
		order by 3,4


--เลือกข้อมูลที่เราสนใจจะนำมาใช้งาน


	--ข้อมูลแสดงร้อยละของการตายจากเคสทั้งหมดตามแต่ละ Location

	Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deaths_percentage
		From portfolio..CovidDeaths$
		where total_deaths  IS NOT NULL 
		order by 1,2

	--ข้อมูลแสดงประเทศที่ติดเชื่อเทียบกับประชากร 

	Select location, Population,date,MAX(total_cases) as HightestInfectCount,Max(total_cases/population)*100 as PercentPopulationInfect
		From portfolio..CovidDeaths$
		Group by Location,Population,date
		order by PercentPopulationInfect desc


		--ทำ Excel_1
		Select Top 40000 location, Population,date,MAX(total_cases) as HightestInfectCount,Max(total_cases/population)*100 as PercentPopulationInfect
		From portfolio..CovidDeaths$
		Group by Location,Population,date
		order by PercentPopulationInfect desc

		--ทำExcel_2
		Select location, Population,date,MAX(total_cases) as HightestInfectCount,Max(total_cases/population)*100 as PercentPopulationInfect
		From portfolio..CovidDeaths$
		Group by Location,Population,date
		order by PercentPopulationInfect desc
		OFFSET 40000 ROWS
		
		
		

	---ข้อมูลแสดงผู้ติดเชื้อเทียบกับประชากรทั้งหมด
	Select Sum(population) as Sum_Of_Population,Sum(total_cases) as Sum_Of_Totalcases,Sum(total_cases)/Sum(population)*100 as PopulationInfecAll
		From portfolio..CovidDeaths$


	--ข้อมูลแสดงข้อมูลจำนวนคนตายแต่ละประเทศ
	Select location,Max((Total_deaths)) as TotalDeathCountLocation
		From portfolio..CovidDeaths$
		Group by Location
		order by TotalDeathCountLocation desc

	--ข้อมูลแสดงข้อมูลจำนวนคนตายแต่ละทวีป
	Select continent ,Sum(cast(new_deaths as int)) as TotalDeathCountContinent
		From portfolio..CovidDeaths$
		Where continent is not null
		and location not in ('World','European Union','International')
		Group by continent
		Order by TotalDeathCountContinent desc


	--ยอดรวมสรุป
	Select Sum(new_cases) as total_cases,Sum(cast(new_deaths as int)) as total_deaths,Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathsPercentage
		From portfolio..CovidDeaths$
		Where continent is not null
		Order by 1,2


	--ดูข้อมูลระหว่างการติดเชื้อและการฉีดวัคซีน Population&Vaccinations
	Select ded.continent,ded.location,ded.date,ded.population,vac.new_vaccinations,
	SUM(CONVERT(int ,vac.new_vaccinations)) OVER (Partition by ded.location Order by ded.location,ded.Date) as RollingPeopleVaccinated
		From portfolio..covidDeaths$ ded
		Join portfolio..covidVaccinations$ vac
			on ded.location = vac.location
			and ded.date = vac.date
		Where ded.continent is not null
		Order by 2,3


-- ใช้ CTE เพื่อดึงข้อมูล

With PopuVsVaccin(Comtinnent,location,date,Population,New_vacinations,RollingPeopleVaccinated) as 
(	Select ded.continent,ded.location,ded.date,ded.population,vac.new_vaccinations,
	SUM(CONVERT(int ,vac.new_vaccinations)) OVER (Partition by ded.location Order by ded.location,ded.Date) as RollingPeopleVaccinated
		From portfolio..covidDeaths$ ded
		Join portfolio..covidVaccinations$ vac
			on ded.location = vac.location
			and ded.date = vac.date
		Where ded.continent is not null)
Select * , (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinatedPercentage
	From PopuVsVaccin 

--TEMP TABLE
		Create Table #PercentPopulationVaccinated
		(
			Continent nvarchar(255),
			Location nvarchar(255),
			Date datetime,
			Population numeric,
			New_vaccinations numeric,
			RollingPeopleVaccinated numeric
		)

Insert into #PercentPopulationVaccinated
Select ded.continent,ded.location,ded.date,ded.population,vac.new_vaccinations,
	SUM(CONVERT(int ,vac.new_vaccinations)) OVER (Partition by ded.location Order by ded.location,ded.Date) as RollingPeopleVaccinated
	From portfolio..covidDeaths$ ded
	Join portfolio..covidVaccinations$ vac
	on ded.location = vac.location
	and ded.date = vac.date
	Where ded.continent is not null
		
Select *
	From #PercentPopulationVaccinated


Create View PercentPopulationVaccinated as
Select ded.continent,ded.location,ded.date,ded.population,vac.new_vaccinations,
	SUM(CONVERT(int ,vac.new_vaccinations)) OVER (Partition by ded.location Order by ded.location,ded.Date) as RollingPeopleVaccinated
	From portfolio..covidDeaths$ ded
	Join portfolio..covidVaccinations$ vac
	on ded.location = vac.location
	and ded.date = vac.date
	Where ded.continent is not null

Select *
	From PercentPopulationVaccinated


