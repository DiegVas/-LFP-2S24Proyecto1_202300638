import tkinter as tk


def mostrar_contenido(frame):
    # Limpiar el frame
    for widget in frame.winfo_children():
        widget.destroy()

    # Añadir contenido al frame
    label = tk.Label(frame, text="Contenido del menú Inicio", font=("Arial", 16))
    label.pack(pady=20)

    # Crear un Text widget grande
    text_input = tk.Text(frame, height=10, width=50)
    text_input.pack(pady=10)

    # Crear botones
    btn_guardar = tk.Button(frame, text="Guardar")
    btn_guardar.pack(side=tk.LEFT, padx=5)

    btn_guardar_como = tk.Button(frame, text="Guardar como")
    btn_guardar_como.pack(side=tk.LEFT, padx=5)

    btn_cargar_archivo = tk.Button(frame, text="Cargar archivo")
    btn_cargar_archivo.pack(side=tk.LEFT, padx=5)

    btn_analizar = tk.Button(frame, text="Analizar", font=("Arial", 12, "bold"))
    btn_analizar.pack(side=tk.LEFT, padx=5, pady=10)
