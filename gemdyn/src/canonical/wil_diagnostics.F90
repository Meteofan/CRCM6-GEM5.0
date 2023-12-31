!--------------------------------- LICENCE BEGIN -------------------------------
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

!**s/r wil_diagnostics - Evaluate Error norms L1,L2,LMASS,L_inf for Williamson's cases

      subroutine wil_diagnostics (F_my_step)


      use adv_options
      use canonical
      use gem_options
      use grid_options
      use geomh
      use step_options
      use wil_options

      use glb_ld
      use cstv
      use lun
      use tr3d
      use gmm_itf_mod
      use ptopo
      implicit none

      integer F_my_step

      !object
      !================================================================================
      !   Evaluate Error norms L1,L2,LMASS,L_inf for Williamson's cases
      !================================================================================


      !---------------------------------------------------------------

      integer istat,i,j,k,n,ierr,istat1,istat2

      real, pointer    , dimension(:,:,:) :: tr,tr_r,cl,cl2

      real*4, parameter :: CLY_REF = 4.*10.**(-6)

      real(8) norm_1_8,norm_2_8,norm_inf_8,norm_m_8, &
              s_err_1_8,s_ref_1_8,s_err_2_8,s_ref_2_8,s_err_m_8,s_ref_m_8,s_err_inf_8,s_ref_inf_8, &
              g_err_1_8,g_ref_1_8,g_err_2_8,g_ref_2_8,g_err_m_8,g_ref_m_8,g_err_inf_8,g_ref_inf_8, &
              w1_8,w2_8

      character(len= 12) name_S
      character(len= 9)  communicate_S

      real, dimension(l_minx:l_maxx,l_miny:l_maxy,G_nk):: bidon,mass

      !---------------------------------------------------------------

      if (Adv_verbose==0) return

      if (Williamson_case/=1) return

      if (F_my_step<Step_total.and.(Williamson_NAIR==1.or.Williamson_NAIR==2).and..not.Williamson_Terminator_L) return

      if (Lun_out>0.and.Ptopo_couleur==0) write (Lun_out,1000)

      call get_density (bidon,mass,1,l_minx,l_maxx,l_miny,l_maxy,G_nk,1) !TIME T1

      do n=1,Tr3d_ntr

         if (.NOT.((Tr3d_name_S(n)(1:2)=='Q1').or. &
                   (Tr3d_name_S(n)(1:2)=='Q2').or. &
                   (Tr3d_name_S(n)(1:2)=='Q3').or. &
                   (Tr3d_name_S(n)(1:2)=='Q4'))) cycle

         if (Lctl_step/=Step_total    .and.(Williamson_NAIR==1.or.Williamson_NAIR==2)) cycle

         if (Tr3d_name_S(n)(1:2)/='Q1'.and.(Williamson_NAIR==0.or.Williamson_NAIR==3)) cycle

         istat = gmm_get('TR/'//trim(Tr3d_name_S(n))//':P',tr)

         if (Tr3d_name_S(n)(1:2)=='Q1') istat = gmm_get(gmmk_q1ref_s,tr_r)
         if (Tr3d_name_S(n)(1:2)=='Q2') istat = gmm_get(gmmk_q2ref_s,tr_r)
         if (Tr3d_name_S(n)(1:2)=='Q3') istat = gmm_get(gmmk_q3ref_s,tr_r)
         if (Tr3d_name_S(n)(1:2)=='Q4') istat = gmm_get(gmmk_q4ref_s,tr_r)

         !Initialize REFERENCE at TIME>0
         !------------------------------
         if (Williamson_Nair==0) call wil_case1(tr_r,l_minx,l_maxx,l_miny,l_maxy,G_nk,0,Lctl_step)
         if (Williamson_Nair==3) call wil_case1(tr_r,l_minx,l_maxx,l_miny,l_maxy,G_nk,5,Lctl_step)

         s_err_1_8 = 0.; s_err_2_8 = 0.; s_err_m_8 = 0.; s_err_inf_8 = 0.
         s_ref_1_8 = 0.; s_ref_2_8 = 0.; s_ref_m_8 = 0.; s_ref_inf_8 = 0.

         do k = 1,G_nk

            do j = 1+pil_s,l_nj-pil_n

               do i = 1+pil_w,l_ni-pil_e

                  s_err_1_8 = s_err_1_8 + abs(tr(i,j,k) - tr_r(i,j,k))    * mass(i,j,k) * geomh_mask_8(i,j)
                  s_ref_1_8 = s_ref_1_8 + abs(            tr_r(i,j,k))    * mass(i,j,k) * geomh_mask_8(i,j)

                  s_err_2_8 = s_err_2_8 +    (tr(i,j,k) - tr_r(i,j,k))**2 * mass(i,j,k) * geomh_mask_8(i,j)
                  s_ref_2_8 = s_ref_2_8 +    (            tr_r(i,j,k))**2 * mass(i,j,k) * geomh_mask_8(i,j)

                  s_err_m_8 = s_err_m_8 +    (tr(i,j,k) - tr_r(i,j,k))    * mass(i,j,k) * geomh_mask_8(i,j)
                  s_ref_m_8 = s_ref_m_8 +    (            tr_r(i,j,k))    * mass(i,j,k) * geomh_mask_8(i,j)

                  w1_8 = abs( tr(i,j,k) - tr_r(i,j,k) )
                  w2_8 = abs(             tr_r(i,j,k) )

                  s_err_inf_8 = max( s_err_inf_8, w1_8 )
                  s_ref_inf_8 = max( s_ref_inf_8, w2_8 )

               end do

            end do

         end do

         communicate_S = "GRID"
         if (Grd_yinyang_L) communicate_S = "MULTIGRID"

         call RPN_COMM_allreduce(s_err_1_8,g_err_1_8,1,"MPI_double_precision","MPI_SUM",communicate_S,ierr)
         call RPN_COMM_allreduce(s_ref_1_8,g_ref_1_8,1,"MPI_double_precision","MPI_SUM",communicate_S,ierr)
         call RPN_COMM_allreduce(s_err_2_8,g_err_2_8,1,"MPI_double_precision","MPI_SUM",communicate_S,ierr)
         call RPN_COMM_allreduce(s_ref_2_8,g_ref_2_8,1,"MPI_double_precision","MPI_SUM",communicate_S,ierr)
         call RPN_COMM_allreduce(s_err_m_8,g_err_m_8,1,"MPI_double_precision","MPI_SUM",communicate_S,ierr)
         call RPN_COMM_allreduce(s_ref_m_8,g_ref_m_8,1,"MPI_double_precision","MPI_SUM",communicate_S,ierr)

         call RPN_COMM_allreduce(s_err_inf_8,g_err_inf_8,1,"MPI_double_precision","MPI_MAX",communicate_S,ierr)
         call RPN_COMM_allreduce(s_ref_inf_8,g_ref_inf_8,1,"MPI_double_precision","MPI_MAX",communicate_S,ierr)

         !Evaluate Norms
         !--------------
         norm_1_8 = 10.**8; norm_2_8 = 10.**8; norm_m_8 = 10.**8; norm_inf_8 = 10.**8

         if (g_ref_1_8  /=0.0d0) norm_1_8   =     (g_err_1_8/g_ref_1_8)
         if (g_ref_2_8  /=0.0d0) norm_2_8   = sqrt(g_err_2_8/g_ref_2_8)
         if (g_ref_m_8  /=0.0d0) norm_m_8   =     (g_err_m_8/g_ref_m_8)
         if (g_ref_inf_8/=0.0d0) norm_inf_8 = g_err_inf_8/g_ref_inf_8

         !Print Norms
         !-----------
         if (Lun_out>0.and.Ptopo_couleur==0) then
            if (Tr3d_name_S(n)(1:2)=='Q1') name_S = 'TRACER Q1 '
            if (Tr3d_name_S(n)(1:2)=='Q2') name_S = 'TRACER Q2 '
            if (Tr3d_name_S(n)(1:2)=='Q3') name_S = 'TRACER Q3 '
            if (Tr3d_name_S(n)(1:2)=='Q4') name_S = 'TRACER Q4 '
            write (Lun_out,*) ' +++++++++++++++++++++++++++++++++++++++++++'
            write (Lun_out,1001) name_S,'TIME (days) = ',(F_my_step*Cstv_dt_8)/3600./24.,' ERROR NORM L1    = ',norm_1_8
            write (Lun_out,1001) name_S,'TIME (days) = ',(F_my_step*Cstv_dt_8)/3600./24.,' ERROR NORM L2    = ',norm_2_8
            write (Lun_out,1001) name_S,'TIME (days) = ',(F_my_step*Cstv_dt_8)/3600./24.,' ERROR NORM LMASS = ',norm_m_8
            write (Lun_out,1001) name_S,'TIME (days) = ',(F_my_step*Cstv_dt_8)/3600./24.,' ERROR NORM L_inf = ',norm_inf_8
            write (Lun_out,*) ' +++++++++++++++++++++++++++++++++++++++++++'
            write (Lun_out,*) ' '
         endif

      end do

      if (Williamson_Terminator_L) then

         istat1 = gmm_get ('TR/CL:P' , cl )
         istat2 = gmm_get ('TR/CL2:P', cl2)

         !Initialize CLY
         !--------------
         istat = gmm_get (gmmk_cly_s, cly)

         cly(1:l_ni,1:l_nj,1:G_nk) = cl(1:l_ni,1:l_nj,1:G_nk) + 2.0d0 * cl2(1:l_ni,1:l_nj,1:G_nk)

         !Initialize CLY REFERENCE
         !------------------------
         istat = gmm_get (gmmk_clyref_s, clyref)

         clyref(1:l_ni,1:l_nj,1:G_nk) =  CLY_REF

         s_err_1_8 = 0.; s_err_2_8 = 0.; s_err_m_8 = 0.; s_err_inf_8 = 0.
         s_ref_1_8 = 0.; s_ref_2_8 = 0.; s_ref_m_8 = 0.; s_ref_inf_8 = 0.

         do k=1,G_nk
            do j = 1+pil_s,l_nj-pil_n
            do i = 1+pil_w,l_ni-pil_e

               s_err_1_8 = s_err_1_8 + abs(cly(i,j,k) - clyref(i,j,k))    * mass(i,j,k) * geomh_mask_8(i,j)
               s_ref_1_8 = s_ref_1_8 + abs(             clyref(i,j,k))    * mass(i,j,k) * geomh_mask_8(i,j)

               s_err_2_8 = s_err_2_8 +    (cly(i,j,k) - clyref(i,j,k))**2 * mass(i,j,k) * geomh_mask_8(i,j)
               s_ref_2_8 = s_ref_2_8 +    (             clyref(i,j,k))**2 * mass(i,j,k) * geomh_mask_8(i,j)

               s_err_m_8 = s_err_m_8 +    (cly(i,j,k) - clyref(i,j,k))    * mass(i,j,k) * geomh_mask_8(i,j)
               s_ref_m_8 = s_ref_m_8 +    (             clyref(i,j,k))    * mass(i,j,k) * geomh_mask_8(i,j)

               w1_8 = abs(cly(i,j,k) - clyref(i,j,k))
               w2_8 = abs(             clyref(i,j,k))

               s_err_inf_8 = max(s_err_inf_8, w1_8)
               s_ref_inf_8 = max(s_ref_inf_8, w2_8)

            end do
            end do
         end do

         communicate_S = "GRID"
         if (Grd_yinyang_L) communicate_S = "MULTIGRID"

         call RPN_COMM_allreduce(s_err_1_8,  g_err_1_8,  1,"MPI_double_precision","MPI_SUM",communicate_S,ierr)
         call RPN_COMM_allreduce(s_ref_1_8,  g_ref_1_8,  1,"MPI_double_precision","MPI_SUM",communicate_S,ierr)
         call RPN_COMM_allreduce(s_err_2_8,  g_err_2_8,  1,"MPI_double_precision","MPI_SUM",communicate_S,ierr)
         call RPN_COMM_allreduce(s_ref_2_8,  g_ref_2_8,  1,"MPI_double_precision","MPI_SUM",communicate_S,ierr)
         call RPN_COMM_allreduce(s_err_m_8,  g_err_m_8,  1,"MPI_double_precision","MPI_SUM",communicate_S,ierr)
         call RPN_COMM_allreduce(s_ref_m_8,  g_ref_m_8,  1,"MPI_double_precision","MPI_SUM",communicate_S,ierr)
         call RPN_COMM_allreduce(s_err_inf_8,g_err_inf_8,1,"MPI_double_precision","MPI_MAX",communicate_S,ierr)
         call RPN_COMM_allreduce(s_ref_inf_8,g_ref_inf_8,1,"MPI_double_precision","MPI_MAX",communicate_S,ierr)

         !Evaluate Norms
         !--------------
         norm_1_8 = 10.**8; norm_2_8 = 10.**8; norm_m_8 = 10.**8; norm_inf_8 = 10.**8

         if (g_ref_1_8  /=0.0d0) norm_1_8   =     (g_err_1_8  /g_ref_1_8)
         if (g_ref_2_8  /=0.0d0) norm_2_8   = sqrt(g_err_2_8  /g_ref_2_8)
         if (g_ref_m_8  /=0.0d0) norm_m_8   =     (g_err_m_8  /g_ref_m_8)
         if (g_ref_inf_8/=0.0d0) norm_inf_8 =      g_err_inf_8/g_ref_inf_8

         !Print Norms
         !-----------
         if (Lun_out>0.and.Ptopo_couleur==0) then
            write (Lun_out,*) ' +++++++++++++++++++++++++++++++++++++++++++'
            write (Lun_out,1001) "TRACER CLY ",'TIME (days) = ',(F_my_step*Cstv_dt_8)/3600./24.,' ERROR NORM L1    = ',norm_1_8
            write (Lun_out,1001) "TRACER CLY ",'TIME (days) = ',(F_my_step*Cstv_dt_8)/3600./24.,' ERROR NORM L2    = ',norm_2_8
            write (Lun_out,1001) "TRACER CLY ",'TIME (days) = ',(F_my_step*Cstv_dt_8)/3600./24.,' ERROR NORM LMASS = ',norm_m_8
            write (Lun_out,1001) "TRACER CLY ",'TIME (days) = ',(F_my_step*Cstv_dt_8)/3600./24.,' ERROR NORM L_inf = ',norm_inf_8
            write (Lun_out,*) ' +++++++++++++++++++++++++++++++++++++++++++'
            write (Lun_out,*) ' '
         endif

      endif

      !-----------------------------------------------------------------

      return

 1000 format( &
      /,'EVALUATE WILLIAMSON ERROR NORMS: (S/R WIL_DIAGNOSTICS)',   &
      /,'======================================================',/,/)
 1001 format(A12,1X,A14,F10.4,A20,E14.7)

      end subroutine wil_diagnostics
