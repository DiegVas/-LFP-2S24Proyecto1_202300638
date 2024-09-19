program leer_archivo
    use token_module
    use grafica_datos
    use GraphTypes
    implicit none

    ! * Declaración de variables

    ! Variables para el manejo de archivos
    integer :: unidad, iostat, longitud, k 
    character(len=1000) :: buffer

    ! Variables para el manejo de la cadena
    character(len=:), allocatable :: contenido
    character(len=1) :: charLinea

    ! Variables para el análisis léxico
    integer :: state, token_Index, token_capacity, error_count, error_Index
    character(len=100) :: current_lexema

    ! Variables para el manejo de tokens
    type(token), allocatable :: tokens(:)
    type(error), allocatable :: errors(:)

    ! Variables para el análisis léxico
    character(len=100) :: lexema, descripcion
    integer :: linea_actual, columna_actual
    integer :: num
    character(len=1), parameter :: relevant_chars(4) = [char(123), char(125), char(46), char(58)]
    character(len=10), parameter :: reserved_words(7) = ['grafica   ', 'nombre    ', 'continente', 'pais      ', 'poblacion ', 'saturacion', 'bandera   ']


    ! * Inicializar variables
    columna_actual = 0
    error_count = 0
    error_Index = 0
    state = 0
    current_lexema = ''
    token_Index = 0
    token_capacity = 100  ! ? Tamaño inicial del arreglo de tokens
    unidad = 10 ! ? Asignar un número de unidad para el archivo
    contenido = '' ! ? Inicializar la cadena de contenido
    allocate(tokens(token_capacity)) ! ? Inicializar el arreglo de tokens
    allocate(errors(token_capacity)) ! ? Inicializar el arreglo de errores
    k = 1 ! ? Inicializar el índice de la cadena


    ! * Leer todo el contenido del archivo en una sola cadena

    do
        read(*, '(A)', iostat=iostat) buffer
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

                else if (charLinea == char(34)) then

                    ! ! Iniciar una cadena
                    state = 3
                    current_lexema = charLinea

                else if (charLinea == char(59)) then

                    ! ! Fin instruccion
                    state = 6
                    current_lexema = charLinea

                else if (charLinea >= "0" .and. charLinea <= "9") then

                    ! ! Iniciar un número
                    state = 7
                    current_lexema = charLinea
                else if (charLinea == char(32) .OR. charLinea == " " .or. charLinea == char(9)) then
                    ! ! Ignorar espacios
                else 

                    ! ? Caracter no reconocido
                    descripcion = 'Caracter no reconocido'

                    call add_error(error_Index, token_capacity, errors,charLinea, descripcion, linea_actual, columna_actual)
                    error_count = error_count + 1
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
                            lexema = 'Identificador no reconocido'
                            call add_error(error_Index, token_capacity, errors,trim(current_lexema),lexema, linea_actual, columna_actual)
                            error_count = error_count + 1
                        end if

                        call save_token(token_Index, tokens, trim(lexema), current_lexema, linea_actual, columna_actual)


                    ! ! Reiniciar el estado
                    state = 0
                    k = k - 1  ! Retroceder un carácter para reevaluar
                end if
            case (2)
                ! ? Procesar el símbolo encontrado
                lexema = 'Simbolo'
                call resize_tokens(token_Index, token_capacity, tokens)
                call save_token(token_Index, tokens, trim(lexema), current_lexema, linea_actual, columna_actual)


                ! ! Reiniciar el estado
                state = 0
                k = k - 1  ! Retroceder un carácter para reevaluar

            case (3)
                ! ? Inicio de una cadena
                    if (charLinea /= '"') then
                        state = 4
                        current_lexema = trim(current_lexema) // charLinea
                    else
                        descripcion = 'Se esperaba un caracter de cadena'

                        error_count = error_count + 1
                        call add_error(error_Index, token_capacity, errors,charLinea, descripcion, linea_actual, columna_actual)
                    end if
            case (4)
                ! ? Continuar con la cadena
                if (charLinea /= '"') then
                    current_lexema = trim(current_lexema) // charLinea
                else
                    current_lexema = trim(current_lexema) // charLinea

                    ! ! Reiniciar el estado
                    state = 5
                end if
            case (5)
                ! ? Fin de la cadena
                state = 0
                if ( charLinea /= "" ) then
                    ! ? Guardar el token
                    lexema = 'Cadena'
                    call resize_tokens(token_Index, token_capacity, tokens)
                    call save_token(token_Index,tokens, trim(lexema), current_lexema, linea_actual, columna_actual)
                    current_lexema = ""
                end if
                k = k - 1  ! Retroceder un carácter para reevaluar
            case (6)
                ! ? Fin de la instrucción
                state = 0
                lexema = 'Fin de instruccion'
                call resize_tokens(token_Index, token_capacity, tokens)
                call save_token(token_Index, tokens, trim(lexema), current_lexema, linea_actual, columna_actual)

                k = k - 1  ! Retroceder un carácter para reevaluar

            case (7)
                ! ? Inicio de un número
                if (charLinea >= "0" .and. charLinea <= "9") then
                    ! ? Continuar con el número
                    current_lexema = trim(current_lexema) // charLinea
                else
                    ! ? verificar si el siguiente carácter es un %
                    if (charLinea == "%") then
                        read(current_lexema, '(I10)', iostat=iostat) num
                        if (iostat == 0 .and. num < 100) then
                            ! ? Guardar el token
                            lexema = 'Saturacion del paiz'
                            current_lexema = trim(current_lexema) // charLinea
                            call resize_tokens(token_Index, token_capacity, tokens)
                            call save_token(token_Index, tokens, trim(lexema), current_lexema, linea_actual, columna_actual)

                            k = k + 1
                        else
                            descripcion = 'Se esperaba un numero menor a 100'

                            current_lexema = trim(current_lexema) // charLinea
                            call add_error(error_Index, token_capacity, errors,current_lexema, descripcion, linea_actual, columna_actual)
                            error_count = error_count + 1
                        end if
                    else
                        ! ? Guardar el token para cualquier valor de número
                        read(current_lexema, '(I10)', iostat=iostat) num
                        if (iostat == 0) then
                            lexema = 'Numero'
                            call resize_tokens(token_Index, token_capacity, tokens)
                            call save_token(token_Index, tokens, trim(lexema), current_lexema, linea_actual, columna_actual)

                        else
                            descripcion = 'Se esperaba un numero'

                            call add_error(error_Index, token_capacity, errors,charLinea, descripcion, linea_actual, columna_actual)
                            error_count = error_count + 1
                        end if
                    end if

                    ! ! Reiniciar el estado
                    state = 0
                    k = k - 1  ! Retroceder un carácter para reevaluar
                end if
        end select

        ! ? Avanzar al siguiente carácter
        k = k + 1
        columna_actual = columna_actual + 1
    end do

    call generate_html(tokens, token_Index, errors, error_Index)
    if ( error_count == 0 ) then
        call leer_grafica_datos(contenido)
    end if

    ! Liberar la memoria del arreglo
    if (allocated(tokens)) deallocate(tokens)
    if (allocated(errors) ) deallocate(errors)

contains

subroutine generate_html(tokens, token_count, errors, error_count)
    implicit none
    type(token), allocatable, intent(in) :: tokens(:)
    type(error), allocatable, intent(in) :: errors(:)
    integer, intent(in) :: token_count, error_count
    integer :: i, iostat
    character(len=1000) :: line
    character(len=100) :: tipo, lexema, fila_str, columna_str


    open(unit=10, file='output.html', status='replace', action='write', iostat=iostat)
    if (iostat /= 0) then
        print *, 'Error al abrir el archivo HTML.'
        stop
    end if

    write(10, '(A)') '<html>'
    write(10, '(A)') '<head><title>Resultados del Análisis Léxico</title>'
    write(10, '(A)') '<style>'
    write(10, '(A)') 'body { font-family: Arial, sans-serif; text-align: center; }'
    write(10, '(A)') 'table { margin: 0 auto; border-collapse: collapse; width: 80%; }'
    write(10, '(A)') 'th, td { border: 1px solid black; padding: 8px; text-align: left; }'
    write(10, '(A)') 'th { background-color: #f2f2f2; }'
    write(10, '(A)') 'h1 { text-align: center; }'
    write(10, '(A)') '</style>'
    write(10, '(A)') '</head>'
    write(10, '(A)') '<body>'
    if (error_count > 0) then
        write(10, '(A)') '<h1>Errores Lexicos</h1>'
        write(10, '(A)') '<table>'
        write(10, '(A)') '<tr><th>No.</th><th>Tipo</th><th>Lexema</th><th>Fila</th><th>Columna</th></tr>'
        do i = 1, error_count
            tipo = trim(adjustl(errors(i)%caracter))
            lexema = trim(adjustl(errors(i)%descripcion))
            write(fila_str, '(I0)') errors(i)%fila
            write(columna_str, '(I0)') errors(i)%columna
            write(line, '(A,I0, A, A, A, A, A, A, A, A, A)') '<tr><td>',i, '</td><td>', tipo, '</td><td>', lexema, '</td><td>', trim(fila_str), '</td><td>', trim(columna_str), '</td></tr>'
            write(10, '(A)') trim(line)
        end do
        write(10, '(A)') '</table>'
    else
        write(10, '(A)') '<h1>Tokens</h1>'
        write(10, '(A)') '<table>'
        write(10, '(A)') '<tr><th>No.</th><th>Tipo</th><th>Lexema</th><th>Fila</th><th>Columna</th></tr>'
        do i = 1, token_count
            tipo = trim(adjustl(tokens(i)%tipo))
            lexema = trim(adjustl(tokens(i)%lexema))
            write(fila_str, '(I0)') tokens(i)%row
            write(columna_str, '(I0)') tokens(i)%col
            write(line, '(A,I0, A, A, A, A, A, A, A, A, A)')"<tr><td>", i, '</td><td>', tipo, '</td><td>', lexema, '</td><td>', trim(fila_str), '</td><td>', trim(columna_str), '</td></tr>'
            write(10, '(A)') trim(line)
        end do
        write(10, '(A)') '</table>'
    end if
    write(10, '(A)') '</body>'
    write(10, '(A)') '</html>'

    close(10)
end subroutine generate_html


end program leer_archivo
