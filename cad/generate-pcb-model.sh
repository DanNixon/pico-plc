#!/usr/bin/env bash

flatpak run --command=kicad-cli org.kicad.KiCad pcb export vrml ../pcb/pico-plc.kicad_pcb
