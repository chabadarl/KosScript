
//-------------------------------------------------------------------------------------------
//SCI
  {
  local goalexperiment is lexicon().
  local specificexperiment is lexicon().
  local modList is ship:modulesnamed("modulescienceexperiment").
  //goalexperiment:add("Mystery goo in space","").
  //goalexperiment:add("La premiere experiment tentée par mystery goo <>0pts",enum[“select”]( ship:modulesnamed("modulescienceexperiment"),{parameter mod. return mod:part:title="Mystery Goo"}.)[0]).
  //-------------------------------------------------------------------------------------------

  //-------------------------------------------------------------------------------------------
  function sci_doscience(){
    parameter experiment.
    if specificexperiment:haskey(experiment) {
      set experimentMod to ship:modulesnamed(experiment).
      for exp in experimentMod {
        ant:getmodule("scansat"):doevent(specificexperiment[experiment]).
      }
      return true.
    }
    return false.
  }

  //-------------------------------------------------------------------------------------------
  function addspecificexperiment {
    parameter modname,action.
    specificexperiment:add(modname,action).
  }

  //-------------------------------------------------------------------------------------------
  function addgoalexperiment {
    parameter title,mod is "".
    goalexperiment:add(title,mod).
  }

  //-------------------------------------------------------------------------------------------
  function sciencemodule {
    parameter mod.
    if not mod:hasdata {
      mod:deploy().
      wait until mod:hasdata.
      notify("Experiment done : "  + mod:data:title).
    }
    if mod:data[0]:sciencevalue = 0 {
      mod:reset.
      notify("Experiment reset (no value). ")
    }
  }

  //-------------------------------------------------------------------------------------------
  function sciencetraitement {
    parameter mod.
    parameter transmit is true.

    if  mod:hasdata and mod:rerunnable and mod:sciencevalue = mod:transmitvalue and transmit and EClevelOK {
        notify("Transmitting data now.").
       log mod:data  to "1:/out/sciencetransmitted").
       mod:transmit().
      } else {
        if goalexperiment:haskey(mod:data[0]:title) and goalexperiment[mod: data[0]:title]= "" set goalexperiment[mod: data[0]:title] to mod.
        if not goalexperiment:hasvalue(mod)  mod:reset().
      }
    }
  }

  //-------------------------------------------------------------------------------------------
  function scienceall {
   enum[“each”]( modList, sciencemodule@).
    enum[“each”](scienceparts, sciencetraitement@).
  }

}
