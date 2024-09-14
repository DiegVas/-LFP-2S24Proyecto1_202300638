import tkinter as tk
from tkinter import filedialog
from tkinter import messagebox


def mostrar_contenido(frame):
    # Limpiar el frame
    for widget in frame.winfo_children():
        widget.destroy()

    # Añadir contenido al frame
    label = tk.Label(frame, text="Contenido del menú Inicio", font=("Arial", 16))
    label.pack(pady=20)

    # Crear un Text widget grande con borde negro y padding interno
    text_input = tk.Text(
        frame,
        height=10,
        width=50,
        highlightbackground="black",
        highlightthickness=1,
        padx=10,
        pady=10,
    )
    text_input.pack(pady=10)

    # Crear un frame para los primeros tres botones
    button_frame = tk.Frame(frame)
    button_frame.pack(pady=10)

    # Variables para almacenar la ruta del archivo actual
    file_path = tk.StringVar()

    # Función para abrir archivo
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

    # Función para guardar archivo
    def guardar_archivo():
        if not file_path.get():
            guardar_como()
        else:
            with open(file_path.get(), "w") as file:
                file.write(text_input.get(1.0, tk.END))
            messagebox.showinfo("Guardar", "Archivo guardado exitosamente.")

    # Función para guardar archivo como
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

    # Crear botones y añadirlos al frame
    btn_guardar = tk.Button(button_frame, text="Guardar", command=guardar_archivo)
    btn_guardar.pack(side=tk.LEFT, padx=5)

    btn_guardar_como = tk.Button(
        button_frame, text="Guardar como", command=guardar_como
    )
    btn_guardar_como.pack(side=tk.LEFT, padx=5)

    btn_cargar_archivo = tk.Button(
        button_frame, text="Cargar archivo", command=abrir_archivo
    )
    btn_cargar_archivo.pack(side=tk.LEFT, padx=5)

    # Crear el botón "Analizar" más grande y resaltado
    btn_analizar = tk.Button(
        frame, text="Analizar", font=("Arial", 12, "bold"), bg="yellow", width=20
    )
    btn_analizar.pack(pady=10)
