create database final;
use final;

select * from dim_drug;
select * from dim_drugbrand;
select * from dim_drugform;
select * from dim_member;
select * from fact_insurance;

#### PART 2

# Modifying Datatype for PK

alter table dim_drug
modify column drug_ndc varchar(100);

alter table dim_drug
modify column drug_form_code varchar(100);

alter table dim_drug
modify column drug_brand_generic_code varchar(100);

alter table dim_drugform
modify column drug_form_code varchar(100);

alter table dim_drugbrand
modify column drug_brand_generic_code varchar(100);

alter table fact_insurance
modify member_id varchar(100);

alter table fact_insurance
modify drug_ndc varchar(100);

alter table dim_member
modify member_id varchar(100);

# Designating Primary Key: Natural keys

alter table dim_drug
add primary key (drug_ndc);

alter table dim_drugbrand
add primary key (drug_brand_generic_code);

alter table dim_drugform
add primary key (drug_form_code);

alter table dim_member
add primary key (member_id);


# Designating Primary Key: Surrogate keys

alter table fact_insurance
add FINo int not null auto_increment primary key;

#Designating Foreign Keys

alter table dim_drug
add foreign key drug_form_foreign(drug_form_code) 
references dim_drugform(drug_form_code)
on delete restrict
on update restrict;

alter table dim_drug
add foreign key drug_brand_foreign(drug_brand_generic_code) 
references dim_drugbrand(drug_brand_generic_code)
on delete restrict
on update restrict;

alter table fact_insurance
add foreign key memberid_foreign(member_id) 
references dim_member(member_id)
on delete restrict
on update restrict;

alter table fact_insurance
add foreign key drug_ndc_foreign(drug_ndc) 
references dim_drug(drug_ndc)
on delete restrict
on update restrict;

#### PART 4
# a.Write a SQL query that identifies the number of prescriptions grouped by drug name.

select d.drug_name as Drug_Name, count(*) as No_Of_Prescriptions
from fact_insurance f
inner join dim_drug d on f.drug_ndc = d.drug_ndc
group by drug_name
order by No_Of_Prescriptions desc;


# b.Write a SQL query that counts total prescriptions, counts unique (i.e. distinct) members, 
#sums copay $$, and sums insurance paid $$, for members grouped as either ‘age 65+’ or ’ < 65’. Use case statement logic 

select count(f.FINo) as Total_Prescriptions, count(distinct f.member_id) as Members, sum(f.copay) as Total_Copay, sum(f.insurancepaid) as Total_Insurance,
case when d.member_age >= 65 then "Age 65+"
when d.member_age < 65 then "< 65"
end as Member_Group
from fact_insurance f
inner join dim_member d on f.member_id = d.member_id
group by Member_Group
order by Total_Prescriptions;


# c.Write a SQL query that identifies the amount paid by the insurance for the most recent prescription fill date. 
#	Use the format that we learned with SQL Window functions. Your output should be a table with member_id, member_first_name, 
# 	member_last_name, drug_name, fill_date (most recent), and most recent insurance paid. 
#SELECT STR_TO_DATE("August 10 2017", "%M %d %Y")

select i.member_id, i.member_first_name, i.member_last_name, i.drug_name, i.fill_date as most_recent_fill_date,
i.insurancepaid as most_recent_insurancepaid
from
	( select
		dm.member_id, dm.member_first_name, dm.member_last_name, dd.drug_name, fi.fill_date, fi.insurancepaid,
lead(fill_date) over(partition by dm.member_id order by member_first_name, fill_date desc),
lead(insurancepaid) over(partition by dm.member_id order by member_first_name, fill_date desc),
row_number() over (partition by dm.member_id) as flag
from fact_insurance fi
        inner join dim_member dm
        on fi.member_id=dm.member_id
        inner join dim_drug dd
        on fi.drug_ndc=dd.drug_ndc
	) as i
    where flag = 1;