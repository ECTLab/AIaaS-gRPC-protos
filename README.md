# AIaaS gRPC protos ⌘
In AIaaS project, we use gRPC to communicate between microservices.\
This repository contains the gRPC protos for AIaaS project.\
You can find the gRPC protos in the `protos` directory.\
Read more about gRPC [here](https://grpc.io/docs/what-is-grpc/introduction/).


## How to add a new gRPC proto?
1. checkout a new branch from `master` branch
2. add a folder for your microservice in `protos` directory if it doesn't exist
3. add your proto file in the folder you created in step 2
4. if you added a new `service`, update `stubs_configs.json` file
5. make sure your proto file is valid
6. commit and push your changes
7. create a pull request to merge your branch into `master` branch

## How to use the gRPC my microservice project?
After you add your proto file to this repository and your pull request is merged into `master` branch, you can have your
proto python package in [this](https://github.com/ECTLab/AIaaS-gRPC-protos-Autogenerated-Python) repository.\
For each merged pull request, a new version tag will be created.
You can find the version tag of python package [here](https://github.com/ECTLab/AIaaS-gRPC-protos-Autogenerated-Python/tags)
