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

!**s/r psadj - Adjust surface pressure for conservation
!
      subroutine psadj (F_kount)
      use gmm_vt1
      use gmm_vt0
      use grid_options
      use gem_options
      use gmm_geof
      use geomh

      use glb_ld
      use cstv
      use lun
      use tr3d
      use psadjust
      use gmm_itf_mod
      use rstr
      implicit none
#include <arch_specific.hf>

      integer, intent(in) :: F_kount

!author
!     Andre Plante from hzd_main
!
!revision
! v4_05 - Lepine M.         - VMM replacement with GMM
! v4_50 - Qaddouri-PLante   - YY version
! v4_70 - Tanguay M.        - dry air pressure conservation
! v4_80 - Tanguay M.        - REAL*8 with iterations and psadj LAM
!

      type(gmm_metadata) :: mymeta
      integer err,i,j,n,istat,MAX_iteration
      real*8,dimension(l_minx:l_maxx,l_miny:l_maxy,1:l_nk):: pr_m_8,pr_t_8
      real*8,dimension(l_minx:l_maxx,l_miny:l_maxy)       :: pr_p0_0_8,pr_p0_w_0_8
      real*8 l_avg_8,g_avg_ps_0_8
      character(len= 9) communicate_S
!
!     ---------------------------------------------------------------
!
      if ( Grd_yinyang_L ) then
      !------------------------

      if ( Schm_psadj == 0 ) then
         if ( Schm_psadj_print_L ) goto 999
         return
      endif

      if ( Schm_psadj <= 2 ) then
         if ( Cstv_dt_8*F_kount <= Iau_period ) goto 999
      endif

      elseif ( .not.Grd_yinyang_L .and. Schm_psadj == 0 ) then
      !-------------------------------------------------------

         if ( Schm_psadj_print_L ) goto 999
         return

      else
      !---

         if ( Cstv_dt_8*F_kount <= Iau_period ) goto 999

         if (.not.Init_mode_L) call adv_psadj_LAM_0

         if ( Schm_psadj_print_L ) goto 999

         return

      endif
      !----

      communicate_S = "GRID"
      if (Grd_yinyang_L) communicate_S = "MULTIGRID"

      istat = gmm_get(gmmk_fis0_s,fis0)
      istat = gmm_get(gmmk_st0_s,st0,mymeta)

      MAX_iteration = 3
      if (Schm_psadj==1) MAX_iteration = 1

      do n= 1,MAX_iteration

         !Obtain pressure levels
         !----------------------
         call calc_pressure_8 (pr_m_8,pr_t_8,pr_p0_0_8,st0,l_minx,l_maxx,l_miny,l_maxy,l_nk)

         !Compute dry surface pressure (- Cstv_pref_8)
         !--------------------------------------------
         if (Schm_psadj>=2) then

            call dry_sfc_pressure_8 (pr_p0_w_0_8,pr_m_8,pr_p0_0_8,l_minx,l_maxx,l_miny,l_maxy,l_nk,'M')

         !Compute wet surface pressure (- Cstv_pref_8)
         !--------------------------------------------
         elseif (Schm_psadj==1) then

            pr_p0_w_0_8(1:l_ni,1:l_nj) = pr_p0_0_8(1:l_ni,1:l_nj) - Cstv_pref_8

         endif

         l_avg_8 = 0.0d0
         do j=1+pil_s,l_nj-pil_n
         do i=1+pil_w,l_ni-pil_e
            l_avg_8 = l_avg_8 + pr_p0_w_0_8(i,j) * geomh_area_8(i,j) * geomh_mask_8(i,j)
         enddo
         enddo

         call RPN_COMM_allreduce (l_avg_8,g_avg_ps_0_8,1, &
                   "MPI_DOUBLE_PRECISION","MPI_SUM",communicate_S,err)

         g_avg_ps_0_8 = g_avg_ps_0_8 * PSADJ_scale_8

         !Correct surface pressure in order to preserve air mass
         !------------------------------------------------------
         do j=1+pil_s,l_nj-pil_n
         do i=1+pil_w,l_ni-pil_e
            if(fis0(i,j) > 1.) then
               pr_p0_0_8(i,j) = pr_p0_0_8(i,j) + &
                 (PSADJ_g_avg_ps_initial_8 - g_avg_ps_0_8)*PSADJ_fact_8
            else
               pr_p0_0_8(i,j) = pr_p0_0_8(i,j) + &
                 (PSADJ_g_avg_ps_initial_8 - g_avg_ps_0_8)*Cstv_psadj_8
            endif
            st0(i,j) = log(pr_p0_0_8(i,j)/Cstv_pref_8)
         end do
         end do

      end do

  999 continue

      if (Schm_psadj_print_L) call stat_psadj (0,"AFTER DYNSTEP")
!
!     ---------------------------------------------------------------
!
      return
      end
