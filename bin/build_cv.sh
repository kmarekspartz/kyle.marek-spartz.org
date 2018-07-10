#!/usr/bin/env bash
set -e
pandoc about.md \
  --pdf-engine=xelatex \
  -o Kyle_Marek-Spartz_CV.pdf \
  -Vmainfont="Palatino" \
  -Vtitle='' \
  -Vgeometry="margin=1in" \
  -Vfontsize="11pt" \
  -Vcolorlinks=true
