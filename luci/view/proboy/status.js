'use strict';
'require form';
'require view';

return view.extend({
    render: function() {
        var html = '<div class="cbi-section">';
        html += '<h2>Proboy Status</h2>';
        html += '<div class="cbi-section-node">';
        html += '<p>Loading status...</p>';
        html += '<script>';
        html += 'fetch("/cgi-bin/luci-proboy?method=status").then(function(r){return r.json()}).then(function(d){';
        html += 'var h="<table class=\'cbi-section-table\' style=\'width:100%\'>";';
        html += 'h+="<tr><td><b>Zapret</b></td><td>"+(d.zapret?"Running":"Stopped")+"</td></tr>";';
        html += 'h+="<tr><td><b>sing-box</b></td><td>"+(d.singbox?"Running":"Stopped")+"</td></tr>";';
        html += 'h+="<tr><td><b>Game Filter</b></td><td>"+(d.gamefilter?"Enabled":"Disabled")+"</td></tr>";';
        html += 'h+="<tr><td><b>DNS Bypass</b></td><td>"+(d.dns?"Enabled":"Disabled")+"</td></tr>";';
        html += 'h+="<tr><td><b>Strategy</b></td><td>"+d.strategy+"</td></tr>";';
        html += 'h+="</table>";';
        html += 'h+="<br><input type=\'button\' class=\'cbi-button cbi-button-apply\' value=\'Start\' onclick=\'proboyAction("start")\' /> "';
        html += 'h+="<input type=\'button\' class=\'cbi-button cbi-button-reset\' value=\'Stop\' onclick=\'proboyAction("stop")\' /> "';
        html += 'h+="<input type=\'button\' class=\'cbi-button cbi-button-apply\' value=\'Restart\' onclick=\'proboyAction("restart")\' /> "';
        html += 'h+="<br><br><a href=\'http://'+window.location.hostname+':8080/\' target=\'_blank\'>Open Web Panel</a>";';
        html += 'document.querySelector(".cbi-section-node").innerHTML=h;';
        html += '}).catch(function(e){document.querySelector(".cbi-section-node").innerHTML="<p>Error: "+e.message+"</p>";});';
        html += 'function proboyAction(m){fetch("/cgi-bin/luci-proboy?method="+m).then(function(){setTimeout(function(){location.reload()},2000)});}';
        html += '</script>';
        html += '</div></div>';
        return L.dom.create('div', {}, L.dom.parse(html));
    }
});
