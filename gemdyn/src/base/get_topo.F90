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

!**s/r get_topo - Obtain topography from geophysical file

      subroutine get_topo ( F_topo, F_topo_ls, Minx,Maxx,Miny,Maxy, i0,in,j0,jn)
      use grid_options
      use gem_options
      use tdpack
      use glb_ld
      use path
      use ptopo
      implicit none
#include <arch_specific.hf>

      integer Minx,Maxx,Miny,Maxy, i0,in,j0,jn
      real :: F_topo (Minx:Maxx,Miny:Maxy), F_topo_ls (Minx:Maxx,Miny:Maxy)

!author
!     M. Desgagne  -   Spring 2010
!
!revision
! v4_13 -  Desgagne M.           - initial version
! v4_80 -  Deagagne M.           - new min:max interface
!

      character(len=8) :: inttyp
      character(len=1024) :: fn
      integer status
      real   xfi(G_ni), yfi(G_nj), topo_destination(G_ni,G_nj)
      real*8 rad2deg_8
!
!-----------------------------------------------------------------------
!
      status = 0

      if (.not.Schm_topo_L) then
         F_topo   = 0.0
         F_topo_ls = 0.0
         return
      endif

      If (Ptopo_myproc==0) Then
         inttyp      = 'LINEAR'
         rad2deg_8   = 180.0d0/Acos(-1.d0)
         xfi(1:G_ni) = G_xg_8(1:G_ni)*rad2deg_8
         yfi(1:G_nj) = G_yg_8(1:G_nj)*rad2deg_8
         fn = trim(Path_input_S)//'/GEOPHY/Gem_geophy.fst'
         call get_field ( topo_destination, G_ni, G_nj, 'ME', trim(fn), &
                          inttyp, xfi, yfi, status)
      endif
      call handle_error (status,'GET_TOPO','Topography "ME" NOT specified')
      call glbdist (topo_destination,G_ni,G_nj,F_topo,Minx,Maxx,Miny,Maxy,1,0,0)
      F_topo(i0:in,j0:jn) = F_topo(i0:in,j0:jn) * grav_8

      if(Schm_sleve_L)then
         If (Ptopo_myproc==0) Then
            call get_field ( topo_destination, G_ni, G_nj, 'MELS', trim(fn), &
                 inttyp, xfi, yfi, status)
         endif
         call handle_error (status,'GET_TOPO','Topography large scale "MESL" NOT specified')
         call glbdist (topo_destination,G_ni,G_nj,F_topo_ls,Minx,Maxx,Miny,Maxy,1,0,0)
         F_topo_ls(i0:in,j0:jn) = F_topo_ls(i0:in,j0:jn) * grav_8
      else
         F_topo_ls = 0.0
      endif

!
!-----------------------------------------------------------------------
!
      return
      end
