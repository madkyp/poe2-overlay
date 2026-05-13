import Quickshell

Singleton {
    PersistentProperties {
        id: store
        restoreId: "poe2overlay-v3"

        property string league:                 "Fate of the Vaal"
        property string poesessid:              ""
        property string buildNotes:             "# Notas de Build\n\n## Skills\n\n## Items necesarios\n\n## Pasivas clave"
        property string filterInstalledVersion: ""
        property string filterStyle:            "DARKMODE"
        property string filterStrictness:       "2-SEMI-STRICT"
        property string filterInstallPath:      ""
    }

    QtObject {
        id: transient
        property bool economyOpen: false
    }

    // If PersistentProperties loaded old data without these keys, they come back
    // as undefined — reset to sensible defaults immediately.
    Component.onCompleted: {
        if (!store.filterInstalledVersion) store.filterInstalledVersion = ""
        if (!store.filterStyle)            store.filterStyle            = "DARKMODE"
        if (!store.filterStrictness)       store.filterStrictness       = "2-SEMI-STRICT"
        if (!store.filterInstallPath)      store.filterInstallPath      = ""
    }

    property alias league:                 store.league
    property alias poesessid:              store.poesessid
    property alias buildNotes:             store.buildNotes
    property alias filterInstalledVersion: store.filterInstalledVersion
    property alias filterStyle:            store.filterStyle
    property alias filterStrictness:       store.filterStrictness
    property alias filterInstallPath:      store.filterInstallPath
    property alias economyOpen:            transient.economyOpen

    function setLeague(name)               { store.league = name }
    function setFilterInstalledVersion(v)  { store.filterInstalledVersion = v }
    function setFilterStyle(v)             { store.filterStyle = v }
    function setFilterStrictness(v)        { store.filterStrictness = v }
    function setFilterInstallPath(v)       { store.filterInstallPath = v }
}
