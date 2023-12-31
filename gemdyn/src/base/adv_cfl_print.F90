!---------------------------------- LICENCE BEGIN -------------------------------
! GEM - Library of kernel routines for the GEM numerical atmospheric model
! Copyright (C) 1990-2010 - Division de Recherche en Prevision Numerique
!                       Environnement Canada
! This library is free software; you can redistribute it and/or modify it
! under the terms of the GNU Lesser General Public License as published by
! the Free Software Foundation, version 2.1 of the License. This library is
! distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
! without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
! PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
! You should have received a copy of the GNU Lesser General Public License
! along with this library; if not, write to the Free Software Foundation, Inc.,
! 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
!---------------------------------- LICENCE END ---------------------------------

subroutine adv_cfl_print()
   use adv_cfl
   implicit none
#include <arch_specific.hf>
   !@objective Print precomputed CFL and reset stats
   !@author  Stephane Chamberland, 2010-01
   !@revisions
   !*@/
   real :: cfl
   !---------------------------------------------------------------------
   cfl = sngl(adv_cfl_8(1))
   write (6,99) 'x,y',adv_cfl_i(1,1),adv_cfl_i(2,1), adv_cfl_i(3,1),cfl
   cfl = sngl(adv_cfl_8(2))
   write (6,99) 'z'  ,adv_cfl_i(1,2),adv_cfl_i(2,2), adv_cfl_i(3,2),cfl
   cfl = sngl(adv_cfl_8(3))
   write (6,99) '3D' ,adv_cfl_i(1,3),adv_cfl_i(2,3), adv_cfl_i(3,3),cfl
   adv_cfl_8 (:  ) = 0.d0
   adv_cfl_i (:,:) = 0

99 format(' MAX COURANT NUMBER:  ', a3,': [(',i4,',',i4,',',i4,') ',f12.5,']')

   !---------------------------------------------------------------------
   return
end subroutine adv_cfl_print
