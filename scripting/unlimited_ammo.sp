#include <sourcemod>
#include <sdktools>

public Plugin myinfo =
{
	name = "Unlimited Ammo",
	author = "Roy (Christian Deacon) and Franc1sco",
	description = "Unlimited ammo plugin for CS:S/CS:GO and possibly other games.",
	version = "1.0.0",
	url = "GFLClan.com"
};

ConVar g_cvMethod = null;
int g_iMethod;

public void OnPluginStart()
{
	/* ConVars */
	g_cvMethod = CreateConVar("sm_ua_method", "0", "0 = use weapon reload and fire on empty event to add ammo, 1 = add extra ammo on weapon fire.");
	HookConVarChange(g_cvMethod, ConVarChanged);
	
	/* Events */
	HookEvent("weapon_reload", Event_WeaponReload);
	HookEvent("weapon_fire_on_empty", Event_WeaponFireOnEmpty);
	HookEvent("weapon_fire", Event_WeaponFire);
	
	AutoExecConfig(true, "plugin.unlimitedammo");
}

public void ConVarChanged(Handle hCVar, const char[] sOldV, const char[] sNewV)
{
	OnConfigsExecuted();
}

public void OnConfigsExecuted()
{
	g_iMethod = GetConVarInt(g_cvMethod);
}

public Action Event_WeaponReload(Handle hEvent, const char[] sName, bool bDontBroadcast)
{
	if (g_iMethod != 0)
	{
		return Plugin_Continue;
	}
	
	int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	
	AddAmmo(iClient);
	
	return Plugin_Continue;
}

public Action Event_WeaponFireOnEmpty(Handle hEvent, const char[] sName, bool bDontBroadcast)
{	
	int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	
	AddAmmo(iClient);
	
	return Plugin_Continue;
}

public Action Event_WeaponFire(Handle hEvent, const char[] sName, bool bDontBroadcast)
{
	if (g_iMethod != 1)
	{
		return Plugin_Continue;
	}
	
	int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	
	if (IsClientInGame(iClient))
	{
		int iCurAmmo = GetReserveAmmo(iClient);
		
		SetReserveAmmo(iClient, iCurAmmo + 1);
	}
	
	return Plugin_Continue;
}

public bool AddAmmo(int iClient)
{
	if (!IsClientInGame(iClient))
	{
		return false;
	}
	
	int iCurAmmo = GetReserveAmmo(iClient);
	
	if (iCurAmmo < 101)
	{
		SetReserveAmmo(iClient, iCurAmmo + 100);
	}
	
	return true;
}

/* I got these stock functions from https://forums.alliedmods.net/showpost.php?p=2278113&postcount=2 */
stock int GetReserveAmmo(int iClient)
{
	int iWep = GetEntPropEnt(iClient, Prop_Data, "m_hActiveWeapon");

	if(iWep < 1) 
	{
		return -1;
	}

	int  iAmmoType = GetEntProp(iWep, Prop_Send, "m_iPrimaryAmmoType");

	if(iAmmoType == -1) 
	{
		return -1;
	}

	return GetEntProp(iClient, Prop_Send, "m_iAmmo", _, iAmmoType);
}

stock void SetReserveAmmo(int iClient, int iAmmo)
{
	int iWep = GetEntPropEnt(iClient, Prop_Data, "m_hActiveWeapon");

	if(iWep < 1) 
	{
		return;
	}

	int iAmmoType = GetEntProp(iWep, Prop_Send, "m_iPrimaryAmmoType");

	if(iAmmoType == -1) 
	{
		return;
	}

	SetEntProp(iClient, Prop_Send, "m_iAmmo", iAmmo, _, iAmmoType);
}  