# CLOUD COMPUTING PROJECT 
The project is composed of 2 folders named:
- Cloud-project-A
- Cloud-project-B

  
## Project A
This project is based on Virtual Machines supported by Vagrant and Virtual Box
### HOW TO
Get into folder `Cloud-Project-A`

run:
```vagrant up``` 
 
## Project B

### HOW TO
Get into folder `Cloud-Project-B`

Initiate a docker swarm using the following command
```docker swarm init```

Build and Deploy:
```docker stack deploy -c docker-compose.yml cloud_project_b```
