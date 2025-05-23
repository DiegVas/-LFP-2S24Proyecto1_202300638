# Proyecto No.1 - Lenguajes Formales y de Programación
![fiusac](https://github.com/user-attachments/assets/8ef01dc2-18fa-40ca-ab60-7b1b61778c3c)

## Descripción del Proyecto
Este proyecto consiste en el desarrollo de una aplicación para ayudar a una empresa internacional a seleccionar el mejor destino para abrir una nueva oficina. La aplicación analiza un archivo de entrada con formato `.ORG`, que contiene información sobre continentes, países, y la saturación del mercado en dichos lugares.

El análisis léxico de este archivo se realiza utilizando el lenguaje de programación **Fortran**, y la visualización de los datos se lleva a cabo mediante una interfaz gráfica desarrollada con **Tkinter** en **Python**.

## Objetivos del Proyecto
- Desarrollar un **analizador léxico** capaz de identificar y procesar tokens en archivos `.ORG` para generar gráficos representativos.
- Aplicar conocimientos en **teoría de autómatas** para implementar un **Autómata Finito Determinista (AFD)** que realice el análisis del archivo.
- Implementar una **interfaz gráfica** que permita cargar archivos `.ORG`, visualizar la información, y generar gráficos que representen los destinos propuestos.
- Seleccionar el destino más adecuado basado en el nivel de saturación del mercado.

## Funcionalidades Principales
- **Carga de Archivos:** Permite cargar archivos con extensión `.ORG` que contienen la información jerárquica de continentes y países.
- **Análisis Léxico:** El archivo se procesa en busca de errores léxicos y se genera un reporte en formato HTML.
- **Generación de Gráficos:** Utilizando **Graphviz**, la aplicación genera gráficos en formato PNG o SVG que visualizan la relación entre continentes y países, coloridos según el nivel de saturación del mercado.
- **Selección de Mejor Destino:** Basado en el porcentaje de saturación, la aplicación selecciona el país más adecuado para la empresa.

## Estructura del Archivo `.ORG`
El archivo `.ORG` contiene los siguientes bloques jerárquicos:

- **Gráfica:** Define la estructura general y contiene bloques de continentes.
- **Continente:** Representa un continente y contiene bloques de países.
- **País:** Define un país con información de su población, saturación de mercado, y ruta de la imagen de su bandera.

### Ejemplo de Archivo `.ORG`
```plaintext
grafica: {
  nombre: "Expansion Global";
  continente {
    nombre: "Asia";
    país: {
      nombre: "Japón";
      población: 125500000;
      saturación: 80%;
      bandera: "C:/images/japan.png";
    }
    país: {
      nombre: "China";
      población: 1400000000;
      saturación: 95%;
      bandera: "C:/images/china.png";
    }
  }
  continente {
    nombre: "América";
    país: {
      nombre: "Guatemala";
      población: 17263239;
      saturación: 40%;
      bandera: "C:/images/guatemala.png";
    }
  }
}
