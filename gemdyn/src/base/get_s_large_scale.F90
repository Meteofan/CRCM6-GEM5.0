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

!**s/r get_s_large_scale - Obtain sls for large scale topography from SLEVE

      subroutine get_s_large_scale (F_topo_ls, Minx,Maxx,Miny,Maxy)
      use gmm_pw
      use gmm_geof
      use gem_options
      use tdpack
      use glb_ld
      use cstv
      use lun
      use gmm_itf_mod
      implicit none
#include <arch_specific.hf>

      integer Minx,Maxx,Miny,Maxy
      real :: F_topo_ls (Minx:Maxx,Miny:Maxy)

!author
!     A. Plante - Aut 2016
!
!revision
!

! Local varibales

      integer :: istat
      real*8 :: oneoRT
      real, dimension(:,:), pointer :: p0_ls
!
!
! From the hydrostic equation and the perfect gaz law we have
!
!   p           z
!  /         g / dz
!  |dlnp = - - | --
!  /         R / T
!  po          0
!
! Take T=To=const and integrating
! ln(p/po) = - gz/(RTo) = s (po = 100000.)

! We take To=Tcdk
!-----------------------------------------------------------------------

      istat = gmm_get (gmmk_sls_s     ,   sls )
      istat = gmm_get (gmmk_pw_p0_ls_s, p0_ls )

      if (.not.Schm_sleve_L) then
         sls = 0.0
         return
      endif

      if (Lun_debug_L) write (Lun_out,1000)

      oneoRT=1.d0/(rgasd_8*Tcdk_8)

      sls(1:l_ni,1:l_nj)= -F_topo_ls(1:l_ni,1:l_nj) * oneoRT

      p0_ls(1:l_ni,1:l_nj)= Cstv_pref_8 * exp(sls(1:l_ni,1:l_nj))

1000  format(3X,'COMPUTE LARGE SCALE S: (S/R GET_S_LARGE_SCALE)')

!-----------------------------------------------------------------------

      return
      end

