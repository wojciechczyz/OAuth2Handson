Class client.Installer Extends %RegisteredObject
{

XData Setup [ XMLNamespace = INSTALLER ]
{
<Manifest> 
    <Log Text="Creating namespaces..." Level="0"/> 
    <Namespace Name="CLIENT" Create="yes" Ensemble=""> 
        <Configuration> 
            <Database Name="CLIENT-DATA" Dir="/usr/irissys/mgr/client-data" Create="yes" MountRequired="true" Resource="%DB_DEFAULT" PublicPermissions="RW" MountAtStartup="true"/> 
            <Database Name="CLIENT-CODE" Dir="/usr/irissys/mgr/client-code" Create="yes" MountRequired="true" Resource="%DB_DEFAULT" PublicPermissions="RW" MountAtStartup="true"/> 
        </Configuration>
    </Namespace>
    <Namespace Name="%SYS" Create="no">
        <Invoke Class="Security.SSLConfigs" Method="Import" CheckStatus="true">
            <Arg Value="/opt/irisapp/install/ssl.xml"/>
        </Invoke>
    </Namespace>
     <Namespace Name="%SYS" Create="no">
        <Invoke Class="Security.Applications" Method="Import" CheckStatus="true">
            <Arg Value="/opt/irisapp/install/webapp-application.xml"/>
        </Invoke>
    </Namespace>
</Manifest>
}

/// Setup method
ClassMethod RunManifest(ByRef pVars, pLogLevel As %Integer = 0, pInstaller As %Installer.Installer) As %Status [ CodeMode = objectgenerator, Internal ]
{
    Quit ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "Setup")
}

/// Setup environment: create namespaces, system configuration, etc.    
ClassMethod SetupEnvironment(ByRef vars) As %Status
{
    set ns = $namespace
    try { 
        $$$ThrowOnError(..RunManifest(.vars)) 

    } catch ex { 
        set sc = ex.AsStatus() 
        write $system.Status.GetErrorText(sc),!
        do $system.Process.Terminate($job,1) 
    }
    set $namespace = ns
    quit sc
}

/// Setup CLIENT
ClassMethod SetupCLIENT() As %Status
{
    set ns = $namespace
    set ret = $$$OK
    try {
        zn "CLIENT"

        // load src
        write "Going to load all classes in /opt/irisapp/src/"
        $$$ThrowOnError($SYSTEM.OBJ.LoadDir("/opt/irisapp/src/", "ck", .errorlog, 1))
        //write "Attempt SetupOauth2Client()"
        //$$$ThrowOnError(  ..RegisterOauth2Client() )
        //write "Finished SetupOauth2Client()"

    } catch ex {
        set ret = ex.AsStatus() 
        write $system.Status.GetErrorText(ret),! 
        do $system.Process.Terminate($job,1) 
    }
    set $namespace = ns
    quit ret
}

ClassMethod RegisterOauth2Client() As %Status
{
    set ns = $namespace
    set ret = $$$OK
    try {
        zn "%SYS"
        write "Registering Client application with Authorization server...",!
        set ^%ISCLOG("Category","OAuth2Server")=1
        set ^%ISCLOG("Category","OAuth2")=1
        set ^%ISCLOG=3

        Set StatusCode = ##class(%SYS.OAuth2.Registration).Discover("https://webserver/authserver/oauth2","ssl",.Server)
        $$$ThrowOnError(StatusCode)
        $$$ThrowOnError( Server.%Save() )
        Set Client = ##class(OAuth2.Client).%New()
        Set Client.ApplicationName = "client-app"
        Set Client.Enabled=1
        Set Client.ClientType = "confidential"
        Set Client.SSLConfiguration="ssl"
        Set Client.ServerDefinition = Server
        //"https://webserver/client/csp/sys/oauth2/OAuth2.Response.cls"
        Set Client.RedirectionEndpoint.UseSSL=1
        Set Client.RedirectionEndpoint.Host="webserver"
        Set Client.RedirectionEndpoint.Port=""
        Set Client.RedirectionEndpoint.Prefix="client"
        Set Client.RedirectionEndpoint.Prefix="client"
        set Client.Metadata."grant_types" = $lb("authorization_code")        
        $$$ThrowOnError( Client.%Save() )
        $$$ThrowOnError( ##class(%SYS.OAuth2.Registration).RegisterClient("client-app") )
        write "Finished registering Client application with Authorization server.",!        
    } catch ex {
        set ret = ex.AsStatus() 
        write $system.Status.GetErrorText(ret),! 
        //do $system.Process.Terminate($job,1) 
    }
    set $namespace = ns
    quit ret
}

}
