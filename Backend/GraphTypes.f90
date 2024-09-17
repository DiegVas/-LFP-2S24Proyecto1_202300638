module graphTypes
    implicit none

    type :: Country
        character(len=50) :: name
        integer :: population
        real :: saturation
        character(len=100) :: flag
    end type Country

    type :: Continent
        character(len=50) :: name
        real :: saturation_Continent
        type(Country), dimension(:), allocatable :: countries
    end type Continent

    type :: Graph
        character(len=50) :: name
        type(Continent), dimension(:), allocatable :: continents
    end type Graph
end module graphTypes