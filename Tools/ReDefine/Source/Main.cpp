#include "FOClassic/Ini.h"

#include "ReDefine.h"

int main( int argc, char** argv )
{
    int result = EXIT_SUCCESS;

    std::setvbuf( stdout, NULL, _IONBF, 0 );

    ReDefine* redefine = new ReDefine();

    redefine->LOG( "ReDefine <3 FO1@2" );
    redefine->LOG( " " );

    //
    // Init() / Finish() can be called at any point to completely reset object
    //
    // Init() recreates all internals and removes all log files
    // Finish() does cleanup only; called by Init() and destructor
    //
    redefine->Init();

    const std::string config = "ReDefine.cfg";
    const std::string section = "ReDefine";

    //
    // load config
    // config can be either loaded from ini-like file,
    // or set "manually" if application is storing configuration in different format
    //
    // in both cases it has to be done before any ReadConfig*() call(s), which parses ReDefine::Config content without touching any files
    //
    if( redefine->Config->LoadFile( config ) )
    {
        // read directories
        const std::string headers = redefine->Config->GetStr( section, "ScriptsDir" );     // TODO HeadersDir
        const std::string scripts = redefine->Config->GetStr( section, "ScriptsDir" );

        //
        // validate config and convert settings to internal structures
        //
        // sections can be loaded separetely by either calling ReadConfig() changing unwanted sections names to empty strings,
        // or calling related function only (ReadConfigDefines() / ReadConfigVariables() / ReadConfigFunctions())
        //
        // defines section needs to be processed before other settings
        //
        if( redefine->ReadConfig( "Defines", "Variable", "Function" ) )
        {
            // unload config
            // added here to make sure Process*() functions are independent o ReadConfig*()
            redefine->Config->Unload();

            // process headers
            //
            redefine->ProcessHeaders( headers );

            // process scripts
            //
            redefine->ProcessScripts( scripts, true );
        }
        else
        {
            redefine->Status.Current.File = config;
            redefine->WARNING( nullptr, "cannot parse config" );
            result = EXIT_FAILURE;
        }
    }
    else
    {
        redefine->Status.Current.File = config;
        redefine->WARNING( nullptr, "cannot read config" );
        result = EXIT_FAILURE;
    }

    // cleanup
    delete redefine;

    return result;
}
