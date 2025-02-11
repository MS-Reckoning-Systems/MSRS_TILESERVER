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

        if "features" not in geojson:
            print(f"⚠️ Skipping {filename} - No 'features' key found.")
            continue

        updated = False  # Track if changes were made
        new_features = []  # Store processed features

        for feature in geojson.get("features", []):
            if not isinstance(feature, dict) or "geometry" not in feature:
                print(f"⚠️ Skipping malformed feature in {filename}")
                continue  # Skip invalid feature

            geometry = feature["geometry"]
            coords = geometry.get("coordinates", [])

            if geometry.get("type") == "Point":
                if isinstance(coords, list) and len(coords) == 3:
                    feature["properties"]["depth"] = coords[2]  # Store depth
                    feature["geometry"]["coordinates"] = coords[:2]  # Keep only [lon, lat]
                    updated = True
                new_features.append(feature)  # Keep the single Point feature

            elif geometry.get("type") == "MultiPoint" and isinstance(coords, list):
                for coord in coords:
                    if isinstance(coord, list) and len(coord) == 3:
                        new_feature = {
                            "type": "Feature",
                            "geometry": {"type": "Point", "coordinates": coord[:2]},  # Extract [lon, lat]
                            "properties": feature["properties"].copy()  # Copy existing properties
                        }
                        new_feature["properties"]["depth"] = coord[2]  # Assign depth
                        new_features.append(new_feature)
                        updated = True
                    else:
                        print(f"⚠️ Skipping invalid coordinate in {filename}: {coord}")

        # Save only if updates were made
        if updated:
            geojson["features"] = new_features  # Replace original features
            with open(filepath, "w") as f:
                json.dump(geojson, f, indent=4)
            print(f"✅ Updated file: {filename}")

    except json.JSONDecodeError:
        print(f"❌ Error: Malformed JSON in {filename}, skipping.")
    except Exception as e:
        print(f"❌ Unexpected error processing {filename}: {e}")

print("🏆 All GeoJSON files processed successfully!")