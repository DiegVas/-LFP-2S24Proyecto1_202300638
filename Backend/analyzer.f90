module analizador_mod
    implicit none
contains
    ! Subrutina para obtener el siguiente token de una línea
    subroutine obtener_token(linea, posicion, token)
        implicit none
        character(*), intent(in) :: linea
        integer, intent(inout) :: posicion
        character(:), allocatable, intent(out) :: token
        integer :: len_linea, inicio, fin
        character :: c

        len_linea = len(linea)
        token = ''
        inicio = posicion

        ! Saltar espacios en blanco
        do while (posicion <= len_linea)
            c = linea(posicion:posicion)
            if (c /= ' ' .and. c /= char(9)) exit
            posicion = posicion + 1
        end do

        if (posicion > len_linea) then
            token = ''
            return
        end if

        c = linea(posicion:posicion)

        ! Si es un símbolo simple
        if (c == '{' .or. c == '}' .or. c == ':' .or. c == ';') then
            allocate(character(1) :: token)
            token = c
            posicion = posicion + 1
            return
        end if

        ! Si es una cadena entre comillas
        if (c == '"') then
            inicio = posicion
            posicion = posicion + 1
            do while (posicion <= len_linea)
                c = linea(posicion:posicion)
                if (c == '"') then
                    posicion = posicion + 1
                    exit
                end if
                posicion = posicion + 1
            end do
            fin = posicion - 1
            allocate(character(fin - inicio + 1) :: token)
            token = linea(inicio:fin)
            return
        end if

        ! Para palabras y números
        inicio = posicion
        do while (posicion <= len_linea)
            c = linea(posicion:posicion)
            if (c == ' ' .or. c == '{' .or. c == '}' .or. c == ':' .or. c == ';') exit
            posicion = posicion + 1
        end do
        fin = posicion - 1
        allocate(character(fin - inicio + 1) :: token)
        token = linea(inicio:fin)

    end subroutine obtener_token

    ! Función que verifica si un token es una cadena
    logical function es_cadena(token)
        implicit none
        character(*), intent(in) :: token
        integer :: len_token
        len_token = len_trim(token)
        es_cadena = .false.
        if (len_token >= 2) then
            if (token(1:1) == '"' .and. token(len_token:len_token) == '"') then
                es_cadena = .true.
            end if
        end if
    end function es_cadena

    ! Función que verifica si un token es un entero
    logical function es_entero(token)
        implicit none
        character(*), intent(in) :: token
        integer :: valor, iostat
        read(token, *, iostat=iostat) valor
        es_entero = (iostat == 0)
    end function es_entero

    ! Función que verifica si un token es un porcentaje
    logical function es_porcentaje(token)
        implicit none
        character(*), intent(in) :: token
        integer :: len_token, valor, iostat
        len_token = len_trim(token)
        es_porcentaje = .false.
        if (len_token >= 2) then
            if (token(len_token:len_token) == '%') then
                read(token(1:len_token-1), *, iostat=iostat) valor
                if (iostat == 0) then
                    es_porcentaje = .true.
                end if
            end if
        end if
    end function es_porcentaje

end module analizador_mod

program automata_dinamico
    use analizador_mod
    implicit none

    ! Variables
    character(:), allocatable :: linea, token
    integer :: estado, posicion, iostat
    integer :: len_linea

    ! Definir estados
    integer, parameter :: INICIO = 0, DENTRO_GRAFICA = 1, ESPERA_CONTINENTE = 2
    integer, parameter :: DENTRO_CONTINENTE = 3, DENTRO_PAIS = 4, ESPERA_ATRIBUTOS = 5
    integer, parameter :: ERROR = -1

    ! Inicializar el estado
    estado = INICIO

    ! Abrir archivo de entrada
    open(unit=10, file='entrada.org', status='old', action='read', iostat=iostat)
    if (iostat /= 0) then
        print *, 'Error al abrir el archivo de entrada.'
        stop
    end if

    ! Leer el archivo línea por línea
    do
        ! Leer una línea completa de longitud variable
        read(10, '(A)', iostat=iostat) linea
        if (iostat /= 0) exit  ! Salir del bucle si llegamos al final del archivo

        ! Remover espacios iniciales y finales
        linea = adjustl(linea)
        linea = trim(linea)
        len_linea = len(linea)

        ! Inicializar posición al inicio de la línea
        posicion = 1

        ! Procesar la línea si no está vacía
        if (len_linea > 0) then
            do while (posicion <= len_linea)
                call obtener_token(linea, posicion, token)

                if (len(token) == 0) exit  ! No hay más tokens en esta línea

                ! Analizar el token según el estado actual
                select case (estado)
                case (INICIO)
                    if (token == 'grafica') then
                        estado = DENTRO_GRAFICA
                    else
                        estado = ERROR
                        print *, 'Error: Se esperaba ''grafica''.'
                        exit
                    end if
                ! Continuar el análisis con el resto de los casos como antes...

                end select

            end do
        end if
    end do

    ! Cerrar archivo
    close(10)

    ! Verificar si el análisis fue exitoso
    if (estado /= ERROR) then
        print *, 'Análisis completado con éxito.'
    end if

end program automata_dinamico
