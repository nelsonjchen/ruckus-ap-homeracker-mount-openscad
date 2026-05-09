SCAD_FILE := models/ruckus_ap_mount/parts/ruckus_ap_homeracker_sleeve.scad
RENDER_DIR := renders
PNG_FILE := $(RENDER_DIR)/ruckus_ap_homeracker_sleeve.png
STL_ROTATION90_FILE := $(RENDER_DIR)/ruckus_ap_homeracker_sleeve_rotation90.stl
STL_ROTATION0_FILE := $(RENDER_DIR)/ruckus_ap_homeracker_sleeve_rotation0.stl
STL_PROTOTYPE_FILE := $(RENDER_DIR)/ruckus_ap_homeracker_mount_prototype.stl
STL_FILE := $(STL_PROTOTYPE_FILE)
VIEW_DIR := $(RENDER_DIR)/views
OPENSCAD_BIN := bin/openscad/openscad
OPENSCAD_APPIMAGE := bin/openscad/OpenSCAD.AppImage
OPENSCAD_MACOS := bin/openscad/OpenSCAD.app/Contents/MacOS/OpenSCAD
OPENSCADPATH := bin/openscad/libraries
OPENSCAD := $(shell if [ "$$(uname -s)" = "Darwin" ]; then command -v openscad; elif [ -x "$(OPENSCAD_MACOS)" ]; then printf '%s' "$(OPENSCAD_MACOS)"; elif [ -x "$(OPENSCAD_APPIMAGE)" ]; then printf '%s' "$(OPENSCAD_APPIMAGE)"; elif [ -x "$(OPENSCAD_BIN)" ]; then printf '%s' "$(OPENSCAD_BIN)"; else command -v openscad; fi)

.PHONY: sync install check render fallback-render render-rotation0 render-rotation90 render-prototype render-all png png-views build clean

sync:
	uv sync

install:
	uv run scadm install

check:
	uv run scadm install --check

render:
	$(MAKE) render-prototype

fallback-render: render-prototype

render-rotation0:
	mkdir -p $(RENDER_DIR)
	OPENSCADPATH="$(OPENSCADPATH)" "$(OPENSCAD)" --hardwarnings -D 'part_mode=0' -D 'sleeve_rotation=0' -o $(STL_ROTATION0_FILE) $(SCAD_FILE)

render-rotation90:
	mkdir -p $(RENDER_DIR)
	OPENSCADPATH="$(OPENSCADPATH)" "$(OPENSCAD)" --hardwarnings -D 'part_mode=0' -D 'sleeve_rotation=90' -o $(STL_ROTATION90_FILE) $(SCAD_FILE)

render-all: render-rotation90 render-rotation0

render-prototype:
	mkdir -p $(RENDER_DIR)
	OPENSCADPATH="$(OPENSCADPATH)" "$(OPENSCAD)" --hardwarnings -D 'part_mode=3' -D 'sleeve_rotation=90' -o $(STL_PROTOTYPE_FILE) $(SCAD_FILE)

png:
	mkdir -p $(RENDER_DIR)
	OPENSCADPATH="$(OPENSCADPATH)" "$(OPENSCAD)" \
		-o $(PNG_FILE) \
		--render=true \
		--hardwarnings \
		-D 'part_mode=0' \
		-D 'sleeve_rotation=90' \
		--camera=0,0,18,55,0,35,190 \
		--autocenter --viewall \
		--imgsize=1400,1000 \
		--colorscheme=Tomorrow \
		$(SCAD_FILE)

png-views:
	mkdir -p $(VIEW_DIR)
	OPENSCADPATH="$(OPENSCADPATH)" "$(OPENSCAD)" -o $(VIEW_DIR)/reference_iso.png --render=true --hardwarnings -D 'part_mode=1' --camera=0,0,5,55,0,35,170 --autocenter --viewall --imgsize=1400,1000 --colorscheme=Tomorrow $(SCAD_FILE)
	OPENSCADPATH="$(OPENSCADPATH)" "$(OPENSCAD)" -o $(VIEW_DIR)/reference_top.png --render=true --hardwarnings -D 'part_mode=1' --camera=0,0,5,0,0,0,170 --autocenter --viewall --imgsize=1400,1000 --colorscheme=Tomorrow $(SCAD_FILE)
	OPENSCADPATH="$(OPENSCADPATH)" "$(OPENSCAD)" -o $(VIEW_DIR)/prototype_iso.png --render=true --hardwarnings -D 'part_mode=3' -D 'sleeve_rotation=90' --camera=0,0,18,55,0,35,210 --autocenter --viewall --imgsize=1400,1000 --colorscheme=Tomorrow $(SCAD_FILE)
	OPENSCADPATH="$(OPENSCADPATH)" "$(OPENSCAD)" -o $(VIEW_DIR)/prototype_top.png --render=true --hardwarnings -D 'part_mode=3' -D 'sleeve_rotation=90' --camera=0,0,18,0,0,0,210 --autocenter --viewall --imgsize=1400,1000 --colorscheme=Tomorrow $(SCAD_FILE)
	OPENSCADPATH="$(OPENSCADPATH)" "$(OPENSCAD)" -o $(VIEW_DIR)/overlay_iso.png --render=true --hardwarnings -D 'part_mode=2' -D 'sleeve_rotation=90' --camera=0,0,18,55,0,35,210 --autocenter --viewall --imgsize=1400,1000 --colorscheme=Tomorrow $(SCAD_FILE)
	OPENSCADPATH="$(OPENSCADPATH)" "$(OPENSCAD)" -o $(VIEW_DIR)/prototype_overlay_iso.png --render=true --hardwarnings -D 'part_mode=4' -D 'sleeve_rotation=90' --camera=0,0,18,55,0,35,210 --autocenter --viewall --imgsize=1400,1000 --colorscheme=Tomorrow $(SCAD_FILE)
	OPENSCADPATH="$(OPENSCADPATH)" "$(OPENSCAD)" -o $(VIEW_DIR)/prototype_overlay_top.png --render=true --hardwarnings -D 'part_mode=4' -D 'sleeve_rotation=90' --camera=0,0,18,0,0,0,210 --autocenter --viewall --imgsize=1400,1000 --colorscheme=Tomorrow $(SCAD_FILE)

build: sync install render-all render-prototype png png-views

clean:
	rm -rf $(RENDER_DIR) models/ruckus_ap_mount/parts/renders
	find models -name '*.stl' -delete
	find models -name '*.3mf' -delete
