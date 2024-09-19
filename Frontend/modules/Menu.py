import tkinter as tk
from tkinter import filedialog, messagebox
import subprocess
import os
from PIL import Image, ImageTk

IMAGE_WIDTH = 300
IMAGE_HEIGHT = 200


def mostrar_contenido(frame):
    for widget in frame.winfo_children():
        widget.destroy()

    frame.grid_rowconfigure(0, weight=1)
    frame.grid_columnconfigure(0, weight=1)

    main_content = tk.Frame(frame)
    main_content.grid(row=0, column=0, sticky="nsew")
    main_content.grid_rowconfigure(0, weight=1)
    main_content.grid_columnconfigure(0, weight=1)

    title_label = tk.Label(
        main_content, text="Contenido del menú Inicio", font=("Arial", 20, "bold")
    )
    title_label.grid(row=0, column=0, pady=(20, 10), sticky="nsew")

    input_frame = tk.Frame(main_content)
    input_frame.grid(row=1, column=0, pady=10, padx=50, sticky="nsew")

    text_input = tk.Text(
        input_frame,
        height=10,
        width=80,
        font=("Arial", 12),
        highlightbackground="black",
        highlightthickness=1,
        padx=10,
        pady=10,
    )
    text_input.pack(expand=True, fill="both")

    pais_seleccionado = tk.Frame(main_content)
    pais_seleccionado.grid(row=2, column=0, pady=10, sticky="nsew")

    label_pais = tk.Label(
        pais_seleccionado, text="País Seleccionado", font=("Arial", 16, "bold")
    )
    label_pais.grid(row=0, column=0, columnspan=2, pady=(0, 10))

    info_frame = tk.Frame(pais_seleccionado)
    info_frame.grid(row=1, column=0, columnspan=2)

    label_nombre = tk.Label(info_frame, text="Nombre: ", font=("Arial", 12))
    label_nombre.grid(row=0, column=0, padx=10, sticky="e")

    label_poblacion = tk.Label(info_frame, text="Población: ", font=("Arial", 12))
    label_poblacion.grid(row=0, column=1, padx=10, sticky="w")

    images_frame = tk.Frame(pais_seleccionado)
    images_frame.grid(row=2, column=0, columnspan=2, pady=10)

    label_bandera = tk.Label(images_frame)
    label_bandera.grid(row=0, column=0, padx=10)

    label_grafica = tk.Label(images_frame)
    label_grafica.grid(row=0, column=1, padx=10)

    button_frame = tk.Frame(main_content)
    button_frame.grid(row=3, column=0, pady=10)

    file_path = tk.StringVar()

    def abrir_archivo():
        path = filedialog.askopenfilename(
            filetypes=[("Text files", "*.txt"), ("All files", "*.*")]
        )
        if path:
            with open(path, "r") as file:
                content = file.read()
                text_input.delete(1.0, tk.END)
                text_input.insert(tk.END, content)
            file_path.set(path)

    def enviar_contenido():
        contenido = text_input.get(1.0, tk.END)
        try:
            exe_path = os.path.join(
                os.path.dirname(__file__), "../../backend/analyzer.exe"
            )
            result = subprocess.run(
                [exe_path], input=contenido, text=True, capture_output=True
            )
            messagebox.showinfo("Resultado", result.stdout)
            salida = result.stdout.strip()
            partes = salida.split(",")

            if len(partes) == 4:
                label_poblacion.config(text="Población: " + partes[1])
                label_nombre.config(text="Nombre: " + partes[2])

                imagen_path = partes[3].strip()
                imagen = Image.open(imagen_path)
                imagen = imagen.resize((IMAGE_WIDTH, IMAGE_HEIGHT))
                imagen_tk = ImageTk.PhotoImage(imagen)
                label_bandera.config(image=imagen_tk)
                label_bandera.image = imagen_tk

                imagen_path_graph = "automata.png"
                imagen_graph = Image.open(imagen_path_graph)
                imagen_graph = imagen_graph.resize((IMAGE_WIDTH, IMAGE_HEIGHT))
                imagen_graph_tk = ImageTk.PhotoImage(imagen_graph)
                label_grafica.config(image=imagen_graph_tk)
                label_grafica.image = imagen_graph_tk
            else:
                label_poblacion.config(text="Población: ")
                label_nombre.config(text="Nombre: ")
                label_bandera.config(image=None)
                label_bandera.image = None
                label_grafica.config(image=None)
                label_grafica.image = None
        except Exception as e:
            messagebox.showerror("Error", str(e))

    def guardar_archivo():
        if not file_path.get():
            guardar_como()
        else:
            with open(file_path.get(), "w") as file:
                file.write(text_input.get(1.0, tk.END))
            messagebox.showinfo("Guardar", "Archivo guardado exitosamente.")

    def guardar_como():
        path = filedialog.asksaveasfilename(
            defaultextension=".org",
            filetypes=[("Org files", "*.org"), ("All files", "*.*")],
        )
        if path:
            with open(path, "w") as file:
                file.write(text_input.get(1.0, tk.END))
            file_path.set(path)
            messagebox.showinfo("Guardar como", "Archivo guardado exitosamente.")

    btn_style = {"font": ("Arial", 12), "width": 15, "padx": 10, "pady": 5}

    btn_guardar = tk.Button(
        button_frame, text="Guardar", command=guardar_archivo, **btn_style
    )
    btn_guardar.grid(row=0, column=0, padx=5)

    btn_guardar_como = tk.Button(
        button_frame, text="Guardar como", command=guardar_como, **btn_style
    )
    btn_guardar_como.grid(row=0, column=1, padx=5)

    btn_cargar_archivo = tk.Button(
        button_frame, text="Cargar archivo", command=abrir_archivo, **btn_style
    )
    btn_cargar_archivo.grid(row=0, column=2, padx=5)

    btn_analizar = tk.Button(
        button_frame,
        text="Analizar",
        font=("Arial", 14, "bold"),
        bg="yellow",
        width=20,
        padx=10,
        pady=10,
        command=enviar_contenido,
    )
    btn_analizar.grid(row=1, column=0, columnspan=3, pady=(10, 0))
