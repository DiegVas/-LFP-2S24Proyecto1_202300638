program parse_org_file
    implicit none
    character(len=1000) :: line
    character(len=1000), allocatable :: file_content(:)
    integer :: i, num_lines, unit, ios
    type :: Country
        character(len=50) :: name
        integer :: population
        integer :: saturation
        character(len=100) :: flag
    end type Country

    type :: Continent
        character(len=50) :: name
        type(Country), allocatable :: countries(:)
    end type Continent

    type(Continent), allocatable :: continents(:)

    ! Open the file and read its content
    open(unit=10, file='Prueba.org', status='old', action='read')
    num_lines = 0
    do
        read(10, '(A)', iostat=ios) line
        if (ios /= 0) exit
        num_lines = num_lines + 1
    end do
    rewind(10)
    allocate(file_content(num_lines))
    do i = 1, num_lines
        read(10, '(A)', iostat=ios) file_content(i)
        if (ios /= 0) exit
    end do
    close(10)

    ! Parse the content
    call parse_content(file_content, num_lines, continents)

    ! Print the structured information
    call print_data(continents)

contains

    subroutine parse_content(file_content, num_lines, continents)
        character(len=1000), intent(in) :: file_content(:)
        integer, intent(in) :: num_lines
        type(Continent), allocatable, intent(out) :: continents(:)
        integer :: i, j, k, num_continents, num_countries, ios
        character(len=1000) :: line
        logical :: in_continent, in_country
        character(len=50) :: temp_str
        type(Continent), allocatable :: temp_continents(:)

        num_continents = 0
        in_continent = .false.
        in_country = .false.

        do i = 1, num_lines
            line = adjustl(file_content(i))
            if (index(line, 'continente {') > 0) then
                num_continents = num_continents + 1
                in_continent = .true.
                in_country = .false.
                allocate(temp_continents(num_continents))
                if (num_continents > 1) then
                    temp_continents(1:num_continents-1) = continents
                    deallocate(continents)
                end if
                temp_continents(num_continents)%name = trim(adjustl(file_content(i+1)(10:)))
                num_countries = 0
                continents = temp_continents
            else if (index(line, 'pais: {') > 0 .and. in_continent) then
                num_countries = num_countries + 1
                in_country = .true.
                allocate(continents(num_continents)%countries(num_countries))
                read(file_content(i+1), '(A)', iostat=ios) line
                if (ios == 0) continents(num_continents)%countries(num_countries)%name = trim(adjustl(line(10:)))
                read(file_content(i+2), '(A)', iostat=ios) line
                if (ios == 0) read(trim(adjustl(line(12:))), *, iostat=ios) continents(num_continents)%countries(num_countries)%population
                if (ios /= 0) print *, 'Error reading population at line ', i+2
                read(file_content(i+3), '(A)', iostat=ios) line
                if (ios == 0) read(trim(adjustl(line(14:))), *, iostat=ios) continents(num_continents)%countries(num_countries)%saturation
                if (ios /= 0) print *, 'Error reading saturation at line ', i+3
                read(file_content(i+4), '(A)', iostat=ios) line
                if (ios == 0) continents(num_continents)%countries(num_countries)%flag = trim(adjustl(line(11:)))
            end if
        end do
    end subroutine parse_content

    subroutine print_data(continents)
        type(Continent), intent(in) :: continents(:)
        integer :: i, j

        do i = 1, size(continents)
            print *, 'Continente: ', trim(continents(i)%name)
            do j = 1, size(continents(i)%countries)
                print *, '  País: ', trim(continents(i)%countries(j)%name)
                print *, '    Población: ', continents(i)%countries(j)%population
                print *, '    Saturación: ', continents(i)%countries(j)%saturation, '%'
                print *, '    Bandera: ', trim(continents(i)%countries(j)%flag)
            end do
        end do
    end subroutine print_data

end program parse_org_file