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

!**s/r itf_ens_init - initialize ensemble prevision system
!
      subroutine itf_ens_init
      use gem_options
      use grid_options
      use glb_ld
      use lun
      use path
      use wb_itf_mod
      implicit none
#include <arch_specific.hf>

!     author
!     Lubos Spacek - December 2009
!
!     revision
! v4_12 - Spacek L.        - Initial version
! v4.4.0 - Gagnon N.       - Remove ptp_env_hor_f and add ptp_cape and ptp_tlc
! v4.5.0 - Gagnon N.       - Add ptp_crit_w and ptp_fac_reduc
!                          - Add else for non-ensemble case


      integer, external :: ens_nml
      integer err
!
!-------------------------------------------------------------------
!
! Read the namelist
!
      if (Lun_out > 0) write(Lun_out,1000)

      err= ens_nml (Path_nml_S, Grd_typ_S, Lun_out)

      if(err==-3) then
        if (Lun_out > 0) write(Lun_out,1010)
        return
      endif

      call handle_error (err,'itf_ens_init','Problem with ens_nml')

      call ens_setmem (l_ni, l_nj, l_nk, Lun_out)

 1000 format(/,'INITIALIZATION OF ENSEMBLES (S/R ITF_ENS_INIT)'/(46('=')))
 1010 format(/,'NO ENSEMBLES REQUIRED       (S/R ITF_ENS_INIT)'/(46('=')))
!
!-------------------------------------------------------------------
!
      return
      end
