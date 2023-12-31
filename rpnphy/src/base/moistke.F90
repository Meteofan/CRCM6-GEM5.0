!-------------------------------------- LICENCE BEGIN ------------------------
!Environment Canada - Atmospheric Science and Technology License/Disclaimer,
!                     version 3; Last Modified: May 7, 2008.
!This is free but copyrighted software; you can use/redistribute/modify it under the terms
!of the Environment Canada - Atmospheric Science and Technology License/Disclaimer
!version 3 or (at your option) any later version that should be found at:
!http://collaboration.cmc.ec.gc.ca/science/rpn.comm/license.html
!
!This software is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
!without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
!See the above mentioned License/Disclaimer for more details.
!You should have received a copy of the License/Disclaimer along with this software;
!if not, you can write to: EC-RPN COMM Group, 2121 TransCanada, suite 500, Dorval (Quebec),
!CANADA, H9P 1J3; or send e-mail to service.rpn@ec.gc.ca
!-------------------------------------- LICENCE END --------------------------
!/@*
subroutine moistke11(en,enold,zn,zd,rif,rig,buoy,shr2,pri,qc,c1,fnn, &
     fngauss,fnnonloc,gama,gamaq,gamal,hpbl,lh,hpar, &
     wthl_ng,wqw_ng,uw_ng,vw_ng, &
     u,v,t,tve,q,qe,ps,s,se,sw, &
     z,z0,gzmom,frv,wstar,turbreg, &
     vcoef,dxdy,tau,kount,trnch,n,nk)
   use tdpack, only: CAPPA, DELTA, GRAV, KARMAN, RGASD
   use series_mod, only: series_xst
   use phy_options
   use phy_status, only: phy_error_L
   use mixing_length, only: ml_tfilt,ml_blend,ml_calc_blac,ml_calc_boujo,ml_calc_lh,ML_LMDA,ML_OK
   use pbl_stabfunc, only: psf_stabfunc, PSF_OK
   implicit none
#include <arch_specific.hf>
#include <rmnlib_basics.hf>
   !Arguments
   integer, intent(in) :: n                          !horizontal dimension
   integer, intent(in) :: nk                         !vertical dimension
   integer, intent(in) :: kount                      !time step number
   integer, intent(in) :: trnch                      !slice number
   real, intent(in) :: tau                           !time step length (s)
   real, dimension(n), intent(in) :: hpbl            !height of the PBL (m)
   real, dimension(n), intent(in) :: lh              !launching height (m)   
   real, dimension(n), intent(in) :: ps              !surface pressure (Pa)
   real, dimension(n), intent(in) :: z0              !roughness length (m)
   real, dimension(n), intent(in) :: frv             !friction velocity (m/s)
   real, dimension(n), intent(in) :: wstar           !convective velocity scale
   real, dimension(n), intent(in) :: dxdy            !horizontal grid area (m^2)
   real, dimension(n,nk), intent(in) :: enold        !TKE of previous time step (m2/s2)
   real, dimension(n,nk), intent(in) :: qe           !specific humidity on e-lev (kg/kg)
   real, dimension(n,nk), intent(in) :: u            !u-component wind (m/s)
   real, dimension(n,nk), intent(in) :: v            !v-component wind (m/s)
   real, dimension(n,nk), intent(in) :: t            !dry air temperature (K)
   real, dimension(n,nk), intent(in) :: tve          !virt. temperature on e-lev (K)
   real, dimension(n,nk), intent(in) :: q            !specific humidity (kg/kg)
   real, dimension(n,nk), intent(in) :: s            !sigma for full levels
   real, dimension(n,nk), intent(in) :: se           !sigma for e-lev
   real, dimension(n,nk), intent(in) :: sw           !sigma for working levels
   real, dimension(*), intent(in) :: vcoef           !coefficients for vertical interpolation
   real, dimension(n,nk), intent(in) :: z            !height of e-levs (m)
   real, dimension(n,nk), intent(in) :: gzmom        !height of momentum levels (m)
   real, dimension(n), intent(inout) :: hpar         !height of parcel ascent (m)
   real, dimension(n,nk), intent(inout) :: en        !TKE (m2/s2)
   real, dimension(n,nk), intent(inout) :: zn        !mixing length (m)
   real, dimension(n,nk), intent(inout) :: zd        !dissipation length (m)
   real, dimension(n,nk), intent(inout) :: qc        !PBL cloud water content
   real, dimension(n,nk), intent(inout) :: fngauss   !Gaussian (local) cloud fraction
   real, dimension(n,nk), intent(inout) :: fnn       !flux enhancement factor
   real, dimension(n,nk), intent(out) :: fnnonloc    !nonlocal cloud fraction
   real, dimension(n,nk), intent(out) :: pri         !inverse Prandtl number (ratio of KT/KM diffusion coefficients)
   real, dimension(n,nk), intent(out) :: rif         !flux Richardson number
   real, dimension(n,nk), intent(out) :: rig         !gradient Richardson number
   real, dimension(n,nk), intent(out) :: buoy        !buoyancy flux (s^-2)
   real, dimension(n,nk), intent(out) :: shr2        !square of vertical wind shear (s^-2)
   real, dimension(n,nk), intent(out) :: turbreg     !turbulence regime
   real, dimension(n,nk), intent(out) :: c1          !coefficient C1 in second-order moment closure (CLSGS)
   real, dimension(n,nk), intent(out) :: gama        !countergradient term for theta_l
   real, dimension(n,nk), intent(out) :: gamaq       !countergradient term for q
   real, dimension(n,nk), intent(out) :: gamal       !countergradient term for q_l
   real, dimension(n,nk), intent(out) :: wthl_ng     !nonlocal flux for theta_l
   real, dimension(n,nk), intent(out) :: wqw_ng      !nonlocal flux for q
   real, dimension(n,nk), intent(out) :: uw_ng       !nonlocal flux for u-wind
   real, dimension(n,nk), intent(out) :: vw_ng       !nonlocal flux for v-wind

   !@Author J. Mailhot (Nov 2000)

   !@Revision
   ! 001      J. Mailhot (Jun 2002) Add cloud ice fraction
   !                      Change calling sequence and rename MOISTKE1
   ! 002      J. Mailhot (Feb 2003) Add boundary layer cloud content
   !                      Change calling sequence and rename MOISTKE2
   ! 003      A. Plante  (May 2003) IBM conversion
   !                        - calls to exponen4 (to calculate power function '**')
   !                        - divisions replaced by reciprocals (call to vsrec from massvp4 library)
   ! 004      B. Bilodeau (Aug 2003) exponen4 replaced by vspown1
   !                                 call to mixlen2
   ! 005      Y. Delage (Sep 2004) Replace UE2 by FRV and rename subroutine. Introduce log-linear
   !                   stability function in mixing length for near-neutral cases.  Perform
   !                    optimisation in calcualtion of KT
   ! 006     A-M. Leduc (June 2007) Add z0 argument, moistke3-->moistke4.
   !                                 Z0 was missing in calculation of ZN.
   ! 007      L. Spacek (Dec 2007) - add "vertical staggering" option
   !                                 correction FITI=BETA*FITI, limit ZN < 5000
   ! 008      A. Zadra/R. McT-C (Sep 2016) Implement nonlocal scaling option designed
   !                    by Mailhot and Lock (Aug 2012).

   !@Object
   !          Calculate the turbulence variables (TKE, mixing length,...)
   !          for a partly cloudy boundary layer, in the framework of a
   !          unified turbulence-cloudiness formulation.
   !          Uses moist conservative variables (thetal and qw), diagnostic
   !          relations for the mixing and dissipation lengths, and a predictive
   !          equation for moist TKE.
   
   !@Notes
   !          Refer to J.Mailhot and R.Benoit JAS 39 (1982)Pg2249-2266
   !          and Master thesis of J.Mailhot.
   !          Mixing length formulation based on Bougeault and Lacarrere .....
   !          Subgrid-scale cloudiness scheme appropriate for TKE scheme
   !          based on studies by Bechtold et al:
   !          - Bechtold and Siebesma 1998, JAS 55, 888-895
   !          - Cuijpers and Bechtold 1995, JAS 52, 2486-2490
   !          - Bechtold et al. 1995, JAS 52, 455-463
   !*@/

#include "clefcon.cdk"
#include "surface.cdk"
#include "machcon.cdk"
#include "tables.cdk"
#include "phyinput.cdk"

   ! Local parameter definitions
   real, parameter :: ICAB=0.4

   ! Local variable declarations
   integer :: ierget,stat,i,j,k
   integer, dimension(n) :: slk
   real :: betai,dtfac
   real, dimension(n) :: e_sfc,beta_sfc
   real, dimension(n,nk) :: znold,work,te,qce,dudz,dvdz,wb_ng,f_cs,e_star,asig,ke,diss_term, &
        shr_term,shr_ng,zero,buoy_term,weight,tv,exner,zn_blac,zn_boujo,zn_blac_clip,frac, &
        blend_hght,przn,fm,fh
   real, dimension(n,nk,3) :: w_cld
   logical, dimension(n,nk) :: turb_mask

   ! External symbols
   integer, external :: neark

   ! Keep the mixing lenght zn from the previous time step
   znold  = zn
   
   ! Initialization
   if(kount.eq.0) then
      do k=1,nk
         do j=1,n
            zn(j,k)=min(KARMAN*(z(j,k)+z0(j)),ML_LMDA)
            zd(j,k)=zn(j,k)
         end do
      end do
      if (.not.any('qtbl' == phyinread_list_s(1:phyinread_n))) qc = 0.
      if (.not.any('fnn' == phyinread_list_s(1:phyinread_n))) fnn = 0.
      if (.not.any('fblgauss' == phyinread_list_s(1:phyinread_n))) fngauss = 0.
      if (.not.any('hpar' == phyinread_list_s(1:phyinread_n))) hpar = hpbl
   endif
   zero = 0.

   ! Estimate boundary layer cloud properties and nonlocal fluxes
   call blcloud5(u,v,t,tve,q,qc,fnn,frac,fngauss,fnnonloc,w_cld, &
        wb_ng,wthl_ng,wqw_ng,uw_ng,vw_ng,f_cs,dudz,dvdz, &
        hpar,frv,z0,wstar,gzmom,z,s,sw,ps,shr2,rig, &
        buoy,tau,vcoef,n,nk,size(w_cld,dim=3))

   ! Output Richardson number time series
   call series_xst(rig, 'RI', trnch)
   call series_xst(rig, 'RM', trnch)

   ! Set countergradient terms to 0 because diffused variables are conserved
   do k=1,nk
      do j=1,n
         gama(j,k)=0.0
         gamaq(j,k)=0.0
         gamal(j,k)=0.0
      end do
   end do

   ! Compute PBL stability functions and inverse Prandtl number (Pr=(fit/fim); pri=(fim/fit))
   if (psf_stabfunc(rig, z, fm, fh, blend_bottom=pbl_slblend_layer(1), &
        blend_top=pbl_slblend_layer(2)) /= PSF_OK) then
      call physeterror('moistke', 'error returned by PBL stability functions')
      return
   endif
   pri = fm/fh

   ! User-selected mixing (zn) and dissipation (zd) length scale estimates
   LENGTH_SCALES: select case (longmel)

   case ('BLAC62') ! Estimate based on Blackadar (1962)
      if (ml_calc_blac(zn, rig, w_cld, z, z0, fm, hpbl, lh, dxdy=dxdy, przn=przn) /= ML_OK) then
         call physeterror('moistke', 'error returned by Blackadar mixing length estimate')
         return
      endif
      if (ml_tfilt(zn, znold, tau, kount) /= ML_OK) then
         call physeterror('moistke', 'error returned by mixing length time filtering')
         return
      endif
      zd = max(zn,1.E-6)
      pri = pri/przn
      
   case ('BOUJO','TURBOUJO') ! Esimate based on Bougeault and Lacarrere (1989)
      call vspown1(exner,se,-CAPPA,n*nk)
      te(1:n,1:nk)  = t(1:n,1:nk)
      qce(1:n,1:nk) = qc(1:n,1:nk)
      tv = te*(1.0+DELTA*qe-qce)*exner
      turb_mask = .true.
      if (longmel == 'TURBOUJO') then
         where (nint(turbreg) == LAMINAR)
            turb_mask = .false.
         endwhere
      endif
      if (ml_calc_boujo(zn_boujo, tv, enold, w_cld, z, s, ps, mask=turb_mask) /= ML_OK) then
           call physeterror('moistke', 'error returned by B-L mixing length estimate')
           return
        endif
      if (ml_calc_blac(zn_blac, rig, w_cld, z, z0, fm, hpbl, lh, przn=przn) /= ML_OK) then
           call physeterror('moistke', 'error returned by Blackadar mixing length estimate')
           return
        endif
      ! Correct thermo levels yields larger mixing lengths: FIXME (remove blend_hght here and gzmom from interface)
      !   stat = ml_blend(zn,zn_blac,zn_boujo,z,s,ps)
      blend_hght(:,:nk-1) = gzmom(:,2:)
      blend_hght(:,nk) = 0.
      if (ml_blend(zn, zn_blac, zn_boujo, blend_hght, s, ps) /= ML_OK) then
         call physeterror('moistke','error returned by mixing length blending')
         return
      endif
      where (zn_boujo < 0.)
         zn = zn_blac   ! Use local (Blackadar) mixing length for laminar flows
      elsewhere
         przn = 1.      ! Use nonlocal (Bougeault) mixing length for turbulent flows
      endwhere
      if (ml_tfilt(zn, znold, tau, kount) /= ML_OK) then
         call physeterror('moistke', 'error returned by mixing length time filtering')
         return
      endif
      pri = pri/przn
      rif = pri*rig
      zd = zn * (1.-min(rif,0.4)) / (1.-2.*min(rif,0.4))
      zd = max(zd,1.e-6)
      if (longmel == 'TURBOUJO' .and. pbl_mlturb_diss) then
         where (nint(turbreg) == LAMINAR) zd = max(zn,1.E-6)
      endif

   case ('LH') ! Estimate based on Lenderink and Holtslag (2004) modified for non-local Cu effects
      przn = 1.
      pri = pri/przn
      if (ml_calc_lh(zd, zn, pri, buoy, enold, w_cld, rig, z, f_cs, hpar) /= ML_OK) then
         call physeterror('moistke', 'error returned by L-H mixing length estimate')
         return
      endif
      if (kount > 0) then ! Blend towards Blackadar length scale at upper levels
         if (ml_calc_blac(zn_blac, rig, w_cld, z, z0, fm, hpbl, lh) /= ML_OK) then
            call physeterror('moistke', 'error returned by Blackadar mixing length estimate')
            return
         endif
         call blweight2(weight, s, ps, n, nk)
         zn = zn_blac + (zn-zn_blac)*weight
         zd = zn_blac + (zd-zn_blac)*weight
         if (ml_tfilt(zn, znold, tau, kount) /= ML_OK) then
            call physeterror('moistke', 'error returned by mixing length time filtering')
            return
         endif
      endif

   end select LENGTH_SCALES
   

   ! Adjust dissipation length scale on user request
   if (pbl_diss == 'LIM50') zd = min(zd,50.)

   ! Recycling of length scales
   if (any('zn'==phyinread_list_s(1:phyinread_n))) zn = znold

   ! Output length scales for time series
   call series_xst(zn, 'L1', trnch)
   call series_xst(zd, 'L2', trnch)
   call series_xst(zd, 'LE', trnch)

   ! Change from gradient to flux form of buoyancy flux and flux Richardson number
   buoy = pri*buoy
   rif = pri*rig
   c1 = 2*BLCONST_CK*pri*ICAB
   CALL series_xst(rif, 'RF', trnch)

   ! Determine turbulence regime
   slk(:) = nk
   if (pbl_turbsl_depth > 0.) &
        stat = neark(se,ps,pbl_turbsl_depth,n,nk,slk) !determine "surface layer" vertical index
   if (kount == 0) then
      INIT_TURB: if (.not.any('turbreg'==phyinread_list_s(1:phyinread_n))) then
         do k=1,nk
            do j=1,n
               if (k <= slk(j)) then
                  if (rif(j,k) > pbl_ricrit(1)) then
                     turbreg(j,k) = LAMINAR
                  else
                     turbreg(j,k) = TURBULENT
                  endif
               else
                  turbreg(j,k) = TURBULENT
               endif
            enddo
         enddo
      endif INIT_TURB
   endif

   ! Apply Richardson number hysteresis and update regime
   do k=1,nk
      if (std_p_prof(k) < 60000.) cycle
      do j=1,n
         ABOVE_SFCLAYER: if (k <= slk(j)) then
            if (rif(j,k) < pbl_ricrit(1)) then
               turbreg(j,k) = TURBULENT
            elseif (rif(j,k) >  pbl_ricrit(2)) then
               turbreg(j,k) = LAMINAR
            endif
            ! Neutral regime: set buoyant suppression to mechanical generation (cute: FIXME)
            if (rif(j,k) > pbl_ricrit(1) .and. rif(j,k) < 1. .and. nint(turbreg(j,k)) == LAMINAR) buoy(j,k) = shr2(j,k)
            if (rif(j,k) > 1. .and. rif(j,k) < pbl_ricrit(2) .and. nint(turbreg(j,k)) == TURBULENT) buoy(j,k) = shr2(j,k)
         else
            turbreg(j,k) = TURBULENT
         endif ABOVE_SFCLAYER
      enddo
   enddo

   ! Update turbulent kinetic energy
   UPDATE_TKE: if (kount == 0) then

      call series_xst(zero, 'EM', trnch)
      call series_xst(zero, 'EB', trnch)
      call series_xst(zero, 'ED', trnch)
      call series_xst(zero, 'ET', trnch)
      call series_xst(zero, 'ER', trnch)

   else

      ! Solve the algabraic part of the TKE equation
      call tkealg2(e_star,en,zn,zd,shr2,buoy,diss_term,shr_term,buoy_term,tau,n,nk)

      ! Add nonlocal fluxes (non-gradient terms) for time series output
      if ( pbl_nonloc == 'LOCK06' ) then
         shr_ng = -uw_ng*dudz - vw_ng*dvdz !non-gradient shear production
         e_star = e_star + tau*(wb_ng + shr_ng) !update of e* for nonlocal
         shr_term = shr_term + shr_ng !non-gradient for shear production term
         buoy_term = buoy_term + wb_ng !non-gradient buoyancy (thermal production) term
      endif

      ! Output TKE equation terms for time series
      call series_xst(shr_term, 'EM', trnch)
      call series_xst(buoy_term, 'EB', trnch)
      call series_xst(diss_term, 'ED', trnch)

      ! Prepare for diffusion term of the TKE equation
      asig = (GRAV/RGASD) * se/tve 
      ke = pbl_tkediff*BLCONST_CK*clefae*zn*sqrt(enold) * asig**2

      ! Compute surface boundary condition
      if (pbl_zerobc) then
         e_sfc = 0.
         beta_sfc = 0.
         e_star(:,nk) = 0.
         call difuvdfj1(en,e_star,ke,zero,zero,zero,e_sfc,beta_sfc,s,se,tau,4,1.,n,n,n,nk)
         if (phy_error_L) return
      else
         e_sfc = BLCONST_CU*frv**2 + BLCONST_CW*wstar**2
         beta_sfc = wstar
         e_star(:,nk) = e_sfc
      endif

      ! Diffuse TKE
      dtfac = 1.
      if (pbl_tkediff2dt) dtfac = 2.
      call difuvdfj1(en,e_star,ke,zero,zero,zero,e_sfc,beta_sfc,s,se,dtfac*tau,4,1.,n,n,n,nk)
      if (phy_error_L) return

      ! update TKE for the timestep
      en = max(ETRMIN,e_star+tau*en)

   endif UPDATE_TKE

   return
end subroutine moistke11
