#!/usr/bin/env python3
"""
Generate sample snapshot PNGs to test the Parity Viewer.
Uses only Python stdlib — no PIL/Pillow needed.
Creates mock phone-screen-shaped images with colored blocks to simulate real snapshots.
"""

import struct
import zlib
import os

PROJECT_ROOT = os.path.join(os.path.dirname(__file__), "../..")

IOS_DIR = os.path.join(PROJECT_ROOT, "ios/TandemEMTTests/__Snapshots__")
ANDROID_DIR = os.path.join(PROJECT_ROOT, "android/app/src/test/snapshots")


def create_png(width, height, pixels_func):
    """Create a PNG file from a pixel function that returns (r, g, b) per pixel."""

    def make_chunk(chunk_type, data):
        chunk = chunk_type + data
        return struct.pack(">I", len(data)) + chunk + struct.pack(">I", zlib.crc32(chunk) & 0xFFFFFFFF)

    # Header
    header = b"\x89PNG\r\n\x1a\n"

    # IHDR
    ihdr_data = struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)
    ihdr = make_chunk(b"IHDR", ihdr_data)

    # IDAT — raw pixel data
    raw = b""
    for y in range(height):
        raw += b"\x00"  # filter: none
        for x in range(width):
            r, g, b = pixels_func(x, y, width, height)
            raw += struct.pack("BBB", r, g, b)

    idat = make_chunk(b"IDAT", zlib.compress(raw))

    # IEND
    iend = make_chunk(b"IEND", b"")

    return header + ihdr + idat + iend


def phone_screen(width, height, bg, status_bar_color, nav_color, content_blocks, platform_label):
    """
    Generate a phone-screen-like image.
    bg: (r,g,b) background
    status_bar_color: (r,g,b) for top status bar
    nav_color: (r,g,b) for bottom nav bar
    content_blocks: list of (y_start_frac, y_end_frac, color, margin_frac)
    """
    status_h = int(height * 0.06)
    nav_h = int(height * 0.08)

    def pixel(x, y, w, h):
        # Status bar
        if y < status_h:
            return status_bar_color
        # Nav bar
        if y > h - nav_h:
            # Draw 4 tab dots
            tab_w = w // 4
            for i in range(4):
                cx = tab_w * i + tab_w // 2
                cy = h - nav_h // 2
                if abs(x - cx) < 8 and abs(y - cy) < 8:
                    return (200, 200, 200)
            return nav_color
        # Content blocks
        for y_start_f, y_end_f, color, margin_f in content_blocks:
            y_start = status_h + int((h - status_h - nav_h) * y_start_f)
            y_end = status_h + int((h - status_h - nav_h) * y_end_f)
            margin = int(w * margin_f)
            if y_start <= y < y_end and margin <= x < w - margin:
                # Rounded corner simulation — skip corners
                in_top = y - y_start < 6
                in_bottom = y_end - y < 6
                in_left = x - margin < 6
                in_right = (w - margin) - x < 6
                if (in_top and in_left) or (in_top and in_right) or (in_bottom and in_left) or (in_bottom and in_right):
                    return bg
                return color
        return bg

    return create_png(width, height, pixel)


# iOS dimensions (iPhone 15 Pro-ish: 393x852 scaled down)
IOS_W, IOS_H = 197, 426

# Android dimensions (Pixel 6-ish: 412x915 scaled down)
AND_W, AND_H = 206, 458

# Color palette
DARK_BG = (15, 17, 23)
IOS_STATUS = (28, 28, 30)
AND_STATUS = (25, 25, 28)
IOS_NAV = (28, 28, 30)
AND_NAV = (30, 30, 35)
CARD_DARK = (40, 43, 55)
CARD_ACTIVE = (45, 60, 80)
RED_BADGE = (180, 50, 50)
GREEN_BADGE = (40, 140, 70)
YELLOW_BADGE = (180, 150, 30)
BLUE_ACCENT = (0, 122, 255)
FILTER_CHIP = (50, 55, 70)
FILTER_ACTIVE = (0, 90, 200)
SKELETON = (35, 38, 48)
ERROR_RED = (100, 30, 30)
EMPTY_GRAY = (50, 55, 65)


# --- Snapshot definitions ---

snapshots = [
    # (ios_subdir, ios_filename, android_subdir, android_filename, description)

    # 1. Incident list - loaded state
    {
        "name": "IncidentList_LoadedState",
        "ios_path": "IncidentListViewModelTests/IncidentList_LoadedState_iPhone.png",
        "android_path": "com.tandem.emt.features.incidentList/IncidentList_LoadedState.png",
        "ios_blocks": [
            (0.00, 0.06, FILTER_ACTIVE, 0.04),   # Active filter chip
            (0.00, 0.06, FILTER_CHIP, 0.55),       # Inactive filter chip (right area)
            (0.08, 0.25, CARD_ACTIVE, 0.04),       # Incident card 1 (active)
            (0.27, 0.44, CARD_DARK, 0.04),         # Incident card 2
            (0.46, 0.63, CARD_DARK, 0.04),         # Incident card 3
            (0.65, 0.82, CARD_DARK, 0.04),         # Incident card 4
        ],
        "android_blocks": [
            (0.00, 0.06, FILTER_ACTIVE, 0.04),
            (0.00, 0.06, FILTER_CHIP, 0.55),
            (0.08, 0.25, CARD_ACTIVE, 0.04),
            (0.27, 0.44, CARD_DARK, 0.04),
            (0.46, 0.63, CARD_DARK, 0.04),
            (0.65, 0.82, CARD_DARK, 0.04),
        ],
    },

    # 2. Incident list - empty state
    {
        "name": "IncidentList_EmptyState",
        "ios_path": "IncidentListViewModelTests/IncidentList_EmptyState_iPhone.png",
        "android_path": "com.tandem.emt.features.incidentList/IncidentList_EmptyState.png",
        "ios_blocks": [
            (0.00, 0.06, FILTER_ACTIVE, 0.04),
            (0.35, 0.55, EMPTY_GRAY, 0.15),        # Empty state message
        ],
        "android_blocks": [
            (0.00, 0.06, FILTER_ACTIVE, 0.04),
            (0.35, 0.55, EMPTY_GRAY, 0.15),
        ],
    },

    # 3. Incident list - loading state
    {
        "name": "IncidentList_LoadingState",
        "ios_path": "IncidentListViewModelTests/IncidentList_LoadingState_iPhone.png",
        "android_path": "com.tandem.emt.features.incidentList/IncidentList_LoadingState.png",
        "ios_blocks": [
            (0.08, 0.22, SKELETON, 0.04),          # Skeleton card 1
            (0.24, 0.38, SKELETON, 0.04),          # Skeleton card 2
            (0.40, 0.54, SKELETON, 0.04),          # Skeleton card 3
            (0.56, 0.70, SKELETON, 0.04),          # Skeleton card 4
        ],
        "android_blocks": [
            (0.08, 0.22, SKELETON, 0.04),
            (0.24, 0.38, SKELETON, 0.04),
            (0.40, 0.54, SKELETON, 0.04),
            (0.56, 0.70, SKELETON, 0.04),
        ],
    },

    # 4. Incident list - error state
    {
        "name": "IncidentList_ErrorState",
        "ios_path": "IncidentListViewModelTests/IncidentList_ErrorState_iPhone.png",
        "android_path": "com.tandem.emt.features.incidentList/IncidentList_ErrorState.png",
        "ios_blocks": [
            (0.30, 0.50, ERROR_RED, 0.10),         # Error message
            (0.52, 0.60, BLUE_ACCENT, 0.25),       # Retry button
        ],
        "android_blocks": [
            (0.30, 0.50, ERROR_RED, 0.10),
            (0.52, 0.60, BLUE_ACCENT, 0.25),
        ],
    },

    # 5. Incident list - filtered active
    {
        "name": "IncidentList_FilteredActive",
        "ios_path": "IncidentListViewModelTests/IncidentList_FilteredActive_iPhone.png",
        "android_path": "com.tandem.emt.features.incidentList/IncidentList_FilteredActive.png",
        "ios_blocks": [
            (0.00, 0.06, FILTER_CHIP, 0.04),
            (0.00, 0.06, FILTER_ACTIVE, 0.40),
            (0.08, 0.25, CARD_ACTIVE, 0.04),       # Active incident 1
            (0.27, 0.44, CARD_ACTIVE, 0.04),       # Active incident 2
        ],
        "android_blocks": [
            (0.00, 0.06, FILTER_CHIP, 0.04),
            (0.00, 0.06, FILTER_ACTIVE, 0.40),
            (0.08, 0.25, CARD_ACTIVE, 0.04),
            (0.27, 0.44, CARD_ACTIVE, 0.04),
        ],
    },

    # 6. Content view - tab bar (iOS only — test the "unpaired" feature)
    {
        "name": "ContentView_TabBar",
        "ios_path": "ContentViewTests/ContentView_TabBar_iPhone.png",
        "android_path": None,
        "ios_blocks": [
            (0.35, 0.55, EMPTY_GRAY, 0.15),        # "Coming Soon" placeholder
        ],
        "android_blocks": [],
    },

    # 7. App navigation - bottom bar (Android only — test the "unpaired" feature)
    {
        "name": "AppNavigation_BottomBar",
        "ios_path": None,
        "android_path": "com.tandem.emt/AppNavigation_BottomBar.png",
        "ios_blocks": [],
        "android_blocks": [
            (0.35, 0.55, EMPTY_GRAY, 0.15),
        ],
    },

    # 8. Incident list - offline banner
    {
        "name": "IncidentList_OfflineBanner",
        "ios_path": "IncidentListViewModelTests/IncidentList_OfflineBanner_iPhone.png",
        "android_path": "com.tandem.emt.features.incidentList/IncidentList_OfflineBanner.png",
        "ios_blocks": [
            (0.00, 0.04, YELLOW_BADGE, 0.0),       # Offline banner
            (0.06, 0.12, FILTER_ACTIVE, 0.04),
            (0.14, 0.31, CARD_DARK, 0.04),         # Cached card 1
            (0.33, 0.50, CARD_DARK, 0.04),         # Cached card 2
        ],
        "android_blocks": [
            (0.00, 0.04, YELLOW_BADGE, 0.0),
            (0.06, 0.12, FILTER_ACTIVE, 0.04),
            (0.14, 0.31, CARD_DARK, 0.04),
            (0.33, 0.50, CARD_DARK, 0.04),
        ],
    },
]


def main():
    generated = 0
    for snap in snapshots:
        # iOS
        if snap["ios_path"]:
            ios_full = os.path.join(IOS_DIR, snap["ios_path"])
            os.makedirs(os.path.dirname(ios_full), exist_ok=True)
            data = phone_screen(IOS_W, IOS_H, DARK_BG, IOS_STATUS, IOS_NAV, snap["ios_blocks"], "iOS")
            with open(ios_full, "wb") as f:
                f.write(data)
            print(f"  iOS: {snap['ios_path']}")
            generated += 1

        # Android
        if snap["android_path"]:
            android_full = os.path.join(ANDROID_DIR, snap["android_path"])
            os.makedirs(os.path.dirname(android_full), exist_ok=True)
            data = phone_screen(AND_W, AND_H, DARK_BG, AND_STATUS, AND_NAV, snap["android_blocks"], "Android")
            with open(android_full, "wb") as f:
                f.write(data)
            print(f"  Android: {snap['android_path']}")
            generated += 1

    print(f"\nGenerated {generated} snapshot images.")


if __name__ == "__main__":
    main()
