uv init
uv sync 

.venv/Scripts/activate # spin up venv



uv add dbt-core
uv add dbt-databricks

## Environment setup is done

## SOurce setup

Create source tables in Databricks which will be used by dbt for creating medallion tables

## Dbt init
initiates dbt instance
host: dbc-9b86b73e-4153.cloud.databricks.com (our databricks sql warehouse host connection details)
/sql/1.0/warehouses/eb6214cf12f8bb6a

Process:

uv init
.venv/Scripts/activate
dbt init

navigate to the dbt project folder: cd basic_project
dbt debug -- check if any errors for dbt project folder
# basically im initiating a sandbox of venv for dbt and then im navigating to specific project folder

# by default all credentials are stored in C drive if hosted locally due to security purpose (not to capture creds in git) C:\Users\LENOVO\.dbt\profiles.yml. make sure we are porting this outside file also for migration

## DBT init is completed

## jinja file association

vsc extension :  dbt (once installed , yml/sql are interpreted as jinja sql/yml)


# move the profiles.yml to project root and make sure folder name , project name of profiles + dbt_projects.yml are in sync with project name


# build:

create schemas in databricks :source dn ingest source data

Create source,bronze,silver,gold folser similar to Databricks medallion arch.

Source feature of dbt stores all sources in yml file for lineage.

**sources.yml:**
sources:
  - name: source
    database: dbt_dev  
    schema: source  
    tables:
      - name: dim_date
      - name: dim_customer

**Bronze:**
select 
* 
from {{source('source','dim_store')}}

Once added, we can gloablly define the config for schema (folder) in main dbt_project.yml:
bronze:
      +materialized: table

**Execute bronze mode**
dbt run
executes all model and creates a target folder : run: actual databricks query for debug

dbt clean - cleans this taget garbage in next run or when troubleshoot done

**Note**: all bronze tables are created in default schema. why ? schema: default is mentioned in profiles.yml. this is fixed by configs


Configurations Precedence (over ride):
dbt_project.yml (project root) < properties.yml (models sub folders) < block level (code.sql)

dbt_project.yml:

models:
  basic_project:
    # Config indicated by + and applies to all files under models/example/
    bronze:
      +materialized: table

properties.yml:

models:
  - name: bronze_customer
    config:
      materialized: view

blocks:
{{config(materialized= 'view')}}
select 
* 
from {{source('source','dim_date')}}


**Custom Schema:**
 the above examples creates only tables in default.

 schema can be defined similar to materialized properties.

dbt_project.yml:

models:
  basic_project:
    # Config indicated by + and applies to all files under models/example/
    bronze:
      +materialized: table
      schema: "bronze"

But the dbt generates schema (macro) in backend by concat(default_schema,custom_schema) . here custom schema is the one in configs.

Fix:
overide macro by remove default:
sample from : https://docs.getdbt.com/docs/build/custom-schemas?version=2.0

Models now saved in bronze correctly.

**feature branch**
git switch -c feature_1 : creates new branch from main branch

Git similar to CICD where we version our codes in dev and deploy to higher branch via merge

**node selection : run specific models**
dbt run --select "bronze_customer" -- runs only one model
dbt run --select "bronze_customer bronze_date " -- runs only specific models
dbt run --select "/models/bronze/" -- runs oall models in a layer

## dbt tests

data test are assertion like pydantic model to chekc for validating data against specific rules.

**Generic Test (for data integrity)**

add datatest on properties file in each layer

  - name: bronze_store
    columns:
      - name: store_sk
        data_tests:
          - unique
          - not_null

      - name: store_name
        data_tests:
          - accepted_values:
              arguments:
                values: ['MegaMart Manhattan','MegaMart Brooklyn','MegaMart Austin','MegaMart San Jose','MegaMart Toronto']
              config:
                severity: warn

severity: warn -- throws warn instead of fail


**Singular Test (for checing logs)**

eg: age>=0,cibil bt 0-900

select 
* 
from
{{ ref("bronze_fact_sales") }} 
where gross_amount < 0 
and net_amount< 0

we code this negation in tests folder . if any op in test then test failed.

after creating this, code didnt run . since model is unable to resolve ref.

dbt parse → Checks your dbt project files, YAML, Jinja, models, and dependencies to build the project graph; doesn't execute SQL.

dbt compile → Resolves Jinja (ref(), source(), macros, configs) and generates the final SQL that dbt would execute; doesn't execute the SQL.
dbt compile --select bronze_fact_sales

Test ran successfully.

singular test can be any nested sql queries join

**Custom generic Test (for checing logs)**

reusable generic tests that are not in build. like non negative.
they are built as macros in .\tests\generic\{name}.sql

macros are basically similar to functions in python

.\tests\generic\generic_non_negative.sql
{% test generic_non_negative(model,column_name) %}

select 
    *
from 
    model
where 
    column_name<0

{% endtest %}

Once done , add it in the generic test i.e bronze properties file

run dbt_test and check

ALL test passed. 

Note : f"{i}" >> {{ model }} - dynamic jinga variable

**git merge**

commit changes >> checkout to tgt >> merge

(dbt-basics) PS E:\AI\GIT\dbt_basics\basic_project> cd ..
(dbt-basics) PS E:\AI\GIT\dbt_basics> git add .
(dbt-basics) PS E:\AI\GIT\dbt_basics> git commit -m "dbt tests check in - generic, singular,custom generic"
[feature_1 226f9c8] dbt tests check in - generic, singular,custom generic
 5 files changed, 150 insertions(+), 5 deletions(-)
 create mode 100644 basic_project/tests/generic/generic_non_negative.sql
 create mode 100644 basic_project/tests/non_negative_amt.sql
(dbt-basics) PS E:\AI\GIT\dbt_basics> git checkout master                                                  
Switched to branch 'master'
(dbt-basics) PS E:\AI\GIT\dbt_basics> git merge feature_1

## dbt seeds

repo for small lookup tables like company category, pincode maps. these doesnt have specific source. DE/BA provides tags.
seeds are saved in databricks as table.
define the properties in dbt_project.yml

run seed (create seed table in table) by:  dbt seed 

use dbt seed tables in models by using {{ ref('store_mapping') }}

## analyses folder

Rough space for exploration . it wont be referenced anywhere in dbt models. pure rough note just for analyses.

**Note:** run and compiled folders in target shows the raw transformed query which will be actually executed in databricks. 

## Jinjas

programming template language. helps integrate sql with programming functionalities.

{% set a=['RAM','ravan','lakshman']%}

{%- for i in a -%}
    {%- if i=="RAM" -%}
        {% continue %}
    {% endif %}

    {{i}}
{% endfor %}


