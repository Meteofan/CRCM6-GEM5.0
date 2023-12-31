!**s/p Bermejo_Conde - Ensures conservation of interpolated field (Bermejo and Conde,2002)

      subroutine Bermejo_Conde (F_name_S,F_out,F_high,F_low,F_min,F_max,F_old,F_for_flux_o,F_for_flux_i, &
                                Minx,Maxx,Miny,Maxy,F_nk,k0,F_BC_min_max_L,F_CLIP_L,F_ILMC_L)

      use grid_options
      use gem_options
      use glb_ld
      use lun
      use tracers
      implicit none

      !Arguments
      !---------
      character (len=*), intent(in) :: F_name_S                           !I, Name of field to be ajusted
      integer,           intent(in) :: Minx,Maxx,Miny,Maxy                !I, Dimension H
      integer,           intent(in) :: k0                                 !I, Scope of operator
      integer,           intent(in) :: F_nk                               !I, Number of vertical levels
      logical,           intent(in) :: F_BC_min_max_L                     !I, T IF MONO(CLIPPING) after Bermejo-Conde
      logical,           intent(in) :: F_CLIP_L                           !I, T IF F_high is MONO(CLIPPING)
      logical,           intent(in) :: F_ILMC_L                           !I, T IF F_high is MONO(ILMC)
      real, dimension(Minx:Maxx,Miny:Maxy,F_nk), intent(out)    :: F_out  !I: Corrected (conservative) solution
      real, dimension(Minx:Maxx,Miny:Maxy,F_nk), intent(in)     :: F_high !I: High-order SL solution based on F_CLIP_L,F_ILMC_L
      real, dimension(Minx:Maxx,Miny:Maxy,F_nk), intent(in)     :: F_low  !I:  Low-order SL solution
      real, dimension(Minx:Maxx,Miny:Maxy,F_nk), intent(in)     :: F_min  !I: MIN over cell
      real, dimension(Minx:Maxx,Miny:Maxy,F_nk), intent(in)     :: F_max  !I: MAX over cell
      real, dimension(Minx:Maxx,Miny:Maxy,F_nk), intent(in)     :: F_old  !I: Field at previous time step
      real, dimension(Minx:Maxx,Miny:Maxy,F_nk), intent(in)     :: F_for_flux_o !I: Advected mixing ratio with 0 in NEST
      real, dimension(Minx:Maxx,Miny:Maxy,F_nk), intent(in)     :: F_for_flux_i !I: Advected mixing ratio with 0 in CORE

      !Author Monique Tanguay
      ! Revision
      ! v4_80 - Qaddouri A.       - Version for Yin-Yang Grid
      ! v5_00 - Tanguay M.        - Provide air mass to mass_tr
      !Object
      !     Based on Bermejo and Conde,2002, A conservative quasi-monotone
      !     semi-Lagrangian scheme. MWR,130,423-430
      !     Based on Bermejo/Conde template from GEM3 (Gravel and DeGrandpre 2012)
      !
!*@/

      !----------------------------------------------------------
      integer i,j,k,err,count(k0:F_nk,3),l_count(3),g_count(3),time_p,time_m,iprod
      real*8  mass_old_8,mass_tot_old_8,mass_new_8,mass_tot_new_8, &
              mass_out_8,mass_tot_out_8,mass_wei_8, &
              mass_deficit_8,lambda_8,correction_8,p_exp_8,H_minus_L_8,ratio_8, &
              mass_flux_o_8,mass_flux_i_8,mass_bflux_8
      real*8, parameter :: ONE_8=1.d0
      real F_new(Minx:Maxx,Miny:Maxy,F_nk),weight(Minx:Maxx,Miny:Maxy,F_nk), &
          mass_p(Minx:Maxx,Miny:Maxy,F_nk),mass_m(Minx:Maxx,Miny:Maxy,F_nk), &
           bidon(Minx:Maxx,Miny:Maxy,F_nk)
      logical LAM_L, verbose_L
      logical :: almost_zero

      !----------------------------------------------------------

      verbose_L = Tr_verbose/=0

      LAM_L = .not.Grd_yinyang_L

      if (Schm_psadj==0 .and. .NOT.LAM_L .and. .NOT.Schm_autobar_L) then
         call handle_error(-1,'BERMEJO-CONDE','Schm_psadj_L should be TRUE when NOT LAM')
      end if

      time_p = 1
      time_m = 0

      call get_density (bidon,mass_p,time_p,Minx,Maxx,Miny,Maxy,F_nk,k0)
      call get_density (bidon,mass_m,time_m,Minx,Maxx,Miny,Maxy,F_nk,k0)


      do k=1,F_nk
         F_new(:,:,k) = F_high(:,:,k)
      enddo


      p_exp_8 = 1.0

      if (verbose_L.and.Lun_out>0) then
                                          write(Lun_out,*) 'TRACERS: ----------------------------------------------------------------------'
         if (F_CLIP_L)                    write(Lun_out,*) 'TRACERS: Restore Mass Conservation of Cubic MONO(CLIPPING): Bermejo and Conde,2002,MWR'
         if (F_ILMC_L)                    write(Lun_out,*) 'TRACERS: Restore Mass Conservation of Cubic MONO(ILMC): Bermejo and Conde,2002,MWR'
         if (.NOT.(F_CLIP_L.or.F_ILMC_L)) write(Lun_out,*) 'TRACERS: Restore Mass Conservation of Cubic: Bermejo and Conde,2002,MWR'
         if (LAM_L)                       write(Lun_out,*) 'TRACERS: Bermejo-Conde LAM: Flux calculations based on Aranami et al. (2015)'
                                          write(Lun_out,*) 'TRACERS: ----------------------------------------------------------------------'
      endif

      !Default values if no Mass correction
      !------------------------------------
      F_out = F_new

      call mass_tr (mass_old_8,F_name_S(4:7),F_old,mass_p,Minx,Maxx,Miny,Maxy,F_nk-k0+1,k0)
      call mass_tr (mass_new_8,F_name_S(4:7),F_new,mass_m,Minx,Maxx,Miny,Maxy,F_nk-k0+1,k0)

      mass_bflux_8 = 0.0d0

      !Estimate mass of FLUX_out and mass of FLUX_in
      !---------------------------------------------
      if (LAM_L) then

         call mass_tr (mass_flux_o_8,'FLUX',F_for_flux_o,mass_m,Minx,Maxx,Miny,Maxy,F_nk-k0+1,k0)
         call mass_tr (mass_flux_i_8,'FLUX',F_for_flux_i,mass_m,Minx,Maxx,Miny,Maxy,F_nk-k0+1,k0)

         mass_bflux_8 = mass_flux_i_8 - mass_flux_o_8

      endif

      mass_tot_old_8= mass_old_8 + mass_bflux_8
      mass_tot_new_8= mass_new_8

      mass_deficit_8 = mass_tot_new_8 - mass_tot_old_8

      if (verbose_L) then

         ratio_8 = 0.0d0
         if (mass_tot_old_8/=0.d0) ratio_8 = mass_deficit_8/mass_tot_old_8*100.

         if (Lun_out>0) then
             write(Lun_out,*)    'TRACERS: P_exponent              =',p_exp_8
             write(Lun_out,*)    'TRACERS: Do MONO (CLIPPING)      =',F_BC_min_max_L
             write(Lun_out,1000) 'TRACERS: Mass BEFORE Bermejo-Conde',mass_tot_new_8,F_name_S(4:6)
             write(Lun_out,1000) 'TRACERS: Mass to RESTORE         =',mass_tot_old_8,F_name_S(4:6)
             write(Lun_out,1001) 'TRACERS: Ori. Diff. of ',ratio_8
         endif

      endif

      !Impose ZERO nesting values when evaluating FLUX(weight)
      !-------------------------------------------------------
      weight = 0.0

      !-----------------------------------------
      !Compute Mass preserving BC solution F_out
      !-----------------------------------------



      do k=k0,F_nk

         do j=1+pil_s,l_nj-pil_n
         do i=1+pil_w,l_ni-pil_e

            H_minus_L_8 = F_high(i,j,k) - F_low(i,j,k)

            if (int(sign(ONE_8,mass_deficit_8)) == int(sign(ONE_8,H_minus_L_8))) then
               weight(i,j,k) = abs(H_minus_L_8)**p_exp_8*sign(ONE_8,mass_deficit_8)
            end if

         enddo
         enddo

      enddo



      call mass_tr (mass_wei_8,F_name_S(4:7),weight,mass_m,Minx,Maxx,Miny,Maxy,F_nk-k0+1,k0)

      if ( almost_zero(mass_wei_8) ) then

         if (verbose_L.and.Lun_out>0) then
            write(Lun_out,1002) 'TRACERS: Diff. too small =',mass_tot_new_8,mass_tot_old_8,mass_tot_new_8-mass_tot_old_8
         end if

         return

      endif

      lambda_8 = mass_deficit_8/mass_wei_8

      if (verbose_L.and.Lun_out>0) write(Lun_out,1003) 'TRACERS: LAMBDA                  = ',lambda_8,F_name_S(4:6)

      if (.NOT.verbose_L) then

         if (.NOT.Tr_BC_min_max_L) then


         do k=k0,F_nk

            do j=1+pil_s,l_nj-pil_n
            do i=1+pil_w,l_ni-pil_e

               correction_8 = lambda_8 * weight(i,j,k)

               F_out(i,j,k) = F_new(i,j,k) - correction_8

            enddo
            enddo

         enddo


         else


         do k=k0,F_nk

            do j=1+pil_s,l_nj-pil_n
            do i=1+pil_w,l_ni-pil_e

               correction_8 = lambda_8 * weight(i,j,k)

               F_out(i,j,k) = F_new(i,j,k) - correction_8

               if (correction_8 > 0.d0 .and. F_out(i,j,k) < F_min(i,j,k)) then
                   F_out(i,j,k) = F_min(i,j,k)
               endif
               if (correction_8 < 0.d0 .and. F_out(i,j,k) > F_max(i,j,k)) then
                   F_out(i,j,k) = F_max(i,j,k)
               endif

            enddo
            enddo

         enddo


        endif

      else




      do k=k0,F_nk

         count(k,1) = 0.
         count(k,2) = 0.
         count(k,3) = 0.

         do j=1+pil_s,l_nj-pil_n
         do i=1+pil_w,l_ni-pil_e

            correction_8 = lambda_8 * weight(i,j,k)

            if (correction_8/=0.0d0) count(k,3) = count(k,3) + 1

            F_out(i,j,k) = F_new(i,j,k) - correction_8

            if (Tr_BC_min_max_L) then

                if (correction_8 > 0.d0 .and. F_out(i,j,k) < F_min(i,j,k)) then
                    count(k,1)   = count(k,1) + 1
                    F_out(i,j,k) = F_min(i,j,k)
                endif
                if (correction_8 < 0.d0 .and. F_out(i,j,k) > F_max(i,j,k)) then
                    count(k,2)   = count(k,2) + 1
                    F_out(i,j,k) = F_max(i,j,k)
                endif

            endif

         enddo
         enddo

      enddo



      endif

      if (verbose_L) then

         l_count = 0
         g_count = 0

         do k=k0,F_nk
            l_count(1) = count(k,1) + l_count(1)
            l_count(2) = count(k,2) + l_count(2)
            l_count(3) = count(k,3) + l_count(3)
         enddo

         if (Grd_yinyang_L) then
            call rpn_comm_Allreduce (l_count,g_count,3,"MPI_INTEGER","MPI_SUM","MULTIGRID",err)
            iprod = 2
         else
            call rpn_comm_Allreduce (l_count,g_count,3,"MPI_INTEGER","MPI_SUM","GRID",err)
            iprod = 1
         endif

         call mass_tr (mass_out_8,F_name_S(4:7),F_out,mass_m,Minx,Maxx,Miny,Maxy,F_nk-k0+1,k0)

         mass_tot_out_8 = mass_out_8

         mass_deficit_8 = mass_tot_out_8 - mass_tot_old_8

         ratio_8 = 0.0d0
         if (mass_tot_old_8/=0.d0) ratio_8 = mass_deficit_8/mass_tot_old_8*100.

         if (Lun_out>0) then
             write(Lun_out,1000) 'TRACERS: Mass  AFTER Bermejo-Conde',mass_tot_out_8,F_name_S(4:6)
             write(Lun_out,*)    'TRACERS: # pts treated by B.-C.  =', g_count(3),'over',G_ni*G_nj*F_nk*iprod
             write(Lun_out,*)    'TRACERS: # pts CLIPPED           =', g_count(1) + g_count(2)
             write(Lun_out,*)    'TRACERS: RESET_MIN_BC            =', g_count(1)
             write(Lun_out,*)    'TRACERS: RESET_MAX_BC            =', g_count(2)
             write(Lun_out,1001) 'TRACERS: Rev. Diff. of ',ratio_8
             if (LAM_L) then
             write(Lun_out,1004) 'TRACERS: Bermejo-Conde STATS: N=',mass_out_8,' O=',mass_old_8,' FI=',mass_flux_i_8,' FO=',mass_flux_o_8,F_name_S(4:6)
             else
             write(Lun_out,1005) 'TRACERS: Bermejo-Conde STATS: N=',mass_out_8,' O=',mass_old_8,F_name_S(4:6)
             endif
             write(Lun_out,*)    'TRACERS: ----------------------------------------------------------------------'
         endif

      endif

 1000 format(1X,A34,E20.12,1X,A3)
 1001 format(1X,A23,E11.4,'%')
 1002 format(1X,A34,3(E20.12,1X))
 1003 format(1X,A34,F20.2,1X,A3)
 1004 format(1X,A32,E19.12,A3,E19.12,A3,E19.12,A3,E19.12,1X,A3)
 1005 format(1X,A32,E19.12,A3,E19.12,1X,A3)

      return
      end
