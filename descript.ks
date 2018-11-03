
{
  runoncepath("0:/librairies/ENU").

  log "" to "0:/desc".
  enum["each"](ship:parts,printAllMod@).
  movepath("0:/desc","0:/ship/" + ship:name + "/description").


  function printAllMod{
    parameter part.
    set p to part.
    log "" to "0:/desc".
    log "----"+part:name+"----" to "0:/desc".

    enum["each"](part:modules,printmodule@).
  }

  function printmodule{
    parameter m.
    set mod to p:getmodule(m).
    //log "" to "0:/desc".
    log "- " + mod:name to "0:/desc".
    set i to 0.
    if not mod:allfields:empty log (" fields : " +  mod:name + ":") to "0:/desc".
    for  field in mod:allfields { log "   " + field to "0:/desc".}

    if not mod:allevents:empty log (" events: " +  mod:name + ":") to "0:/desc".
    for  event in mod:allevents { log "   " + event to "0:/desc".}

    if not mod:allactions:empty <> 0  log (" actions  " +  mod:name + ":") to "0:/desc".
    for  action in mod:allactions { log "   " + action to "0:/desc".}

  }
}
