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
!**s/r sol_2d - Elliptic solver based on vertical decomposition leading to
!               F_nk 2D horizontal elliptic problems to solve.
!
      subroutine sol_2d ( F_rhs_sol, F_lhs_sol, F_ni, F_nj, F_nk, &
                          F_print_L, F_offi, F_offj )
      use grid_options
      use gem_options
      use glb_ld
      use lun
      use ldnh
      use sol
      use opr
      use trp
      use ptopo
      implicit none
#include <arch_specific.hf>

      logical, intent(in) :: F_print_L
      integer, intent(in) :: F_ni,F_nj,F_nk,F_offi, F_offj
      real*8, dimension(F_ni,F_nj,F_nk), intent(in) :: F_rhs_sol
      real*8, dimension(F_ni,F_nj,F_nk), intent(inout) :: F_lhs_sol
!
!author
!     Michel Desgagne / Abdessamad Qaddouri -- January 2014
!
!revision
! v4_70 - Desgagne/Qaddouri  - initial version


      integer i,j,k,ni,nij,iter
      real linfini
      real*8, dimension (ldnh_maxx,ldnh_maxy,l_nk) :: wk1,wk2,wk3
      real*8 fdg1  ((ldnh_maxy -ldnh_miny +1)*(trp_12smax-trp_12smin+1)*(G_ni+Ptopo_npex  ))
      real*8 fdg2  ((trp_12smax-trp_12smin+1)*(trp_22max -trp_22min +1)*(G_nj+Ptopo_npey  ))
      real*8 fdwfft((ldnh_maxy -ldnh_miny +1)*(trp_12smax-trp_12smin+1)*(G_ni+2+Ptopo_npex))
!
!     ---------------------------------------------------------------
!
      ni   = ldnh_ni-pil_w-pil_e
      nij  = (ldnh_maxy-ldnh_miny+1)*(ldnh_maxx-ldnh_minx+1)
      wk1=0.0 ; wk2=0.0

      do j=1+pil_s,ldnh_nj-pil_n
         call dgemm ('N','N', ni, G_nk, G_nk, 1.0D0, F_rhs_sol(1+pil_w,j,1), &
                     nij, Opr_lzevec_8, G_nk, 0.0d0, wk1(1+pil_w,j,1), nij)
         do k=1,Schm_nith
            do i = 1+pil_w, ldnh_ni-pil_e
               wk1(i,j,k)= Opr_opsxp0_8(G_ni+F_offi+i) * &
                           Opr_opsyp0_8(G_nj+F_offj+j) * wk1(i,j,k)
            enddo
         end do
      end do

      if (Grd_yinyang_L) then
         wk3 = wk1
         do iter=1, Sol_yyg_maxits
            call sol_lam ( wk2, wk1, fdg1, fdg2, fdwfft, &
                           Lun_debug_L, F_ni, F_nj, F_nk )
            wk1 = wk3
            call yyg_rhs_scalbc(wk1, wk2, ldnh_minx, ldnh_maxx,&
                                ldnh_miny, ldnh_maxy, l_nk, iter, linfini)
            if (Lun_debug_L.and.F_print_L) write(Lun_out,1001) linfini,iter
            if ((iter > 1).and.(linfini < Sol_yyg_eps)) goto 999
         end do
 999     if (F_print_L) then
            write(Lun_out,1002) linfini,iter
            if (linfini > Sol_yyg_eps) write(Lun_out,9001) Sol_yyg_eps
         endif
      else
         call sol_lam ( wk2, wk1, fdg1, fdg2, fdwfft, &
                        F_print_L, F_ni, F_nj, F_nk )
      endif

      do j=1+pil_s,ldnh_nj-pil_n
         call dgemm ('N','T', ni, G_nk, G_nk, 1.0D0, wk2(1+pil_w,j,1), &
                      nij, Opr_zevec_8, G_nk, 0.0d0, F_lhs_sol(1+pil_w,j,1), nij)
      enddo

 1001 format (3x,'Iterative YYG    solver convergence criteria: ',1pe14.7,' at iteration', i3)
 1002 format (3x,'Final YYG    solver convergence criteria: ',1pe14.7,' at iteration', i3)
 9001 format (3x,'WARNING: iterative YYG solver DID NOT converge to requested criteria:: ',1pe14.7)
!
!     ---------------------------------------------------------------
!
      return
      end


