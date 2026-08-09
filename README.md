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
      schema: bronze

properties.yml:

models:
  - name: bronze_customer
    config:
      materialized: view
      schema: bronze

blocks:
{{config(materialized= 'view')}}
select 
* 
from {{source('source','dim_date')}}