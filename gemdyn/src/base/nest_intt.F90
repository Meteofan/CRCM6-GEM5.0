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

!**s/r nest_intt -- Linear interpolation in time of nesting data
!
      subroutine nest_intt()
      use cstv
      use gem_options
      use gmm_itf_mod
      use gmm_nest
      use glb_ld
      use lun
      use tr3d
      use step_options
      implicit none
#include <arch_specific.hf>

!author   M. Desgagne - April 2002
!
!revision
! v3_01 - Desgagne M.               - initial version (after MC2 v_4.9.3)
! v3_03 - Tanguay M.                - Adjoint Lam configuration
! v3_20 - Pellerin P. and Y. Delage - Special interpolations for MEC
! v4    - Girard-Plante-Lee         - Staggered version
! v4_04 - Plante A.                 - Remove offline
! v4_05 - Lepine M.                 - VMM replacement with GMM
! v4_10 - Tanguay M.                - Adjust digital filter when LAM


      integer,external ::  newdate
!
      character(len=16) :: datev
      character(len=GMM_MAXNAMELENGTH) :: tr_name
      integer :: yy,mo,dd,hh,mm,ss,dum,n,istat
      real, pointer, dimension(:,:,:) :: tr_deb,tr_fin,tr
      real*8 :: dayfrac,tx,dtf,a,b
      real*8, parameter :: one=1.0d0, sid=86400.0d0, rsid=one/sid
!
!     ---------------------------------------------------------------
!
      dayfrac = dble(Step_kount) * Cstv_dt_8 * rsid
      call incdatsd  (datev, Step_runstrt_S, dayfrac)
      call prsdate   (yy,mo,dd,hh,mm,ss,dum,datev)
      call pdfjdate2 (tx, yy,mo,dd,hh,mm,ss)

      istat = gmm_get(gmmk_nest_u_deb_s ,nest_u_deb )
      istat = gmm_get(gmmk_nest_v_deb_s ,nest_v_deb )
      istat = gmm_get(gmmk_nest_t_deb_s ,nest_t_deb )
      istat = gmm_get(gmmk_nest_s_deb_s ,nest_s_deb )
      istat = gmm_get(gmmk_nest_w_deb_s ,nest_w_deb )
      istat = gmm_get(gmmk_nest_q_deb_s ,nest_q_deb )
      istat = gmm_get(gmmk_nest_zd_deb_s,nest_zd_deb)
      istat = gmm_get(gmmk_nest_fullme_deb_s,nest_fullme_deb)

      istat = gmm_get(gmmk_nest_u_s ,nest_u )
      istat = gmm_get(gmmk_nest_v_s ,nest_v )
      istat = gmm_get(gmmk_nest_t_s ,nest_t )
      istat = gmm_get(gmmk_nest_s_s ,nest_s )
      istat = gmm_get(gmmk_nest_w_s ,nest_w )
      istat = gmm_get(gmmk_nest_q_s ,nest_q )
      istat = gmm_get(gmmk_nest_zd_s,nest_zd)
      istat = gmm_get(gmmk_nest_fullme_s,nest_fullme)

      istat = gmm_get(gmmk_nest_u_fin_s ,nest_u_fin )
      istat = gmm_get(gmmk_nest_v_fin_s ,nest_v_fin )
      istat = gmm_get(gmmk_nest_t_fin_s ,nest_t_fin )
      istat = gmm_get(gmmk_nest_s_fin_s ,nest_s_fin )
      istat = gmm_get(gmmk_nest_w_fin_s ,nest_w_fin )
      istat = gmm_get(gmmk_nest_q_fin_s ,nest_q_fin )
      istat = gmm_get(gmmk_nest_zd_fin_s,nest_zd_fin)
      istat = gmm_get(gmmk_nest_fullme_fin_s,nest_fullme_fin)

      dayfrac = Step_nesdt*rsid

      if (tx < Lam_tdeb) then

         Lam_current_S  = Step_runstrt_S
         Lam_previous_S = Lam_current_S
         call prsdate   (yy,mo,dd,hh,mm,ss,dum,Step_runstrt_S)
         call pdfjdate2 (Lam_tdeb,yy,mo,dd,hh,mm,ss)
         do
            call incdatsd (datev, Lam_current_S,dayfrac)
            Lam_current_S = datev
            call prsdate   (yy,mo,dd,hh,mm,ss,dum,Lam_current_S)
            call pdfjdate2 (Lam_tfin, yy,mo,dd,hh,mm,ss)
            if (Lam_tfin >= tx) exit
            Lam_previous_S = Lam_current_S
            Lam_tdeb       = Lam_tfin
         end do
         Lam_current_S = Lam_previous_S
         Lam_tfin      = Lam_tdeb

         call nest_indata ( Lam_previous_S )

      endif

      dtf = 1.0d0
      if (tx > Lam_tfin) then
         dtf = (tx-Lam_tfin) * sid / Cstv_dt_8
         Lam_previous_S = Lam_current_S
         Lam_tdeb       = Lam_tfin

         call incdatsd (datev, Lam_current_S, dayfrac)
         Lam_current_S = datev
         call prsdate   (yy,mo,dd,hh,mm,ss,dum,Lam_current_S)
         call pdfjdate2 (Lam_tfin, yy,mo,dd,hh,mm,ss)

         nest_u_deb  = nest_u_fin
         nest_v_deb  = nest_v_fin
         nest_t_deb  = nest_t_fin
         nest_s_deb  = nest_s_fin
         nest_w_deb  = nest_w_fin
         nest_q_deb  = nest_q_fin
         nest_zd_deb = nest_zd_fin
         nest_fullme_deb = nest_fullme_fin
         do n=1,Tr3d_ntr
            tr_name = 'NEST/'//trim(Tr3d_name_S(n))//':F'
            istat = gmm_get(tr_name,tr_fin)
            tr_name = 'NEST/'//trim(Tr3d_name_S(n))//':A'
            istat = gmm_get(tr_name,tr_deb)
            tr_deb = tr_fin
         end do

         call nest_indata ( Lam_current_S )

      endif
!
!     Temporal linear interpolation
!
      call timing_start2 ( 28, 'NESTINTT', 10)

      b = (tx - Lam_tdeb) / (Lam_tfin - Lam_tdeb)
      a = one - b

      if (Lun_debug_L) write(Lun_out,'(/"In nest_intt, temporal interpolation parametres A,B =",1p2e24.16/)') a,b

      nest_u (1:l_ni,1:l_nj,1:G_nk) = a*nest_u_deb (1:l_ni,1:l_nj,1:G_nk) + b*nest_u_fin (1:l_ni,1:l_nj,1:G_nk)
      nest_v (1:l_ni,1:l_nj,1:G_nk) = a*nest_v_deb (1:l_ni,1:l_nj,1:G_nk) + b*nest_v_fin (1:l_ni,1:l_nj,1:G_nk)
      nest_t (1:l_ni,1:l_nj,1:G_nk) = a*nest_t_deb (1:l_ni,1:l_nj,1:G_nk) + b*nest_t_fin (1:l_ni,1:l_nj,1:G_nk)
      nest_s (1:l_ni,1:l_nj       ) = a*nest_s_deb (1:l_ni,1:l_nj       ) + b*nest_s_fin (1:l_ni,1:l_nj       )
      nest_w (1:l_ni,1:l_nj,1:G_nk) = a*nest_w_deb (1:l_ni,1:l_nj,1:G_nk) + b*nest_w_fin (1:l_ni,1:l_nj,1:G_nk)
      nest_q (1:l_ni,1:l_nj,1:G_nk+1) = a*nest_q_deb (1:l_ni,1:l_nj,1:G_nk+1) + b*nest_q_fin (1:l_ni,1:l_nj,1:G_nk+1)
      nest_zd(1:l_ni,1:l_nj,1:G_nk) = a*nest_zd_deb(1:l_ni,1:l_nj,1:G_nk) + b*nest_zd_fin(1:l_ni,1:l_nj,1:G_nk)
      nest_fullme(1:l_ni,1:l_nj       ) = a*nest_fullme_deb(1:l_ni,1:l_nj       ) + b*nest_fullme_fin (1:l_ni,1:l_nj      )

      do n=1,Tr3d_ntr
         tr_name = 'NEST/'//trim(Tr3d_name_S(n))//':F'
         istat = gmm_get(tr_name,tr_fin)
         tr_name = 'NEST/'//trim(Tr3d_name_S(n))//':C'
         istat = gmm_get(tr_name,tr)
         tr_name = 'NEST/'//trim(Tr3d_name_S(n))//':A'
         istat = gmm_get(tr_name,tr_deb)
         tr (1:l_ni,1:l_nj,1:G_nk) = a*tr_deb(1:l_ni,1:l_nj,1:G_nk) + b*tr_fin(1:l_ni,1:l_nj,1:G_nk)
      end do

      call timing_stop ( 28 )
!
!     ---------------------------------------------------------------
!
      return
      end

