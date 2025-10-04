## Github & Git Usage Rules
- The default branching strategy is to feature branch from main. If the user requests changing strategy then migrate to the new strategy.  
- Always use the conventional commits standard for commit messages [link](https://www.conventionalcommits.org/en/v1.0.0/)
- when making a batch of changes, commit the changes when done. If you need to undo changes you can easily go back to a previous commit.
- work on the dev branch or feature branch only. If you are on master and need to make changes you should switch to dev or the relevant feature branch. You will have to decide or get feedback from the user if working on multiple feature branches at once e.g do they want to stash their changes instead etc. 
- Always use git in every project. If there is no .git folder then initialize the repo with a .gitignore file as well. If it's a python project then a .gitignore file relevant to python project. Add a basic Readme License file etc. 

## Package Manager and Default Dependancies

- Always use poetry package manager. 
- Always add python-dotenv as a dependency in every python project (this also helps generate the poetry files when starting the project)
- Always create a .env file with some placeholder env variables
- Always us mkdocs and keep project documentation up to date for each feature branch. Check documentation is up to date before finishing a feature branch.

## Coding Standards

- If the use asks to connect to a database then add the connection details i.e credentials as env vars in .env file. 
- When adding env vars make them descriptive and namespaced to avoid conflicts e.g. ther username for a supabase db connection 'user' should be 'db_user' or 'SUPABASE_DB_USER'
- If the user wants to connect to a database, create a health check script (or add to existing one) to test connection to the database e.g. "SELECT 1" query and run it if possible to confirm connection details are correct
- For python projects use PEP8 standards and styling
- add comments to functions and docstrings, keep docstrings up to date when making changes

## Database Querying
- When the user mentions a table, don't take the table name on trust, confirm and cross check with connected databases (i.e databases that you have credentials for in .env file and have confirmed connection with health check) by checking the schema

## Project Specifications
- Always create a file called SPEC.md and keep it at the root of the project. Update SPEC.md with any functional requirements, non functional requirements as the user mentions them. Refer back to SPEC.md to get clarity on the overall goals of the project.
- Always include background information about the project in the README.md that the user mentions, i.e what the goals, challenges of the project are. Include a journal section at the top of README.md that you update with any major pivots, challenges, architectural decisions etc. of note.
