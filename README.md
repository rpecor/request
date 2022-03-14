# Re(quest) App

**App code lives in /app and infrastructure code lives within /infra. Application code can be built and deployed independent of the infrastructure provisioning.**

## App
Each push to the main branch in the /app directory will trigger an Actions pipeline that builds the docker image and pushes to the Github Container Registry. The image is currently publicly hosted here: ghcr.io/rpecor/request. Each build is tagged using the pipeline run number.

Building the image and serving it independent of the infrastructure gave me flexibility to decide on my infrastructure strategy. It also gave some advantages on the development side-- quickly testing, versioning and the ability to easily roll back.


## Infra
On the infrastructure side I decided to use Azure App Services. This managed compute allows me to simply run the container and define the compute tier. All of this is in the Terraform code under /infra. 

The Terraform backend is pointed to a Workspace in Terraform Cloud to manage builds and remote state. VCS Integration is configured so that a Pull Request into the main branch would trigger a speculative plan. In my current solo developer workflow, direct pushes to main will queue a plan. 