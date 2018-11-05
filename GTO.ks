// GTO.ks
// This program launches a ship from the KSC and flies it into orbit

//Flight Parameter

if exist("1:/flightParameters") {
  runpath("1:/flightParameters").
}
else{
  set targetApoapsis to 700000.    //Target apoapsis in meters
  set targetPeriapsis to 100000.   //Target periapsis in meters
  set altStartGT to 10000.        //Altitude to start Gravity Turn
  set targetInclinaison to 0.     // Target Inclinaison  in degree
  set altToNoSteer to 50000.      // altitude where steer =0
  set startTime to time.             // time to start the mission
  set rota to 90.
}

set prevThrust to 0.
set finalTVAL TO 0.
set targetPitch TO 0.
LOCK steering to heading (90-targetInclinaison ,targetPitch)+r(0,0,-rota).
LOCK throttle to finalTVAL.

set main_sequence to list(
  "Prelaunch", lastChance@,
  "Launch", tooLate@,
  "First Climb", toBackOff@,
  "Gravity Turn", theCriticalPart@,
  "Climb", waitingForActualSpace@,
  "Final Burn", lastButNotLeast@,
  "Final Settings", inSpace@
).



set events to lex(
  "Stage Check", Stage_check@,
  "Info Print", printing@,
  "fairingsOut", fairingdecouple@
).

function lastChance{
  parameter mission.

  SAS off.
  RCS on.
  lights off.
  gear off.
  clearscreen.

  //Inialisation of  parameter
  set finalTVAL TO 0.         //No throttle to start with
  set targetPitch TO 90.     //Starting  up
  set TVAL to 0.
  EVE_Staging(FALSE).

  // end of initialisation
  if time:seconds > startTime:seconds mission["next"]().
}

function tooLate{
  parameter mission.

  print "3...".
  wait 1.
  print "2...".
  wait 1.
  print "1...".
  wait 1.
  print "Ignition !".
  if startTime:seconds < time:seconds - 10 set startTime to time.
  set TVAL to 1.               //Throttle up to 100%
  set targetPitch TO 85.
  stage.                           //Same thing as pressing Space-bar
  EVE_Staging(FALSE).
  clearscreen.
  mission["next"]().
  }

function toBackOff{
  parameter mission.
  set TVAL to 1.
  set targetPitch TO 85.
  set rota to max(0,90*(1-alt:radar/5000)).
  if ship:altitude > altStartGT {
  //Once altitude is higher than 10km, go to Gravity Turn mode
  mission["next"]().
  }
}

function theCriticalPart{
  //Gravity turn
  parameter mission.

  set targetPitch to max( 5, 85 * ((1 - (alt:radar-altStartGT) / (altToNoSteer-altStartGT)))^2).            //Pitch over gradually until levelling out to 5 degrees at 50km
  set TVAL to 1.
  if ship:velocity:surface:mag >(100 + 2000*(alt:radar/altToNoSteer)) set TVAL to 0.50.

  if targetPitch = 5  {
    mission["next"]().
  }
}

function waitingForActualSpace{
  //Coast to Ap
  parameter mission.

  set targetPitch to 0. //Stay pointing 3 degrees above horizon
  set TVAL to 0. //Engines off.
  if ship:apoapsis < targetApoapsis  {
    set TVAL to 0.1.
  }
  if ship:apoapsis + 5000 < targetApoapsis  {
    set TVAL to 0.5.
  }
  if ship:apoapsis + 10000 < targetApoapsis  {
    set TVAL to 1.
  }

  if (ship:altitude > 70000) and (verticalspeed > 0) and (TVAL=0) {
    wait 1.  //Wait to make sure the ship is stable
    mission["next"]().
  }
}

function lastButNotLeast{
  //Burn to raise Periapsis
  parameter mission.
  set targetPitch to 0.


  set v1 to sqrt(ship:orbit:body:mu * (2 /(ship:apoapsis +ship:orbit:body:radius)-1/ship:orbit:semimajoraxis)).
  set v2 to sqrt(ship:orbit:body:mu * (2 /(ship:apoapsis +ship:orbit:body:radius)-1/(2*ship:orbit:body:radius+ship:apoapsis+targetPeriapsis))).
  set dv to v2-v1.
  print "dv : "+ round(dv,3) at (5,2).
  print "time to start: "+ round(orb_time4man(v2-v1)/2,1) at (5,3).
  if ( eta:apoapsis < orb_time4man(v2-v1)/2 ) {
    if not warp = 0 set warp to 0.
    set TVAL to min(0.9*orb_time4man(v2-v1), 1).
  } else {
    set TVAL to 0.
    if eta:apoapsis > orb_time4man(v2-v1)/2+200 set warp TO 3. //Be really careful about warping
      else{
        if eta:apoapsis > orb_time4man(v2-v1)/2+100 {set warp TO 2.} //Be really careful about warping
        else{
          if eta:apoapsis > orb_time4man(v2-v1)/2+20 {set warp TO 0.} //Be really careful about warping
        }
      }

  }


  if (ship:periapsis + 10 > targetPeriapsis) or (ship:periapsis > targetApoapsis * 0.98) or (ship:periapsis > 70000 and ship:apoapsis >targetApoapsis * 1.1) {
    //If the periapsis is high enough or getting close to the apoapsis or the apoapsis start to increase too much
    set TVAL to 0.
    clearscreen.
    mission["next"]().
  }
}

function inSpace{
  //Final touches
  parameter mission.

  set TVAL to 0. //Shutdown engine.
  panels on.     //Deploy solar panels
  lights on.     // blop
  EVE_telco().
  unlock steering.
  notify("SHIP SHOULD NOW BE IN SPACE!").
  set ship:control:pilotmainthrottle to 0.
  clearscreen.
  mission["terminate"]().
}

function printing{
  //Print data to screen.
  parameter mission.

  print "RUNMODE    : " + mission["runmode"]() + " : Mission Time : " + (time-startTime) at (5,4).
  print "ALTITUDE   : " + round(ship:altitude) + " m     " at (5,5).
  print "APOAPSIS   : " + round(ship:apoapsis) + " m       (target: " + targetApoapsis + "m)"at (5,6).
  print "PERIAPSIS  : " + round(ship:periapsis) + " m     (target: " + targetPeriapsis + "m)" at (5,7).
  print "ETA TO AP  : " + round(eta:apoapsis) + " s     " at (5,8).
  print "PITCH      : " + round (targetPitch,1) + " °     " at (5,9).
  print "TROTTLE    : " + finalTVAL*100 + " %     " at (5,10).
  print "MAX THRUST : " + round(ship:maxthrust,0) + "/" + round(prevthrust,0) + "  kN    " at (5,11).
  print "VELOCITY   : " + round(ship:velocity:surface:mag,2) + "  m/s     " at (5,12).
  print "MASS       : " + round(ship:mass,2) + " Tons     " at (5,13) .
  print "MAX SPEED  : " + round((100 + 2000*(alt:radar/altToNoSteer)),1)+ " m/s     " at (5,14) .
}

function Stage_check {
  parameter mission.
  EVE_Staging(true).
  lock THROTTLE to finalTVAL.
  set finalTVAL to TVAL.
}

function fairingdecouple{
  parameter mission.
  if EVE_fairdecoup(){
    mission["remove_event"]("fairingsOut").
    mission["add_event"]("PanelsOn",ouvrelespanneaux@).
  }
}

function ouvrelespanneaux{
  parameter mission.
  if ship:altitude > 75000 {
    panels on.
    lights on.

    mission["remove_event"]("PanelsOn").
  }
}


run_mission(main_sequence,events).
