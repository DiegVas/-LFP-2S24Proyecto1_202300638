import tkinter as tk
import Frontend.modules.Menu as Menu
from tkinter import messagebox


class App:

    WIDTH = 1200
    HEIGHT = 800

    def __init__(self, root):
        self.root = root
        self.root.geometry(f"{self.WIDTH}x{self.HEIGHT}")
        self.root.title("Analizador")
        self.selected_button = None

        # Crear el frame principal
        self.main_frame = tk.Frame(root)
        self.main_frame.pack(side="right", fill="both", expand=True)

        self.NavBar(root)

    def NavBar(self, root):
        # Crear el frame del navbar con mayor ancho
        self.navbar = tk.Frame(root, bg="#393E46", width=300)  # Ajusta el ancho aquí
        self.navbar.pack(side="left", fill="y")

        self.boton0 = tk.Button(
            self.navbar,
            bg="#393E46",
            bd=0,
        )
        self.boton0.pack(fill="x", expand=True, padx=80)

        # Lista de botones con sus textos
        botones = ["Inicio", "Acerca de", "Salir"]

        # Crear y añadir botones al navbar usando un bucle
        for texto in botones:
            boton = tk.Button(
                self.navbar,
                text=texto,
                bg="#393E46",
                fg="white",
                bd=0,
                font=("Arial", 12),
                height=3,  # Ajusta el alto del botón aquí
            )
            boton.pack(fill="x", expand=True)
            boton.bind("<Enter>", lambda e: self.on_enter(e))
            boton.bind("<Leave>", lambda e: self.on_leave(e))
            boton.bind("<Button-1>", lambda e, t=texto: self.on_click(e, t))

    def on_enter(self, event):
        event.widget.config(bg="#D3D3D3")

    def on_leave(self, event):
        if self.selected_button != event.widget:
            event.widget.config(bg="#393E46")

    def on_click(self, event, texto):
        if self.selected_button:
            self.selected_button.config(bg="#393E46", fg="white")
        self.selected_button = event.widget
        event.widget.config(bg="#FFFFFF", fg="#393E46")

        # Cargar contenido según el botón seleccionado
        if texto == "Inicio":
            Menu.mostrar_contenido(self.main_frame)
        elif texto == "Acerca de":
            self.mostrar_acerca_de()
        elif texto == "Salir":
            self.root.quit()

    def mostrar_acerca_de(self):
        # Limpiar el frame
        for widget in self.main_frame.winfo_children():
            widget.destroy()

        # Mostrar mensaje
        messagebox.showinfo(
            "Estudiante: Diego Alejandro Vásquez Alonzo\n",
            "Carné: 202300638\nCurso: Lenguajes Formales y de Programación\nSección: B+",
        )
