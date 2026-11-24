#pragma semicolon 1

#include <sourcemod>
#include <cstrike>
#include <vip_core>

#pragma newdecls required

#define VIP_TAG		"Tag"

// Player's own Steam group tag. Since the CS:S update of 24/08/2026 the engine no longer
// applies it: the client sends it in a cmdkeyvalues ("tag" key) and plugins set it.
// It wins over the VIP tag; plugin-made tags (country tags...) do not.
char g_sOwnClanTag[MAXPLAYERS + 1][32];
// VIP tag we applied, as the game stores it (empty when none is applied)
char g_sAppliedVipTag[MAXPLAYERS + 1][32];

public Plugin myinfo =
{
	name = "[VIP] Tag",
	author = "R1KO, maxime1907",
	description = "Gives a default VIP tag to VIPs",
	version = "1.0.7",
	url = ""
};

public void OnPluginStart()
{
#if defined VIPTAG_DEBUG
	RegAdminCmd("sm_viptag_debug", Command_Debug, ADMFLAG_ROOT, "sm_viptag_debug <#userid|name> <on|off|status>");
#endif

	// Late load (manual reload, or SourceMod reloading an updated .smx at map change):
	// VIP_OnVIPLoaded already fired, so register now and pick up the players in game.
	if (VIP_IsVIPLoaded())
	{
		VIP_OnVIPLoaded();

		for (int client = 1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client) && !IsFakeClient(client))
				OnClientLateLoad(client);
		}
	}
}

public void OnPluginEnd()
{
	// Give players their own clan tag back
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && g_sAppliedVipTag[client][0] != '\0')
			RestoreOwnClanTag(client);
	}

	if (CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "VIP_UnregisterFeature") == FeatureStatus_Available
		&& VIP_IsValidFeature(VIP_TAG))
		VIP_UnregisterFeature(VIP_TAG);
}

public void VIP_OnVIPLoaded()
{
	// Up to 1.0.5 the plugin never unregistered on unload: after a reload the core kept
	// the feature bound to the dead plugin and the !vip toggle threw "Plugin handle is invalid".
	if (VIP_IsValidFeature(VIP_TAG))
		VIP_UnregisterFeature(VIP_TAG);

	VIP_RegisterFeature(VIP_TAG, STRING, TOGGLABLE, OnToggleItem);
}

public Action OnToggleItem(int client, const char[] sFeatureName, VIP_ToggleState OldStatus, VIP_ToggleState &NewStatus)
{
	DebugLog(client, "toggle %d -> %d", OldStatus, NewStatus);

	if (NewStatus == ENABLED)
		SetVipTag(client);
	else if (g_sAppliedVipTag[client][0] != '\0')
		RestoreOwnClanTag(client);

	return Plugin_Continue;
}

public void VIP_OnVIPClientLoaded(int client)
{
	DebugLog(client, "VIP loaded, feature use %d", VIP_IsClientFeatureUse(client, VIP_TAG));

	if (VIP_IsClientFeatureUse(client, VIP_TAG))
		SetVipTag(client);
	else if (g_sAppliedVipTag[client][0] != '\0')
		RestoreOwnClanTag(client);
}

public void VIP_OnVIPClientRemoved(int client, const char[] sReason, int iAdmin)
{
	DebugLog(client, "VIP removed (%s)", sReason);

	if (g_sAppliedVipTag[client][0] != '\0')
		RestoreOwnClanTag(client);
}

public Action OnClientCommandKeyValues(int client, KeyValues kv)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || IsFakeClient(client))
		return Plugin_Continue;

	// The client sends its Steam group tag ("tag", empty when it has none) on connect
	// and when it changes it. Other cmdkeyvalues have no "tag" key.
	char sTag[32];
	kv.GetString("tag", sTag, sizeof(sTag), "\x01");

#if defined VIPTAG_DEBUG
	char sSection[64], sCurrent[32];
	kv.GetSectionName(sSection, sizeof(sSection));
	if (IsClientInGame(client))
		CS_GetClientClanTag(client, sCurrent, sizeof(sCurrent));
	DebugLog(client, "cmdkeyvalues \"%s\", tag key %s \"%s\", current tag \"%s\"", sSection, sTag[0] == '\x01' ? "missing" : "present", sTag[0] == '\x01' ? "" : sTag, sCurrent);
#endif

	if (sTag[0] == '\x01')
		return Plugin_Continue;

	strcopy(g_sOwnClanTag[client], sizeof(g_sOwnClanTag[]), sTag);

	// The engine applies this tag right after this hook (seen on 24/11/2026: an empty
	// tag wiped the VIP tag set at VIP load), so decide on the next frame.
	RequestFrame(Frame_OwnClanTagChanged, GetClientUserId(client));
	return Plugin_Continue;
}

void Frame_OwnClanTagChanged(int userid)
{
	int client = GetClientOfUserId(userid);
	if (!client || !IsClientInGame(client) || !VIP_IsClientVIP(client))
		return;

	// Their own tag takes over the VIP tag; without one, show the VIP tag again
	if (g_sOwnClanTag[client][0] != '\0')
	{
		if (g_sAppliedVipTag[client][0] != '\0')
			RestoreOwnClanTag(client);
	}
	else if (VIP_IsClientFeatureUse(client, VIP_TAG))
	{
		SetVipTag(client);
	}
}

public void OnClientSettingsChanged(int client)
{
	// The game clears the clan tag on a settings change (seen on 24/11/2026: a name change
	// left an empty tag that CountryTags filled with the country tag): put the VIP tag
	// back once the other plugins are done.
	if (g_sAppliedVipTag[client][0] != '\0' && IsClientInGame(client) && !IsFakeClient(client))
		RequestFrame(Frame_ReapplyVipTag, GetClientUserId(client));
}

void Frame_ReapplyVipTag(int userid)
{
	int client = GetClientOfUserId(userid);
	if (!client || !IsClientInGame(client) || g_sAppliedVipTag[client][0] == '\0')
		return;

	char sCurrent[32];
	CS_GetClientClanTag(client, sCurrent, sizeof(sCurrent));
	if (StrEqual(sCurrent, g_sAppliedVipTag[client]))
		return;

	DebugLog(client, "settings changed, tag \"%s\" replaced the VIP tag", sCurrent);

	if (VIP_IsClientVIP(client) && VIP_IsClientFeatureUse(client, VIP_TAG))
		SetVipTag(client);
	else
		g_sAppliedVipTag[client][0] = '\0';
}

public void OnClientDisconnect(int client)
{
	g_sOwnClanTag[client][0] = '\0';
	g_sAppliedVipTag[client][0] = '\0';
}

void OnClientLateLoad(int client)
{
	// The client only sends its own tag on connect or when it changes it: when it has
	// selected a Steam group (cl_clanid), take the current tag unless it is the VIP tag.
	char sClanID[16], sTag[32];
	g_sOwnClanTag[client][0] = '\0';
	g_sAppliedVipTag[client][0] = '\0';
	GetClientInfo(client, "cl_clanid", sClanID, sizeof(sClanID));
	CS_GetClientClanTag(client, sTag, sizeof(sTag));

	bool bVIP = VIP_IsClientVIP(client);
	// An older instance may have left its VIP tag on the player (up to 1.0.5 tags are not restored on unload)
	bool bLeftoverVipTag = bVIP && IsClientVipTag(client, sTag);

	if (StringToInt(sClanID) != 0 && !bLeftoverVipTag)
		strcopy(g_sOwnClanTag[client], sizeof(g_sOwnClanTag[]), sTag);

	DebugLog(client, "late load, cl_clanid %s, current tag \"%s\", own tag \"%s\"", sClanID, sTag, g_sOwnClanTag[client]);

	if (!bVIP)
		return;

	if (bLeftoverVipTag)
		strcopy(g_sAppliedVipTag[client], sizeof(g_sAppliedVipTag[]), sTag);

	if (VIP_IsClientFeatureUse(client, VIP_TAG))
		SetVipTag(client);
	else if (bLeftoverVipTag)
		RestoreOwnClanTag(client);
}

bool IsClientVipTag(int client, const char[] sTag)
{
	if (sTag[0] == '\0')
		return false;

	char sVipTag[64];
	VIP_GetClientFeatureString(client, VIP_TAG, sVipTag, sizeof(sVipTag));
	return StrEqual(sTag, sVipTag);
}

void SetVipTag(int client)
{
	// The player's own Steam group tag wins over the VIP tag
	if (!IsClientInGame(client) || g_sOwnClanTag[client][0] != '\0')
	{
		DebugLog(client, "VIP tag not set (own tag \"%s\")", g_sOwnClanTag[client]);
		return;
	}

	char sTag[64];
	VIP_GetClientFeatureString(client, VIP_TAG, sTag, sizeof(sTag));
	CS_SetClientClanTag(client, sTag);

	// Read it back: the game truncates clan tags
	CS_GetClientClanTag(client, g_sAppliedVipTag[client], sizeof(g_sAppliedVipTag[]));
	DebugLog(client, "VIP tag set \"%s\"", g_sAppliedVipTag[client]);
}

void RestoreOwnClanTag(int client)
{
	g_sAppliedVipTag[client][0] = '\0';

	if (!IsClientInGame(client))
		return;

	// Empty when the player has no Steam group tag: CountryTags puts its tag back
	CS_SetClientClanTag(client, g_sOwnClanTag[client]);
	DebugLog(client, "own tag restored \"%s\"", g_sOwnClanTag[client]);
}

#if defined VIPTAG_DEBUG
public Action Command_Debug(int client, int args)
{
	if (args < 2)
	{
		ReplyToCommand(client, "[VIP Tag] Usage: sm_viptag_debug <#userid|name> <on|off|status>");
		return Plugin_Handled;
	}

	char sTarget[64], sAction[16];
	GetCmdArg(1, sTarget, sizeof(sTarget));
	GetCmdArg(2, sAction, sizeof(sAction));

	int target = FindTarget(client, sTarget, true, false);
	if (target == -1)
		return Plugin_Handled;

	bool bOn = StrEqual(sAction, "on", false);
	if (bOn || StrEqual(sAction, "off", false))
	{
		// Same callback as the !vip menu, without saving the player's cookie.
		// Unlike the menu, this does not fire VIP_OnFeatureToggle for other plugins.
		bool bDone = VIP_SetClientFeatureStatus(target, VIP_TAG, bOn ? ENABLED : DISABLED, true, false);
		ReplyToCommand(client, "[VIP Tag] %s %N: %s", sAction, target, bDone ? "done" : "no change or no access");
		DebugLog(target, "forced %s by %L: %d", sAction, client, bDone);
	}

	char sClanID[16], sCurrent[32], sVipTag[64];
	GetClientInfo(target, "cl_clanid", sClanID, sizeof(sClanID));
	CS_GetClientClanTag(target, sCurrent, sizeof(sCurrent));
	bool bVIP = VIP_IsClientVIP(target);
	if (bVIP)
		VIP_GetClientFeatureString(target, VIP_TAG, sVipTag, sizeof(sVipTag));

	ReplyToCommand(client, "[VIP Tag] %N: vip %d, status %d, vip tag \"%s\", current \"%s\", own \"%s\", applied \"%s\", cl_clanid %s",
		target, bVIP, bVIP ? view_as<int>(VIP_GetClientFeatureStatus(target, VIP_TAG)) : -1, sVipTag, sCurrent,
		g_sOwnClanTag[target], g_sAppliedVipTag[target], sClanID);
	DebugLog(target, "status: vip %d, vip tag \"%s\", current \"%s\", own \"%s\", applied \"%s\", cl_clanid %s",
		bVIP, sVipTag, sCurrent, g_sOwnClanTag[target], g_sAppliedVipTag[target], sClanID);

	return Plugin_Handled;
}

void DebugLog(int client, const char[] sFormat, any ...)
{
	char sBuffer[256];
	VFormat(sBuffer, sizeof(sBuffer), sFormat, 3);
	LogToFileEx("addons/sourcemod/logs/viptag_debug.log", "%L: %s", client, sBuffer);
}
#else
void DebugLog(int client, const char[] sFormat, any ...)
{
	#pragma unused client
	#pragma unused sFormat
}
#endif
