
//


function fli_circulization {
  parameter altitudetarget,
            marginerror,
            autostage.

  // initialisation of operator check if dv is enough and put ship in known config

  if ship:apoapsis < altitudetarget - marginerror {
    // create operation to push periapsis to altitudetarget
    if not fli_pushperiapsis(altitudetarget,marginerror,autostage){
      set positioncirculaire to 1.
      return false.
    }
  }
  if ship:apoapsis < altitudetarget + marginerror and ship:periapsis < altitudetarget - marginerror  {
    // create operation to push periapsis to altitudetarget
    if not fli_pushperiapsis(altitudetarget,marginerror,autostage){
      set positioncirculaire to 2.
      return false.
    }
  }else {
    if ship:periapsis < altitudetarget - marginerror  {
      // create operation to push periapsis to altitudetarget
      if not fli_pushperiapsis(altitudetarget,marginerror,autostage){
        set positioncirculaire to 3.
        return false.
      }
    }else if ship:periapsis > altitudetarget - marginerror  {
      // create operation to pull periapsis to altitudetarget
      if not fli_pushperiapsis(altitudetarget,marginerror,autostage){
        set positioncirculaire to 4.
        return false.
      }
    }
    // create operation to pull apoapsis to altitudetarget
    if fli_pushapoapsis(altitudetarget,marginerror,autostage){
      set positioncirculaire to 5.
      return false.
    }
  }
  return true.
}

function fli_pushperiapsis {
  parameter altitudetarget,
            marginerror,
            autostage.
  set v1 to sqrt(ship:orbit:body:mu * (2 /(ship:apoapsis +ship:orbit:body:radius)-1/ship:orbit:semimajoraxis)).
  set v2 to sqrt(ship:orbit:body:mu * (2 /(ship:apoapsis +ship:orbit:body:radius)-1/(2*ship:orbit:body:radius+ship:apoapsis+altitudetarget))).
  set mynode to node(time:seconds+eta:apoapsis,0,0,v2-v1).
  fli_executenode(mynode,autostage).
}

function fli_pushapoapsis {
  parameter altitudetarget,
            marginerror,
            autostage.
  set v1 to sqrt(ship:orbit:body:mu * (2 /(ship:periapsis +ship:orbit:body:radius)-1/ship:orbit:semimajoraxis)).
  set v2 to sqrt(ship:orbit:body:mu * (2 /(ship:periapsis +ship:orbit:body:radius)-1/(2*ship:orbit:body:radius+ship:periapsis+altitudetarget))).
  set mynode to node(time:seconds+eta:periapsis,0,0,v2-v1).
  fli_executenode(mynode,autostage).
}

function fli_synchronizeorbit {
  parameter targetsynchro,
            anglesynchro,
            altitudesyncro.
  if marginangle=0 {set marginangle to 0.1.}
  if marginerror=0 {set marginerror to 1.}

  set syncro to true.

  if altitude > altitudesyncro+marginerror
    or altitude < altitudesyncro+marginerror
    or orb_diffang(shipname,targetsynchro) > anglesynchro + marginangle
    or orb_diffang(shipname,targetsynchro) < anglesynchro - marginangle {
    set syncro to false.
  }

  if not syncro {
    set targetorb to orbitable(targetsynchro).
    set angletostart to mod(anglesynchro-2*constant:pi*sqrt((2*body:radius+altitude+targetorb:altitude)^3/mu)+360,360).
    set startangle to orb_diffang(shipname,targetsynchro).
    set syncro to true.
    set starttime to time.

    if orb_diffang(shipname,targetsynchro) >= angletostart + marginangle
      or orb_diffang(shipname,targetsynchro) <= angletostart - marginangle {
      set v1 to sqrt(ship:orbit:body:mu * (2 /(ship:periapsis + ship:orbit:body:radius)-1/ship:orbit:semimajoraxis)).
      set v2 to sqrt(ship:orbit:body:mu * (2 /(ship:periapsis + ship:orbit:body:radius)-1/(2*ship:orbit:body:radius + ship:periapsis + targetorb:altitude))).
      set mynode to node(time:seconds + 30,0,0,v2-v1).
      fli_executenode(mynode,true).
    }
  }
}​​

function fli_executenode {
 parameter mynode,
          autostage.
 if mynode:istype("node") {
               set n to mynode.
 } else{
   set n to nextnode.
 }

 set v to n:burnvector.
 set starttime to time:seconds + n:eta - orb_time4man(v:mag)/2.

  if  n:eta - orb_time4man(v:mag)/2 < 60 {
   set actualsteer to steering.
   lock steering to n:burnvector.
   man_staging(false).

    until vdot(n:burnvector, v) < 0 {
       man_staging(autostage).
       lock throttle to min(0.9*orb_time4man(n:burnvector:mag), 1).
     }
   lock throttle to 0.
   lock steering to actualsteer.
   return true.
  }
 return false.
}
