module grafica_datos
  use GraphTypes


contains

  subroutine leer_grafica_datos(contenido)
    implicit none
      type(Graph) :: graphFile
      character(len=:), allocatable :: contenido

      type(Country) :: country_select
      integer :: num_continentes, num_paises, pos, i
      real :: menor_saturacion
      character(len=5) :: saturacion, poblacion
      integer :: num_lineas

      character(len=:), allocatable :: lineas(:)

      ! Inicializar variables
      num_continentes = 0

    ! Abrimos el archivo para leer
    call separar_por_lineas(contenido, lineas, num_lineas)

    i = 1
    ! Leemos linea por linea
    do while (i<= num_lineas)

      ! Leemos el nombre de la gráfica
      if (index(lineas(i), 'grafica:') > 0) then
        !print *, "Leyendo nombre de la gráfica"
        do
          i = i + 1
            if (index(lineas(i), 'nombre:') > 0) then
              call extraer_valorGra(lineas(i), graphFile%name)
              !print *, "Nombre de la gráfica: ", graphFile%name
              exit
            endif
        end do
      endif

      if (index(lineas(i), 'continente') > 0) then
        
        num_continentes = num_continentes + 1

        if (.not. allocated(graphFile%continents)) then
          allocate(graphFile%continents(num_continentes))
        else
          call redimensionar_arreglo(graphFile%continents, num_continentes)
        endif

        do
          i = i + 1
          if (index(lineas(i), 'nombre:') > 0) then
            call extraer_valor(lineas(i), graphFile%continents(num_continentes)%name)
            exit
          end if
        end do

        ! inicializar el numero de paises
        num_paises = 0

        ! Leemos los paises

        do

          !print * , trim(lineas(i))
          if (i > num_lineas) then
            exit
          end if
          if (index(lineas(i), '}') > 0 .and. index(lineas(i), "}") > 0) then
            
            !print *, "Fin de los paises"
            exit
          end if



          if (index(lineas(i), 'pais') > 0) then
            num_paises = num_paises + 1

            if (.not. allocated(graphFile%continents(num_continentes)%countries)) then
              allocate(graphFile%continents(num_continentes)%countries(num_paises))
            else
              call redimensionar_arreglo_country(graphFile%continents(num_continentes)%countries, num_paises)
            end if
            do
              i = i + 1
              if (index(lineas(i), 'nombre:') > 0) then
                call extraer_valor(lineas(i), graphFile%continents(num_continentes)%countries(num_paises)%name)
                !print *, "Nombre del país: ", graphFile%continents(num_continentes)%countries(num_paises)%name
              
              else if (index(lineas(i), 'poblacion:')>0) then
                call extraer_valor(lineas(i), poblacion)
                read(poblacion, *) graphFile%continents(num_continentes)%countries(num_paises)%population
                !print *, "Nombre del país: ", graphFile%continents(num_continentes)%countries(num_paises)%population
              else if (index(lineas(i), 'saturacion:')>0) then
                call extraer_valor(lineas(i), saturacion)
                if (index(saturacion, '%')>0) then
                  saturacion = saturacion(1:len_trim(saturacion)-1)
                endif
                read(saturacion, *) graphFile%continents(num_continentes)%countries(num_paises)%saturation
                !print *, "Nombre del país: ", graphFile%continents(num_continentes)%countries(num_paises)%saturation
              else if (index(lineas(i), 'bandera:')>0) then
                call extraer_valor(lineas(i), graphFile%continents(num_continentes)%countries(num_paises)%flag)
                !print *, "Nombre del país: ", graphFile%continents(num_continentes)%countries(num_paises)%flag
              else
                exit
              endif

            end do
          end if
          i = i + 1
        end do

      end if
      i = i + 1
    end do

    menor_saturacion = 1.0e30  ! Un valor muy grande para empezar

    

     !Recorrer todos los continentes y países para encontrar el país con la menor saturación
    do pos = 1, num_continentes
      do i = 1, size(graphFile%continents(pos)%countries)
        if (graphFile%continents(pos)%countries(i)%saturation < menor_saturacion) then
          menor_saturacion = graphFile%continents(pos)%countries(i)%saturation
          country_select = graphFile%continents(pos)%countries(i)
        endif
      end do
    end do

do pos = 1 , num_continentes
  graphFile%continents(pos)%saturation_Continent = 0.0  ! Inicializar la saturación del continente
  do i = 1, size(graphFile%continents(pos)%countries)
    ! Redondear el valor de saturación a 3 decimales
    graphFile%continents(pos)%countries(i)%saturation = nint(graphFile%continents(pos)%countries(i)%saturation * 1000.0) / 1000.0
   ! Sumar el valor redondeado a la saturación del continente
    graphFile%continents(pos)%saturation_Continent = graphFile%continents(pos)%saturation_Continent + graphFile%continents(pos)%countries(i)%saturation
  end do
  ! Calcular la saturación promedio del continente
  graphFile%continents(pos)%saturation_Continent = graphFile%continents(pos)%saturation_Continent / size(graphFile%continents(pos)%countries)
end do

    call graphiv_Process(graphFile, num_continentes, num_paises)

    print *, trim("") // "," // trim(adjustl(itoa(country_select%population))) // "," // trim(country_select%name) // "," // trim(country_select%flag)

  end subroutine leer_grafica_datos

  function itoa(i) result(str)
    implicit none
    integer, intent(in) :: i
    character(len=12) :: str
    write(str, '(I0)') i
  end function itoa

  subroutine extraer_valor(linea, valor)
    character(len=*), intent(in) :: linea
    character(len=*), intent(out) :: valor
    integer :: pos

    pos = index(linea, ':') + 1
    valor = adjustl(trim(linea(pos:)))
    ! Remover el punto y coma al final si existe
    if (valor(len_trim(valor):len_trim(valor)) == ';') then
      valor = valor(1:len_trim(valor)-1)
    endif
    ! Remover las comillas si existen
    if (valor(1:1) == '"' .and. valor(len_trim(valor):len_trim(valor)) == '"') then
      valor = valor(2:len_trim(valor)-1)
    endif

  end subroutine extraer_valor

  subroutine extraer_valorGra(linea, valor)
    character(len=*), intent(in) :: linea
    character(len=*), intent(out) :: valor
    integer :: pos

    pos = index(linea, ':') + 1
    valor = adjustl(trim(linea(pos:)))
    ! Remover el punto y coma al final si existe
    if (valor(len_trim(valor):len_trim(valor)) == ';') then
      valor = valor(1:len_trim(valor)-1)
    endif

  end subroutine extraer_valorGra

  subroutine redimensionar_arreglo(arreglo, nuevo_tamano)
    type(Continent), dimension(:), allocatable :: arreglo
    integer, intent(in) :: nuevo_tamano
    type(Continent), dimension(:), allocatable :: temp

    allocate(temp(nuevo_tamano))
    temp(1:size(arreglo)) = arreglo
    call move_alloc(temp, arreglo)
  end subroutine redimensionar_arreglo

  function eliminar_espacios(cadena) result(cadena_sin_espacios)
  implicit none
  character(len=*), intent(in) :: cadena
  character(len=len(cadena)) :: cadena_sin_espacios
  integer :: i, j

  j = 1
  do i = 1, len(cadena)
    if (cadena(i:i) /= ' ') then
      cadena_sin_espacios(j:j) = cadena(i:i)
      j = j + 1
    end if
  end do

  cadena_sin_espacios = adjustl(cadena_sin_espacios(1:j-1))
end function eliminar_espacios

  subroutine redimensionar_arreglo_country(arreglo, nuevo_tamano)
    type(Country), dimension(:), allocatable :: arreglo
    integer, intent(in) :: nuevo_tamano
    type(Country), dimension(:), allocatable :: temp

    allocate(temp(nuevo_tamano))
    temp(1:size(arreglo)) = arreglo
    call move_alloc(temp, arreglo)
  end subroutine redimensionar_arreglo_country

  function real_to_char(num) result(char_rep)
        implicit none
        real, intent(in) :: num          ! Número real de entrada
        character(len=32) :: char_rep    ! Resultado como cadena de caracteres
        write(char_rep, '(F10.3)') num   ! Escribe el número en formato de cadena
  end function real_to_char

  subroutine graphiv_Process(dataFile, num_continentes, num_paises)
    type(Graph) :: dataFile
    integer :: num_continentes, num_paises, i, j
    character(len=5000) :: dot_code
    character(len=10) :: saturacion, saturacion_pais
    character(len=10) :: color
    real :: saturacion_real, saturacion_pais_real

    dot_code = "digraph G {" // new_line('A') // 'node [shape=box, style=filled, fontname="Arial"];' // new_line('A')

    do i = 1 , num_continentes
      saturacion_real = dataFile%continents(i)%saturation_Continent
      write(saturacion, '(F10.3)') saturacion_real
        if (dataFile%continents(i)%saturation_Continent < 15) then
      color = "white"
    else if (dataFile%continents(i)%saturation_Continent < 30) then
      color = "blue"
    else if (dataFile%continents(i)%saturation_Continent < 45) then
      color = "green"
    else if (dataFile%continents(i)%saturation_Continent < 60) then
      color = "yellow"
    else if (dataFile%continents(i)%saturation_Continent < 75) then
      color = "orange"
    else
      color = "red"
    end if
     saturacion = real_to_char(saturacion_real)

     dataFile%continents(i)%name = eliminar_espacios(trim(dataFile%continents(i)%name))
      dot_code = trim(dot_code) // (eliminar_espacios(trim(dataFile%continents(i)%name))) // ' [label="' // trim(dataFile%continents(i)%name) // '\n' // saturacion // '" , fillcolor=' // color // '];' // new_line('A')
      dot_code = trim(dot_code) // eliminar_espacios(trim(dataFile%name)) // " -> " // eliminar_espacios(trim(dataFile%continents(i)%name)) // new_line('A')
      do j = 1, size(dataFile%continents(i)%countries)
      saturacion_pais_real = dataFile%continents(i)%countries(j)%saturation
    if (dataFile%continents(i)%countries(j)%saturation < 15) then
      color = "white"
    else if (dataFile%continents(i)%countries(j)%saturation < 30) then
      color = "blue"
    else if (dataFile%continents(i)%countries(j)%saturation < 45) then
      color = "green"
    else if (dataFile%continents(i)%countries(j)%saturation < 60) then
      color = "yellow"
    else if (dataFile%continents(i)%countries(j)%saturation < 75) then
      color = "orange"
    else
      color = "red"
    end if
     saturacion_pais = real_to_char(saturacion_pais_real)
          do while (index(trim(dataFile%continents(i)%countries(j)%name), ' ') /= 0)
        dataFile%continents(i)%countries(j)%name = eliminar_espacios(trim(dataFile%continents(i)%countries(j)%name))
        
     end do
      dot_code = trim(dot_code) // trim(dataFile%continents(i)%countries(j)%name)// ' [label="' // trim(dataFile%continents(i)%countries(j)%name) // '\n' // saturacion_pais // '" , fillcolor=' // color //'];' // new_line('A')
      dot_code = trim(dot_code) // eliminar_espacios(trim(dataFile%continents(i)%name)) // " -> " // eliminar_espacios(trim(dataFile%continents(i)%countries(j)%name)) // new_line('A')
      end do
    end do
    dot_code = trim(dot_code) // '}' // new_line('A')


    open(unit=11, file="automata.dot", status='replace')
    write(11, '(A)') trim(dot_code)
    close(11)

    !  Llamar a Graphviz para crear la imagen PNG
    call system("dot -Tpng automata.dot -o automata.png")

    ! Aquí va el código de la función graphiv_Process
  end subroutine graphiv_Process


  subroutine separar_por_lineas(texto, lineas, num_lineas)
    character(len=*), intent(in) :: texto
    character(len=:), allocatable, intent(out) :: lineas(:)
    integer, intent(out) :: num_lineas
    
    integer :: i, start, line_end
    
    ! Contar el número de líneas
    num_lineas = 1
    do i = 1, len(texto)
      if (texto(i:i) == new_line('A')) num_lineas = num_lineas + 1
    end do
    
    ! Asignar espacio para las líneas
    allocate(character(len=len(texto)) :: lineas(num_lineas))
    
    ! Separar el texto en líneas
    start = 1
    num_lineas = 0
    do i = 1, len(texto)
      if (texto(i:i) == new_line('A') .or. i == len(texto)) then
        line_end = i - 1
        if (i == len(texto) .and. texto(i:i) /= new_line('A')) line_end = i
        num_lineas = num_lineas + 1
        lineas(num_lineas) = texto(start:line_end)
        start = i + 1
      end if
    end do
  end subroutine separar_por_lineas

end module grafica_datos