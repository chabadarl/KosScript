//Satnet- '

set satNet to list(
// nom    , reference, altitude, angle
"OmniSat0","OmniSat0", 1585176,  0,
"OmniSat1","OmniSat0", 1585176,  60,
"OmniSat2","OmniSat0", 1585176,  120,
"OmniSat3","OmniSat0", 1585176,  180,
"OmniSat4","OmniSat0", 1585176,  240,
"OmniSat5","OmniSat0", 1585176,  300).

set sat to 0.
set isInSatNet to False.

until sat =satNet:length{
  if SHIP:NAME = SatNet[sat]{
   set satNetRef to SatNet[sat+1].
   set satNetAltitude to SatNet[sat+2].
   set satNetAngle toSatNet[sat+3].
   set isInSatNet to true.
   BREAK.
  }
  set sat to sat+4.
 }
