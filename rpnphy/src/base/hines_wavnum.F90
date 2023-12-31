!-------------------------------------- LICENCE BEGIN -------------------------
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
SUBROUTINE hines_wavnum ( m_alpha, sigma_t, sigma_alpha, ak_alpha,     &
       &                    mmin_alpha, losigma_t,                       &
       &                    v_alpha, visc_mol, density, densb,           &
       &                    bvfreq, bvfb, rms_wind, anis, lorms,         &
       &                    sigsqmcw, sigmatm,                           &
       &                    il1, il2, levtop, levbot, nlons, nlevs, nazmth)

    USE mo_gwspectrum,   ONLY: kstar, m_min, slope, f1, f2, f3, naz
    use phy_status, only: phy_error_L
    implicit none
#include <arch_specific.hf>

    INTEGER :: il1, il2, levtop, levbot, nlons, nlevs, nazmth
    REAL*8    :: m_alpha(nlons,nlevs,nazmth)
    REAL*8    :: sigma_alpha(nlons,nlevs,nazmth)
    REAL*8    :: sigalpmc(nlons,nlevs,nazmth)
    REAL*8    :: sigsqh_alpha(nlons,nlevs,nazmth)
    REAL*8    :: sigma_t(nlons,nlevs)
    REAL*8    :: sigmatm(nlons,nlevs)
    REAL*8    :: sigsqmcw(nlons,nlevs,nazmth)
    REAL*8    :: ak_alpha(nlons,nazmth)
    REAL*8    :: v_alpha(nlons,nlevs,nazmth)
    REAL*8    :: visc_mol(nlons,nlevs)
    REAL*8    :: f2mod(nlons,nlevs)
    REAL*8    :: density(nlons,nlevs),  densb(nlons)
    REAL*8    :: bvfreq(nlons,nlevs),   bvfb(nlons),  rms_wind(nlons)
    REAL*8    :: anis(nlons,nazmth) 
    REAL*8    :: i_alpha(nlons,nazmth), mmin_alpha(nlons,nazmth)

    LOGICAL :: lorms(nlons), losigma_t(nlons,nlevs), do_alpha(nlons,nazmth)

!@Author
!  aug. 10/95 - c. mclandress
!  2000-2001  - m. charron
!  2002       - e. manzini
!@Object
!
!  This routine calculates the cutoff vertical wavenumber and velocity
!  variances on a longitude by altitude grid for the hines' doppler 
!  spread gravity wave drag parameterization scheme.
!  note: (1) only values of four or eight can be used for # azimuths (naz).
!        (2) only values of 1.0, 1.5 or 2.0 can be used for slope (slope). 
!        (3) if m_min not zero, only slope=1. can be used. 
!
!@Arguments
!
!              - Output
! m_alpha      cutoff wavenumber at each azimuth (1/m).
! sigma_t      total rms horizontal wind (m/s).
! sigma_alpha  total rms wind in each azimuth (m/s).
! ak_alpha     spectral amplitude factor at each azimuth 
!              (i.e.,{ajkj}) in m^4/s^2.
! losigma_t    .true. for total sigma not zero
! mmin_alpha   minimum value of cutoff wavenumber.
!
!              - Input -
! v_alpha      wind component at each azimuth (m/s). 
! visc_mol     molecular viscosity (m^2/s)
! density      background density (kg/m^3).
! densb        background density at model bottom (kg/m^3).
! bvfreq       background brunt vassala frequency (radians/sec).
! bvfb         background brunt vassala frequency at model bottom.
! rms_wind     root mean square gravity wave wind at lowest level (m/s).
! anis         anisotropy factor (sum over azimuths is one)
! lorms        .true. for drag computation at lowest level 
! levbot       index of lowest vertical level.
! levtop       index of highest vertical level 
!              (note: if levtop < levbot then level index 
!              increases from top down).
! il1          first longitudinal index to use (il1 >= 1).
! il2          last longitudinal index to use (il1 <= il2 <= nlons).
! nlons        number of longitudes.
! nlevs        number of vertical levels.
! nazmth       azimuthal array dimension (nazmth >= naz).
!
!             - work arrays -
! i_alpha      hines' integral at a single level.
! do_alpha     .true. for the azimuths and longitudes for
!                   which to continue to compute the drag above  
!                   the lowest level
!*@/

    INTEGER :: i, l, n, istart, lend, lincr, lbelow

    REAL*8    :: m_sub_m_turb, m_sub_m_mol, m_trial, mmsq
    REAL*8    :: visc, visc_min, sp1, f2mfac, deno, t1

    REAL*8    :: n_over_m(nlons), sigfac(nlons)

    !-----------------------------------------------------------------------     
    !

    t1=1.d-10
    visc_min = 1.e-10 

    sp1 = slope + 1.
    mmsq = m_min**2

    !
    !  indices of levels to process.
    !
    IF (levbot > levtop)  THEN
       istart = levbot - 1     
       lend   = levtop         
       lincr  = -1
    ELSE
       call physeterror('hines_wavnum', 'level index not increasing downward')
       return
    END IF


    !   initialize logical flags and arrays
    DO l=1,nlevs
       losigma_t(:,l) = lorms(:)
    ENDDO
    DO n=1,nazmth
       do_alpha(:,n) = lorms(:)
    ENDDO

    sigsqh_alpha(:,:,:) = 0
    i_alpha(:,:) = 0.0

    !
    ! calculate azimuthal variances at bottom level using anisotropy factor
    !
    DO n = 1,naz
       DO i = il1,il2
          sigsqh_alpha(i,levbot,n) = anis(i,n)* rms_wind(i)**2
       END DO
    END DO
    !
    !  velocity variances at bottom level.
    !
    CALL hines_sigma ( sigma_t, sigma_alpha,     &
         &                   sigsqh_alpha, naz, levbot,     &
         &                   il1, il2, nlons, nlevs, nazmth)

    CALL hines_sigma ( sigmatm, sigalpmc,     &
         &                   sigsqmcw, naz, levbot,     &
         &                   il1, il2, nlons, nlevs, nazmth)

    !  calculate cutoff wavenumber and spectral amplitude factor 
    !  at bottom level where it is assumed that background winds vanish
    !  and also initialize minimum value of cutoff wavnumber.
    !
    IF ( ABS(slope-1.) < EPSILON(1.) ) THEN
       DO n = 1,naz
          DO i = il1,il2
             IF (lorms(i)) THEN
                m_alpha(i,levbot,n) =  bvfb(i) /    &
                     &                             ( f1 * sigma_alpha(i,levbot,n)    &
                     &                             + f2 * sigma_t(i,levbot) )
                ak_alpha(i,n)   = 2. * sigsqh_alpha(i,levbot,n)    &
                     &                        / ( m_alpha(i,levbot,n)**2 - mmsq )
                mmin_alpha(i,n) = m_alpha(i,levbot,n)
             ENDIF
          END DO
       END DO
    ELSE
       DO n = 1,naz
          DO i = il1,il2
             IF (lorms(i)) THEN
                m_alpha(i,levbot,n) =  bvfb(i) /    & 
                     &                           ( f1 * sigma_alpha(i,levbot,n)    & 
                     &                           + f2 * sigma_t(i,levbot) )
                ak_alpha(i,n)   = sigsqh_alpha(i,levbot,n)    & 
                     &                      / ( m_alpha(i,levbot,n)**sp1 / sp1 )
                mmin_alpha(i,n) = m_alpha(i,levbot,n)
             ENDIF
          END DO
       END DO
    ENDIF
    !
    !  calculate quantities from the bottom upwards, 
    !  starting one level above bottom.
    !

    DO l = istart,lend,lincr
       !
       !  level beneath present level.
       !
       lbelow = l - lincr 
       !
       !  calculate n/m_m where m_m is maximum permissible value of the vertical
       !  wavenumber (i.e., m > m_m are obliterated) and n is buoyancy frequency.
       !  m_m is taken as the smaller of the instability-induced 
       !  wavenumber (m_sub_m_turb) and that imposed by molecular viscosity
       !  (m_sub_m_mol). since variance at this level is not yet known
       !  use value at level below.
       !

       DO i = il1,il2
          IF (losigma_t(i,lbelow))   THEN

             f2mfac=sigmatm(i,lbelow)**2
             f2mod(i,lbelow) =1.+ 2.*f2mfac  &
                  &                      / ( f2mfac+sigma_t(i,lbelow)**2 )

             visc = MAX ( visc_mol(i,l), visc_min )
             m_sub_m_turb = bvfreq(i,l)   &
                  &                 / ( f2 *f2mod(i,lbelow)*sigma_t(i,lbelow))
             m_sub_m_mol = (bvfreq(i,l)*kstar/visc)**0.33333333/f3

             IF (m_sub_m_turb < m_sub_m_mol)  THEN
                n_over_m(i) = f2 *f2mod(i,lbelow)*sigma_t(i,lbelow)
             ELSE
                n_over_m(i) = bvfreq(i,l) / m_sub_m_mol 
             END IF

          ENDIF
       END DO

       !
       !  calculate cutoff wavenumber at this level.
       !
       DO n = 1,naz
          DO i = il1,il2
             IF ( do_alpha(i,n) .AND. losigma_t(i,lbelow) ) THEN
                !
                !  calculate trial value (variance at this level is not yet known:
                !  use value at level below). if trial value negative or larger 
                !  minimum value (not permitted) then set it to minimum value. 
                !
                deno= f1 * (sigma_alpha(i,lbelow,n)+sigalpmc(i,lbelow,n)) + n_over_m(i) + v_alpha(i,l,n)
                if (abs(deno).lt.t1) deno= sign(t1,deno)
  	        m_trial = bvfb(i) / deno
!                m_trial = bvfb(i) / ( f1 * ( sigma_alpha(i,lbelow,n)+   & 
!                     &       sigalpmc(i,lbelow,n)) + n_over_m(i) + v_alpha(i,l,n) )

                IF (m_trial <= 0. .OR. m_trial > mmin_alpha(i,n))  THEN
                   m_trial = mmin_alpha(i,n)
                END IF
                m_alpha(i,l,n) = m_trial

                !  do not permit cutoff wavenumber to be less than minimum  value.

                IF (m_alpha(i,l,n) < m_min) THEN
                   m_alpha(i,l,n) = m_min
                ENDIF
                !
                !  reset minimum value of cutoff wavenumber if necessary.
                !
                IF (m_alpha(i,l,n) < mmin_alpha(i,n))  THEN
                   mmin_alpha(i,n) = m_alpha(i,l,n)
                END IF
             ELSE

                m_alpha(i,l,n) = m_min

             ENDIF
          END DO
       END DO
       !
       !  calculate the hines integral at this level.
       !
       CALL hines_intgrl ( i_alpha,                                     &
            &              v_alpha, m_alpha, bvfb, m_min, slope, naz,   &
            &              l, il1, il2, nlons, nlevs, nazmth,           &
            &              lorms, do_alpha )
!	i_alpha=0.
       if (phy_error_L) return

       !
       !  calculate the velocity variances at this level.
       !
       DO i = il1,il2
          sigfac(i) = densb(i) / density(i,l) * bvfreq(i,l) / bvfb(i) 
       END DO
	
       DO n = 1,naz
          DO i = il1,il2
!           sigsqh_alpha(i,l,n)=0.
             sigsqh_alpha(i,l,n) = sigfac(i) * ak_alpha(i,n) * i_alpha(i,n)
          END DO
       END DO
       CALL hines_sigma ( sigma_t, sigma_alpha, sigsqh_alpha, naz, l, &
            &                    il1, il2, nlons, nlevs, nazmth )

       CALL hines_sigma ( sigmatm, sigalpmc, sigsqmcw, naz, l,   &
            &                     il1, il2, nlons, nlevs, nazmth )

       !
       !  if total rms wind zero (no more drag) then set drag to false
       !
       DO i=il1,il2
          IF ( sigma_t(i,l) < EPSILON(1.) ) THEN
             losigma_t(i,l) = .FALSE.
          ENDIF
       ENDDO
       !
       !  end of level loop.
       !
    END DO
    !
    RETURN
    !-----------------------------------------------------------------------
  END SUBROUTINE hines_wavnum
