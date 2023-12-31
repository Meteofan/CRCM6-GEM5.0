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

      function adv_nml (F_nmlFileName_S) result (F_stat)
      use adv_grid
      use adv_options
      use grid_options
      use outgrid
      implicit none
#include <arch_specific.hf>

!@objective Advection default configuration and reading namelists adv_cfgs
!@arguments
      character(len=*) :: F_nmlFileName_S
!@returns
      integer :: F_stat
!@author Stephane Chamberland, Nov 2009
!@revisions
! v4_80 - Tanguay M.        - GEM4 Mass-Conservation

#include "msg.h"

      integer :: fileUnit
      integer, external :: file_open_existing
!
!---------------------------------------------------------------------
!
      F_stat = -1
      fileUnit = file_open_existing(F_nmlFileName_S,'SEQ')
      if (fileUnit >= 0) then
         read(fileUnit, nml=adv_cfgs, iostat=F_stat)
         call fclos(fileUnit)
         F_stat = -1 * F_stat
         if (F_stat<0) then
            call msg(MSG_ERROR,'adv_nml - Probleme reading nml adv_cfgs in file: '//trim(F_nmlFileName_S))
         endif
      endif

      adv_maxcfl= max(1,Grd_maxcfl)
      adv_halox = max(1,adv_maxcfl + 1)
      adv_haloy = adv_halox
!
!---------------------------------------------------------------------
!
      return
      end function adv_nml

      subroutine adv_nml_print()
      use adv_options
      implicit none
#include <arch_specific.hf>

#include "msg.h"

      integer :: msgUnit
      integer, external :: msg_getUnit

!---------------------------------------------------------------------
      msgUnit = msg_getUnit(MSG_INFO)
      if (msgUnit>=0) write(msgUnit,nml=adv_cfgs)
!---------------------------------------------------------------------
      return
      end subroutine adv_nml_print
