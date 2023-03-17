Class res.Installer Extends %RegisteredObject
{

XData Setup [ XMLNamespace = INSTALLER ]
{
<Manifest> 
    <Log Text="Creating namespaces..." Level="0"/> 
    <Namespace Name="RESSERVER" Create="yes" Ensemble=""> 
        <Configuration> 
            <Database Name="RESSERVER-DATA" Dir="/usr/irissys/mgr/resserver-data" Create="yes" MountRequired="true" Resource="%DB_DEFAULT" PublicPermissions="RW" MountAtStartup="true"/> 
            <Database Name="RESSERVER-CODE" Dir="/usr/irissys/mgr/resserver-code" Create="yes" MountRequired="true" Resource="%DB_DEFAULT" PublicPermissions="RW" MountAtStartup="true"/> 
        </Configuration>
    </Namespace>
    <Namespace Name="%SYS" Create="no">
        <Invoke Class="Security.SSLConfigs" Method="Import" CheckStatus="true">
            <Arg Value="/opt/irisapp/install/ssl.xml"/>
        </Invoke>
    </Namespace>
    <Namespace Name="%SYS" Create="no">
        <Invoke Class="Security.Applications" Method="Import" CheckStatus="true">
            <Arg Value="/opt/irisapp/install/webapp-protected-resources.xml"/>
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

/// Setup RESSERVER
ClassMethod SetupRESSERVER() As %Status
{
    set ns = $namespace
    set ret = $$$OK
    try {
        zn "RESSERVER"

        // load src
        write "Going to load all classes in /opt/irisapp/src/",!
        $$$ThrowOnError($SYSTEM.OBJ.LoadDir("/opt/irisapp/src/", "ck", .errorlog, 1))

        //write "Attempt SetupOauth2Client()",!
        //do ..SetupOauth2Client()
        //write "Finished SetupOauth2Client()",!

    } catch ex {
        set ret = ex.AsStatus() 
        write $system.Status.GetErrorText(ret),! 
        do $system.Process.Terminate($job,1) 
    }
    set $namespace = ns
    quit ret
}

ClassMethod SetupOauth2Client() As %Status
{
    set ns = $namespace
    set ret = $$$OK
    try {
        zn "%SYS"
        write "Registering Resource server with Authorization server...",!
        set ^%ISCLOG("Category","OAuth2Server")=1
        set ^%ISCLOG("Category","OAuth2")=1
        set ^%ISCLOG=3

        Set StatusCode = ##class(%SYS.OAuth2.Registration).Discover("https://webserver/authserver/oauth2","ssl",.Server)
        $$$ThrowOnError(StatusCode)
        $$$ThrowOnError( Server.%Save() )
        Set Client = ##class(OAuth2.Client).%New()
        Set Client.ApplicationName = "resserver"
        Set Client.Enabled=1
        Set Client.ClientType = "resource"
        Set Client.SSLConfiguration="ssl"
        Set Client.ServerDefinition = Server

        /*
        //"https://webserver/client/csp/sys/oauth2/OAuth2.Response.cls"
        Set Client.RedirectionEndpoint.UseSSL=1
        Set Client.RedirectionEndpoint.Host="webserver"
        Set Client.RedirectionEndpoint.Port=""
        Set Client.RedirectionEndpoint.Prefix="client"
        Set Client.RedirectionEndpoint.Prefix="client"
        */
        set Client.Metadata."grant_types" = $lb("authorization_code") 

        $$$ThrowOnError( Client.%Save() )
        $$$ThrowOnError( ##class(%SYS.OAuth2.Registration).RegisterClient("resserver") )

        write "Finished registering Resource server with Authorization server.",!   
    } catch ex {
        set ret = ex.AsStatus() 
        write $system.Status.GetErrorText(ret),! 
        //do $system.Process.Terminate($job,1) 
    }
    set $namespace = ns
    quit ret
}

}
