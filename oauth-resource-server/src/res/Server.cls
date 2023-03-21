Class res.Server Extends %CSP.REST
{

Parameter OAUTH2APPNAME = "resserver";

Parameter OAUTH2SCOPES = "openid profile email my/scope";

Parameter UseSession As Integer = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
    <Route Method="GET" Url = "/" Call = "ResServer" />
</Routes>
}

ClassMethod ResServer() As %Status
{    
    // retrieve access token from HTTP request
    set accessToken = ##class(%SYS.OAuth2.AccessToken).GetAccessTokenFromRequest(.status)
    if $$$ISERR(status) {
        set %response.Status = ..#HTTP401UNAUTHORIZED
        write "[Error] GetAccessTokenFromRequest: "_$system.Status.GetErrorText(status),!
        quit $$$OK
    }

    // validate token
    set isJWTValid = ##class(%SYS.OAuth2.Validation).ValidateJWT(
        "resserver",
        accessToken,
        "", // scope check only of client
        "", // aud
        .jwtPayload,
        .securityParameters,
        .sc,
        .jwtHeader
    )
    if (('isJWTValid) || ($$$ISERR(sc))) {
        set %response.Status = ..#HTTP401UNAUTHORIZED
        write "Error Getting Access Token="_$system.Status.GetErrorText(sc),!
        quit $$$OK
    }

    // introspection
    set sc = ##class(%SYS.OAuth2.AccessToken).GetIntrospection("resserver", accessToken, .jsonObject)
    if $$$ISERR(sc) {
        set %response.Status = ..#HTTP401UNAUTHORIZED
        write "Introspection Error="_..EscapeHTML($system.Status.GetErrorText(sc)),!
        quit $$$OK
    }

    write !,"This is protected content that you just accessed.",!
    
    quit $$$OK
}

}
