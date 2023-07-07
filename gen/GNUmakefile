all: logo.webp

logo.png: logo.xcf
	gimp -i -b "$$(< xcf2png.scm) (main-single-file \"$<\" \"$@\")" -b '(gimp-quit 0)'

logo.webp: logo.png
	cwebp -blend_alpha 0 -z 9 -lossless $< -o $@

