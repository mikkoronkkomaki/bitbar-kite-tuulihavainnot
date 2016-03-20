#!/bin/bash

# Hakee viimeisimmän tuuliennusteen valitulta havaintoasemalta FMI:n julkisen API:n kautta
#
# Mikko Rönkkömäki (mikko.ronkkomaki@gmail.com)

# metadata
# <bitbar.title>Oulu Kite</bitbar.title>
# <bitbar.version>v0.1</bitbar.version>
# <bitbar.author>Mikko Rönkkömäki</bitbar.author>
# <bitbar.image>http://i.imgur.com/y1SZwfq.png</bitbar.image>

asematunnus="101794"

if [ "$1" != '' ]; then
  asematunnus=$1
fi

data=$(curl -sL 'http://data.fmi.fi/fmi-apikey/55d44f5f-70e8-4d88-9d5e-ee083dcd0ca3/wfs?request=getFeature&storedquery_id=fmi::observations::weather::simple&fmisid='$asematunnus'&parameters=windspeedms,winddirection,windGust,temperature')
lampotila=$(xmllint --format --xpath "//*[local-name()='FeatureCollection']/*[local-name()='member'][last()]/*[local-name()='BsWfsElement']/*[local-name()='ParameterValue']/text()" - <<<"$data")
tuulenNopeus=$(xmllint --format --xpath "(//*[local-name()='FeatureCollection']/*[local-name()='member'][*[local-name()='BsWfsElement']/*[local-name()='ParameterName']='windspeedms'])[last()]/*[local-name()='BsWfsElement']/*[local-name()='ParameterValue']/text()" - <<<"$data")
puuskat=$(xmllint --format --xpath "(//*[local-name()='FeatureCollection']/*[local-name()='member'][*[local-name()='BsWfsElement']/*[local-name()='ParameterName']='windGust'])[last()]/*[local-name()='BsWfsElement']/*[local-name()='ParameterValue']/text()" - <<<"$data")
tuulenSuuntaAste=$(xmllint --format --xpath "(//*[local-name()='FeatureCollection']/*[local-name()='member'][*[local-name()='BsWfsElement']/*[local-name()='ParameterName']='winddirection'])[last()]/*[local-name()='BsWfsElement']/*[local-name()='ParameterValue']/text()" - <<<"$data")
puuskienErotus=$(echo "$puuskat - $tuulenNopeus" | bc -l)
tuulenSuunta=""
sisalto=""

# koilinen
if (( $(echo "$tuulenSuuntaAste >= 22.5" |bc -l) )) && (( $(echo "$tuulenSuuntaAste <= 67.5" |bc -l) )); then
  tuulenSuunta="↙"
fi

# itä
if (( $(echo "$tuulenSuuntaAste >= 67.5" |bc -l) )) && (( $(echo "$tuulenSuuntaAste <= 112.5" |bc -l) )); then
  tuulenSuunta="←"
fi

# kaakko
if (( $(echo "$tuulenSuuntaAste >= 112.5" |bc -l) )) && (( $(echo "$tuulenSuuntaAste <= 157.5" |bc -l) )); then
  tuulenSuunta="↖"
fi

# etelä
if (( $(echo "$tuulenSuuntaAste >= 157.5" |bc -l) )) && (( $(echo "$tuulenSuuntaAste <= 202.5" |bc -l) )); then
  tuulenSuunta="↑"
fi

# lounas
if (( $(echo "$tuulenSuuntaAste >= 202.5" |bc -l) )) && (( $(echo "$tuulenSuuntaAste <= 247.5" |bc -l) )); then
  tuulenSuunta="↗"
fi

# länsi
if (( $(echo "$tuulenSuuntaAste >= 247.5" |bc -l) )) && (( $(echo "$tuulenSuuntaAste <= 292.5" |bc -l) )); then
  tuulenSuunta="→"
fi

# luode
if (( $(echo "$tuulenSuuntaAste >= 292.5" |bc -l) )) && (( $(echo "$tuulenSuuntaAste <= 337.5" |bc -l) )); then
  tuulenSuunta="↘"
fi

# pohjoinen
if (( $(echo "$tuulenSuuntaAste >= 337.5" |bc -l) )) || (( $(echo "$tuulenSuuntaAste <= 22.5" |bc -l) )); then
  tuulenSuunta="↓"
fi

sisalto="$tuulenSuunta $tuulenNopeus/$puuskat $lampotila"


if (( $(echo "$tuulenNopeus >= 6" |bc -l) )) && (( $(echo "$tuulenNopeus <= 12" |bc -l) )) && (( $(echo "$puuskienErotus < 3.5" |bc -l) )); then
  sisalto="✅ $sisalto | color=#80ff00"
fi

if (( $(echo "$tuulenNopeus > 12" |bc -l) )); then
  sisalto="⚠️ $sisalto | color=#ff8000"
fi

if (( $(echo "$tuulenNopeus > 6" |bc -l) )) &&  (( $(echo "$puuskienErotus > 3.5" |bc -l) )); then
  sisalto="⚠️ $sisalto | color=ff8000"
fi

if (( $(echo "$tuulenNopeus > 15" |bc -l) )); then
  sisalto="⛔ $sisalto | color=#ff1a1a"
fi

echo $sisalto
echo "---"
echo "Oulu Vihreäsaari | bash=$0 param1=101794 terminal=false"
echo "Hailuoto Marjaniemi | bash=$0 param1=101784 terminal=false"
echo "Oulunsalo Pellonpää | bash=$0 param1=101799 terminal=false"
echo "Raahe Lapaluoto | bash=$0 param1=100540 terminal=false"
echo "---"
echo "Avaa mittari| href=http://windmeter.laivuri.net/#kite-oulu/"