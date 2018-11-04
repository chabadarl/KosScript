  //boot.ks
clearscreen.

function notify {
  parameter message.
  parameter color is YELLOW.
  hudtext("kOS:" + message, 5, 2, 50, color, false).
}.


function transfert {
  parameter    TransferFile,   // File to transfer
               volumeF,       // Volume to transfer from
               volumeT,      // volume to transfer to
               type.             // 0 : cut on volume; 1: copy

  switch to volumeF.
  set FileExists to exists(TransferFile).
  if volumeT<>volumeF and FileExists {
    switch to volumeT.
    if exists(TransferFile) delete(TransferFile).
    notify(" Transfering : " + TransferFile).
    copypath(volumeF + ":" +TransferFile,volumeF+":"+TransferFile).
  }
  if type=0 and FileExists{
    switch to volumeF.
    delete TransferFile.
  }
  switch to core:volume:name.
  return fileExists.
}

function update {
  if exists("1:/update") {
    notify(" Updating requested by script...").
    runpath ("1:/update").
    deletepath ("1:/update").
  }

  if addons:rt:hasconnection(ship) {
    if not exists("0:/ship/"+ship:name+"/") createdir("0:/ship/"+ship:name+"/").
    if not exists("0:/ship/"+ship:name+"/load/") createdir("0:/ship/"+ship:name+"/load/").
    if not exists("0:/ship/"+ship:name+"/lib/") createdir("0:/ship/"+ship:name+"/lib/").
    if not exists("0:/ship/"+ship:name+"/description") runpath ("0:/descript").

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
          runliblist:add(lib).
          print lib + " is loaded".
        } else {
          notify("WARNING! : " + lib + " doesnot exist.",RED).
        }
      }
    }
    return true.
  }
  else return false.
}

function export {
  if not exists("1:/out/") or not addons:rt:hasconnection(ship) return false.
  //movepath(("1:/out/",("0:/" + ship:name + "/out/"
  cd ("1:/out/").
  list files in outfiles.
  for file in outfiles {
    until not exists("0:/ship/" + ship:name + "/out/" + file + "-" + time:second) {
     wait 0.1.
    }
    movepath(file, "0:/ship/" + ship:name + "/out/" + file + "-" + time:second).
  }
  cd("1:/").
  return true.
}

function getlib{
  parameter lib.
  if not getliblist:contains(lib){
    print "Getting " + lib.
    getliblist:add(lib).
    log "" to glibs.
    deletepath("1:/glibs").
    writejson(getliblist,glibs).
    update().
  }
  if not runliblist:contains(lib) return false.
  return true.
}

function runlib{
  if not exists("1:/lib/") createdir("1:/lib/").
  cd("1:/lib/").
  list files in listfiles.
  for lib in listfiles{
    runoncepath(lib).
    runliblist:add(lib:name).
    print lib:name + " is loaded".
  }
  cd("1:/").
}


//main
notify(" Booting ...").
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
//open terminal at first iteration of the booting process.


// delete temp files that shouldn't be there
//not to be usedful anymore
transfert("tmp.exe.ks",core:volume:name,core:volume:name,0).
transfert("flightplan-" + ship:name,core:volume:name,core:volume:name,0).
transfert("main-" + ship:name,core:volume:name,core:volume:name,0).

//looking for update
update().
export().

//looking for libraries
runlib().


// run main if it exists.
if exists("main") {
  notify(" Running Main ...").
  runpath("1:/main").
}


print "End of boot :"+ time.
set startTime to time.
lock waitTime to time-startTime.
wait TimeToWaitReboot.
wait until addons:rt:hasconnection(ship) or waitTime > TimeToWaitConnection.
reboot.
