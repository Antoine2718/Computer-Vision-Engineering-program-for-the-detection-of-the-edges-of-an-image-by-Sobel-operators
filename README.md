# 🖥️⚙️ Computer Vision Engineering program for the detection of the edges of an image by Sobel operators

[![License](https://img.shields.io/badge/LICENSE-MIT-blue.svg)](LICENSE)

The program waits for an image represented in memory (width, height, RGB pixels) and returns a binary card (0/255) indicating the edges. The code includes: **grayscale conversion, convolution, gradient calculation, normalization and threshold**. A sample of use and a minimal dune file are provided.

## To use it with others format

The module above does not make an image IO. To use it with PNG/JPEG files you can:

> Use the ocaml-images library (package images) or ocaml-magick to load/save, then convert the pixels to the format expected by the module. (Recommended)

> Or write a small adapter that reads via Stb_image bindings or other.

## Exemple in subprocess with Python
```
sobel_filter_ocaml("image_in.png", "image_out.png")
```

### An exemple of use without subprocess (⚠️Not recommended)

```
open Printf

let () =
  (* simple synthetic test: 100x100, black with white square in center *)
  let w = 100 and h = 100 in
  let img = Edge.make_image w h (fun x y ->
    if x >= 30 && x < 70 && y >= 30 && y < 70 then (255,255,255) else (0,0,0)
  ) in
  let edges = Edge.detect_edges img ~threshold:40 in
  (* print a tiny ASCII preview *)
  for y = 0 to h-1 do
    for x = 0 to w-1 do
      let v = edges.(y*w + x) in
      printf "%c" (if v = 255 then '#' else ' ')
    done;
    printf "\n"
  done
```
