! * Adminstracion de tokens

module token_module
    implicit none
    type :: token
        character(len=100) :: tipo
        character(len=100) :: lexema
        integer :: row
        integer :: col
    end type token

    type :: error
        character(len=:),allocatable :: caracter
        character(len=100) :: descripcion
        integer :: fila
        integer :: columna
    end type error

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

        subroutine add_error(error_Index, error_capacity, errors, caracter, descripcion, fila, columna)
        implicit none
        integer, intent(inout) :: error_Index
        integer, intent(inout) :: error_capacity
        type(error), allocatable, intent(inout) :: errors(:)
        type(error), allocatable :: temp_errors(:)
        character(len=*), intent(in) :: caracter
        character(len=100), intent(in) :: descripcion
        integer, intent(in) :: fila, columna

        error_Index = error_Index + 1
        if (error_Index > error_capacity) then
            error_capacity = error_capacity * 2
            allocate(temp_errors(error_capacity))
            temp_errors(1:error_Index-1) = errors
            deallocate(errors)
            allocate(errors(error_capacity))
            errors(1:error_Index-1) = temp_errors(1:error_Index-1)
            deallocate(temp_errors)
        end if

        allocate(character(len=len(caracter)) :: errors(error_Index)%caracter)
        errors(error_Index)%caracter = caracter
        errors(error_Index)%descripcion = descripcion
        errors(error_Index)%fila = fila
        errors(error_Index)%columna = columna
    end subroutine add_error


end module token_module