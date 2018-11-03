{
  local prevThrust is maxthrust.
  local eve_rota is 0.
  local eve_lastEF is 0.
  local eve_difrota is 1.

  // Check if the ship needs to stage
  set EVE_Staging to {
    parameter AutoStage is true.

    if maxthrust < (prevThrust - 10) {
      if AutoStage{
        set currentthrottle to throttle.
        lock throttle to 0.
        wait 1. stage. wait 1.
        lock throttle to currentThrottle.
      }
      set prevThrust to maxthrust.
      return true.
    }
    if maxthrust > prevThrust{set prevThrust to maxthrust.}
    return false.
  }.

  //Check if the ship can optimize Enlightment
  set EVE_EnlightmentOptim to {
    lock steering to heading(0,ship:latitude)+r(0,0,eve_rota).

    set LMpanel to ship:modulesnamed("ModuleDeployableSolarPanel").
    set EF to 0.
    for Mpanel in LMpanel {
      set EF to EF + Mpanel:getfield("energy flow").
    }
    if eve_lastEF < EF {set eve_rota to mod(eve_rota + eve_difrota,360).}
    else {
      set eve_difrota to -1*eve_difrota.
      set eve_rota to mod(eve_rota + eve_difrota,360).
    }
    set eve_lastEF to EF.
  }.

  //Check if ship can open antenna
  set EVE_telco to{
    function hasAntenna{
      parameter part.
      for m in part:modules{ if m="ModuleRTAntenna" {log "- " + part + " : " + m to "1:/out/eve_log". return true.} }
      return false.
    }
    set antenna to enum["select"](ship:parts,hasAntenna@).

    for ant in antenna {
      if ant:getmodule("ModuleRTAntenna"):getfield("status")="off"{
        ant:getmodule("ModuleRTAntenna"):doevent("activate").
      }
      set i to 0.
      until i > 5 {
          set telco_target to "OmniSat200"+i.
          log "* " + ant + " : " + telco_target to "1:/out/eve_log".
          ant:getmodule("ModuleRTAntenna"):setfield("target",telco_target).
          wait 1.
        if addons:rt:hasconnection(ship) {
          return true.
        }
        set i to i + 1.
      }
    }
  }.

  set EVE_waitDA to{
    parameter vector.
    lock steering TO vector.
    wait until vang(ship:facing:forevector, vector) < 2.
  }.


  set EVE_fairdecoup to {
    if ship:altitude > 0.95 * body:atm:height {
      for module in ship:modulesnamed("moduleproceduralfairing") {
        module:doevent("deploy").
        notify("fairings out").
      }
      for module in ship:modulesnamed("proceduralfairingdecoupler") {
        module:doevent("jettison").
        notify("fairings out").
      }
      return true.
    }.
    return false.
}.

}

//-------------------------------------------------------------------------------------------
//ECU
{
  //-------------------------------------------------------------------------------------------
  function calculateecproduction  {
    local modList is ship:modulesnamed("ec?").
    local ecproduction is 0.
    for mod in modList {
      ecproduction= ecproduction + mod:getfield(“”).
    }
    return ecproduction.
  }

  //-------------------------------------------------------------------------------------------
  function ActivateAntennae {
    local modList is ship:modulesnamed("ModuleRTAntenna").
    local excludeTags is list("", "empty", "none").

    for mod in modList {
     while EClevelOK {
        if mod:hasevent("Activate") and EClevelOK mod:doevent("Activate").
        if mod:hasfield("target") and not excludeTags:contains(mod:part:tag) { mod:setfield("target", mod:part:tag). }
      }
    }
  }

  //-------------------------------------------------------------------------------------------
  function ECcomsommation {
    local ecold is ship:electriccharge.
    wait 0.1.
    local ecnew is ship:electriccharge.
    return 10*(ecnew- ecold).
  }

  //-------------------------------------------------------------------------------------------
  function ECshut{
    notify(“Alerte ! Batteries vides”).
  }

  //-------------------------------------------------------------------------------------------
  function EClevelOK {
    parameter shutdown is false.
    list resources in resourcelist.
    for resource in resourcelist {
      if resource:name = "electriccharge" {
        if resource:amount / resource:capacity > 0.1 and ECcomsommation () > 0 return true.
        notify(“EC level decreasing.”).
        if shutdown and ECcomsommation()<0  and resource:amount / resource:capacity <= 0.1 ECshut.
        return false.
      }
    }
  }

}
//-------------------------------------------------------------------------------------------
//SCI
