#pragma semicolon 1

#include <sourcemod>
#include <cstrike>
#include <vip_core>

#pragma newdecls required

#define VIP_TAG		"Tag"

char g_sOriginalClanTag[MAXPLAYERS + 1][32];

public Plugin myinfo =
{
	name = "[VIP] Tag",
	author = "R1KO, maxime1907",
	description = "Gives a default VIP tag to VIPs",
	version = "1.0.1",
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

public void OnClientConnected(int client)
{
	if (IsFakeClient(client))
		return;

	// Store original clan tag
	CS_GetClientClanTag(client, g_sOriginalClanTag[client], sizeof(g_sOriginalClanTag[]));
}

public void OnClientSettingsChanged(int client)
{
	if (!IsClientInGame(client) || IsFakeClient(client))
		return;

	// Update original clan tag
	CS_GetClientClanTag(client, g_sOriginalClanTag[client], sizeof(g_sOriginalClanTag[]));
}

public void OnClientDisconnect(int client)
{
	g_sOriginalClanTag[client] = "\0";
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
	char sTag[64];
	VIP_GetClientFeatureString(client, VIP_TAG, sTag, sizeof(sTag));
	CS_SetClientClanTag(client, sTag);
}

public void RestoreOriginalClanTag(int client)
{
	CS_SetClientClanTag(client, g_sOriginalClanTag[client]);
}
