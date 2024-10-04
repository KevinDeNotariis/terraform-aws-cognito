# AWS Cognito Terraform module

Terraform module that is in charge of creating a usable cognito user pool and identity pool with all the necessary resources.

## Features

- Creates an identity pool with standardized presence and definition of compulsory attributes:
  - email
  - given_name
  - family_name
- Set up the user pool for verification of a new user via email and with a invite message via email.
- Create a custom domain (with its certificate) for the user pool in the form of:

    ```txt
    auth.<environment>.<prefix>.<base_domain>
    ```
- Create a user pool client
- Create an identity pool which will allow to assign AWS permissions on user logged in (or not logged in)
- Extract the groups and users to be created from two distinct YAML files.
- Save in SSM Paramater store the client-id of the user pool client.
