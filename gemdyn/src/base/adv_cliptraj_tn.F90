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
!
      subroutine adv_cliptraj_tn (F_x, F_y, F_ni,F_nj,i0, in, j0, jn,mesg)
      use grid_options
      use glb_ld
      use adv_grid
      use outgrid
      implicit none
#include <arch_specific.hf>

      character(len=*) :: mesg
      integer,intent(in) :: i0,in,j0,jn !I, scope of the operator
      integer,intent(in) :: F_ni,F_nj
      real, dimension(F_ni,F_nj)  ::  F_x, F_y !I/O, upstream pos

   !@author Michel Desgagne, Spring 2008
   !@revisions
   ! v3_31 - Desgagne M.  - Initial version
   ! v4_40 - Qaddouri/Lee - Yin-Yang trajectory clipping
   !@objective Clip SL hor. trajectories to either fit inside the
   !                    physical domain of the processor or to the
   !                    actual maximum allowed COURANT number (LAM)

#include "stop_mpi.h"
#include "msg.h"


      real*8,  parameter :: EPS_8 = 1.D-5
!     integer, parameter :: BCS_BASE = 4
      integer :: BCS_BASE       ! BCS points for Yin-Yang, normal LAM

      character(len=MSG_MAXLEN) :: msg_S
      integer :: n, i,j, cnt, sum_cnt, err, totaln
      real :: minposx,maxposx,minposy,maxposy
!
!---------------------------------------------------------------------
!
      call timing_start2 (35, 'ADV_CLIP', 34)
      BCS_BASE= 4
      if (Grd_yinyang_L) BCS_BASE = 3
      minposx = adv_xx_8(adv_lminx+1) + EPS_8
      if (l_west)  minposx = adv_xx_8(1+BCS_BASE) + EPS_8
      maxposx = adv_xx_8(adv_lmaxx-1) - EPS_8
      if (l_east)  maxposx = adv_xx_8(F_ni-BCS_BASE) - EPS_8
      minposy = adv_yy_8(adv_lminy+1) + EPS_8
      if (l_south) minposy = adv_yy_8(1+BCS_BASE) + EPS_8
      maxposy = adv_yy_8(adv_lmaxy-1) - EPS_8
      if (l_north) maxposy = adv_yy_8(F_nj-BCS_BASE) - EPS_8

      cnt=0

!- Clipping to processor boundary
      do j=j0,jn
         do i=i0,in
            if ( (F_x(i,j)<minposx).or.(F_x(i,j)>maxposx).or. &
               (F_y(i,j)<minposy).or.(F_y(i,j)>maxposy) ) then
               cnt=cnt+1
            endif

            F_x(i,j) = min(max(F_x(i,j),minposx),maxposx)

            F_y(i,j) = min(max(F_y(i,j),minposy),maxposy)

         enddo
      enddo

      n = max(1,adv_maxcfl)

      totaln = (F_ni*n*2 + (F_nj-2*n)*n*2)

      call rpn_comm_Allreduce(cnt,sum_cnt,1,"MPI_INTEGER", "MPI_SUM","grid",err)

      if (trim(mesg) /= "" .and. sum_cnt>0) then
         write(msg_S,'(a,i5,a,f6.2,2x,a)')  &
         ' ADW trajtrunc: npts=',sum_cnt, &
         ', %=',real(sum_cnt)/real(totaln)*100., &
         mesg
         call msg(MSG_INFO,msg_S)
      endif

      call timing_stop (35)
!
!---------------------------------------------------------------------
!
      return
      end subroutine adv_cliptraj_tn

