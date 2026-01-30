#!/bin/bash
#
# Run Inferno OS in QEMU for testing
#
# Usage: ./run-qemu.sh [options]
#   -h, --hd FILE    Attach IDE hard drive image
#   -n, --net        Enable networking (RTL8139)
#   -g, --graphic    Use graphical display (default is serial console)
#   --create-hd MB   Create a test hard drive image of given size
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FLOPPY="${SCRIPT_DIR}/floppy.img"

# Defaults
USE_NET=0
USE_GRAPHIC=0
HD_IMAGE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--hd)
            HD_IMAGE="$2"
            shift 2
            ;;
        -n|--net)
            USE_NET=1
            shift
            ;;
        -g|--graphic)
            USE_GRAPHIC=1
            shift
            ;;
        --create-hd)
            SIZE_MB="$2"
            HD_IMAGE="${SCRIPT_DIR}/test_hd.img"
            echo "Creating ${SIZE_MB}MB hard drive image: ${HD_IMAGE}"
            dd if=/dev/zero of="${HD_IMAGE}" bs=1M count="${SIZE_MB}" 2>/dev/null
            shift 2
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo "  -h, --hd FILE    Attach IDE hard drive image"
            echo "  -n, --net        Enable networking (RTL8139)"
            echo "  -g, --graphic    Use graphical display (default: serial)"
            echo "  --create-hd MB   Create test hard drive of given size"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check floppy exists
if [[ ! -f "${FLOPPY}" ]]; then
    echo "Error: Floppy image not found: ${FLOPPY}"
    echo "Run the build steps in README.md first."
    exit 1
fi

# Build QEMU command
QEMU_CMD="qemu-system-i386"
QEMU_ARGS="-fda ${FLOPPY} -boot a"

# Display mode
if [[ ${USE_GRAPHIC} -eq 0 ]]; then
    QEMU_ARGS="${QEMU_ARGS} -nographic"
fi

# Hard drive
if [[ -n "${HD_IMAGE}" ]]; then
    QEMU_ARGS="${QEMU_ARGS} -hda ${HD_IMAGE}"
fi

# Networking - use RTL8139 which we have a driver for
if [[ ${USE_NET} -eq 1 ]]; then
    QEMU_ARGS="${QEMU_ARGS} -net nic,model=rtl8139 -net user"
fi

echo "Starting QEMU..."
echo "  Floppy: ${FLOPPY}"
[[ -n "${HD_IMAGE}" ]] && echo "  HD: ${HD_IMAGE}"
[[ ${USE_NET} -eq 1 ]] && echo "  Network: RTL8139 (user mode)"
[[ ${USE_GRAPHIC} -eq 0 ]] && echo "  Console: serial (Ctrl-A X to quit)"
echo ""

exec ${QEMU_CMD} ${QEMU_ARGS}
