  //boot.ks
clearscreen.
function notify {
  parameter message.
  hudtext("kOS:" + message, 5, 2, 50, YELLOW, false).
}.
function update {
  if addons:rt:hasconnection(ship) {
    if not exists("0:/"+ship:name+"/") createdir("0:/ship/"+ship:name+"/").
    if not exists("0:/ship/"+ship:name+"/load/") createdir("0:/ship/"+ship:name+"/load/").
    if not exists("0:/ship/"+ship:name+"/lib/") createdir("0:/ship/"+ship:name+"/lib/").
    if not exists("0:/ship/"+ship:name+"/description") runpath ("0:/ship/descript").
    if exists("0:/ship/"+ship:name+ "/update") {
      notify(" Updating from KSC...").
      runpath ("0:/ship/"+ship:name+"/update").
      deletepath ("0:/ship/"+ship:name+"/update").
    }
    if exists("0:/ship/"+ship:name+"/load/"){
      cd("0:/ship/"+ship:name+"/load/").
      list files in load.
      if load:length > 0 {
        notify(" Loading ...").
        for file in load {
          print file:name.
          copypath(file:name,"1:/").
          movepath(file:name,"../").
        }
      }
    }
    for lib in getliblist {
      if not exists("1:/lib/"+lib) {
        if exists("0:/librairies/"+lib){
          copypath("0:/librairies/"+lib,"1:/lib/"+lib).
          copypath("0:/librairies/"+lib,"0:/ship/"+ship:name+"/lib/"+lib).
          runoncepath("1:/lib/"+lib).
          runliblist:add(file).
        } else {
          notify("WARNING! : " + lib + " doesnot exist.",RED).
        }
      }
    }
    return true.
  }
  else return false.
}
function getlib{
  parameter lib.
  if not getliblist:contains(lib){
    getliblist:add(lib).
    log "" to glibs.
    delete(glibs).
    writejson(getliblist,glibs).
  }
  if not runliblist:contains(lib) return false.
  return true.
}
function runlib{
  if not exists("1:/lib/") createdir("1:/lib/").
  cd("1:/lib/").
  list files in listfiles.
  for file in listfiles{
    runoncepath(file).
    runliblist:add(file).
  }
  cd("1:/").
}
//main
if sessiontime < 5 core:doevent("open terminal").
set TimeToWaitConnection to 1000.
set TimeToWaitReboot to 10.
set glibs to "1:/glibs".
if not exists(glibs) {
  set getliblist to UniqueSet().
  writejson(getliblist,glibs).
  }
else set getliblist to readjson(glibs).
set runliblist to UniqueSet().
update().
runlib().
print runliblist.
print "libraries loaded".
if exists("main") {
  notify(" Running Main ...").
  runpath("1:/main").
}
print time.
set startTime to time.
lock waitTime to time-startTime.
wait TimeToWaitReboot.
wait until addons:rt:hasconnection(ship) or waitTime > TimeToWaitConnection.
reboot.
