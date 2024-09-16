module grafica_datos
  use GraphTypes
  
contains

  subroutine leer_grafica_datos(contenido)
    implicit none
      type(Graph) :: graphFile
      character(len=:), allocatable :: contenido
      type(Country) :: country_select
      integer :: iostat,num_continentes, num_paises, pos, i
      real :: menor_saturacion
      character(len=200) :: linea
      character(len=5) :: saturacion, poblacion
      logical :: volver_a_leer

      ! Inicializar variables
      num_continentes = 0
      volver_a_leer = .false.

    ! Abrimos el archivo para leer

    ! Leemos linea por linea
    do
      if (.not. volver_a_leer) then
      read(contenido, '(A)', iostat=iostat) linea
      if (iostat /= 0) exit 
      else
        volver_a_leer = .false.
      end if

      ! Leemos el nombre de la gráfica
      if (index(linea, 'grafica:') > 0) then
      do
          read(contenido, '(A)', iostat=iostat) linea
          if (iostat /= 0) exit
          if (index(linea, 'nombre:') > 0) then
            call extraer_valor(linea, graphFile%name)
            exit
          endif
        end do
      endif

      ! Leemos los nombres de los continentes
      if (index(linea, 'continente') > 0) then
        num_continentes = num_continentes + 1
        if (.not. allocated(graphFile%continents)) then
          allocate(graphFile%continents(num_continentes))
        else
          call redimensionar_arreglo(graphFile%continents, num_continentes)
        endif
        
        do
          read(contenido, '(A)', iostat=iostat) linea
          if (iostat /= 0) exit
          if (index(linea, 'nombre:') > 0) then
            call extraer_valor(linea, graphFile%continents(num_continentes)%name)
            exit
          end if

        end do

        ! inicializar el numero de paises
        num_paises = 0

        ! Leemos los nombres de los paises
        do
          read(contenido, '(A)', iostat=iostat) linea
          if (iostat /= 0 .or. index(linea, 'continente') > 0) then
            volver_a_leer = .true.
            exit
          end if
          if (index(linea, 'pais') > 0) then
            num_paises = num_paises + 1
            if (.not. allocated(graphFile%continents(num_continentes)%countries)) then
              allocate(graphFile%continents(num_continentes)%countries(num_paises))
            else
              call redimensionar_arreglo_country(graphFile%continents(num_continentes)%countries, num_paises)
            end if

            do
              read(contenido, '(A)', iostat=iostat) linea
              if (iostat /= 0) exit
              if (index(linea, 'nombre:') > 0) then
                call extraer_valor(linea, graphFile%continents(num_continentes)%countries (num_paises)%name)
              else if (index(linea, 'poblacion:')>0) then
                call extraer_valor(linea, poblacion)
                read(poblacion, *) graphFile%continents(num_continentes)%countries(num_paises)%population
              else if (index(linea, 'saturacion:')>0) then
                call extraer_valor(linea, saturacion)
                if (index(saturacion, '%')>0) then
                  saturacion = saturacion(1:len_trim(saturacion)-1)
                endif
                read(saturacion, *) graphFile%continents(num_continentes)%countries(num_paises)%saturation
              else if (index(linea, 'bandera:')>0) then
                call extraer_valor(linea, graphFile%continents(num_continentes)%countries(num_paises)%flag)
              else
                exit
              endif
            end do
          end if
        end do

      endif
    end do


    menor_saturacion = 1.0e30  ! Un valor muy grande para empezar

    ! Recorrer todos los continentes y países para encontrar el país con la menor saturación
    do pos = 1, num_continentes
      do i = 1, size(graphFile%continents(pos)%countries)
        if (graphFile%continents(pos)%countries(i)%saturation < menor_saturacion) then
          menor_saturacion = graphFile%continents(pos)%countries(i)%saturation
          country_select = graphFile%continents(pos)%countries(i)
        endif
      end do
    end do

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

  subroutine redimensionar_arreglo(arreglo, nuevo_tamano)
    type(Continent), dimension(:), allocatable :: arreglo
    integer, intent(in) :: nuevo_tamano
    type(Continent), dimension(:), allocatable :: temp

    allocate(temp(nuevo_tamano))
    temp(1:size(arreglo)) = arreglo
    call move_alloc(temp, arreglo)
  end subroutine redimensionar_arreglo

  subroutine redimensionar_arreglo_country(arreglo, nuevo_tamano)
    type(Country), dimension(:), allocatable :: arreglo
    integer, intent(in) :: nuevo_tamano
    type(Country), dimension(:), allocatable :: temp

    allocate(temp(nuevo_tamano))
    temp(1:size(arreglo)) = arreglo
    call move_alloc(temp, arreglo)
  end subroutine redimensionar_arreglo_country

  subroutine graphiv_Process(dataFile)
    type(Graph) :: dataFile
    ! Aquí va el código de la función graphiv_Process
  end subroutine graphiv_Process

end module grafica_datos