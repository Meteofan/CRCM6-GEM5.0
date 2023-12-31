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

!**s/r get_density - Evaluate Fluid's density and mass

      subroutine get_density (F_density,F_mass,F_time,Minx,Maxx,Miny,Maxy,F_nk,F_k0)

      use gmm_vt1
      use gmm_vt0
      use gem_options
      use geomh
      use tdpack
      use glb_ld
      use ver
      use gmm_itf_mod
      implicit none

      !Arguments
      !---------
      integer,                                    intent(in) :: F_time              !I, Time 0 or Time 1
      integer,                                    intent(in) :: Minx,Maxx,Miny,Maxy !I, Dimension H
      integer,                                    intent(in) :: F_k0                !I, scope of operator
      integer,                                    intent(in) :: F_nk                !I, number of vertical levels

      real, dimension(Minx:Maxx,Miny:Maxy,F_nk),  intent(out):: F_density           !O, Fluid's density
      real, dimension(Minx:Maxx,Miny:Maxy,F_nk),  intent(out):: F_mass              !O, Fluid's mass

      !object
      !======================================
      !     Evaluate Fluid's density and mass
      !======================================


      !-----------------------------------------------------------------------------

      real, pointer, dimension(:,:)   :: w2d
      integer i,j,k,istat
      real, dimension(Minx:Maxx,Miny:Maxy)         :: pr_p0
      real, dimension(Minx:Maxx,Miny:Maxy,1:F_nk+1):: pr_m,pr_t
      real, dimension(Minx:Maxx,Miny:Maxy,F_nk)    :: sumq
      real, pointer, dimension(:,:,:)              :: tr
      character(len=1) :: timelevel_S

      !-----------------------------------------------------------------------------

      !Recuperate GMM variables at appropriate time
      !--------------------------------------------
      if (F_time == 0) istat = gmm_get(gmmk_st0_s,w2d)
      if (F_time == 1) istat = gmm_get(gmmk_st1_s,w2d)

      !Evaluate Pressure based on pw_update_GPW
      !----------------------------------------
      call calc_pressure ( pr_m, pr_t, pr_p0, w2d, l_minx, l_maxx, l_miny, l_maxy, F_nk )

      pr_m(1:l_ni,1:l_nj,F_nk+1) = pr_p0(1:l_ni,1:l_nj)

      !Evaluate water tracers if dry mixing ratio
      !------------------------------------------
      sumq = 0.

      if (Schm_dry_mixing_ratio_L) then

         if (F_time == 1) timelevel_S = 'P'
         if (F_time == 0) timelevel_S = 'M'

         call sumhydro (sumq,l_minx,l_maxx,l_miny,l_maxy,l_nk,timelevel_S)

         istat = gmm_get('TR/HU:'//timelevel_S,tr)


         do k=1,l_nk
            sumq(1+pil_w:l_ni-pil_e,1+pil_s:l_nj-pil_n,k)= &
            sumq(1+pil_w:l_ni-pil_e,1+pil_s:l_nj-pil_n,k)+ &
            tr  (1+pil_w:l_ni-pil_e,1+pil_s:l_nj-pil_n,k)
         end do


      endif

      !Evaluate Fluid's density and mass
      !---------------------------------
      if (.NOT.Schm_testcases_L) then


         do k=F_k0,F_nk
            do j=1,l_nj
            do i=1,l_ni
               F_density(i,j,k) = +(pr_m(i,j,k+1) - pr_m(i,j,k)) * (1.-sumq(i,j,k)) * Ver_idz_8%t(k) / grav_8
            end do
            end do
         end do


      else


         do k=F_k0,F_nk
            do j=1,l_nj
            do i=1,l_ni
               F_density(i,j,k) = +pr_t(i,j,k) * (1.0 + Ver_dbdz_8%t(k) * w2d(i,j)) / grav_8
            end do
            end do
         end do


      endif


      do k=F_k0,F_nk
         do j=1,l_nj
         do i=1,l_ni
            F_mass(i,j,k) = F_density(i,j,k) * geomh_area_8(i,j) * Ver_dz_8%t(k)
         end do
         end do
      end do


      !---------------------------------------------------------------

      return
      end
