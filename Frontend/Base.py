import tkinter as tk

class App:
    
    WIDHT = 800
    HEIGHT = 600
    
    def __init__(self, root):
        self.root = root
        self.root.geometry(f"{self.WIDHT}x{self.HEIGHT}")
        self.root.title("Analizador")

        # Crear una etiqueta
        self.label = tk.Label(root, text="¡Hola, mundo!")
        self.label.pack(pady=10)

        # Crear un botón para cerrar la aplicación
        self.quit_button = tk.Button(root, text="Salir", command=root.quit)
        self.quit_button.pack(pady=10)