import subprocess

def sobel_filter_ocaml(input_path: str, output_path: str):
    subprocess.run(["./edge.ml", input_path, output_path], check=True)
    print(f"Image traitée et enregistrée dans {output_path}")

# Exemple d’utilisation
sobel_filter_ocaml("image_in.png", "image_out.png")