#!/bin/bash

# Hakee viimeisimmän tuuliennusteetn Vihreäsaaren havaintoasemalta FMI:n julkisen API:n kautta
#
# Mikko Rönkkömäki (mikko.ronkkomaki@gmail.com)

# metadata
# <bitbar.title>Oulu Kite</bitbar.title>
# <bitbar.version>v0.1</bitbar.version>
# <bitbar.author>Mikko Rönkkömäki</bitbar.author>
# <bitbar.image>http://i.imgur.com/y1SZwfq.png</bitbar.image>
# XPATH jolla saa viimeisen elementin, joka mätsää listaan (//wfs:FeatureCollection/wfs:member[BsWfs:BsWfsElement/BsWfs:ParameterName = 'windspeedms'])[last()]/BsWfs:BsWfsElement/BsWfs:ParameterValue/text()

data=$(curl -sL 'http://data.fmi.fi/fmi-apikey/55d44f5f-70e8-4d88-9d5e-ee083dcd0ca3/wfs?request=getFeature&storedquery_id=fmi::observations::weather::simple&fmisid=101794&parameters=windspeedms,winddirection,windGust,temperature')
lampotila=$(xmllint --format --xpath "//*[local-name()='FeatureCollection']/*[local-name()='member'][last()]/*[local-name()='BsWfsElement']/*[local-name()='ParameterValue']/text()" - <<<"$data")
tuulenNopeus=$(xmllint --format --xpath "(//*[local-name()='FeatureCollection']/*[local-name()='member'][*[local-name()='BsWfsElement']/*[local-name()='ParameterName']='windspeedms'])[last()]/*[local-name()='BsWfsElement']/*[local-name()='ParameterValue']/text()" - <<<"$data")
puuskat=$(xmllint --format --xpath "(//*[local-name()='FeatureCollection']/*[local-name()='member'][*[local-name()='BsWfsElement']/*[local-name()='ParameterName']='windGust'])[last()]/*[local-name()='BsWfsElement']/*[local-name()='ParameterValue']/text()" - <<<"$data")
tuulenSuuntaAste=$(xmllint --format --xpath "(//*[local-name()='FeatureCollection']/*[local-name()='member'][*[local-name()='BsWfsElement']/*[local-name()='ParameterName']='winddirection'])[last()]/*[local-name()='BsWfsElement']/*[local-name()='ParameterValue']/text()" - <<<"$data")
tuulenSuunta=""


if (( $(echo "$tuulenSuuntaAste >= 22.5" |bc -l) )) && (( $(echo "$tuulenSuuntaAste <= 67.5" |bc -l) )); then
  tuulenSuunta="koilinen"
fi

if (( $(echo "$tuulenSuuntaAste >= 67.5" |bc -l) )) && (( $(echo "$tuulenSuuntaAste <= 112.5" |bc -l) )); then
  tuulenSuunta="itä"
fi

if (( $(echo "$tuulenSuuntaAste >= 112.5" |bc -l) )) && (( $(echo "$tuulenSuuntaAste <= 157.5" |bc -l) )); then
  tuulenSuunta="kaakko"
fi

if (( $(echo "$tuulenSuuntaAste >= 157.5" |bc -l) )) && (( $(echo "$tuulenSuuntaAste <= 202.5" |bc -l) )); then
  tuulenSuunta="etelä"
fi

if (( $(echo "$tuulenSuuntaAste >= 202.5" |bc -l) )) && (( $(echo "$tuulenSuuntaAste <= 247.5" |bc -l) )); then
  tuulenSuunta="lounas"
fi

if (( $(echo "$tuulenSuuntaAste >= 247.5" |bc -l) )) && (( $(echo "$tuulenSuuntaAste <= 292.5" |bc -l) )); then
  tuulenSuunta="länsi"
fi

if (( $(echo "$tuulenSuuntaAste >= 292.5" |bc -l) )) && (( $(echo "$tuulenSuuntaAste <= 337.5" |bc -l) )); then
  tuulenSuunta="luode"
fi

if (( $(echo "$tuulenSuuntaAste >= 337.5" |bc -l) )) || (( $(echo "$tuulenSuuntaAste <= 22.5" |bc -l) )); then
  tuulenSuunta="pohjoinen"
fi

echo "$tuulenNopeus / $puuskat ($tuulenSuunta) $lampotila "
echo "---"
echo "Avaa mittari | href=http://windmeter.laivuri.net/#kite-oulu/"