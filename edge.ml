type image = {
  w : int;
  h : int;
  data : int array;  (* length = w*h*3, pixels in R,G,B order *)
}

type edge_map = int array  (* length = w*h, values 0 or 255 *)

(* safe accessor for RGB channel *)
let get_rgb img x y =
  let w = img.w in
  if x < 0 || x >= img.w || y < 0 || y >= img.h then (0,0,0)
  else
    let idx = (y * w + x) * 3 in
    (img.data.(idx), img.data.(idx + 1), img.data.(idx + 2))

(* convert to grayscale (luminance) as float *)
let to_grayscale img =
  let w = img.w and h = img.h in
  let g = Array.make (w*h) 0.0 in
  for y = 0 to h-1 do
    for x = 0 to w-1 do
      let r,gc,b = get_rgb img x y in
      let lum = 0.299 *. (float_of_int r) +. 0.587 *. (float_of_int gc) +. 0.114 *. (float_of_int b) in
      g.(y*w + x) <- lum
    done
  done;
  g

(* generic 3x3 convolution at position (x,y) with kernel (k array length 9, row-major) *)
let conv3x3 gray w h x y k =
  let sum = ref 0.0 in
  for ky = -1 to 1 do
    for kx = -1 to 1 do
      let sx = x + kx in
      let sy = y + ky in
      let v =
        if sx < 0 || sx >= w || sy < 0 || sy >= h then 0.0
        else gray.(sy*w + sx)
      in
      let kval = k.((ky+1)*3 + (kx+1)) in
      sum := !sum +. (v *. kval)
    done
  done;
  !sum

(* Sobel kernels *)
let sobel_x = [|
  -1.0; 0.0; 1.0;
  -2.0; 0.0; 2.0;
  -1.0; 0.0; 1.0
|]

let sobel_y = [|
   1.0;  2.0;  1.0;
   0.0;  0.0;  0.0;
  -1.0; -2.0; -1.0
|]

(* compute gradient magnitude image *)
let gradient_magnitude gray w h =
  let mag = Array.make (w*h) 0.0 in
  for y = 0 to h-1 do
    for x = 0 to w-1 do
      let gx = conv3x3 gray w h x y sobel_x in
      let gy = conv3x3 gray w h x y sobel_y in
      mag.(y*w + x) <- sqrt (gx*.gx +. gy*.gy)
    done
  done;
  mag

(* normalize array of floats to range 0.0 .. 255.0 *)
let normalize_to_255 arr =
  let len = Array.length arr in
  let mx = ref neg_infinity and mn = ref infinity in
  for i = 0 to len-1 do
    let v = arr.(i) in
    if v > !mx then mx := v;
    if v < !mn then mn := v;
  done;
  let range = if !mx -. !mn = 0.0 then 1.0 else !mx -. !mn in
  let out = Array.make len 0.0 in
  for i = 0 to len-1 do
    out.(i) <- ((arr.(i) -. !mn) /. range) *. 255.0
  done;
  out

(* main detection: returns edge_map with 0 / 255 *)
let detect_edges ?(threshold=50) img =
  let w = img.w and h = img.h in
  let gray = to_grayscale img in
  let mag = gradient_magnitude gray w h in
  let norm = normalize_to_255 mag in
  let out = Array.make (w*h) 0 in
  for i = 0 to w*h - 1 do
    out.(i) <- if norm.(i) >= (float_of_int threshold) then 255 else 0
  done;
  out

(* helper to create an image from a function (for tests) *)
let make_image w h f_rgb =
  let data = Array.make (w*h*3) 0 in
  for y = 0 to h-1 do
    for x = 0 to w-1 do
      let r,g,b = f_rgb x y in
      let idx = (y*w + x)*3 in
      data.(idx) <- r; data.(idx+1) <- g; data.(idx+2) <- b
    done
  done;
  { w; h; data }
