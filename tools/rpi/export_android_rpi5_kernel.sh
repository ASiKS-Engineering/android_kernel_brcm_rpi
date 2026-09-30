#!/bin/sh
set -eu

KERNEL_OUT="${1:-bazel-bin/common/rpi5}"
DESTINATION="${2:-../android_device_brcm_rpi5-kernel}"

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
KERNEL_OUT_PATH="$REPO_ROOT/$KERNEL_OUT"
DESTINATION_PATH=$(CDPATH= cd -- "$REPO_ROOT/$(dirname -- "$DESTINATION")" && pwd)/$(basename -- "$DESTINATION")
MODULES_PATH="$DESTINATION_PATH/modules"
OVERLAYS_PATH="$DESTINATION_PATH/overlays"

DTBS="
    bcm2712d0-rpi-5-b.dtb
    bcm2712-rpi-500.dtb
    bcm2712-rpi-5-b.dtb
    bcm2712-rpi-cm5-cm4io.dtb
    bcm2712-rpi-cm5-cm5io.dtb
    bcm2712-rpi-cm5l-cm4io.dtb
    bcm2712-rpi-cm5l-cm5io.dtb
"

if [ ! -d "$KERNEL_OUT_PATH" ]; then
    echo "Kernel output path not found: $KERNEL_OUT_PATH" >&2
    exit 1
fi

mkdir -p "$DESTINATION_PATH" "$MODULES_PATH" "$OVERLAYS_PATH"

copy_single_artifact() {
    file_name="$1"
    target_dir="$2"
    artifact_path=$(find "$KERNEL_OUT_PATH" -type f -name "$file_name" | head -n 1)
    if [ -z "$artifact_path" ]; then
        echo "Required artifact not found: $file_name" >&2
        exit 1
    fi
    cp "$artifact_path" "$target_dir/$file_name"
}

copy_single_artifact Image "$DESTINATION_PATH"

for dtb_name in $DTBS; do
    copy_single_artifact "$dtb_name" "$DESTINATION_PATH"
done

overlay_source=$(find "$KERNEL_OUT_PATH" -type d -name overlays | while read -r candidate; do
    if find "$candidate" -maxdepth 1 -type f -name '*.dtbo' | grep -q .; then
        echo "$candidate"
        break
    fi
done)

if [ -n "$overlay_source" ]; then
    find "$OVERLAYS_PATH" -maxdepth 1 -type f -delete
    cp -R "$overlay_source"/. "$OVERLAYS_PATH"/
fi

find "$MODULES_PATH" -maxdepth 1 -type f -name '*.ko' -delete
find "$KERNEL_OUT_PATH" -type f -name '*.ko' -exec cp {} "$MODULES_PATH"/ \;

echo "Exported Raspberry Pi 5 kernel artifacts to $DESTINATION_PATH"
