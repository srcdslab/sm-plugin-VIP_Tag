#pragma semicolon 1

#include <sourcemod>
#include <cstrike>
#include <vip_core>

#pragma newdecls required

public Plugin myinfo =
{
	name = "[VIP] Tag",
	author = "R1KO, maxime1907",
	description = "Gives a default VIP tag to VIPs",
	version = "1.0",
	url = ""
};

#define VIP_TAG		"Tag"

public void VIP_OnVIPLoaded()
{
	VIP_RegisterFeature(VIP_TAG, STRING, TOGGLABLE, OnToggleItem);
}

public Action OnToggleItem(int client, const char[] sFeatureName, VIP_ToggleState OldStatus, VIP_ToggleState &NewStatus)
{
	if (NewStatus == ENABLED)
		SetVipTag(client);
	else if (OldStatus != NO_ACCESS)
		CS_SetClientClanTag(client, "");
	return Plugin_Continue;
}

public void VIP_OnVIPClientLoaded(int client)
{
	if (VIP_IsClientFeatureUse(client, VIP_TAG))
		SetVipTag(client);
}

public void SetVipTag(int client)
{
	char sTag[64];
	VIP_GetClientFeatureString(client, VIP_TAG, sTag, sizeof(sTag));
	CS_SetClientClanTag(client, sTag);
}