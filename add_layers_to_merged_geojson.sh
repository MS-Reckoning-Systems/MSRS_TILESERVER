#!/bin/bash

# Paths
ENC_JSON=~/Downloads/merged_enc.json
ENC_CLEANED_JSON=~/Downloads/merged_enc_cleaned.json
OUTPUT_MBTS=~/Downloads/enc_fixed.mbtiles

echo "🔄 Cleaning ENC JSON: Removing null geometries and storing Z-coordinates as 'depth' property..."

# Process JSON: Keep 3D (Z) data in a new 'depth' property while keeping 2D geometries
jq '.features |= map(
    select(.geometry != null) | 
    if .geometry.type == "MultiPoint" then 
        .geometry.coordinates |= map(
            if type == "array" and length == 3 then 
                {"x": .[0], "y": .[1], "depth": .[2]} 
            else 
                {"x": .[0], "y": .[1], "depth": null} 
            end
        ) | 
        .properties.depths = [.geometry.coordinates[].depth] | 
        .geometry.coordinates |= map([.x, .y])
    else 
        . 
    end
)' "$ENC_JSON" > "$ENC_CLEANED_JSON"

echo "✅ Cleaned JSON saved as $ENC_CLEANED_JSON with 'depth' property."

# Extract unique OBJL values dynamically
OBJL_VALUES=$(jq -r '.features[].properties.OBJL' "$ENC_CLEANED_JSON" | grep -v null | sort -n | uniq)

# Start building the Tippecanoe command
TIPPECANOE_CMD="tippecanoe -o $OUTPUT_MBTS -Z4 -z12 --drop-densest-as-needed --coalesce-densest-as-needed --name 'ENC Vector Tiles' --attribution 'NOAA ENC Charts' --description 'Converted S-57 NOAA ENC Charts' --force"

# Add each OBJL value as a separate layer
for objl in $OBJL_VALUES; do
    TIPPECANOE_CMD+=" -L \"$objl:$ENC_CLEANED_JSON\""
done

echo "🚀 Running Tippecanoe..."
# Execute the command
eval $TIPPECANOE_CMD

echo "🎉 MBTiles file created: $OUTPUT_MBTS"