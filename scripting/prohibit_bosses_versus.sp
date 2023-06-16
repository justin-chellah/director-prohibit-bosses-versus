#include <sourcemod>

#define REQUIRE_EXTENSIONS
#include <dhooks>

#define GAMEDATA_FILE	"prohibit_bosses_versus"
#define CHAT_TAG		"[PROHIBIT-BOSSES-VERSUS] "

DynamicDetour g_hDDetour_CDirector_AreBossesProhibited = null;

// #define DEBUG_ARE_BOSSES_PROHIBITED
#if defined DEBUG_ARE_BOSSES_PROHIBITED
Handle g_hSDKCall_CDirector_AreBossesProhibited = null;
Address g_addrTheDirector = Address_Null;
#endif

// Pseudocode:
// void CDirectorVersusMode::AreBossesProhibited( bool *pbAreBossesProhibited )
// {
// 	bool bIsVersusMode = IsVersusMode();

// 	if ( bIsVersusMode )
// 	{
// 		*pbAreBossesProhibited = false;
// 	}

// 	return bIsVersusMode;
// }

// Director won't pass tanks to other players if it's prohibited
public MRESReturn DDetour_CDirector_AreBossesProhibited( Address addrTheDirector, DHookReturn hReturn )
{
	hReturn.Value = false;

	return MRES_Supercede;
}

public MRESReturn DDetour_CDirector_UpdateTankSpawns_Pre( Address addrTheDirector )
{
	g_hDDetour_CDirector_AreBossesProhibited.Enable( Hook_Pre, DDetour_CDirector_AreBossesProhibited );

	return MRES_Ignored;
}

public MRESReturn DDetour_CDirector_UpdateTankSpawns_Post( Address addrTheDirector )
{
	g_hDDetour_CDirector_AreBossesProhibited.Disable( Hook_Pre, DDetour_CDirector_AreBossesProhibited );

	return MRES_Ignored;
}

public MRESReturn DDetour_CDirectorVersusMode_AreBossesProhibited( Address addrTheDirector, DHookReturn hReturn, DHookParam hParams )
{
	hReturn.Value = false;

	return MRES_Supercede;
}

#if defined DEBUG_ARE_BOSSES_PROHIBITED
public Action Command_AreBossesProhibited( int iClient, int nArgs )
{
	if ( g_hSDKCall_CDirector_AreBossesProhibited && g_addrTheDirector )
	{
		bool bResult = SDKCall( g_hSDKCall_CDirector_AreBossesProhibited, g_addrTheDirector );

		ReplyToCommand( iClient, CHAT_TAG ... "CDirector::AreBossesProhibited() = %d", bResult );
	}

	return Plugin_Handled;
}
#endif

public void OnPluginStart()
{
	GameData hGameData = new GameData( GAMEDATA_FILE );

	if ( hGameData == null )
	{
		SetFailState( "Unable to load gamedata file \"" ... GAMEDATA_FILE ... "\"" );
	}

	DynamicDetour hDDetour_CDirector_UpdateTankSpawns = new DynamicDetour( Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_Address );

	if ( !hDDetour_CDirector_UpdateTankSpawns.SetFromConf( hGameData, SDKConf_Signature, "CDirector::UpdateTankSpawns" ) )
	{
		delete hGameData;

		SetFailState( "Unable to find gamedata signature entry for \"CDirector::UpdateTankSpawns\"" );
	}

	hDDetour_CDirector_UpdateTankSpawns.Enable( Hook_Pre, DDetour_CDirector_UpdateTankSpawns_Pre );
	hDDetour_CDirector_UpdateTankSpawns.Enable( Hook_Post, DDetour_CDirector_UpdateTankSpawns_Post );

	DynamicDetour hDDetour_CDirectorVersusMode_AreBossesProhibited = new DynamicDetour( Address_Null, CallConv_THISCALL, ReturnType_Bool, ThisPointer_Address );

	if ( !hDDetour_CDirectorVersusMode_AreBossesProhibited.SetFromConf( hGameData, SDKConf_Signature, "CDirectorVersusMode::AreBossesProhibited" ) )
	{
		delete hGameData;

		SetFailState( "Unable to find gamedata signature entry for \"CDirectorVersusMode::AreBossesProhibited\"" );
	}

	hDDetour_CDirectorVersusMode_AreBossesProhibited.AddParam( HookParamType_Int );
	hDDetour_CDirectorVersusMode_AreBossesProhibited.Enable( Hook_Pre, DDetour_CDirectorVersusMode_AreBossesProhibited );

	g_hDDetour_CDirector_AreBossesProhibited = new DynamicDetour( Address_Null, CallConv_THISCALL, ReturnType_Bool, ThisPointer_Address );

	if ( !g_hDDetour_CDirector_AreBossesProhibited.SetFromConf( hGameData, SDKConf_Signature, "CDirector::AreBossesProhibited" ) )
	{
		delete hGameData;

		SetFailState( "Unable to find gamedata signature entry for \"CDirector::AreBossesProhibited\"" );
	}

#if defined DEBUG_ARE_BOSSES_PROHIBITED
	g_addrTheDirector = hGameData.GetAddress( "CDirector" );

	if ( g_addrTheDirector == Address_Null )
	{
		LogError( "Unable to find address entry or address in binary for \"CDirector\"" );
	}

	StartPrepSDKCall( SDKCall_Raw );
	if ( !PrepSDKCall_SetFromConf( hGameData, SDKConf_Signature, "CDirector::AreBossesProhibited" ) )
	{
		LogError( "Unable to find gamedata signature entry or signature in binary for \"CDirector::AreBossesProhibited\"" );
	}
	else
	{
		PrepSDKCall_SetReturnInfo( SDKType_Bool, SDKPass_Plain );
	}

	g_hSDKCall_CDirector_AreBossesProhibited = EndPrepSDKCall();

	RegConsoleCmd( "sm_arebossesprohibited", Command_AreBossesProhibited );
#endif

	delete hGameData;
}

public Plugin myinfo =
{
	name = "[L4D2] Director \"ProhibitBosses\" for Versus",
	author = "Justin \"Sir Jay\" Chellah",
	description = "Allows level designers to use \"ProhibitBosses\" director key for VScripts as well as \"director_no_bosses\" CVar in Versus mode",
	version = "1.0.0",
	url = "https://justin-chellah.com"
};