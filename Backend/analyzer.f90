program leer_archivo
    use token_module
    implicit none

    ! * Declaración de variables

    ! Variables para el manejo de archivos
    integer :: unidad, iostat, longitud, k 
    character(len=1000) :: buffer

    ! Variables para el manejo de la cadena
    character(len=:), allocatable :: contenido
    character(len=1) :: charLinea

    ! Variables para el análisis léxico
    integer :: state, token_Index, token_capacity
    character(len=100) :: current_lexema

    ! Variables para el manejo de tokens
    type(token), allocatable :: tokens(:)

    ! Variables para el análisis léxico
    character(len=100) :: lexema
    integer :: linea_actual, columna_actual
    character(len=1), parameter :: relevant_chars(4) = [char(123), char(125), char(46), char(58)]
    character(len=10), parameter :: reserved_words(7) = ['grafica   ', 'nombre    ', 'continente', 'pais      ', 'poblacion ', 'saturacion', 'bandera   ']

    ! * Inicializar variables
    state = 0
    current_lexema = ''
    token_Index = 0
    token_capacity = 100  ! ? Tamaño inicial del arreglo de tokens
    unidad = 10 ! ? Asignar un número de unidad para el archivo
    contenido = '' ! ? Inicializar la cadena de contenido
    allocate(tokens(token_capacity)) ! ? Inicializar el arreglo de tokens
    k = 1 ! ? Inicializar el índice de la cadena


    ! * Abrir el archivo en modo de lectura

    open(unit=unidad, file='./test/Prueba.org', status='old', action='read', iostat=iostat)
    if (iostat /= 0) then
        print *, 'Error al abrir el archivo.'
        stop
    end if


    ! * Leer todo el contenido del archivo en una sola cadena

    do
        read(unit=unidad, fmt='(A)', iostat=iostat) buffer
        if (iostat /= 0) exit
        contenido = trim(contenido) // trim(buffer) // char(10)
    end do

    ! Guardar el tamaño de la cadena
    longitud = len_trim(contenido)

    ! ! Cerrar el archivo
    close(unit=unidad)



    ! * Recorrer el contenido del archivo

    do while (k <= longitud)

        ! ? Obtener el carácter actual
        charLinea = contenido(k:k)

        select case (state)
            case (0) ! * Estado inicial
                if (charLinea == char(10)) then
                    ! ! Salto de linea

                    linea_actual = linea_actual + 1
                    columna_actual = 1
                    
                else if (charLinea >= 'a' .and. charLinea <= 'z') then
                    ! ! Iniciar un identificador

                    state = 1
                    current_lexema = charLinea
                else if (any(charLinea == relevant_chars)) then
                    ! ! Iniciar un símbolo

                    state = 2
                    current_lexema = charLinea
                else if (charLinea == ' ') then
                    ! ! Ignorar espacios

                else
                    ! ! Error de lexema
                    print *, 'Error de lexema: ', charLinea
                end if

            case (1) ! * Estado de identificador
                if (charLinea >= 'a' .and. charLinea <= 'z') then
                    ! ! Continuar con el identificador
                    current_lexema = trim(current_lexema) // charLinea
                else
                    ! ? Guardar el token

                    call resize_tokens(token_Index, token_capacity, tokens)
                    ! ? Verificar si es una palabra reservada

                        if (any(current_lexema == reserved_words)) then
                            lexema = 'Palabra reservada'
                        else
                            lexema = 'Identificador'
                        end if

                        call save_token(token_Index, tokens, trim(lexema), current_lexema, linea_actual, columna_actual)
                        print *, trim(lexema), ": ", current_lexema

                    ! ! Reiniciar el estado
                    state = 0
                    k = k - 1  ! Retroceder un carácter para reevaluar
                end if
            case (2)
                ! ? Procesar el símbolo encontrado
                call resize_tokens(token_Index, token_capacity, tokens)
                call save_token(token_Index, tokens, 'Simbolo', current_lexema, linea_actual, linea_actual)
                print *, 'Simbolo: ', current_lexema

                ! ! Reiniciar el estado
                state = 0

        end select

        ! ? Avanzar al siguiente carácter
        k = k + 1
        columna_actual = columna_actual + 1
    end do

    ! Liberar la memoria del arreglo
    if (allocated(tokens)) deallocate(tokens)

end program leer_archivo



! * Adminstracion de tokens

module token_module
    implicit none
    type :: token
        character(len=100) :: tipo
        character(len=100) :: lexema
        integer :: row
        integer :: col
    end type token
contains
    subroutine resize_tokens(token_Index, token_capacity, tokens)
        implicit none
        integer, intent(inout) :: token_Index
        integer, intent(inout) :: token_capacity
        type(token), allocatable, intent(inout) :: tokens(:)
        type(token), allocatable :: temp_tokens(:)

        token_Index = token_Index + 1
        if (token_Index > token_capacity) then
            token_capacity = token_capacity * 2
            allocate(temp_tokens(token_capacity))
            temp_tokens(1:token_Index-1) = tokens
            deallocate(tokens)
            allocate(tokens(token_capacity))
            tokens(1:token_Index-1) = temp_tokens(1:token_Index-1)
            deallocate(temp_tokens)
        end if
    end subroutine resize_tokens

    subroutine save_token(token_Index, tokens, tipo, lexema, row, col)
        implicit none
        integer, intent(in) :: token_Index
        type(token), allocatable, intent(inout) :: tokens(:)
        character(len=*), intent(in) :: tipo, lexema
        integer, intent(in) :: row, col

        tokens(token_Index)%tipo = tipo
        tokens(token_Index)%lexema = trim(lexema)
        tokens(token_Index)%row = row
        tokens(token_Index)%col = col
    end subroutine save_token

end module token_module