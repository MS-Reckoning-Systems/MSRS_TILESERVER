import json
import os

# 🚀 Define directory
MERGED_JSON_DIR = os.path.expanduser("~/Downloads/merged_json_layers")

# 🔍 Process each GeoJSON file
for filename in os.listdir(MERGED_JSON_DIR):
    if not filename.endswith(".json"):
        continue  # Skip non-JSON files

    filepath = os.path.join(MERGED_JSON_DIR, filename)
    print(f"🔄 Processing file: {filename}")

    try:
        with open(filepath, "r") as f:
            geojson = json.load(f)

        updated = False  # Track if changes were made
        new_features = []  # Store processed features

        for feature in geojson.get("features", []):
            geometry = feature.get("geometry", {})
            coords = geometry.get("coordinates", [])

            if geometry["type"] == "Point":
                if len(coords) == 3:
                    feature["properties"]["depth"] = coords[2]  # Store depth
                    feature["geometry"]["coordinates"] = coords[:2]  # Keep only [lon, lat]
                    updated = True
                new_features.append(feature)  # Keep the single Point

            elif geometry["type"] == "MultiPoint":
                for coord in coords:
                    if len(coord) == 3:  # Ensure it's a [lon, lat, depth] triplet
                        new_feature = {
                            "type": "Feature",
                            "geometry": {
                                "type": "Point",
                                "coordinates": coord[:2]  # Extract [lon, lat]
                            },
                            "properties": feature["properties"].copy()  # Copy existing properties
                        }
                        new_feature["properties"]["depth"] = coord[2]  # Assign depth
                        new_features.append(new_feature)
                    else:
                        print(f"⚠️ Skipping invalid coordinate (wrong length) in {filename}: {coord}")

                updated = True  # Changes were made

        # Save only if updates were made
        if updated:
            geojson["features"] = new_features  # Replace original features
            with open(filepath, "w") as f:
                json.dump(geojson, f, indent=4)
            print(f"✅ Updated file: {filename}")

    except Exception as e:
        print(f"❌ Error processing {filename}: {e}")

print("🏆 All GeoJSON files processed successfully!")