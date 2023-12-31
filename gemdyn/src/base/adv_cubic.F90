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
      subroutine adv_cubic (F_name, fld_out,  fld_in, F_capx, F_capy, F_capz, &
                            F_usmx , F_usmy , F_usmz, F_svmx, F_svmy, F_svmz, &
                            F_ni, F_nj, F_nk, F_minx, F_maxx, F_miny, F_maxy, &
                            F_nind, F_ii, F_i0, F_in, F_j0, F_jn, F_k0,       &
                            F_lev_S, F_mono_kind, F_mass_kind)
      use gmm_tracers
      use adv_options
      use grid_options
      use glb_ld
      use gmm_itf_mod
      use adv_grid
      use tracers
      use outgrid
      implicit none
#include <arch_specific.hf>
      character(len=1) :: F_lev_S
      character(len=*), intent(in) :: F_name
      integer, intent(in) :: F_ni,F_nj,F_nk ! dims of position fields
      integer, intent(in) :: F_minx,F_maxx,F_miny, F_maxy ! wind fields array bounds
      integer :: F_k0             !I, vertical scope k0 to F_nk
      integer :: F_i0, F_j0, F_in, F_jn
      integer ,  intent(in) :: F_nind
      integer ,  dimension(F_nind*4) :: F_ii    ! precomputed indices to be used in tricubic lagrangian interp
      real, intent(in)::  F_capx(*), F_capy(*), F_capz(*) !I, upstream positions at t1
      real, intent(in)::  F_usmx(*), F_usmy(*), F_usmz(*) !I, upstream positions at t1 USM
      real, intent(in)::  F_svmx(*), F_svmy(*), F_svmz(*) !I, upstream positions at t1 SVM
      integer, intent(in) :: F_mono_kind !I, Kind of Shape preservation
      integer, intent(in) :: F_mass_kind !I, Kind of  Mass conservation
!     @objective  prepare for  cubic interpolation of RHS and Tracers
!     @author RPN-A Model Infrastructure Group (based on adx_interp_gmm , adx_int_rhs , adx_interp ) June 2015
!     @arguments


      real,save,pointer,dimension(:,:,:) :: adw_mask_o =>null(), adw_mask_i =>null()
      logical :: mono_L, conserv_L
      integer :: flux_n
      logical, parameter :: EXTEND_L = .true.
      integer ::  i, j, k, nbpts, i0_e, in_e, j0_e, jn_e
      real    :: fld_adw(adv_lminx:adv_lmaxx,adv_lminy:adv_lmaxy,F_nk)
      real, pointer, dimension(:,:,:) ::adw_rho,cub_o,cub_i,w_cub_o_c,w_cub_i_c,adw_o,adw_i
      real, dimension(F_ni,F_nj,F_nk) :: wrkc, w_mono_c, w_lin_c, w_min_c, w_max_c
      real, dimension(F_minx:F_maxx, F_miny:F_maxy ,F_nk), intent(in)  :: Fld_in
      real, dimension(F_minx:F_maxx, F_miny:F_maxy ,F_nk), intent(out) :: Fld_out
      real, dimension(F_minx:F_maxx, F_miny:F_maxy ,F_nk) :: in_rho,in_o,in_i,fld_ONE
      type(gmm_metadata) :: mymeta
      real, dimension(1,1,1), target :: no_conserv, no_slice, no_flux
      integer :: err, conserv_local
      logical,save :: done_mask_L=.FALSE.
!
!---------------------------------------------------------------------
!
      mono_L = .false.

      if (F_name(1:3) == 'TR/') then
         mono_L = (F_mono_kind==1)
      endif

      if ( adv_rhst_mono_L .and. (F_name=='RHST_S')) mono_L=.true.

      flux_n = 0
      if (F_mass_kind == 1 .and. .not.Grd_yinyang_L) flux_n = 1

      if (flux_n>0.and..NOT.done_mask_L) then

          allocate (adw_mask_o(adv_lminx:adv_lmaxx,adv_lminy:adv_lmaxy,F_nk), &
                    adw_mask_i(adv_lminx:adv_lmaxx,adv_lminy:adv_lmaxy,F_nk))

      endif

      if (flux_n>0) then

         !Establish scope of extended advection operations
         !------------------------------------------------
         call adv_get_ij0n_ext (i0_e,in_e,j0_e,jn_e)

         allocate (cub_o(l_minx:l_maxx,l_miny:l_maxy,F_nk), &
                   cub_i(l_minx:l_maxx,l_miny:l_maxy,F_nk))

         allocate (adw_o(adv_lminx:adv_lmaxx,adv_lminy:adv_lmaxy,F_nk), &
                   adw_i(adv_lminx:adv_lmaxx,adv_lminy:adv_lmaxy,F_nk))

         allocate (w_cub_o_c(l_ni,l_nj,F_nk), &
                   w_cub_i_c(l_ni,l_nj,F_nk))

      else
         w_cub_o_c=> no_flux ; adw_o=> no_flux ; cub_o=> no_flux
         w_cub_i_c=> no_flux ; adw_i=> no_flux ; cub_i=> no_flux
      endif

      conserv_L = F_mono_kind>1.or.F_mass_kind/=0

      Tr_SLICE_mono = F_mono_kind
      if (F_mass_kind==2) then
         if (.NOT.(Tr_SLICE_mono==0.or.Tr_SLICE_mono==3.or.Tr_SLICE_mono==4).and.Tr_SLICE_rebuild==2) call handle_error(-1,'adv_cubic','SLICE options NOT available 1')
         if (                                              Tr_SLICE_mono/=0 .and.Tr_SLICE_rebuild==1) call handle_error(-1,'adv_cubic','SLICE options NOT available 2')
      endif

      conserv_local = 0
      if (F_mass_kind==2) conserv_local = 1

      if (conserv_local>0) then
         allocate (adw_rho(adv_lminx:adv_lmaxx,adv_lminy:adv_lmaxy,F_nk))
      else
         adw_rho => no_slice
      endif

      nbpts = F_ni*F_nj*F_nk

      if (flux_n>0) then
!$omp parallel do private(k)
      do k = 1,F_nk
         fld_adw(:,:,k)= 0.0
      enddo
!$omp end parallel do
      endif

      call rpn_comm_xch_halox( fld_in, F_minx, F_maxx,F_miny, F_maxy , &
       F_ni, F_nj, F_nk, adv_halox, adv_haloy, G_periodx, G_periody  , &
       fld_adw, adv_lminx,adv_lmaxx,adv_lminy,adv_lmaxy, F_ni, 0)

      if (conserv_L) then
         nullify(fld_cub,fld_mono,fld_lin,fld_min,fld_max)
         err = gmm_get(gmmk_cub_s ,fld_cub ,mymeta)
         err = gmm_get(gmmk_mono_s,fld_mono,mymeta)
         err = gmm_get(gmmk_lin_s ,fld_lin ,mymeta)
         err = gmm_get(gmmk_min_s ,fld_min ,mymeta)
         err = gmm_get(gmmk_max_s ,fld_max ,mymeta)

!$omp parallel do private(k)
         do k = 1,F_nk
            fld_cub (:,:,k)= fld_out(:,:,k)
            fld_mono(:,:,k)= fld_out(:,:,k)
         enddo
!$omp end parallel do

         if (flux_n>0) then

!$omp parallel do private(k)
            do k = 1,F_nk
               cub_o(:,:,k)= 0.0
               cub_i(:,:,k)= 0.0
            enddo
!$omp end parallel do

            if (.NOT.done_mask_L) then

!$omp parallel private(i,j,k)
!$omp do
               do k = 1,F_nk
                  fld_ONE(:,:,k)= 0.0
               enddo
!$omp enddo
!$omp do
               do k=1,F_nk
               do j=1,F_nj
               do i=1,F_ni
                  fld_ONE(i,j,k) = 1.0
               enddo
               enddo
               enddo
!$omp enddo
!$omp end parallel

               call adv_set_flux_in (in_o,in_i,fld_ONE,l_minx,l_maxx,l_miny,l_maxy,F_nk)

               adw_mask_o = 0.

               call rpn_comm_xch_halox( in_o, F_minx, F_maxx,F_miny, F_maxy , &
                F_ni, F_nj, F_nk, adv_halox, adv_haloy, G_periodx, G_periody  , &
                adw_mask_o, adv_lminx,adv_lmaxx,adv_lminy,adv_lmaxy, F_ni, 0)

               adw_mask_i = 0.

               call rpn_comm_xch_halox( in_i, F_minx, F_maxx,F_miny, F_maxy , &
                F_ni, F_nj, F_nk, adv_halox, adv_haloy, G_periodx, G_periody  , &
                adw_mask_i, adv_lminx,adv_lmaxx,adv_lminy,adv_lmaxy, F_ni, 0)

            endif

            done_mask_L = .TRUE.

!$omp parallel do private (i,j,k)
            do k=1,F_nk
            do j=adv_lminy,adv_lmaxy
            do i=adv_lminx,adv_lmaxx
               adw_o(i,j,k) = adw_mask_o(i,j,k) * fld_adw(i,j,k)
               adw_i(i,j,k) = adw_mask_i(i,j,k) * fld_adw(i,j,k)
            enddo
            enddo
            enddo
!$omp end parallel do

         endif

         if (conserv_local>0) then
            call adv_mixing_2_density (fld_in,in_rho,l_minx,l_maxx,l_miny,l_maxy,F_nk,1,1)

            call rpn_comm_xch_halox( in_rho, F_minx, F_maxx,F_miny, F_maxy , &
             F_ni, F_nj, F_nk, adv_halox, adv_haloy, G_periodx, G_periody  , &
             adw_rho, adv_lminx,adv_lmaxx,adv_lminy,adv_lmaxy, F_ni, 0)
         endif

      else
         fld_cub  => no_conserv
         fld_mono => no_conserv
         fld_lin  => no_conserv
         fld_min  => no_conserv
         fld_max  => no_conserv
      endif

         call adv_tricub_lag3d (wrkc, w_mono_c, w_lin_c, w_min_c, w_max_c, &
                                   fld_adw, adw_rho, conserv_local,        &
                                   w_cub_o_c,adw_o,w_cub_i_c,adw_i,flux_n, &
                                   F_capx, F_capy, F_capz,                 &
                                   F_usmx, F_usmy, F_usmz,                 &
                                   F_svmx, F_svmy, F_svmz,                 &
                                   nbpts, F_nind, F_ii, F_k0, F_nk,        &
                                   mono_L, conserv_L, F_lev_S)

!$omp parallel private(k)
      if (.NOT. conserv_L) then
!$omp do
         do k = F_k0, F_nk
            Fld_out(F_i0:F_in,F_j0:F_jn,k) = wrkc(F_i0:F_in,F_j0:F_jn,k)
         enddo
!$omp enddo
      else
!$omp do
         do k = F_k0, F_nk
            Fld_cub (F_i0:F_in,F_j0:F_jn,k) = wrkc    (F_i0:F_in,F_j0:F_jn,k)
            Fld_mono(F_i0:F_in,F_j0:F_jn,k) = w_mono_c(F_i0:F_in,F_j0:F_jn,k)
            Fld_lin (F_i0:F_in,F_j0:F_jn,k) = w_lin_c (F_i0:F_in,F_j0:F_jn,k)
            Fld_min (F_i0:F_in,F_j0:F_jn,k) = w_min_c (F_i0:F_in,F_j0:F_jn,k)
            Fld_max (F_i0:F_in,F_j0:F_jn,k) = w_max_c (F_i0:F_in,F_j0:F_jn,k)
         enddo
!$omp enddo
         if (flux_n>0) then
!$omp do
         do k = F_k0, F_nk
               cub_o(i0_e:in_e,j0_e:jn_e,k)= w_cub_o_c(i0_e:in_e,j0_e:jn_e,k)
               cub_i(i0_e:in_e,j0_e:jn_e,k)= w_cub_i_c(i0_e:in_e,j0_e:jn_e,k)
         enddo
!$omp enddo
         endif
      endif
!$omp end parallel

      if (conserv_local>0) call adv_mixing_2_density (fld_cub,fld_cub,l_minx,l_maxx,l_miny,l_maxy,F_nk,2,0)

      if (conserv_L) call adv_tracers_mono_mass (F_name, fld_out, fld_cub, fld_mono, fld_lin, &
                                           fld_min, fld_max, fld_in, cub_o, cub_i           , &
                                           F_minx, F_maxx , F_miny, F_maxy ,F_nk            , &
                                           F_i0, f_in ,F_j0 ,F_jn ,F_k0 , F_mono_kind, F_mass_kind )

      if (conserv_local>0) deallocate (adw_rho)

      if (flux_n>0) deallocate (cub_o,cub_i,adw_o,adw_i,w_cub_o_c,w_cub_i_c)
!
!---------------------------------------------------------------------
!
      return
      end subroutine adv_cubic
