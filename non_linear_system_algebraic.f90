module non_linear_system_algebraic
    use linear_system
    use diffur
	implicit none
    
    
!    -----------------------------------------------------
!    |   Module solves nonlinear systems                 |
!    |             with Newton's method                  |
!    |                                                   |
!    |               Input parameters:                   |
!    |   x_starting -- first guess                       |
!    |   f -- function (situated in another module func) |
!    |   x_starting -- final answer                      |
!	 -----------------------------------------------------
      
    
    real(16), parameter :: delta_x = 1e-8                                ! delta of x, needed when calculate f'
    real(16), parameter :: prec = 1e-8                                   ! precision of iterative method
    
	contains
	
        subroutine nonlinear_system_solver_algebraic ( x_starting, f, x_current )
        
            interface

            function f(x)
                real(16), dimension(0:2*size(u)+1) :: x
                real(16), dimension(0:2*size(u)+1) :: f
            end function f
            
            end interface
        
            real(16), dimension (:) :: x_starting
            real(16), dimension ( size( x_starting) ) :: x_current, x_previous, vector
            real(16), dimension ( size( x_starting), size( x_starting) ) :: Jacobi_matrix
            
            integer :: maximum_iter_num, N
            integer :: i, j
            
            i = 1
            maximum_iter_num = 400
            
            N = size( x_starting)
            
            x_current = x_starting
            
            do while( norm2( x_current - x_previous ) > prec .and. i <= maximum_iter_num) !main iteration cycle
                        
                x_previous = x_current			
                Jacobi_matrix = matrix_derivative_algebraic ( f, x_previous )                       ! calculation of f' matrix (matrix of linear system)
                
                vector = matmul(Jacobi_matrix, x_previous) - f(x_previous)                ! calculation of f'*x - f vector (vector of linear system)
                
                
                call Lin_sys_solver( Jacobi_matrix, vector, x_current, N , "Gauss")       ! solve linear system (f'*x = vector) with Gauss method
                
                i = i + 1                                                                 ! rise iteration step
                            
            enddo
        
		end subroutine nonlinear_system_solver_algebraic
        
        function matrix_derivative_algebraic( f, x )  result( derivative )        ! function which calculates derivative matrix of function f in given point(x)
        
            interface

            function f(x)
                real(16), dimension(0:2*size(u)+1) :: x
                real(16), dimension(0:2*size(u)+1) :: f
            end function f
            
            end interface
            
            real(16), dimension (:) :: x
            real(16), dimension ( size(x), size(x) ) :: derivative
            integer :: i
            
            do i = 1, size(x)                                           ! on each step function finds df/dx(i) aka matrix column with index i 
                if(i /= 1) then
                    x(i-1) = x(i-1) - delta_x                           ! small incriment of x used on previous step
                endif
                
                derivative(:, i) = f(x)
                x(i) = x(i) + delta_x                                   ! small incriment of x                           
                derivative(:, i) = ( f(x) - derivative(:, i) )/delta_x  ! linear approximation of derivative
                
            enddo
        
        end function matrix_derivative_algebraic
        
end module non_linear_system_algebraic
