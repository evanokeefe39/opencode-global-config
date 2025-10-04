## Shortcuts
- if user just says 'audit', they mean they want to audit the codebase against rules in this AGENT.md file, always reload the rules when auditing.
- if user just says 'health', they mean they want to run all the health checks, or if there are no health checks or missing health checks, create health checks for the services the project is integrating with.

## Utilities
- scripts, tools etc. that aid in development should go under a /utils folder (i.e interrogate the schema of a database to find tables and column names) should go in utils folder
- scripts, tools etc. that aid with administrative tasks, or repetitive tasks, or operational tasks (i.e a script to build artifact like docker container) should go in utils folder
- For example if the user wants to connect to a database, create a health check script (or add to existing one) to test connection to the database e.g. "SELECT 1" query and run it if possible to confirm connection details are correct

## Github & Git Usage Rules
- The default branching strategy is to feature branch from main. If the user requests changing strategy then migrate to the new strategy.  
- When implementing user-requested changes or features, commit batches of changes when done using
conventional commits. [link](https://www.conventionalcommits.org/en/v1.0.0/)
- work on the dev branch or feature branch only. If you are on master and need to make changes you should switch to dev or the relevant feature branch. You will have to decide or get feedback from the user if working on multiple feature branches at once e.g do they want to stash their changes instead etc. 
- Always use git in every project. If there is no .git folder then initialize the repo with a .gitignore file as well. If it's a python project then a .gitignore file relevant to python project. Add a basic Readme License file etc. 

## Package Manager and Default Dependancies & Artifacts

- Always use poetry package manager. 
- Always add python-dotenv as a dependency in every python project (this also helps generate the poetry files when starting the project)
- Always create a .env file with some placeholder env variables
- Always us mkdocs and keep project documentation up to date for each feature branch. Check documentation is up to date before finishing a feature branch.
- Always create a config.yaml for holding project and app/service configuration, this is different to .env which is more about holding secrets. By default all secrets are stored in .env and all config is stored in config.yaml. The user will specify whether certain config items should be promoted to env vars. 

- always create config.py module at the top level which will parse both the config.yaml and .env vars so that all config and secrets are accessible through a config object and obfuscates any secrets when being logged.

- always create a log.py module which configures a basic custom logger with colourful text.

## Licensing
Always ensure the repository contains a LICENSE file in the root directory.

- If no license type is specified, generate the LICENSE file using the MIT License.  
- If a license type is explicitly specified (e.g., Apache-2.0, GPL-3.0, AGPL-3.0, BSD-2-Clause, BSD-3-Clause, MPL-2.0, LGPL-3.0, CC0-1.0, Unlicense), generate the correct standard license text for that type.  
- Always replace [year] with the current year and [fullname] with the repository owner’s name or organization.  
- The LICENSE file must contain the full canonical license text (not just a link).  
- If repo artifacts (e.g., `spec.md`, `SECURITY.md`, compliance docs, or non-functional requirements) suggest confidentiality, privacy, non-commercial use, or other restrictive terms, then:
  1. Suggest a more restrictive license (e.g., GPL-3.0, AGPL-3.0, or a custom proprietary license).  
  2. Prompt the user to confirm whether they want to change the license.  


## Coding Standards

- If the use asks to connect to a database then add the connection details i.e credentials as env vars in .env file. 
- When adding env vars make them descriptive and namespaced to avoid conflicts e.g. ther username for a supabase db connection 'user' should be 'db_user' or 'SUPABASE_DB_USER'
- For python projects use PEP8 standards and styling
- add comments to functions and docstrings, keep docstrings up to date when making changes

## Database Querying, Data Pipelines & Integrations

- **Validate table names.** Never assume a table name provided by the user is correct. Always confirm by inspecting the schemas of connected databases (those with credentials in the `.env` file and confirmed via a health check).  
- **Generate ingestion contracts.** When creating any module, script, or service that ingests data from external systems, also generate a *data ingestion contract* as a YAML file. Always include these contracts in the MkDocs documentation.  
- **Centralize configuration.**  
  - Keep all service configuration in `config.yaml` under the hierarchy:  
    ```yaml
    integrations:
      <service_name>:
        <config_item>: ${ENV_VAR_NAME}
    ```  
  - Reference sensitive values (passwords, tokens, API keys) using environment variables.  
  - Store those environment variables in the `.env` file using double underscores (`__`) to separate service name and config item.  
    Example:  
    - `config.yaml`:  
      ```yaml
      integrations:
        supabase:
          db_user: ${SUPABASE__DB_USER}
          db_password: ${SUPABASE__DB_PASSWORD}
      ```  
    - `.env`:  
      ```ini
      SUPABASE__DB_USER=postgres
      SUPABASE__DB_PASSWORD=password123
      ```  
- **Consistency enforcement.** Always ensure `config.yaml`, `.env`, and MkDocs documentation remain consistent whenever new integrations or config changes are introduced.


## Project Specifications
- Always create a file called SPEC.md and keep it at the root of the project. Update SPEC.md with any functional requirements, non functional requirements as the user mentions them. Refer back to SPEC.md to get clarity on the overall goals of the project.
- Always include background information about the project in the README.md that the user mentions, i.e what the goals, challenges of the project are. Include a journal section at the top of README.md that you update with any major pivots, challenges, architectural decisions etc. of note.
