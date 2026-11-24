#pragma semicolon 1

#include <sourcemod>
#include <cstrike>
#include <vip_core>

#pragma newdecls required

#define VIP_TAG		"Tag"

char g_sOriginalClanTag[MAXPLAYERS + 1][32];
// VIP tag we applied, as the game stores it (empty when none is applied)
char g_sAppliedVipTag[MAXPLAYERS + 1][32];

public Plugin myinfo =
{
	name = "[VIP] Tag",
	author = "R1KO, maxime1907",
	description = "Gives a default VIP tag to VIPs",
	version = "1.0.5",
	url = ""
};

public void VIP_OnVIPLoaded()
{
	VIP_RegisterFeature(VIP_TAG, STRING, TOGGLABLE, OnToggleItem);
}

public Action OnToggleItem(int client, const char[] sFeatureName, VIP_ToggleState OldStatus, VIP_ToggleState &NewStatus)
{
	// If disabling VIP tag, restore original clan tag
	if (OldStatus == ENABLED && NewStatus != ENABLED)
		RestoreOriginalClanTag(client);
	else if (NewStatus == ENABLED)
		SetVipTag(client);

	return Plugin_Continue;
}

public void OnClientPutInServer(int client)
{
	if (IsFakeClient(client))
		return;

	// Store original clan tag
	g_sAppliedVipTag[client][0] = '\0';
	CS_GetClientClanTag(client, g_sOriginalClanTag[client], sizeof(g_sOriginalClanTag[]));

	// VIP can be loaded before the client is in game (e.g. VIP_Test grants it on auth),
	// in which case SetVipTag skipped it: apply it now.
	if (VIP_IsClientVIP(client) && VIP_IsClientFeatureUse(client, VIP_TAG))
		SetVipTag(client);
}

public void OnClientSettingsChanged(int client)
{
	if (!IsClientInGame(client) || IsFakeClient(client))
		return;

	char sCurrentTag[32];
	CS_GetClientClanTag(client, sCurrentTag, sizeof(sCurrentTag));

	// Still our VIP tag: it is not the player's own clan tag, keep the stored one.
	// Storing it made the toggle "restore" the VIP tag, so it could never be disabled.
	if (g_sAppliedVipTag[client][0] != '\0' && StrEqual(sCurrentTag, g_sAppliedVipTag[client]))
		return;

	// Update original clan tag
	strcopy(g_sOriginalClanTag[client], sizeof(g_sOriginalClanTag[]), sCurrentTag);
	g_sAppliedVipTag[client][0] = '\0';
}

public void OnClientDisconnect(int client)
{
	g_sOriginalClanTag[client] = "\0";
	g_sAppliedVipTag[client] = "\0";
}

public void VIP_OnVIPClientLoaded(int client)
{
	if (VIP_IsClientFeatureUse(client, VIP_TAG))
		SetVipTag(client);
	else
		RestoreOriginalClanTag(client);
}

public void SetVipTag(int client)
{
	if (!IsClientInGame(client) || g_sOriginalClanTag[client][0] != '\0')
		return;

	char sTag[64];
	VIP_GetClientFeatureString(client, VIP_TAG, sTag, sizeof(sTag));
	CS_SetClientClanTag(client, sTag);

	// Read it back: the game truncates clan tags, compare against what it really holds
	CS_GetClientClanTag(client, g_sAppliedVipTag[client], sizeof(g_sAppliedVipTag[]));
}

public void RestoreOriginalClanTag(int client)
{
	if (!IsClientInGame(client))
		return;

	CS_SetClientClanTag(client, g_sOriginalClanTag[client]);
	g_sAppliedVipTag[client][0] = '\0';
}
