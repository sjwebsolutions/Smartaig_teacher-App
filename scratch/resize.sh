#!/bin/bash
DESKTOP_DIR="/Users/sjsolutionsandinfotech/Desktop"
OUT_67="${DESKTOP_DIR}/AppStore_6.7_New"
OUT_65="${DESKTOP_DIR}/AppStore_6.5_New"
OUT_55="${DESKTOP_DIR}/AppStore_5.5_New"

mkdir -p "$OUT_67"
mkdir -p "$OUT_65"
mkdir -p "$OUT_55"

echo "Creating folders on Desktop..."

# Find simulator screenshots from today
find "$DESKTOP_DIR" -maxdepth 1 -name "Simulator Screenshot - iPhone 15 Pro - 2026-07-13*.png" | while read -r img; do
    filename=$(basename "$img")
    echo "Processing $filename..."
    
    # Resize for 6.7" Display (1290 x 2796)
    sips -z 2796 1290 "$img" --out "${OUT_67}/${filename}" > /dev/null
    
    # Resize for 6.5" Display (1242 x 2688)
    sips -z 2688 1242 "$img" --out "${OUT_65}/${filename}" > /dev/null
    
    # Resize for 5.5" Display (1242 x 2208)
    sips -z 2208 1242 "$img" --out "${OUT_55}/${filename}" > /dev/null
done

echo "Done! Check folders AppStore_6.7_New, AppStore_6.5_New, and AppStore_5.5_New on your Desktop."
