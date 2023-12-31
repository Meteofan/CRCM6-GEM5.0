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

!**s/r dynstep -  Control of the dynamical timestep of the model

      subroutine dynstep()
      use gem_options
      use glb_ld
      use gmm_itf_mod
      use gmm_orh
      use grid_options
      use lun
      use step_options
      use tr3d
      implicit none
#include <arch_specific.hf>

      character(len=GMM_MAXNAMELENGTH) :: tr_name
      logical first_L
      integer itraj, n, istat, keep_itcn
      real, pointer, dimension(:,:,:) :: tr1
!
!     ---------------------------------------------------------------
!

      if (Lun_debug_L) write(Lun_out,1000)
      call timing_start2 ( 10, 'DYNSTEP', 1 )

!     first_L is TRUE  for the first timestep
!           or the first timestep after digital filter initialisation

      first_L = (Step_kount == 1).or.(.not.Init_mode_L .and.  &
                 Step_kount == (Init_dfnp+1)/2)

      keep_itcn = Schm_itcn

      itraj = Schm_itraj

      if (Schm_bitpattern_L) then
         call pospers ()
      else
         if ( first_L) then
            call pospers ()
            itraj = max( 5, Schm_itraj )
         end if
      end if

      if (Lun_debug_L) write(Lun_out,1005) Schm_itcn-1

      call psadj_init ( Step_kount )

      do Orh_icn = 1,Schm_itcn-1

         call tstpdyn (itraj)
         itraj = Schm_itraj

         call hzd_momentum()
         call hzd_smago_momentum()

      end do

      if (Lun_debug_L) write(Lun_out,1006)

      Orh_icn=Schm_itcn

      call tstpdyn ( Schm_itraj )

      call tracers_step (.true. )

      call psadj ( Step_kount )

      call tracers_step (.false.)

!     ------------------------------------------------------------
!     C	  When the timestep is completed, rename all the
!     C        variables at time level t1 -> t0 and rename all the
!     C        variables at time level t0 -> t1 for the next timestep
!     ------------------------------------------------------------

      call t02t1()

      if (Grd_yinyang_L) then
         do n= 1, Tr3d_ntr
            tr_name = 'TR/'//trim(Tr3d_name_S(n))//':P'
            istat = gmm_get(tr_name, tr1)
            call yyg_xchng (tr1 , l_minx,l_maxx,l_miny,l_maxy, G_nk,&
                            .true., 'CUBIC')
         end do
      else
         call nest_gwa()
         call spn_main()
      end if

      call canonical_cases ("RAYLEIGH")

      call hzd_main_stag()
      call hzd_smago_main()

      call pw_update_GPW()
      call pw_update_UV()
      call pw_update_T()

      if ( Lctl_step-Vtopo_start == Vtopo_ndt) Vtopo_L = .false.

      Schm_itcn = keep_itcn

      call timing_stop ( 10 )

 1000 format( &
      /,'CONTROL OF DYNAMICAL STEP: (S/R DYNSTEP)', &
      /,'========================================'/)
 1005 format( &
      /3X,'##### Crank-Nicholson iterations: ===> PERFORMING',I3, &
          ' timestep(s) #####'/)
 1006 format( &
      /3X,'##### Crank-Nicholson iterations: ===> DONE... #####'/)
!
!     ---------------------------------------------------------------
!
      return
      end
