
/// if GTO still exist run it to takeoff


Notify(SHIP:STATUS).
if SHIP:STATUS ="PRELAUNCH"{
  if transfert("flightplan",1,1,1) {
    run flightplan.
    delete "flightplan".
  }
}

if SHIP:STATUS ="ORBITING" or SHIP:STATUS ="ESCAPING" {

}
