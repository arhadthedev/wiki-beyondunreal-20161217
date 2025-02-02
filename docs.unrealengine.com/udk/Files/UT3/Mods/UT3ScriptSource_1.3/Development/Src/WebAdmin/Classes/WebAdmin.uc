﻿/**
 * The main entry point for the UT3 WebAdmin. This manages the initial web page
 * request and authentication and session handling. The eventual processing of
 * the request will be doen by query handlers.
 *
 * Copyright 2008 Epic Games, Inc. All Rights Reserved
 *
 * @author  Michiel 'elmuerte' Hendriks
 */
class WebAdmin extends WebApplication dependsOn(IQueryHandler) config(WebAdmin);

`define WITH_BASE64ENC

`include(WebAdmin/timestamp.uci)

/**
 * The menu handler
 */
var WebAdminMenu menu;

/**
 * The authorization handler instance
 */
var IWebAdminAuth auth;

/**
 * Defines the authentication handler class to use instead of the default one.
 */
var globalconfig string AuthenticationClass;

/**
 * The default authentication class
 */
var class/*<IWebAdminAuth>*/ defaultAuthClass;

/**
 * The session handler
 */
var ISessionHandler sessions;

/**
 * The session handler to use instead of the default session handler
 */
var globalconfig string SessionHandlerClass;

/**
 * The default session handler class
 */
var class/*<ISessionHandler>*/ defaultSessClass;

/**
 * The loaded handlers.
 */
var array<IQueryHandler> handlers;

/**
 * The list of query handlers to automativally load
 */
var globalconfig array<string> QueryHandlers;

/**
 * If set to true, use HTTP Basic authentication rather than a HTML form. Using
 * HTTP authentication gives the functionality of automatic re-authentication.
 */
var globalconfig bool bHttpAuth;

/**
 * The starting page. Defaults to /current
 */
var globalconfig string startpage;

/**
 * local storage. Used to construct the auth URLs.
 */
var protected string serverIp;

/**
 * Will contain the timestamp when this package was compiled
 */
var const string timestamp;

var const string version;

function init()
{
	local class/*<IWebAdminAuth>*/ authClass;
	local class/*<ISessionHandler>*/ sessClass;
	local class<Actor> aclass;
	local IpAddr ipaddr;
	local int i;

	super.init();

	if (QueryHandlers.length == 0)
	{
		QueryHandlers[0] = "WebAdmin.QHCurrent";
		QueryHandlers[1] = "WebAdmin.QHDefaults";
	}

	menu = new(Self) class'WebAdminMenu';
	menu.webadmin = self;
	menu.addMenu("/about", "", none,, MaxInt-1);
	menu.addMenu("/logout", "Log out", none, "Log out from the webadmin and clear all authentication information.", MaxInt);

	if (len(AuthenticationClass) != 0)
	{
		authClass = class(DynamicLoadObject(AuthenticationClass, class'Class'));
	}
	if (authClass == none)
	{
		authClass = defaultAuthClass;
	}

	`Log("Creating IWebAdminAuth instance from: "$authClass,,'WebAdmin');
	if (!ClassIsChildOf(authClass, class'Actor'))
	{
		auth = new(self) authClass;
	}
	else {
		aclass = class<Actor>(DynamicLoadObject(""$authClass, class'Class'));
		auth = Worldinfo.spawn(aclass);
	}
	auth.init(Worldinfo);

	if (len(AuthenticationClass) != 0)
	{
		sessClass = class(DynamicLoadObject(SessionHandlerClass, class'class'));
	}
	if (sessClass == none)
	{
		sessClass = defaultSessClass;
	}

	`Log("Creating ISessionHandler instance from: "$sessClass,,'WebAdmin');
	if (!ClassIsChildOf(sessClass, class'Actor'))
	{
		sessions = new(self) sessClass;
	}
	else {
		aclass = class<Actor>(DynamicLoadObject(""$sessClass, class'Class'));
		sessions = Worldinfo.spawn(aclass);
	}

	WebServer.GetLocalIP(ipaddr);
	serverIp = WebServer.IpAddrToString(ipaddr);
	i = InStr(serverIp, ":");
	if (i > -1)
	{
		serverIp = left(serverIp, i);
	}

	initQueryHandlers();
}

function CleanupApp()
{
	local IQueryHandler handler;
	foreach handlers(handler)
	{
		handler.cleanup();
	}
	handlers.Remove(0, handlers.Length);
	menu.menu.Remove(0, menu.menu.length);
	menu = none;
	auth.cleanup();
	auth = none;
	sessions.destroyAll();
	sessions = none;
	super.CleanupApp();
}

/**
 * Load the registered query handlers
 */
protected function initQueryHandlers()
{
	local IQueryHandler qh;
	local string entry;
	local class/*<IQueryHandler>*/ qhc;
	local class<Actor> aclass;

	foreach QueryHandlers(entry)
	{
		qhc = class(DynamicLoadObject(entry, class'class'));
		if (qhc == none)
		{
			`Log("Unable to find query handler class: "$entry,,'WebAdmin');
			continue;
		}
		qh = none;
		if (!ClassIsChildOf(qhc, class'Actor'))
		{
			qh = new(self) qhc;
		}
		else {
			aclass = class<Actor>(DynamicLoadObject(""$qhc, class'Class'));
			qh = Worldinfo.spawn(aclass);
		}
		if (qh == none)
		{
			`Log("Unable to create query handler: "$entry,,'WebAdmin');
		}
		else {
			addQueryHandler(qh);
		}
	}
}

/**
 * Add a query handler to the list. This will also call init() and
 * registerMenuItems() on the query handler.
 */
function addQueryHandler(IQueryHandler qh)
{
	if (handlers.find(qh) != -1)
	{
		return;
	}
	qh.init(self);
	qh.registerMenuItems(menu);
	handlers.addItem(qh);
}

/**
 * return the authentication URL string used in the user privileged system.
 */
function string getAuthURL(string forpath)
{
	if (Left(forpath, 1) != "/") forpath = "/"$forpath;
	return "webadmin://"$ serverIp $":"$ WebServer.ListenPort $ forpath;
}

function Query(WebRequest Request, WebResponse Response)
{
	local WebAdminQuery currentQuery;
	local WebAdminMenu wamenu;
	local IQueryHandler handler;
	local string title, description;

	response.Subst("webadmin.path", path);
	response.Subst("page.uri", Request.URI);
	response.Subst("page.fulluri", Path$Request.URI);

	currentQuery.request = Request;
	currentQuery.response = Response;
	parseCookies(Request.GetHeader("cookie", ""), currentQuery.cookies);
	if (!getSession(currentQuery))
	{
		return;
	}
	if (!getWebAdminUser(currentQuery))
	{
		return;
	}
	response.Subst("admin.name", currentQuery.user.getUsername());

	wamenu = WebAdminMenu(currentQuery.session.getObject("WebAdminMenu"));
	if (wamenu == none)
	{
		wamenu = menu.getUserMenu(currentQuery.user);
		currentQuery.session.putObject("WebAdminMenu", wamenu);
		currentQuery.session.putString("WebAdminMenu.rendered", wamenu.render());
	}
	response.Subst("navigation.menu", currentQuery.session.getString("WebAdminMenu.rendered"));

	if (request.URI == "/")
	{
		if (len(startpage) != 0)
		{
			Response.Redirect(path$startpage);
			return;
		}
		pageGenericError(currentQuery, "No starting page.");
		return;
	}
	else if (request.URI == "/logout")
	{
		if (auth.logout(currentQuery.user)) {
			sessions.destroy(currentQuery.session);
			Response.AddHeader("Set-Cookie: sessionid=; Path="$path$"/; Max-Age=0");
			Response.AddHeader("Set-Cookie: authcred=; Path="$path$"/; Max-Age=0");
			Response.Redirect(path$"/");
			return;
		}
		pageGenericError(currentQuery, "Unable to log out.");
		return;
	}
	else if (request.URI == "/about")
	{
		pageAbout(currentQuery);
		return;
	}

	// get proper handler
	handler = wamenu.getHandlerFor(request.URI, title, description);
	if (handler != none)
	{
		response.Subst("page.title", title);
		response.Subst("page.description", description);
		if (handler.handleQuery(currentQuery))
		{
			return;
		}
	}

	if (currentQuery.user.canPerform(getAuthURL(request.URI))) {
		// try other way
		foreach handlers(handler)
		{
			if (handler.unhandledQuery(currentQuery))
			{
				return;
			}
		}
	}

	// check with the overal menu, if the handler is null the page doesn't exist
	if (menu.getHandlerFor(request.URI, title, description) == none)
	{
		Response.HTTPResponse("HTTP/1.1 404 Not Found");
		pageGenericError(currentQuery, "The requested page was not found.", "Error 404 - Page not found");
	}
	else {
		Response.HTTPResponse("HTTP/1.1 403 Forbidden");
		pageGenericError(currentQuery, "You do not have the privileges to view this page.", "Access Denied");
	}
}

protected function parseCookies(String cookiehdr, out array<KeyValuePair> cookies)
{
	local array<string> cookieParts;
	local string entry;
	local int pos;
	local KeyValuePair kvp;

	ParseStringIntoArray(cookiehdr, cookieParts, ";", true);
	foreach cookieParts(entry)
	{
		pos = InStr(entry, "=");
		if (pos > -1)
		{
			kvp.key = Left(entry, pos);
			kvp.key -= " ";
			kvp.value = Mid(entry, pos+1);
			//`Log("Received cookie with name="$kvp.key$" ; value="$kvp.value,,'WebAdmin');
			cookies.AddItem(kvp);
		}
	}
}

/**
 * Adds the ISession instance to query
 */
protected function bool getSession(out WebAdminQuery q)
{
	local string sessionId;
	local int idx;

	idx = q.cookies.Find('key', "sessionid");
	if (idx > -1)
	{
		sessionId = q.cookies[idx].value;
	}
	if (len(sessionId) == 0)
	{
		sessionId = q.request.GetVariable("sessionid");
	}
	if (len(sessionId) > 0)
	{
		q.session = sessions.get(sessionId);
	}
	if (q.session == none)
	{
		q.session = sessions.create();
		q.response.headers.AddItem("Set-Cookie: sessionid="$q.session.getId()$"; Path="$path$"/");
	}
	if (q.session == none)
	{
		pageGenericError(q, "Unable to create a session. See the log file for details."); // TODO: localize
		return false;
	}
	q.response.Subst("sessionid", q.session.getId());
	return true;
}

/**
 * Retreives the webadmin user. Creates a new one when needed.
 */
protected function bool getWebAdminUser(out WebAdminQuery q)
{
	local string username, password, token, errorMsg, rememberCookie;
	local int idx;
	local bool checkToken;

	local string realm;
	if (bHttpAuth)
	{
		realm = "UT3 WebAdmin - "$worldinfo.Game.GameReplicationInfo.ServerName;
		q.response.AddHeader("WWW-authenticate: basic realm=\""$realm$"\"");
		q.session.putString("UsedHttpAuth", "1");
	}

	q.user = q.session.getObject("IWebAdminUser");
	// 1: find existing user
	if (q.user != none)
	{
		if (q.session.getString("UsedHttpAuth") == "1")
		{
			// not really needed
			if (!auth.validate(q.request.Username, q.request.Password, errorMsg))
			{
				pageAuthentication(q, errorMsg);
				return false;
			}
		}
		return true;
	}

	idx = q.cookies.Find('key', "authcred");
	if (idx > -1)
	{
		rememberCookie = q.cookies[idx].value;
	}
	else {
		rememberCookie = "";
	}

	checkToken = false;

	// 2: try to authenticate
	if (len(q.request.Username) > 0 && len(q.request.Password) > 0)
	{
		username = q.request.Username;
		password = q.request.Password;
	}
	else if (len(rememberCookie) > 0)
	{
		username = q.request.DecodeBase64(rememberCookie);
		idx = InStr(username, Chr(10));
		password = Mid(username, idx+1);
		username = Left(username, idx);
	}

	if (len(username) == 0 || len(password) == 0)
	{
		username = q.request.GetVariable("username");
		password = q.request.GetVariable("password");
		token = q.request.GetVariable("token");
		checkToken = true;
	}

	if (len(username) == 0 || len(password) == 0)
	{
		pageAuthentication(q, "");
		return false;
	}

	// check data
	if (checkToken && (len(token) == 0 || token != q.session.getString("AuthFormToken")))
	{
		pageAuthentication(q, "Invalid form data.");
		return false;
	}
	q.user = auth.authenticate(username, password, errorMsg);

	if (q.user == none)
	{
		if (len(rememberCookie) > 0)
		{
			// unset cookie
			q.response.headers.AddItem("Set-Cookie: authcred=; Path="$path$"/; Max-Age=0");
			errorMsg = "Authentication cookie does not contain correct information.";
			rememberCookie = "";
		}
		pageAuthentication(q, errorMsg);
		return false;
	}
	q.session.putObject("IWebAdminUser", q.user);

	`if(WITH_BASE64ENC)
	if (q.request.GetVariable("remember") == "1")
	{
		rememberCookie = q.request.EncodeBase64(username$chr(10)$password);
		q.response.headers.AddItem("Set-Cookie: authcred="$rememberCookie$"; Path="$path$"/; Max-Age=2678400"); // 2678400 = 1 month
	}
	`endif

	return true;
}

/**
 * Include the specified file.
 */
function string include(WebAdminQuery q, string file)
{
	return q.response.LoadParsedUHTM(Path $ "/" $ file);
}

/**
 * Load the given file and send it to the client.
 */
function sendPage(WebAdminQuery q, string file)
{
	q.response.IncludeUHTM(Path $ "/" $ file);
	q.response.ClearSubst();
}

/**
 * Create a generic error message.
 */
function pageGenericError(WebAdminQuery q, coerce string errorMsg, optional string title = "Error")
{
	q.response.Subst("page.title", title);
	q.response.Subst("page.description", "");
	q.response.Subst("message", errorMsg);
	sendPage(q, "error.html");
}

/**
 * Produces the authentication page.
 */
function pageAuthentication(WebAdminQuery q, string errorMsg)
{
	local string token;
	if (q.request.getVariable("ajax") == "1")
	{
		q.response.HTTPResponse("HTTP/1.1 403 Forbidden");
		pageGenericError(q, "Unauthorized access.", "Error 403 - Forbidden");
		return;
	}
	if (bHttpAuth)
	{
		q.response.HTTPResponse("HTTP/1.1 401 Unauthorized");
		pageGenericError(q, "Unauthorized access. You need to log in.", "Error 401 - Unauthorized");
		return;
	}
	token = Right(ToHex(Rand(MaxInt)), 4)$Right(ToHex(Rand(MaxInt)), 4);
	q.session.putString("AuthFormToken", token);
	q.response.Subst("page.title", "Login");
	q.response.Subst("page.description", "Log in using the administrator username and password. Cookies must be enabled for this site.");
	q.response.Subst("message", errorMsg);
	q.response.Subst("token", token);
	sendPage(q, "login.html");
}

function pageAbout(WebAdminQuery q)
{
	q.response.Subst("page.title", "About");
	q.response.Subst("page.description", "Various information about the UT3 WebAdmin");
	q.response.Subst("build.timestamp", timestamp);
	q.response.Subst("build.version", version);
	q.response.Subst("engine.version", worldinfo.EngineVersion);
	q.response.Subst("engine.netversion", worldinfo.MinNetVersion);
	q.response.Subst("client.address", q.request.RemoteAddr);
	q.response.Subst("webadmin.address", serverIp$":"$WebServer.ListenPort);
	if (bHttpAuth) q.response.Subst("webadmin.authmethod", "HTTP Authentication");
	else q.response.Subst("webadmin.authmethod", "Login form");
	if (q.cookies.Find('key', "authcred") > -1) q.response.Subst("client.remember", "True");
	else q.response.Subst("client.remember", "False");
	q.response.Subst("client.sessionid", q.session.getId());
	sendPage(q, "about.html");
}

defaultproperties
{
	defaultAuthClass=class'BasicWebAdminAuth'
	defaultSessClass=class'SessionHandler'
	timestamp=`{TIMESTAMP}
	version="0.1"
}