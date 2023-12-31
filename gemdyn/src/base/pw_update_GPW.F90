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

!**s/r pw_update - Update physical quantities WZ, GZ, PM and PT
!
      subroutine pw_update_GPW()
      use gmm_geof
      use gmm_itf_mod
      use glb_ld
      use gmm_pw
      use gmm_vt1
      use ver
      implicit none
#include <arch_specific.hf>

!author
!     Michel Desgagne - May 2010
!
!revision
! v4_14 - Desgagne, M.     - Initial revision

      integer :: k, istat
      real, dimension(l_minx:l_maxx,l_miny:l_maxy,G_nk+1) :: fi
!     ________________________________________________________________
!
      call timing_start2 ( 5, 'PW_UPDATE', 0)

      istat = gmm_get(gmmk_pw_wz_plus_s , pw_wz_plus )
      istat = gmm_get(gmmk_pw_gz_plus_s , pw_gz_plus )
      istat = gmm_get(gmmk_pw_pm_plus_s , pw_pm_plus )
      istat = gmm_get(gmmk_pw_pt_plus_s , pw_pt_plus )
      istat = gmm_get(gmmk_pw_me_plus_s , pw_me_plus )
      istat = gmm_get(gmmk_pw_p0_plus_s , pw_p0_plus )
      istat = gmm_get(gmmk_pw_log_pm_s  , pw_log_pm  )
      istat = gmm_get(gmmk_pw_log_pt_s  , pw_log_pt  )

      istat = gmm_get(gmmk_tt1_s  ,   tt1)
      istat = gmm_get(gmmk_wt1_s  ,   wt1)
      istat = gmm_get(gmmk_st1_s  ,   st1)
      istat = gmm_get(gmmk_fis0_s ,  fis0)
      istat = gmm_get(gmmk_qt1_s  ,   qt1)

      call diag_fi (fi, st1, tt1, qt1, &
                    l_minx,l_maxx,l_miny,l_maxy,G_nk, 1, l_ni, 1, l_nj)

      call calc_pressure ( pw_pm_plus, pw_pt_plus, pw_p0_plus, st1, &
                           l_minx,l_maxx, l_miny,l_maxy, G_nk )

!$omp parallel private(k) shared(fi)
!$omp do
      do k=1,l_nk
         pw_wz_plus(:,:,k) = wt1(:,:,k)
         pw_gz_plus(1:l_ni,1:l_nj,k)= fi(1:l_ni,1:l_nj,k)
         pw_log_pm (1:l_ni,1:l_nj,k)= log(pw_pm_plus(1:l_ni,1:l_nj,k))
         pw_log_pt (1:l_ni,1:l_nj,k)= log(pw_pt_plus(1:l_ni,1:l_nj,k))
         if (k == 1) then
            pw_me_plus(1:l_ni,1:l_nj)= fis0(1:l_ni,1:l_nj)
         end if
         if (k == l_nk) then
            pw_log_pm(1:l_ni,1:l_nj,l_nk+1)= log(pw_p0_plus(1:l_ni,1:l_nj))
            pw_log_pt(1:l_ni,1:l_nj,l_nk+1)= pw_log_pm(1:l_ni,1:l_nj,l_nk+1)
         endif
      end do
!$omp enddo
!$omp end parallel

      call timing_stop (5)
!     ________________________________________________________________
!
      return
      end
