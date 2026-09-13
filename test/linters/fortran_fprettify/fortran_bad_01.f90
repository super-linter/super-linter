program bad_format
implicit none
integer :: i
real :: x

x=0.0
do i=1,10
x=x+real(i)
if(x>5.0) then
print *,"x is greater than 5"
end if
end do

print *,"Sum:",x
end program bad_format
