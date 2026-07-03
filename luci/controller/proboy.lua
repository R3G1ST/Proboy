module("luci.controller.proboy", package.seeall)

function index()
    entry({"admin", "services", "proboy"}, alias("admin", "services", "proboy", "status"), _("Proboy"), 90)
    entry({"admin", "services", "proboy", "status"}, template("proboy/status"), _("Dashboard"), 1)
    entry({"admin", "services", "proboy", "zapret"}, template("proboy/zapret"), _("Zapret"), 2)
    entry({"admin", "services", "proboy", "games"}, template("proboy/games"), _("Games"), 3)
    entry({"admin", "services", "proboy", "network"}, template("proboy/network"), _("Network"), 4)
    entry({"admin", "services", "proboy", "subs"}, template("proboy/subs"), _("Subscriptions"), 5)
    entry({"admin", "services", "proboy", "settings"}, template("proboy/settings"), _("Settings"), 6)

    entry({"admin", "services", "proboy", "action"}, call("proboy_action"), nil).leaf = true
end

function proboy_action()
    local method = luci.http.formvalue("method") or ""
    local result = {}

    if method == "start" then
        os.execute("/etc/init.d/proboy start >/dev/null 2>&1")
        result.ok = true
        result.message = "Proboy started"
    elseif method == "stop" then
        os.execute("/etc/init.d/proboy stop >/dev/null 2>&1")
        result.ok = true
        result.message = "Proboy stopped"
    elseif method == "restart" then
        os.execute("/etc/init.d/proboy restart >/dev/null 2>&1")
        result.ok = true
        result.message = "Proboy restarted"
    elseif method == "status" then
        result = get_status()
    else
        result.error = "Unknown method"
    end

    luci.http.prepare_content("application/json")
    luci.http.write_json(result)
end

function get_status()
    local status = {
        running = false,
        zapret = false,
        singbox = false,
        gamefilter = false,
        dns = false,
        strategy = "auto",
        dns_provider = "cloudflare",
        version = "unknown"
    }

    -- Read config
    local conf = io.open("/etc/proboy/proboy.conf", "r")
    if conf then
        for line in conf:lines() do
            local k, v = line:match("^(%w+)%s*=%s*(.+)$")
            if k == "enabled" then status.enabled = (v == "1")
            elseif k == "zapret_strategy" then status.strategy = v
            elseif k == "dns_provider" then status.dns_provider = v
            elseif k == "gamefilter_enabled" then status.gamefilter = (v == "1")
            elseif k == "dns_enabled" then status.dns = (v == "1")
            end
        end
        conf:close()
    end

    -- Check zapret PID
    local pf = io.open("/var/run/proboy/zapret.pid", "r")
    if pf then
        local pid = pf:read("*l")
        pf:close()
        if pid and pid ~= "" then
            local ret = os.execute("kill -0 " .. pid .. " 2>/dev/null")
            if ret == 0 then status.zapret = true; status.running = true end
        end
    end

    -- Check singbox PID
    local sf = io.open("/var/run/proboy/singbox.pid", "r")
    if sf then
        local pid = sf:read("*l")
        sf:close()
        if pid and pid ~= "" then
            local ret = os.execute("kill -0 " .. pid .. " 2>/dev/null")
            if ret == 0 then status.singbox = true; status.running = true end
        end
    end

    -- Get version
    local vf = io.open("/opt/proboy/VERSION", "r")
    if vf then
        status.version = vf:read("*l") or "unknown"
        vf:close()
    end

    return status
end
