
global function listPlayers
global function PawsPlayerMonitor_Init

struct
{
    bool running = false
} file


void function listPlayers()
{
    printt("=====================================")

    array<entity> players = GetPlayerArray()
    int count = 0

    foreach (entity player in players)
    {
        if (!IsValid(player))
            continue

        string decorated = player.GetPlayerNameWithClanTag()
        string uid = GetUID(player)

        printt(decorated + " | " + uid)
        count++
    }

    printt("Total: " + count)
    printt("=====================================")
}


void function PawsPlayerMonitor_Poll()
{
    table<string, string> knownPlayers = {}
    float baselineUntil = Time() + 2.0 //starting interval
    bool initialized = false

    while (true)
    {
        table<string, string> currentPlayers = {}

        foreach (entity player in GetPlayerArray())
        {
            if (!IsValid(player))
                continue

            string uid = GetUID(player)

            if (uid == "0" || uid == "")
                continue

            string decorated = player.GetPlayerNameWithClanTag()

            if (decorated == "")
                continue

            if (uid in currentPlayers)
                continue

            currentPlayers[uid] <- decorated

            if (initialized && !(uid in knownPlayers))
            {
                printt(">>>>>>>> [JOIN] " + decorated + " | " + uid + " <<<<<<<")
            }
        }

        if (initialized)
        {
            foreach (string uid, string name in knownPlayers)
            {
                if (!(uid in currentPlayers))
                {
                    printt("<<<<<<<< [LEAVE] " + name + " | " + uid + " >>>>>>>>")
                }
            }
        }

        knownPlayers = currentPlayers

        if (!initialized && Time() >= baselineUntil)
        {
            initialized = true
            printt("[PlayerMonitor] Ready")
        }

        wait 0.1
    }
}


void function PawsPlayerMonitor_Init()
{
    if (file.running)
        return

    file.running = true

    printt("[PlayerMonitor] Started")

    thread PawsPlayerMonitor_Poll()
}
