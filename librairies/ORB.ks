

function orbitable {
  parameter named.
  list targets in vessels.
  for vs in vessels {
    if vs:name = named {
      return vs.
    }
  }
  return body(named).
}

function orb_diffang{
 parameter orbital1,
           orbital2.
 return mod(orbital1:longitude-orbital2:longitude+360,360).
}

// time to complete a maneuver
function orb_time4man {
  parameter dv.
  local ens is list().
  ens:clear.
  local ens_thrust is 0.
  local ens_isp is 0.
  list engines in myengines.

  for en in myengines {
    if en:ignition = true and en:flameout = false {
      ens:add(en).
    }
  }
  set ens_thrust to 0.
  set ens_isp to 0.

  for en in ens {
    set ens_thrust to ens_thrust + en:availablethrust.
    set ens_isp to ens_isp + en:isp.
  }



  if ens_thrust = 0 or ens_isp = 0 {
    notify("no engines available!").
    return 0.
  }
  else {
    local f is ens_thrust * 1000.  // engine thrust (kg * m/s²)
    local m is ship:mass * 1000.        // starting mass (kg)
    local e is constant():e.            // base of natural log
    local p is ens_isp/ens:length.               // engine isp (s) support to average different isp values
    local g is ship:orbit:body:mu/ship:obt:body:radius^2.    // gravitational acceleration constant (m/s²)
    return g * m * p * (1 - e^(-dv/(g*p))) / f.
  }
}
