//boot.ks
clearscreen.


function notify {
  parameter message.
  hudtext("kOS:" + message, 5, 2, 50, YELLOW, false).
}.

function transfert {
  parameter    TransferFile,   // File to transfer
               volumeF,       // Volume to transfer from
               volumeT,      // volume to transfer to
               type.             // 0 : transfer and delete on volume; 1: transfert without deleting;

  switch to volumeF.
  set FileExists to exists(TransferFile).
  if volumeT<>volumeF and FileExists {
    switch to volumeT.
    if exists(TransferFile) delete(TransferFile).
    notify(" Transfering : " + TransferFile).
    copy TransferFile from volumeF.
  }
  if type=0 and FileExists{
    switch to volumeF.
    delete TransferFile.
  }
  switch to core:volume:name.
  return fileExists.
}

//main
notify(" Booting ...").
if sessiontime < 5 ship:modulesnamed("kOSProcessor")[0]:doevent("open terminal").

set TimeToWaitConnection to 1000.
set TimeToWaitReboot to 10.

// delete temp files that shouldn't be there
transfert("tmp.exe.ks",core:volume:name,core:volume:name,0).
transfert("updatefile",core:volume:name,core:volume:name,0).
transfert("update-" + ship:name,core:volume:name,core:volume:name,0).
transfert("flightplan-" + ship:name,core:volume:name,core:volume:name,0).
transfert("main-" + ship:name,core:volume:name,core:volume:name,0).
transfert("descript",core:volume:name,core:volume:name,0).

//looking for update
if addons:rt:hasconnection(ship) {
  if transfert("update-" + ship:name,0,core:volume:name,0) {
  notify(" Updating ...").

  rename "update-" + ship:name to updatefile.
  run updatefile.
  delete updatefile.
  }
}
//looking for libraries
if exists("ENU") run once ENU.
if exists("EVE") run once EVE.
if exists("FLI") run once FLI.
if exists("MRS") run once MRS.
if exists("ORB") run once ORB.
if exists("SCI") run once SCI.



// run main if it exists.
if exists("main") {
  notify(" Running Main ...").
  run main.
}


print time.
set startTime to time.
lock waitTime to time-startTime.
wait TimeToWaitReboot.
wait until addons:rt:hasconnection(ship) or waitTime > TimeToWaitConnection.
reboot.
