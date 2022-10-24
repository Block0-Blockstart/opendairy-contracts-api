# opendairy-contracts-api

API handling smart contracts patterns

## Installation

```bash
$ npm install
```

## Commands

```bash
# run the express server
$ npm run start

# run the express server with .env loading
$ npm run start:dev
```

## Environment variables

| name | value | example
| --- | --- | --- |
| ```NODE_ENV``` | development \|\| production | production |
| ```PORT``` | number | 42002 |


### Using .env file
While developing, you can pass environment variables using a .env file.
See .env.example at project root folder.   
You MUST use ```npm run start:dev``` when using an .env file.

### Using Windows Powershell
To pass env variables in a Windows Powershell console :
```posh
$env:PORT=42002; $env:NODE_ENV="production"; npm run start
 ```
:warning: The variables will remains after node process exits. You can reset them using command :
```posh
$env:PORT=$null; $env:NODE_ENV=$null
 ```

### Using Linux console
To pass env variables under Linux:
```sh
PORT=42002 NODE_ENV=production npm run start
```
The variables will be set only during the process execution (reset after process ends).

### Using Docker
see Docker deployment below.

### Using cloud services like AWS, Azure, ...
There are many tools allowing you to pass env variables securely using a managed environment. It depends of the service you use. See its documentation.


## Deploy with Docker
This procedure is for deployment on an AWS EC2 instance. The same can be done locally or on any virtual server with Docker installed.

1. **<u>Log on EC2</u>**

Use your favorite SSH tool to access your server instance.


2. **<u>Build the Docker image</u>**


A. **Build the image directly from the Git repo**

```sh
sudo docker build -t opendairy-contracts-api:latest https://github.com/Block0-Blockstart/opendairy-contracts-api.git
```

B. **Aternative: copy the repo**

* Clone a fresh copy of the git main branch locally.\
DO NOT npm install, as we don't want any node_modules !           

* Then, upload the whole project directory to the EC2 (FileZilla can do this).

* On the EC2, open a console and navigate to the directory you have just copied. Now, build the image:

    ```sh
    sudo docker build -t opendairy-contracts-api:latest .
    ``` 

    WARNING: notice the '.' at the end of the command line to instruct Docker to use the Dockerfile in current directory.

3. **<u>Run the image</u>**

You need to pass the environment variables to docker when running the image. There are many options to do this.


* *passing args to the docker run command*

You can pass the required variables directly to the docker run command. Example for NODE_ENV and PORT variables:

```sh
sudo docker run --name opendairy-contracts-api \
-it -e NODE_ENV=development -e PORT=42002 \
-p 42002:42002 --restart=unless-stopped \
opendairy-contracts-api:latest
```

:warning: Anyone with access to the Docker runtime can inspect a running container and discover the env values. For example:
```sh
$ docker inspect 6b6b033a3240

"Config": {
  // ...
  "Env": [
    "PORT=42002",
    "NODE_ENV=development",
    // ...
  ]
}
```

* *setting the environment variables in Dockerfile*

You can declare your environment variables in the DockerFile. This way, you can run the image with this simple command:

```sh
sudo docker run --name opendairy-contracts-api -it -p 42002:42002 --restart=unless-stopped opendairy-contracts-api:latest
```
:warning: Anyone with access to the Dockerfile can dicover your values.

* *using a temporary .env file*

Create a .env file at project's root (on the EC2) and pass the file path to the docker run command. Example:

```sh
sudo docker run --name opendairy-contracts-api \
-it --env-file=.env \
-p 42002:42002 --restart=unless-stopped \
opendairy-contracts-api:latest
```

Then you can delete the .env file, so that nobody can discover your values. This is more secure (see also https://docs.docker.com/engine/swarm/secrets/).

4. **<u>AWS: update security group</u>**

If you use an AWS EC2, don't forget to update your security group rules to open the port used by this api. Add an inbound rule:

  | Type | Protocol | Port range | Source | Description (optional) |
  | --- | --- | --- | --- | --- |
  | Custom TCP | TCP | 42002 | 0.0.0.0/0, ::/0 | Allows connections to opendairy-contracts-api

## Creating / updating a contract pattern

1. Create the contract with Remix IDE.
2. Compile with Remix (https://remix.ethereum.org). :warning: Choose byzantium as target version if the contract targets Alastria T-Network (as of September 2022, Alastria doesn't support more recent fork).
3. Test it online with Remix tools.
4. Place your contract source file (.sol) in the contract's folder at project root:         
```[root]/contracts/your-contract-name-lowercase/your-contract.sol```
4. Download the contract ABI (json file) and the bytecode (json file). Place them in the pattern subfolder :          
```[root]/contracts/your-contract-name-lowercase/pattern/abi.json```
```[root]/contracts/your-contract-name-lowercase/pattern/bytecode.json```

## Fetching a contract pattern

Call the api with GET and query param :
```
'name': 'your-contract-name'
```

## Testing

These flows were tested on Document.sol:

#### Document provider sends first hash

**Result:** the storage has a new hash in the mapping with “1” (to be reviewed).

| DD | DR |
| --- | --- |
| hash1 | 1 |

#### Document provider sends first hash, then sends another hash, before the requester does any action

**Result:** the mapping contains 2 hashes. The first hash with “5” (dropped), the second one with “1” (to be reviewed).
    
| DD | DR |
| --- | --- |
| hash1 | 5 |
| hash2 | 1 |

#### Document provider sends first hash, then sends same hash, before the requester does any action.

**Result:** revert with "Same document is already waiting for review".
    
| DD | DR |
| --- | --- |
| hash1 | 1 |

#### Document requester tries to [approve *or* reject *or* ask update] before the provider sends a hash.

**Result:** revert with "No document has been sent yet"

#### Document requester tries to [approve *or* reject *or* ask update] and the last hash has status 1.

**Result:** the status has changed from “to be reviewed” to the new status (respectively 3 *or* 4 *or* 2)

#### On status 2 (update asked), the document provider can send a new hash.

**Result:** the former hash keeps the status 2, the new hash has status 1.

| DD | DR |
| --- | --- |
| hash1 | 2 |
| hash2 | 1 |

#### This flow can be repeated: submission -> ask update -> submission -> ask update -> ...

**Result:** the mapping keeps records of the whole flow, which is:
    
| DD | DR |
| --- | --- |
| hash1 | 2 |
| hash2 | 2 |
| hash3 | 2 |
| hash4 | 2 |
| hash5 | 1 |


#### After an update request, the document provider sends a hash, then sends another hash (before the requester takes any action)

**Result:** the mapping contains:
 
| DD | DR |
| --- | --- |
| hash1 | 2 |
| hash2 | 5 |
| hash3 | 1 |

#### The provider sends **hash1**; then the requester ask for an update; then the provider sends **hash2**, immediately followed by **hash3** and then immediately followed the previous **hash2**. The requester then accepts *or* reject the last hash.

**Result:** the mapping contains:
 
| DD | DR |
| --- | --- |
| hash1 | 2 |
| hash2 | 5 |
| hash3 | 5 |
| hash2 | 3 *or* 4 |

#### Document requester tries to [approve *or* reject *or* ask update] after he accepted *or* rejected the last hash.

**Result:** revert with "The document has already been accepted" *or* "The document has already been rejected"

# Contact
**block0**
+ info@block0.io
+ [https://block0.io/](https://block0.io/)

# License
This repository is released under the [MIT License](https://opensource.org/licenses/MIT).