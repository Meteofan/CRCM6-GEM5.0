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

!**s/r dcmip_steady_state_mountain - Setup for Steady-State Atmosphere at Rest
!                                    in the Presence of Orography (DCMIP 2012)

      subroutine dcmip_steady_state_mountain (F_u,F_v,F_zd,F_t,F_q,F_topo,F_s, &
                                              Mminx,Mmaxx,Mminy,Mmaxy,Nk,Set_topo_L)

      use dcmip_2012_init_1_2_3
      use canonical

      use geomh

      use glb_ld
      use cstv
      use lun
      use ver
      use gmm_itf_mod
      use ptopo
      implicit none

      integer Mminx,Mmaxx,Mminy,Mmaxy,Nk
      real F_u    (Mminx:Mmaxx,Mminy:Mmaxy,Nk), &
           F_v    (Mminx:Mmaxx,Mminy:Mmaxy,Nk), &
           F_zd   (Mminx:Mmaxx,Mminy:Mmaxy,Nk), &
           F_t    (Mminx:Mmaxx,Mminy:Mmaxy,Nk), &
           F_q    (Mminx:Mmaxx,Mminy:Mmaxy,Nk), &
           F_s    (Mminx:Mmaxx,Mminy:Mmaxy),    &
           F_topo (Mminx:Mmaxx,Mminy:Mmaxy)

      logical  :: Set_topo_L ! If TRUE : Set F_topo to initialize  Topo_High and calculate Reference  variables
                             ! If FALSE: Use F_topo initialized as Topo_low  and calculate Associated variables

      !object
      !======================================================================================
      !   Setup for Steady-State Atmosphere at Rest in the Presence of Orography (DCMIP 2012)
      !======================================================================================


      !-----------------------------------------------------------------------

      integer i,j,k,istat

      real(8) x_a_8,y_a_8,utt_8,vtt_8,s_8(2,2),rlon_8

      real(8)  :: lon, &          ! Longitude (radians)
                  lat, &          ! Latitude (radians)
                  z               ! Height (m)
               !!!z,   &          ! Height (m)
               !!!hyam,&          ! A coefficient for hybrid-eta coordinate, at model level midpoint
               !!!hybm,&          ! B coefficient for hybrid-eta coordinate, at model level midpoint
               !!!gc              ! bar{z} for Gal-Chen coordinate

      logical  :: hybrid_eta      ! flag to indicate whether the hybrid sigma-p (eta) coordinate is used
                                  ! if set to .true., then the pressure will be computed via the
!!!                               !    hybrid coefficients hyam and hybm, they need to be initialized
                                  !    hybrid coefficients GEM Ver_a and Ver_b, they need to be initialized
                                  ! if set to .false. (for pressure-based models): the pressure is already pre-computed
                                  !    and is an input value for this routine
                                  ! for height-based models: pressure will always be computed based on the height and
                                  !    hybrid_eta is not used

      real(8)  :: p               ! Pressure  (Pa)

      integer  :: zcoords         ! 0 or 1 see below

      real(8)  :: u, &            ! Zonal wind (m s^-1)
                  v, &            ! Meridional wind (m s^-1)
                  w, &            ! Vertical Velocity (m s^-1)
                  t, &            ! Temperature (K)
                  tv,&            ! Virtual Temperature (K)
                  phis, &         ! Surface Geopotential (m^2 s^-2)
                  ps, &           ! Surface Pressure (Pa)
                  rho, &          ! density (kg m^-3)
                  q               ! Specific Humidity (kg/kg)

      ! if zcoords = 1, then we use z and output p
      ! if zcoords = 0, then we compute or use p
      !
!!!   ! In hybrid-eta coords: p = hyam p0 + hybm ps
      ! In hybrid-eta GEM coords: p = exp(Ver_a p0 + Ver_b ps)

      real(8), parameter:: ztop_8 = 12000.d0, & ! Model Top
                           zh_8   =  8000.d0    ! Altitude of the Rayleigh damped layer

      real(8) zblen_max_8,zblen_top_8,work1_8,work2_8,fact_8

      !-----------------------------------------------------------------------

      if (Lun_out > 0) write (Lun_out,1000) Set_topo_L

      zcoords    = 0
      hybrid_eta = .TRUE. ! as in GEM

      !Factors in Rayleigh damped layer (Based on set_betav)
      !-----------------------------------------------------
      if (Set_topo_L) then

         zblen_max_8 = Cstv_Zsrf_8 - zh_8/8780.2 !HREF = 8780.2 R T_ref/grav as in set_geom
         zblen_top_8 = Cstv_Ztop_8

         fact_8 = 1.0d0

         istat = gmm_get(gmmk_fcu_s,fcu)
         istat = gmm_get(gmmk_fcv_s,fcv)
         istat = gmm_get(gmmk_fcw_s,fcw)

      endif

      !Initial conditions: T,ZD,Q,S,TOPO
      !---------------------------------
      do k = 1,Nk

         do j = 1,l_nj

            lat   = geomh_y_8(j)
            y_a_8 = geomh_y_8(j)

            if (Ptopo_couleur == 0) then

               do i = 1,l_ni

                  lon = geomh_x_8(i)

                  if (.NOT.Set_topo_L) phis = F_topo(i,j)

                  call test2_steady_state_mountain (lon,lat,p,z,zcoords,Ver_a_8%t(k),Ver_b_8%t(k),Cstv_pref_8,hybrid_eta, &
                                                    u,v,w,t,tv,phis,ps,rho,q,Set_topo_L)

                  F_t(i,j,k)  = tv
                  F_q(i,j,k)  = q
                  F_s(i,j)    = log(ps/Cstv_pref_8)

                  if (Set_topo_L) F_topo(i,j) = phis

                  F_zd(i,j,k) = w ! It is zero

                  if (Set_topo_L) then

                     work1_8 = zblen_max_8-(Ver_a_8%t(k)+Ver_b_8%t(k)*log(ps/Cstv_pref_8))
                     work2_8 = zblen_max_8-zblen_top_8
                     work1_8 = min(1.d0,max(0.d0,work1_8/work2_8))

                     fcw(i,j,k) = work1_8*work1_8*min(1.d0,fact_8)

                  endif

               end do

            else

               do i = 1,l_ni

                  x_a_8 = geomh_x_8(i) - acos(-1.D0)

                  call smat(s_8,rlon_8,lat,x_a_8,y_a_8)

                  lon = rlon_8 + acos(-1.D0)

                  if (.NOT.Set_topo_L) phis = F_topo(i,j)

                  call test2_steady_state_mountain (lon,lat,p,z,zcoords,Ver_a_8%t(k),Ver_b_8%t(k),Cstv_pref_8,hybrid_eta, &
                                                    utt_8,vtt_8,w,t,tv,phis,ps,rho,q,Set_topo_L)

                  F_t(i,j,k)  = tv
                  F_q(i,j,k)  = q
                  F_s(i,j)    = log(ps/Cstv_pref_8)

                  if (Set_topo_L) F_topo(i,j) = phis

                  F_zd(i,j,k) = w ! It is zero

                  if (Set_topo_L) then

                     work1_8 = zblen_max_8-(Ver_a_8%t(k)+Ver_b_8%t(k)*log(ps/Cstv_pref_8))
                     work2_8 = zblen_max_8-zblen_top_8
                     work1_8 = min(1.d0,max(0.d0,work1_8/work2_8))

                     fcw(i,j,k) = work1_8*work1_8*min(1.d0,fact_8)

                  endif

               end do

            end if

         end do

      end do

      !Initial conditions: U True
      !--------------------------
      do k = 1,Nk

         do j = 1,l_nj

            lat   = geomh_y_8(j)
            y_a_8 = geomh_y_8(j)

            if (Ptopo_couleur == 0) then

               do i = 1,l_niu

                  lon = geomh_xu_8(i)

                  if (.NOT.Set_topo_L) phis = F_topo(i,j)

                  call test2_steady_state_mountain (lon,lat,p,z,zcoords,Ver_a_8%m(k),Ver_b_8%m(k),Cstv_pref_8,hybrid_eta, &
                                                    utt_8,vtt_8,w,t,tv,phis,ps,rho,q,Set_topo_L)

                  F_u(i,j,k) = u

                  if (Set_topo_L) then

                     work1_8 = zblen_max_8-(Ver_a_8%m(k)+Ver_b_8%m(k)*log(ps/Cstv_pref_8))
                     work2_8 = zblen_max_8-zblen_top_8
                     work1_8 = min(1.d0,max(0.d0,work1_8/work2_8))

                     fcu(i,j,k) = work1_8*work1_8*min(1.d0,fact_8)

                  endif

               end do

            else

               do i = 1,l_niu

                  x_a_8 = geomh_xu_8(i) - acos(-1.D0)

                  call smat(s_8,rlon_8,lat,x_a_8,y_a_8)

                  lon = rlon_8 + acos(-1.D0)

                  if (.NOT.Set_topo_L) phis = F_topo(i,j)

                  call test2_steady_state_mountain (lon,lat,p,z,zcoords,Ver_a_8%m(k),Ver_b_8%m(k),Cstv_pref_8,hybrid_eta, &
                                                    utt_8,vtt_8,w,t,tv,phis,ps,rho,q,Set_topo_L)

                  u = s_8(1,1)*utt_8 + s_8(1,2)*vtt_8

                  F_u(i,j,k) = u

                  if (Set_topo_L) then

                     work1_8 = zblen_max_8-(Ver_a_8%m(k)+Ver_b_8%m(k)*log(ps/Cstv_pref_8))
                     work2_8 = zblen_max_8-zblen_top_8
                     work1_8 = min(1.d0,max(0.d0,work1_8/work2_8))

                     fcu(i,j,k) = work1_8*work1_8*min(1.d0,fact_8)

                  endif

               end do

            end if

         end do

      end do

      !Initial conditions: V True
      !--------------------------
      do k = 1,Nk

         do j = 1,l_njv

            lat   = geomh_yv_8(j)
            y_a_8 = geomh_yv_8(j)

            if (Ptopo_couleur == 0) then

               do i = 1,l_ni

                  lon = geomh_x_8(i)

                  if (.NOT.Set_topo_L) phis = F_topo(i,j)

                  call test2_steady_state_mountain (lon,lat,p,z,zcoords,Ver_a_8%m(k),Ver_b_8%m(k),Cstv_pref_8,hybrid_eta, &
                                                    utt_8,vtt_8,w,t,tv,phis,ps,rho,q,Set_topo_L)

                  F_v(i,j,k) = v

                  if (Set_topo_L) then

                     work1_8 = zblen_max_8-(Ver_a_8%m(k)+Ver_b_8%m(k)*log(ps/Cstv_pref_8))
                     work2_8 = zblen_max_8-zblen_top_8
                     work1_8 = min(1.d0,max(0.d0,work1_8/work2_8))

                     fcv(i,j,k) = work1_8*work1_8*min(1.d0,fact_8)

                  endif

               end do

            else

               do i = 1,l_ni

                  x_a_8 = geomh_x_8(i) - acos(-1.D0)

                  call smat(s_8,rlon_8,lat,x_a_8,y_a_8)

                  lon = rlon_8 + acos(-1.D0)

                  if (.NOT.Set_topo_L) phis = F_topo(i,j)

                  call test2_steady_state_mountain (lon,lat,p,z,zcoords,Ver_a_8%m(k),Ver_b_8%m(k),Cstv_pref_8,hybrid_eta, &
                                                    utt_8,vtt_8,w,t,tv,phis,ps,rho,q,Set_topo_L)

                  v = s_8(2,1)*utt_8 + s_8(2,2)*vtt_8

                  F_v(i,j,k) = v

                  if (Set_topo_L) then

                     work1_8 = zblen_max_8-(Ver_a_8%m(k)+Ver_b_8%m(k)*log(ps/Cstv_pref_8))
                     work2_8 = zblen_max_8-zblen_top_8
                     work1_8 = min(1.d0,max(0.d0,work1_8/work2_8))

                     fcv(i,j,k) = work1_8*work1_8*min(1.d0,fact_8)

                  endif

               end do

            end if

         end do

      end do

      if (Set_topo_L) then

         !Initialize u,v,w REFERENCE for Rayleigh damped layer
         !----------------------------------------------------
         istat = gmm_get(gmmk_uref_s,uref)
         istat = gmm_get(gmmk_vref_s,vref)
         istat = gmm_get(gmmk_wref_s,wref)

         do k=1,Nk
            do j= 1,l_nj
               do i= 1,l_niu
                  uref(i,j,k) = F_u(i,j,k)
               end do
            end do
            do j= 1,l_njv
               do i= 1,l_ni
                  vref(i,j,k) = F_v(i,j,k)
               end do
            end do
            do j= 1,l_nj
               do i= 1,l_ni
                  wref(i,j,k) = 0.0 !ZERO Dz/Dt
               end do
            end do
         end do

      endif

      !-----------------------------------------------------------------------

      return

 1000 format( &
      /,'USE INITIAL CONDITIONS FOR STEADY-STATE ATMOSPHERE AT REST IN THE PRESENCE OF OROGRAPHY: (S/R DCMIP_STEADY_STATE_MOUNTAIN)',   &
      /,'==========================================================================================================================',/, &
        ' Set Topo   = ',L2                                                                                                         ,   &
      /,'==========================================================================================================================',/,/)

      end subroutine dcmip_steady_state_mountain
