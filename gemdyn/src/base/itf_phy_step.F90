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

!**s/r itf_phy_step - Apply the physical processes: CMC/RPN package

      subroutine itf_phy_step ( F_step_kount, F_lctl_step )
      use iso_c_binding
      use phy_itf, only: phy_input,phy_step,phy_snapshot
      use itf_phy_cloud_objects, only: cldobj_displace,cldobj_expand,CLDOBJ_OK
      use itf_phy_filter, only: ipf_smooth_fld
      use gem_options
      use step_options, only: Step_CMCdate0
      use cstv, only: Cstv_dt_8
      use lun
      use tr3d
      use rstr
      use path
      use wb_itf_mod
      use ptopo
      use mu_jdate_mod, only: jdate_to_print, jdate_from_cmc
      implicit none
#include <arch_specific.hf>

      integer, intent(IN) :: F_step_kount, F_lctl_step

!arguments
!  Name        I/O                 Description
!----------------------------------------------------------------
! F_step_kount  I          step count
! F_lctl_step   I          step number
!----------------------------------------------------------------

      include "rpn_comm.inc"

      integer,external :: itf_phy_prefold_opr

      integer err_geom, err_input, err_step, err_smooth, err
      logical :: cloudobj
!
!     ---------------------------------------------------------------
!
      if ( Rstri_user_busper_L .and. (F_step_kount == 0) ) return

      call timing_start2 ( 40, 'PHYSTEP', 1 )

!!$      if (Lun_out > 0) write (Lun_out,1002) F_lctl_step, F_step_kount, &
!!$           jdate_to_print( &
!!$           jdate_from_cmc(Step_CMCdate0)+nint(F_step_kount*Cstv_dt_8))
      if (Lun_out > 0) write (Lun_out,1001) F_lctl_step

      if (F_step_kount == 0) then
         call itf_phy_geom4 (err_geom)
         if (NTR_Tr3d_ntr > 0) then
            err = wb_put('itf_phy/READ_TRACERS', &
                                NTR_Tr3d_name_S(1:NTR_Tr3d_ntr))
         endif
      endif

      !call pw_glbstat('DEBUG')

      call itf_phy_copy ()

      call timing_start2 ( 45, 'PHY_input', 40 )
      err_input = phy_input ( itf_phy_prefold_opr, F_step_kount, &
            Path_phyincfg_S, Path_phy_S, 'GEOPHY/Gem_geophy.fst' )

      call gem_error (err_input,'itf_phy_step','Problem with phy_input')
      call timing_stop  ( 45 )

      ! Smooth the thermodynamic state variables on request
      err_smooth = min(&
           ipf_smooth_fld('TPOSTCND','TTMS'), &
           ipf_smooth_fld('HUPOSTCND','HUMS'), &
           ipf_smooth_fld('PW_TT:P','TTPS'), &
           ipf_smooth_fld('TR/HU:P','HUPS') &
           )
      call gem_error (err_smooth,'itf_phy_step','Problem with ipf_smooth_fld')

      ! Advect cloud objects
      if (.not.WB_IS_OK(wb_get('phy/deep_cloudobj',cloudobj))) cloudobj = .false.
      if (cloudobj .and. F_lctl_step > 0) then
         if (cldobj_displace() /= CLDOBJ_OK) &
              call gem_error (-1,'itf_phy_step','Problem with cloud object displacement')
      endif


      call set_num_threads ( Ptopo_nthreads_phy, F_step_kount )

      call timing_start2 ( 46, 'PHY_step', 40 )
      err_step = phy_step ( F_step_kount, F_lctl_step )
      call rpn_comm_barrier (RPN_COMM_ALLGRIDS, err)
      call timing_stop  ( 46 )

      call gem_error (err_step,'itf_phy_step','Problem with phy_step')

      call set_num_threads ( Ptopo_nthreads_dyn, F_step_kount )

      call timing_start2 ( 47, 'PHY_update', 40 )
      call itf_phy_update3 ( F_step_kount > 0 )
      call timing_stop  ( 47 )

      call timing_start2 ( 48, 'PHY_output', 40 )
      call itf_phy_output2 ( F_lctl_step )
      call timing_stop  ( 48 )

      if ( Init_mode_L ) then
         if (F_step_kount ==   Init_halfspan) then
            err = phy_snapshot('W')
         else if (F_step_kount == 2*Init_halfspan) then
            err = phy_snapshot('R')
         endif
      endif

      call timing_stop ( 40 )

 1001 format(/,'PHYSICS : PERFORMING TIMESTEP #',I9, &
             /,'========================================')
 1002 format(/,'PHYSICS : PERFORMING TIMESTEP #',I9,'[',I9,', ',a,']', &
             /,'========================================')
!
!     ---------------------------------------------------------------
!
      return
      end subroutine itf_phy_step
