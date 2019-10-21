# TEMPLATE/aws-config.yml

The file in this folder is for the user base to use as a template to consume the **GitHub** Action:
- **Deploy-NodeJS-AWS-SAM**

The user will need to copy the file to the location:

- `/github/aws-config.yml` in their repository

The file will be parsed at run time on the local branch to load all variables needed to deploy their **NodeJS** application to **AWS** Serverless utilizing **AWS SAM**.  
The **GitHub** Action will inform the user via the **Checks API** on the status and success of the deployment process.
