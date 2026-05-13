.pragma library

var GH_RELEASES = "https://api.github.com/repos/NeverSinkDev/NeverSink-Filter-for-PoE2/releases/latest"
var GH_ZIPBALL  = "https://api.github.com/repos/NeverSinkDev/NeverSink-Filter-for-PoE2/zipball/"

function checkLatestVersion(callback) {
    var xhr = new XMLHttpRequest()
    xhr.open("GET", GH_RELEASES, true)
    xhr.setRequestHeader("Accept", "application/vnd.github.v3+json")
    xhr.setRequestHeader("User-Agent", "poe2-qs-overlay/1.0")
    xhr.onreadystatechange = function() {
        if (xhr.readyState !== 4) return
        if (xhr.status === 200) {
            try {
                var d = JSON.parse(xhr.responseText)
                callback(null, { tag: d.tag_name, name: d.name })
            } catch(e) {
                callback("Parse error: " + e, null)
            }
        } else {
            callback("HTTP " + xhr.status, null)
        }
    }
    xhr.send()
}

// Returns the detect command as a static array suitable for Process.command binding.
// Scans standard Steam locations + libraryfolders.vdf for custom library paths.
// Call this once at binding time: command: NeverSink.getDetectCmd()
function getDetectCmd() {
    var script =
        "import os\n" +
        "rel = 'pfx/drive_c/users/steamuser/My Documents/My Games/Path of Exile 2'\n" +
        "def chk(b):\n" +
        "    c = os.path.join(b, 'steamapps/compatdata/2694490')\n" +
        "    if os.path.isdir(c): print(os.path.join(c, rel)); return True\n" +
        "    vdf = os.path.join(b, 'steamapps/libraryfolders.vdf')\n" +
        "    if not os.path.isfile(vdf): return False\n" +
        "    for p in open(vdf):\n" +
        "        if '\"path\"' in p:\n" +
        "            ps = p.strip().split('\"')\n" +
        "            if len(ps) > 3:\n" +
        "                c2 = os.path.join(ps[3], 'steamapps/compatdata/2694490')\n" +
        "                if os.path.isdir(c2): print(os.path.join(c2, rel)); return True\n" +
        "    return False\n" +
        "any(chk(os.path.expanduser(b)) for b in ['~/.local/share/Steam','~/.steam/steam','~/.var/app/com.valvesoftware.Steam/data/Steam'])\n"
    return ["python3", "-c", script]
}

// Installs ALL strictness levels for the given style into destPath.
// Style folders in zip: "(STYLE) DARKMODE", "(STYLE) COBALT", etc.
// Writes .neversink-version marker so the overlay can detect installed version on restart.
function buildInstallCmd(tag, style, destPath) {
    var url = GH_ZIPBALL + encodeURIComponent(tag)
    var folder = "(STYLE) " + style
    var script =
        'TMPDIR=$(mktemp -d) && ' +
        'cd "$TMPDIR" && ' +
        'curl -fsSL "' + url + '" -o ns.zip && ' +
        'unzip -q ns.zip && ' +
        'SRCDIR=$(find . -maxdepth 1 -mindepth 1 -type d -not -name ".*" | head -1) && ' +
        '[ -d "$SRCDIR/' + folder + '" ] || { echo "ERR: estilo no encontrado"; exit 1; } && ' +
        'mkdir -p "' + destPath + '" && ' +
        'rm -f "' + destPath + '"/*.filter "' + destPath + '"/.neversink-version && ' +
        'cp "$SRCDIR/' + folder + '"/*.filter "' + destPath + '/" && ' +
        'printf "%s" "' + tag + '" > "' + destPath + '/.neversink-version" && ' +
        'rm -rf "$TMPDIR" && ' +
        'echo OK'
    return ["bash", "-c", script]
}
