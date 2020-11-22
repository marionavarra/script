#!/usr/bin/ruby
require 'net/http'
@log = File.open("/home/mario/Documenti/script/azioni.log","a")
@cambiamenti = false
@log.puts "_________________________"+Time.now.strftime("%d/%m/%Y %H:%M:%S") +"_________________________"
@log.puts "AVVIO PROCEDURA"
@log.puts "______________________________________________________________________"
@access = "http://marionavarra.hostinggratis.it/s/s.php"


def stato_teamviewer
  `ps -fe | grep -i teamviewer | grep -v grep| wc -l`.to_i > 0
end

def stato_tunnel
  `ps -ef | grep "2222:localhost:22 mario@stava.mooo.com"| grep -v grep| wc -l`.to_i >0
end

def stato_dropbox
  `dropbox running ; echo $?`.to_i
end

def stato_motion
  `ps -ef | grep motion|grep -v grep | wc -l`.to_i > 0
end

def stato_cpu
  `top -bn2 | grep '%Cpu' | tail -1 | awk '{ print $9 }'`.to_f
end

def stato_mem
   `free -h| grep Mem:| awk '{ print $7 }'`.to_f
end

def stato_mem
   `free -h| grep Mem:| awk '{ print $7 }'`.to_f
end

def stato_power
  `cat /sys/class/power_supply/AC0/online`.to_i 
end

def stato_temp
 `cat /sys/class/thermal/thermal_zone0/temp`.to_f / 1000 
end
def get_stato
{:tunnel_aperto => stato_tunnel,:teamviewer_attivato => stato_teamviewer,:stato_mem => stato_mem, :stato_cpu => stato_cpu, :stato_power => stato_power, :stato_temp => stato_temp, :dropbox_attivato => stato_dropbox, :motion_attivato => stato_motion}
end

def get_stato_richiesto stato
  url = @access	+ "?tunnel_aperto=" + stato[:tunnel_aperto].to_s + "&teamviewer_attivato=" + stato[:teamviewer_attivato].to_s + "&stato_mem=" +stato[:stato_mem].to_s  + "&stato_cpu=" + stato[:stato_cpu].to_s  + "&stato_power=" + stato[:stato_power].to_s + "&stato_temp=" + stato[:stato_temp].to_s + "&motion_attivato=" + stato[:motion_attivato].to_s + "&stato_dropbox=" + stato[:dropbox_attivato].to_s 
p url
  url = url.gsub(/\n/," ")
#p url
  uri = URI(url)
  req = Net::HTTP::Get.new(url)
  req.basic_auth 'mario', 'stava'
  #p uri.hostname
  res = Net::HTTP.start(uri.hostname, uri.port) {|http|
  http.request(req)
}
  #p res.body
  string_action = res.body
#  string_action = Net::HTTP.get(uri)
  p  string_action
  p ""
  apri_tunnel = string_action.split(",")[0].to_i
  attiva_teamviewer = string_action.split(",")[1].to_i
  attiva_motion = string_action.split(",")[2].to_i
  attiva_dropbox = string_action.split(",")[3].to_i
  eseguire = string_action.split(",")[4]
  comando = string_action.split(",")[5]
  {:apri_tunnel => apri_tunnel,:attiva_teamviewer => attiva_teamviewer,:attiva_motion => attiva_motion,:attiva_dropbox => attiva_dropbox, :eseguire => eseguire, :comando => comando}
end
##Gestione Teamviewer
def gestione_team_viewer stato, stato_richiesto
 if stato[:teamviewer_attivato]
   unless stato_richiesto[:attiva_teamviewer] == 1
     p "disattivo Teamviewer"
     @cambiamenti = true
     @log.puts Time.now.strftime("%d/%m/%Y %H:%M:%S") + "- Disattivo Teamviewer"
     `sudo teamviewer --daemon stop`
   else
     @log.puts Time.now.strftime("%d/%m/%Y %H:%M:%S") + "- Stato Teamviewer OK (attivo)"    
   end
 else
   if stato_richiesto[:attiva_teamviewer] == 1
     @log.puts Time.now.strftime("%d/%m/%Y %H:%M:%S") + "-Avvio Teamviewer"    
     p "Avvio Teamviewer"
     @cambiamenti = true
     `sudo teamviewer --daemon start`
      pid = Process.fork { system "teamviewer&" }
   else
     @log.puts Time.now.strftime("%d/%m/%Y %H:%M:%S") + "- Stato Teamviewer OK (spento)"    
   end
 end
end

##Gestione Tunnel
def gestione_tunnel stato, stato_richiesto
 if stato[:tunnel_aperto]
   unless stato_richiesto[:apri_tunnel] == 1
     p "Chiudo il tunnel"
     @cambiamenti = true
     @log.puts Time.now.strftime("%d/%m/%Y %H:%M:%S") + "- Chiudo il tunnel"
     pid = File.readlines('pid')[0].gsub("\n","")
     #pid = `ps -ef | grep "ruby get_azioni.rb" | grep -v grep | awk '{ print $2 }'`
     `kill #{pid}`
     #`ps -ef | grep #{pid} | awk '{ print $2 }'|xargs kill -1 `
     pid2 = `ps -ef | grep -v grep | grep stava.mooo.com | awk '{ print $2 }'`.gsub("\n","")
     `kill #{pid2}`
     File.write("pid","")
   else
     @log.puts Time.now.strftime("%d/%m/%Y %H:%M:%S") + "- Stato Tunnel OK (aperto)"    
   end
 else
   if stato_richiesto[:apri_tunnel] == 1
     @log.puts Time.now.strftime("%d/%m/%Y %H:%M:%S") + "- Apro il tunnel"
     p "Apro il tunnel" 
     @cambiamenti = true
     #pid = spawn("nohup ssh -R 2222:127.0.0.1:22 stava.mooo.com", :out => "test.out", :err => "test.err")
     pid = Process.fork { system "ssh -o ServerAliveInterval=290 -o ServerAliveCountMax=1 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -N -R 2222:localhost:22 mario@stava.mooo.com" }
     File.write("pid",pid)
     #`nohup ssh -R 2222:127.0.0.1:22 stava.mooo.com`
   else
     @log.puts Time.now.strftime("%d/%m/%Y %H:%M:%S") + "- Stato Tunnel OK (chiuso)"    
   end
 end
end

##Gestione Motion
def gestione_motion stato, stato_richiesto
 if stato[:motion_attivato]
   unless stato_richiesto[:attiva_motion] == 1
     p "disattivo Motion"
     @cambiamenti = true
     @log.puts Time.now.strftime("%d/%m/%Y %H:%M:%S") + "- Disattivo Motion"
     `sudo killall motion`
   else
     @log.puts Time.now.strftime("%d/%m/%Y %H:%M:%S") + "- Stato Motion OK (attivo)"    
   end
 else
   if stato_richiesto[:attiva_motion] == 1
     @log.puts Time.now.strftime("%d/%m/%Y %H:%M:%S") + "-Avvio Motion"    
     p "Avvio Motion"
     @cambiamenti = true
     `sudo motion`
   else
     @log.puts Time.now.strftime("%d/%m/%Y %H:%M:%S") + "- Stato Motion OK (spento)"    
   end
 end
end

##Gestione Dropbox
def gestione_dropbox stato, stato_richiesto
 if stato[:dropbox_attivato] == 1
   unless stato_richiesto[:attiva_dropbox] == 1
     p "disattivo Dropbox"
     @cambiamenti = true
     @log.puts Time.now.strftime("%d/%m/%Y %H:%M:%S") + "- Disattivo Dropbox"
     `dropbox stop`
   else
     @log.puts Time.now.strftime("%d/%m/%Y %H:%M:%S") + "- Stato Dropbox OK (attivo)"    
   end
 else
   if stato_richiesto[:attiva_dropbox] == 1
     @log.puts Time.now.strftime("%d/%m/%Y %H:%M:%S") + "- Avvio Dropbox"    
     p "Avvio Dropbox"
     @cambiamenti = true
     `dropbox start`
   else
     @log.puts Time.now.strftime("%d/%m/%Y %H:%M:%S") + "- Stato Dropbox OK (spento)"    
   end
 end
end

#esecuzione di un comando arbitrario
def esecuzione_comando stato
  comando = stato[:comando].to_s.gsub /\t/, ''
  #risultato = stato[:comando].to_s
  #esito = 0
  risultato = `#{stato[:comando].to_s}`
  esito = `echo $?`
  {:risultato => risultato, :esito => esito}
end
@log.puts  Time.now.strftime("%d/%m/%Y %H:%M:%S") + "- Recupero stato del sistema"
stato = get_stato
@log.puts "Teamviewer attivato: "+stato[:teamviewer_attivato].to_s
@log.puts "Motion attivato: "+stato[:motion_attivato].to_s
@log.puts "Dropbox attivato: "+stato[:dropbox_attivato].to_s
@log.puts "Tunnel aperto: "+stato[:tunnel_aperto].to_s

@log.puts Time.now.strftime("%d/%m/%Y %H:%M:%S") + "- Recupero stato richiesto"
stato_richiesto = get_stato_richiesto stato
@log.puts "Attivare Teamviewer : "+stato_richiesto[:attiva_teamviewer].to_s
@log.puts "Attivare Motion: "+stato_richiesto[:attiva_motion].to_s
@log.puts "Attivare Dropbox: "+stato_richiesto[:attiva_dropbox].to_s
@log.puts "Aprire il Tunnel: "+stato_richiesto[:apri_tunnel].to_s
@log.puts "Comando da eseguire: "+stato_richiesto[:comando].to_s

p stato#[:teamviewer_attivato]
p stato_richiesto

gestione_tunnel stato, stato_richiesto
gestione_team_viewer stato, stato_richiesto
#gestione_motion stato, stato_richiesto
gestione_dropbox stato, stato_richiesto
r = esecuzione_comando stato_richiesto
p r[:risultato]
p r[:esito]
if @cambiamenti
  @log.puts Time.now.strftime("%d/%m/%Y %H:%M:%S") + "- Ci sono stati @cambiamenti => Aggiorno lo stato"    
  get_stato_richiesto get_stato
  @log.puts "_________________________"+Time.now.strftime("%d/%m/%Y %H:%M:%S") +"_________________________"
  @log.puts "FINE PROCEDURA"
  @log.puts "______________________________________________________________________"
end

@log.close

