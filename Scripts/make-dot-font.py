#!/usr/bin/env python3
# make-dot-font.py — generates Resources/Fonts/DotoRounded.ttf, the WidgetKit
# widget's dot-matrix font: a static round-dot instance of Doto (OFL,
# https://github.com/google/fonts/tree/main/ofl/doto). SwiftUI cannot reach
# the variable font's ROND axis, so the instance is baked here.
# Needs fonttools. Run from repo root:
#   python3 Scripts/make-dot-font.py "Doto[ROND,wght].ttf"

import sys
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont

WEIGHT = 800  # bigger dots stay legible at the widget's 8-9 pt
NAMES = {1: "Doto Rounded", 2: "Regular", 3: "DotoRounded-Regular", 4: "Doto Rounded", 6: "DotoRounded-Regular"}

font = instantiateVariableFont(TTFont(sys.argv[1]), {"ROND": 100, "wght": WEIGHT})
name = font["name"]
for nid in (16, 17, 25):  # typographic family/style and variations prefix
    name.removeNames(nameID=nid)
for nid, value in NAMES.items():
    name.setName(value, nid, 3, 1, 0x409)
    name.setName(value, nid, 1, 0, 0)
font["OS/2"].usWeightClass = WEIGHT
font.save("Resources/Fonts/DotoRounded.ttf")
