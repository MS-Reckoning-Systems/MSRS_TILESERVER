#!/bin/bash

rm -rf ~/Downloads/geojson_output
mkdir -p ~/Downloads/geojson_output

# Function to retrieve layer information dynamically
get_layer_info() {
    case "$1" in
        "BCNLAT") echo "false|Point|Lateral beacon used for navigation" ;;
        "BCNSPP") echo "false|Point|Special purpose beacon, may indicate hazards or guidance" ;;
        "BRIDGE") echo "false|Polyline|Bridges crossing waterways|1|15" ;;
        "BUISGL") echo "false|Polyline|Building silhouette used for navigation|1|15" ;;
        "BUAARE") echo "false|Polygon|Built-up areas indicating towns and populated places|1|15" ;;
        "BOYLAT") echo "true|Point|Lateral buoy as part of the channel marking system|1|16" ;;
        "BOYSAW") echo "true|Point|Safe water buoy, marking deep water or channel entrances|1|16" ;;
        "BOYSPP") echo "true|Point|Special purpose buoy, often marking underwater hazards|1|16" ;;
        "CBLARE") echo "false|Polygon|Cable area indicating underwater cables|1|15" ;;
        "CBLOHD") echo "false|Polyline|Overhead cable crossing navigable waters|1|15" ;;
        "CBLSUB") echo "false|Polyline|Submarine cable (electrical, telecom, etc.)|1|15" ;;
        "CTNARE") echo "false|Polygon|Caution area indicating hazards or restrictions|1|15" ;;
        "COALNE") echo "false|Polyline|Coastline marking the boundary between land and sea|1|15" ;;
        "DAYMAR") echo "true|Point|Daymark, a fixed navigation aid visible in daylight|1|16" ;;
        "DEPARE") echo "false|Polygon|Depth area, showing different depth zones|1|15" ;;
        "DEPCNT") echo "false|Polyline|Depth contour indicating underwater depth changes|1|15" ;;
        "DRGARE") echo "false|Polygon|Dredged area for safe passage of ships|1|15" ;;
        "FAIRWY") echo "false|Polygon|Officially designated navigation route|1|15" ;;
        "FERYRT") echo "false|Polyline|Ferry route showing regular crossings|1|15" ;;
        "FSHFAC") echo "false|Polygon|Fishing facility such as aquaculture areas|1|15" ;;
        "FOGSIG") echo "false|Point|Fog signal, an audible navigation aid|1|15" ;;
        "LAKARE") echo "false|Polygon|Lake area, showing significant inland water bodies|1|15" ;;
        "LNDARE") echo "false|Polygon|Land area, marking solid land masses|1|15" ;;
        "LNDRGN") echo "false|Polygon|Land region, specifying land types or usage|1|15" ;;
        "LNDMRK") echo "false|Point|Landmark, a recognizable structure for navigation|1|15" ;;
        "LIGHTS") echo "false|Point|Lighthouse or navigational light|1|15" ;;
        "MAGVAR") echo "false|Point|Magnetic variation for compass correction|1|15" ;;
        "MARCUL") echo "false|Polygon|Marine culture area such as fish farms|1|15" ;;
        "MIPARE") echo "false|Polygon|Military practice area|1|15" ;;
        "MORFAC") echo "false|Point|Mooring facility for docking vessels|1|15" ;;
        "OBSTRN") echo "false|Point|Obstruction such as underwater rocks|1|15" ;;
        "OFSPLF") echo "false|Polygon|Offshore platform (oil rigs, research stations)|1|15" ;;
        "PILPNT") echo "false|Point|Pilot boarding point for maritime pilots|1|15" ;;
        "PONTON") echo "false|Polygon|Floating pontoon used for docking|1|15" ;;
        "RESARE") echo "false|Polygon|Restricted area limiting vessel movement|1|15" ;;
        "RIVERS") echo "false|Polyline|Rivers for inland navigation|1|15" ;;
        "SEAARE") echo "false|Polygon|Sea area designated for specific use|1|15" ;;
        "SBDARE") echo "false|Polygon|Seabed area providing underwater terrain info|1|15" ;;
        "SLCONS") echo "false|Polygon|Sealing construction such as dikes and sea walls|1|15" ;;
        "SILTNK") echo "false|Polygon|Silos or tanks, often for oil storage|1|15" ;;
        "SOUNDG") echo "true|3D MultiPoint|Soundings, representing underwater depth measurements|18|19" ;;
        "UWTROC") echo "false|Point|Underwater rock, a hazard for vessels|1|15" ;;
        "WRECKS") echo "false|Point|Wrecked ship, indicating submerged wrecks|1|15" ;;
        "M_COVR") echo "false|Polygon|Metadata coverage defining ENC data boundaries|1|15" ;;
        "M_NPUB") echo "false|Polygon|Metadata for nautical publications|1|15" ;;
        "M_NSYS") echo "false|Polygon|Metadata for navigation systems|1|15" ;;
        "M_QUAL") echo "false|Polygon|Metadata describing ENC data quality|1|15" ;;
        *) echo "false|Unknown|Unknown layer, skipping" ;;  # Default case for unknown layers
    esac
}

# # Find the latest .000 ENC file in each subfolder
# for dir in ~/Downloads/ENC_ROOT/*/; do
#     latest_enc=$(ls -v "$dir"/*.000 2>/dev/null | tail -n 1)  # Get the latest ENC file
#     if [[ -z "$latest_enc" ]]; then
#         echo "⚠️ No .000 ENC file found in $dir, skipping..."
#         continue
#     fi

#     base_name=$(basename "$latest_enc" .000)
#     echo "📂 Processing latest ENC file: $latest_enc..."

#     # Get valid named layers (excluding metadata)
#     layers=$(ogrinfo -ro -q "$latest_enc" | awk -F: '{print $2}' | grep -v "DSID")

#     for layer in $layers; do
#         # Get layer info dynamically
#         layer_info=$(get_layer_info "$layer")
#         IFS='|' read enabled geometry description <<< "${layer_info}"

#         # Process only enabled layers
#         if [[ "$enabled" == "true" ]]; then
#             geojson_file=~/Downloads/geojson_output/"$base_name"_"$layer".json
#             echo "✅ Extracting ($geometry): $layer - $description"

#             # Run ogr2ogr to extract the layer
#             ogr2ogr -f GeoJSON "$geojson_file" "$latest_enc" "$layer" 2>/dev/null

#             # Remove empty files
#             if [ -s "$geojson_file" ]; then
#                 echo "✅ Successfully extracted: $layer"
#             else
#                 echo "🚫 Empty layer: $layer, removing file"
#                 rm -f "$geojson_file"
#             fi
#         else
#             echo "❌ Skipping disabled layer: $layer"
#         fi
#     done
# done

# # Define directories
# RAW_JSON_DIR=~/Downloads/geojson_output
# LAYER_TMP_DIR=~/Downloads/tmp_layers
# MERGED_JSON_DIR=~/Downloads/merged_json_layers

# # Create directories
# mkdir -p "$LAYER_TMP_DIR"
# mkdir -p "$MERGED_JSON_DIR"

# echo "🔄 Organizing files into layer folders..."

# # Step 1: Organize JSON files into separate folders by layer
# for geojson_file in "$RAW_JSON_DIR"/*.json; do
#     layer_name=$(basename "$geojson_file" | cut -d'_' -f2 | cut -d'.' -f1)
#     mkdir -p "$LAYER_TMP_DIR/$layer_name"
#     cp "$geojson_file" "$LAYER_TMP_DIR/$layer_name/"
# done

# echo "✅ Files organized into per-layer folders."

# # Function to merge two JSON files safely
# merge_two_json() {
#     local file1="$1"
#     local file2="$2"
#     local output="$3"

#     # Validate JSON before merging
#     if ! jq empty "$file1" 2>/dev/null; then
#         echo "❌ Skipping invalid JSON: $file1" >> invalid_files.log
#         return
#     fi
#     if ! jq empty "$file2" 2>/dev/null; then
#         echo "❌ Skipping invalid JSON: $file2" >> invalid_files.log
#         return
#     fi

#     # Merge JSON files
#     jq -s '.[0].features += .[1].features | .[0]' "$file1" "$file2" > "$output"

#     # Log if merge fails
#     if [[ $? -ne 0 ]]; then
#         echo "❌ Merge failed for $file1 and $file2" >> merge_errors.log
#     fi
# }

# export -f merge_two_json

# # Step 2: Merge files within each layer folder using a bracket-style approach
# echo "🔄 Starting bracket-style merging per layer..."

# for layer in "$LAYER_TMP_DIR"/*; do
#     layer_name=$(basename "$layer")
#     echo "🔹 Processing layer: $layer_name"

#     # Collect JSON files for this layer
#     json_files=("$layer"/*.json)

#     # If only one file exists, move it to final directory
#     if [[ ${#json_files[@]} -eq 1 ]]; then
#         mv "${json_files[0]}" "$MERGED_JSON_DIR/${layer_name}.json"
#         echo "✅ Only one file in layer $layer_name, moved to final result."
#         continue
#     fi

#     round=1
#     while [[ ${#json_files[@]} -gt 1 ]]; do
#         echo "  🔄 Round $round - ${#json_files[@]} files in layer $layer_name..."
#         new_round_files=()
        
#         for ((i=0; i<${#json_files[@]}; i+=2)); do
#             file1="${json_files[i]}"
#             file2="${json_files[i+1]}"
            
#             if [[ -z "$file2" ]]; then
#                 # If odd number of files, push last file to next round
#                 new_round_files+=("$file1")
#                 continue
#             fi

#             output_file="$layer/merge_round_${round}_${i}.json"
#             merge_two_json "$file1" "$file2" "$output_file" &
#             new_round_files+=("$output_file")
#         done

#         # Wait for all background merges to complete
#         wait

#         json_files=("${new_round_files[@]}")
#         ((round++))
#     done

#     # Move final merged file to destination
#     mv "${json_files[0]}" "$MERGED_JSON_DIR/${layer_name}.json"
#     echo "✅ Layer $layer_name merged successfully!"
# done

echo "🏆 All layers merged! Final outputs in $MERGED_JSON_DIR"
echo "❗ Check invalid_files.log and merge_errors.log for any issues."

echo "🔄 Processing GeoJSON files to remove third-dimension coordinates..."
python3 process_geojson.py

if [ $? -eq 0 ]; then
    echo "✅ Successfully processed all GeoJSON files!"
else
    echo "❌ Failed to process GeoJSON files!"
    exit 1
fi

# Define directories
MERGED_JSON_DIR=~/Downloads/merged_json_layers
MBTILES_DIR=~/Downloads/mbtiles_per_layer

# Ensure MBTiles directory exists
mkdir -p "$MBTILES_DIR"

echo "🔄 Creating MBTiles files from merged GeoJSON layers..."

for master_json in "$MERGED_JSON_DIR"/*.json; do
    layer_name=$(basename "$master_json" .json)
    output_file="$MBTILES_DIR/$layer_name.mbtiles"

    echo "Processing layer: $layer_name..."

    # Get min/max zoom levels dynamically
    layer_info=$(get_layer_info "$layer_name")
    IFS='|' read enabled geometry description min_zoom max_zoom <<< "${layer_info}"

    # Skip disabled layers
    if [[ "$enabled" != "true" ]]; then
        echo "❌ Skipping disabled layer: $layer_name"
        continue
    fi

    # Run Tippecanoe with dynamic zoom levels
    if tippecanoe -o "$output_file" --maximum-tile-features=10000000 --maximum-tile-bytes=99999999999999 -z6 -L "$layer_name:$master_json" --name="$layer_name"; then
        echo "✅ Successfully created: $output_file"
    else
        echo "❌ Failed to create MBTiles for layer: $layer_name" >> mbtiles_errors.log
    fi
done

echo "✅ All layers processed! MBTiles saved in: $MBTILES_DIR"
echo "❗ Check mbtiles_errors.log for any failed conversions."

# 🚀 Define source and destination directories
MBTILES_SOURCE=~/Downloads/mbtiles_per_layer
MBTILES_DEST=/Users/andrewhumphrey/Github_Repos/MSRS_TILESERVER/data

# Ensure destination directory exists
mkdir -p "$MBTILES_DEST"

echo "🚀 Moving MBTiles files to $MBTILES_DEST..."

# Loop through each MBTiles file in the source directory
for file in "$MBTILES_SOURCE"/*.mbtiles; do
    filename=$(basename "$file")  # Extract the file name

    # Check if the file already exists in the destination
    if [ -f "$MBTILES_DEST/$filename" ]; then
        echo "🔄 Replacing existing file: $filename"
        rm -f "$MBTILES_DEST/$filename"
    fi

    # Move the file to the destination
    mv -f "$file" "$MBTILES_DEST/"
    echo "✅ Moved: $filename"
done

# Verify if files moved successfully
if ls "$MBTILES_DEST"/*.mbtiles 1> /dev/null 2>&1; then
    echo "✅ MBTiles files successfully updated in $MBTILES_DEST!"
else
    echo "❌ No MBTiles files were moved!"
    exit 1
fi

echo "🎉 All steps completed successfully! 🎉"