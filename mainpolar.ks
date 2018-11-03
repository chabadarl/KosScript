
until false {

  if pstbiome = ship:biome {
  wait 10.
  }
  else{

    set pstbiome to ship:biome.
    experiment
    if experimentvalue > 0 {
      until  addons:rt:hasconnection(ship){
        wait 10.
      }

      send experiment
    }

  }

}
