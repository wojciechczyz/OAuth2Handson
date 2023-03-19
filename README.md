Using OAuth2 framework in InterSystems IRIS. Learn how to act as Client, Authentication Server or Resource Server.

Quick setup of all three servers,
Troubleshooting

# 6. Hands on - let's prepare servers on docker

Install required tools:

a.Git

Windows:
https://gitforwindows.org/

Mac:
https://sourceforge.net/projects/git-osx-installer/files/git-2.23.0-intel-universal-mavericks.dmg/download?use_mirror=autoselect

```
Brew install git
```

b.Docker for desktop

Windows and Mac:
https://www.docker.com/products/docker-desktop/

Mac:
```
Brew install docker
```

c.Visual Studio Code
Windows and Mac:
https://code.visualstudio.com/download

Mac:
brew install visual-studio-code


d.Preload all needed images:
Run your Docker Desktop

Login to Intersystems docker repository
https://containers.intersystems.com

Obtain your docker login command from the  portal

Login using above command and pull required images:

```
docker login -u="wczyz" -p="INSERT-YOUR-TOKEN-HERE"  containers.intersystems.com
docker pull containers.intersystems.com/intersystems/iris-community:2023.1.0.207.0
docker pull containers.intersystems.com/intersystems/webgateway:2023.1.0.207.0

```

For Mac M2:

```
docker login -u="wczyz" -p="INSERT-YOUR-TOKEN-HERE"  containers.intersystems.com
docker pull containers.intersystems.com/intersystems/iris-community:2023.1.0.207.0-linux-arm64v8
docker pull containers.intersystems.com/intersystems/webgateway:2023.1.0.207.0-linux-arm64v8

```

All tools are loaded now, lets start setting up

# 7. Hands on - Setting setting up OAuth2 servers

Load code (and this readme file) on your machine:

```
git clone https://github.com/wojciechczyz/OAuth2Handson.git
cd OAuth2Handson
```
Open the above link in browser 


Add new configuration line to your hosts file to resolve webserver to 127.0.0.1:
```
127.0.0.1 webserver
```


Windows
```
code c:\Windows\System32\Drivers\etc\hosts
```

Mac

```
code /private/etc/hosts
```
or
```
sudo nano /private/etc/hosts
```

Let's create new images and start servers
Build images:
```
docker-compose build
```

Run containers:
```
docker-compose up -d
```

# 8. Hands on - Registering OAuth2 Client and Resource server

a.Setting up authorization server - already done!

```
docker exec -it authserver iris terminal IRIS
```

Node: authserver, Instance: IRIS
```
zn "AUTHSERVER"
AUTHSERVER>do ##class(auth.server.Utils).CreateServerConfig()
```

b.Registering client server

```
docker exec -it client iris terminal IRIS
zn "client"
write ##class(client.Installer).RegisterOauth2Client()
```

c.Registering resource server

```
docker exec -it resourceserver iris terminal IRIS
zn "resserver"
write ##class(res.Installer).RegisterOauth2ResourceServer()
```

# 9.Hands on - Review configuration

After running containers, you should get access to:
| Container  | Mng. Portal URL                                    | Notes                                                |
| ---------  | -----------                                        | -----------                                          |
| webserver  | https://webserver/csp/bin/Systems/Module.cxw       | HTTPS access to all IRIS instances                   |
| authserver | https://webserver/authserver/csp/sys/UtilHome.csp?IRISUsername=superuser&IRISPassword=SYS  | IRIS instance that will act as Authorization Server  |
| resserver  | https://webserver/resserver/csp/sys/UtilHome.csp?IRISUsername=superuser&IRISPassword=SYS   | IRIS instance that will act as Resource Server       |
| client     | https://webserver/client/csp/sys/UtilHome.csp?IRISUsername=superuser&IRISPassword=SYS      | IRIS instance that will act as Client                |

You can login in InterSystems IRIS instances using `superuser`/`SYS`.

Resource server
* [ResServer](https://webserver/resserver/csp/sys/UtilHome.csp?IRISUsername=superuser&IRISPassword=SYS) is serving protected resource URL:

```
* https://webserver/resserver/protected-resources/
```

* Resource server can be accessed only through the client application (otherwise it will return an error). 


# 10.Hands on - Test OAuth2 workflow with Web Client Application

In the [Client](https://webserver/client/csp/sys/UtilHome.csp) instance you have already a simple web app created that
will attempt to connect to the resource server attempting to get authorization with  `%OAuth2` classes.

https://webserver/client/application/

Superuser	SYS
developer	test

Notice that these users are actually defined in [AuthServer](https://webserver/authserver/csp/sys/UtilHome.csp?IRISUsername=superuser&IRISPassword=SYS) instance.

11.Hands on - Test OAuth2 workflow with Web Client Application - result

# 12.what are we troubleshooting



# 13.Hands on troubleshooting using ISCSOAP

```
kill ^ISCLOG // clear the global
set ^%ISCLOG("Category","OAuth2Server")=1
set ^%ISCLOG("Category","OAuth2")=1
set ^%ISCLOG=3
```

***Perform test***

```
set ^%ISCLOG=0 //disable logging

do $system.OBJ.Export("ISCLOG.GBL","c:\temp\isclog.xml")

zn "%SYS"
do ##class(%OAuth2.Utils).DisplayLog("/tmp/isclog.log")
```

See both ^%ISCLOG and ^ISCLOG via management portal on all instances:

| authserver | https://webserver/authserver/csp/sys/UtilHome.csp?IRISUsername=superuser&IRISPassword=SYS  | IRIS instance that will act as Authorization Server  |
| resserver  | https://webserver/resserver/csp/sys/UtilHome.csp?IRISUsername=superuser&IRISPassword=SYS   | IRIS instance that will act as Resource Server       |
| client     | https://webserver/client/csp/sys/UtilHome.csp?IRISUsername=superuser&IRISPassword=SYS      | IRIS instance that will act as Client 

Search for client_id

# 14.Hands on - Troubleshooting using Gateway traces

| Container  | Mng. Portal URL                                    | Notes                                                |
| ---------  | -----------                                        | -----------                                          |
| webserver  | https://webserver/csp/bin/Systems/Module.cxw       | HTTPS access to all IRIS instances                   |
| authserver | https://webserver/authserver/csp/sys/UtilHome.csp?IRISUsername=superuser&IRISPassword=SYS  | IRIS instance that will act as Authorization Server  |
| resserver  | https://webserver/resserver/csp/sys/UtilHome.csp?IRISUsername=superuser&IRISPassword=SYS   | IRIS instance that will act as Resource Server       |
| client     | https://webserver/client/csp/sys/UtilHome.csp?IRISUsername=superuser&IRISPassword=SYS      | IRIS instance that will act as Client                |

Review traces and log of the previous requests

# 15.Hands on - Troubleshooting using Developer tools in browser

Open developer tools in Google Chrome

Delete session on the client

Repeat the OAuth2 flow noticing requests in Network tab

https://webserver/client/application/

# 16. HealthShare 


Deployed mode
%ZHS.ZAUTHENTICATE.cls
%ZHS.ZAUTHENTICATE.inc


kill ^CacheTemp.HSAuthEnabled
Set  ^CacheTemp.HSAuthEnabled
Debugging enabled


In BEARER token flow
ValidateJWT return

# 16.Hands on - Review server build using Visual Studio Code





