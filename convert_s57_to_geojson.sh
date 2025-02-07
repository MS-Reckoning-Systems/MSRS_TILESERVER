# mkdir -p ~/Downloads/geojson_output

# for dir in ~/Downloads/ENC_ROOT/*/; do
#     latest_enc=$(ls -v "$dir"/*.??? | tail -n 1)  # Get the latest ENC file
#     base_name=$(basename "$latest_enc" .000)
#     echo "Processing latest ENC file: $latest_enc..."
    
#     for layer in DEPARE DEPCNT LNDARE SOUNDG WRECKS LIGHTS BCNLAT BOYLAT FAIRWY M_COVR; do
#         echo "Extracting $layer from $base_name..."
#         ogr2ogr -f GeoJSON ~/Downloads/geojson_output/"$base_name"_"$layer".json "$latest_enc" "$layer"
#     done
# done

#!/bin/bash

#!/bin/bash
rm -rf ~/Downloads/geojson_output
mkdir -p ~/Downloads/geojson_output

# Function to retrieve layer information dynamically
get_layer_info() {
    case "$1" in
        "BCNLAT") echo "false|Point|Lateral beacon used for navigation" ;;
        "BCNSPP") echo "false|Point|Special purpose beacon, may indicate hazards or guidance" ;;
        "BRIDGE") echo "false|Polyline|Bridges crossing waterways" ;;
        "BUISGL") echo "false|Polyline|Building silhouette used for navigation" ;;
        "BUAARE") echo "false|Polygon|Built-up areas indicating towns and populated places" ;;
        "BOYLAT") echo "true|Point|Lateral buoy as part of the channel marking system" ;;
        "BOYSAW") echo "true|Point|Safe water buoy, marking deep water or channel entrances" ;;
        "BOYSPP") echo "true|Point|Special purpose buoy, often marking underwater hazards" ;;
        "CBLARE") echo "false|Polygon|Cable area indicating underwater cables" ;;
        "CBLOHD") echo "false|Polyline|Overhead cable crossing navigable waters" ;;
        "CBLSUB") echo "false|Polyline|Submarine cable (electrical, telecom, etc.)" ;;
        "CTNARE") echo "false|Polygon|Caution area indicating hazards or restrictions" ;;
        "COALNE") echo "false|Polyline|Coastline marking the boundary between land and sea" ;;
        "DAYMAR") echo "true|Point|Daymark, a fixed navigation aid visible in daylight" ;;
        "DEPARE") echo "false|Polygon|Depth area, showing different depth zones" ;;
        "DEPCNT") echo "false|Polyline|Depth contour indicating underwater depth changes" ;;
        "DRGARE") echo "false|Polygon|Dredged area for safe passage of ships" ;;
        "FAIRWY") echo "false|Polygon|Officially designated navigation route" ;;
        "FERYRT") echo "false|Polyline|Ferry route showing regular crossings" ;;
        "FSHFAC") echo "false|Polygon|Fishing facility such as aquaculture areas" ;;
        "FOGSIG") echo "false|Point|Fog signal, an audible navigation aid" ;;
        "LAKARE") echo "false|Polygon|Lake area, showing significant inland water bodies" ;;
        "LNDARE") echo "false|Polygon|Land area, marking solid land masses" ;;
        "LNDRGN") echo "false|Polygon|Land region, specifying land types or usage" ;;
        "LNDMRK") echo "false|Point|Landmark, a recognizable structure for navigation" ;;
        "LIGHTS") echo "false|Point|Lighthouse or navigational light" ;;
        "MAGVAR") echo "false|Point|Magnetic variation for compass correction" ;;
        "MARCUL") echo "false|Polygon|Marine culture area such as fish farms" ;;
        "MIPARE") echo "false|Polygon|Military practice area" ;;
        "MORFAC") echo "false|Point|Mooring facility for docking vessels" ;;
        "OBSTRN") echo "false|Point|Obstruction such as underwater rocks" ;;
        "OFSPLF") echo "false|Polygon|Offshore platform (oil rigs, research stations)" ;;
        "PILPNT") echo "false|Point|Pilot boarding point for maritime pilots" ;;
        "PONTON") echo "false|Polygon|Floating pontoon used for docking" ;;
        "RESARE") echo "false|Polygon|Restricted area limiting vessel movement" ;;
        "RIVERS") echo "false|Polyline|Rivers for inland navigation" ;;
        "SEAARE") echo "false|Polygon|Sea area designated for specific use" ;;
        "SBDARE") echo "false|Polygon|Seabed area providing underwater terrain info" ;;
        "SLCONS") echo "false|Polygon|Sealing construction such as dikes and sea walls" ;;
        "SILTNK") echo "false|Polygon|Silos or tanks, often for oil storage" ;;
        "SOUNDG") echo "false|3D MultiPoint|Soundings, representing underwater depth measurements" ;;
        "UWTROC") echo "false|Point|Underwater rock, a hazard for vessels" ;;
        "WRECKS") echo "false|Point|Wrecked ship, indicating submerged wrecks" ;;
        "M_COVR") echo "false|Polygon|Metadata coverage defining ENC data boundaries" ;;
        "M_NPUB") echo "false|Polygon|Metadata for nautical publications" ;;
        "M_NSYS") echo "false|Polygon|Metadata for navigation systems" ;;
        "M_QUAL") echo "false|Polygon|Metadata describing ENC data quality" ;;
        *) echo "false|Unknown|Unknown layer, skipping" ;;  # Default case for unknown layers
    esac
}

# Find the latest .000 ENC file in each subfolder
for dir in ~/Downloads/ENC_ROOT/*/; do
    latest_enc=$(ls -v "$dir"/*.000 2>/dev/null | tail -n 1)  # Get the latest ENC file
    if [[ -z "$latest_enc" ]]; then
        echo "⚠️ No .000 ENC file found in $dir, skipping..."
        continue
    fi

    base_name=$(basename "$latest_enc" .000)
    echo "📂 Processing latest ENC file: $latest_enc..."

    # Get valid named layers (excluding metadata)
    layers=$(ogrinfo -ro -q "$latest_enc" | awk -F: '{print $2}' | grep -v "DSID")

    for layer in $layers; do
        # Get layer info dynamically
        layer_info=$(get_layer_info "$layer")
        IFS='|' read enabled geometry description <<< "${layer_info}"

        # Process only enabled layers
        if [[ "$enabled" == "true" ]]; then
            geojson_file=~/Downloads/geojson_output/"$base_name"_"$layer".json
            echo "✅ Extracting ($geometry): $layer - $description"

            # Run ogr2ogr to extract the layer
            ogr2ogr -f GeoJSON "$geojson_file" "$latest_enc" "$layer" 2>/dev/null

            # Remove empty files
            if [ -s "$geojson_file" ]; then
                echo "✅ Successfully extracted: $layer"
            else
                echo "🚫 Empty layer: $layer, removing file"
                rm -f "$geojson_file"
            fi
        else
            echo "❌ Skipping disabled layer: $layer"
        fi
    done
done

# 🚀 **Post-Processing Steps**
echo "🔄 Merging extracted GeoJSON files into a single file..."
rm -f ~/Downloads/merged_enc.json
ogrmerge.py -single -overwrite_ds -f GeoJSON -o ~/Downloads/merged_enc.json ~/Downloads/geojson_output/*.json

if [ -f ~/Downloads/merged_enc.json ]; then
    echo "✅ Merged GeoJSON file created: ~/Downloads/merged_enc.json"
else
    echo "❌ Failed to create merged GeoJSON file!"
    exit 1
fi

# 🚀 **Convert Merged GeoJSON to MBTiles using Tippecanoe**
echo "🔄 Converting merged GeoJSON to MBTiles..."
rm -f ~/Downloads/enc.mbtiles


TIPPECANOE_CMD="tippecanoe -o ~/Downloads/enc.mbtiles -z19 -Z1 --force"

# Add dynamically detected layers to Tippecanoe
for geojson_file in ~/Downloads/geojson_output/*.json; do
    layer_name=$(basename "$geojson_file" | cut -d'_' -f2 | cut -d'.' -f1)  # Extract layer name
    TIPPECANOE_CMD+=" -L \"$layer_name:$geojson_file\""
done

# Execute the command
eval $TIPPECANOE_CMD

if [ -f ~/Downloads/enc.mbtiles ]; then
    echo "✅ MBTiles file successfully created: ~/Downloads/enc.mbtiles"
else
    echo "❌ Failed to create MBTiles file!"
    exit 1
fi

# 🚀 **Move & Replace MBTiles File**
rm -f /Users/andrewhumphrey/Github_Repos/MSRS_TILESERVER/enc.mbtiles
echo "🚀 Moving MBTiles to /Users/andrewhumphrey/Github_Repos/MSRS_TILESERVER..."
mv -f ~/Downloads/enc.mbtiles /Users/andrewhumphrey/Github_Repos/MSRS_TILESERVER/

if [ -f /Users/andrewhumphrey/Github_Repos/MSRS_TILESERVER/enc.mbtiles ]; then
    echo "✅ MBTiles file successfully moved!"
else
    echo "❌ Failed to move MBTiles file!"
    exit 1
fi

echo "🎉 All steps completed successfully! 🎉"