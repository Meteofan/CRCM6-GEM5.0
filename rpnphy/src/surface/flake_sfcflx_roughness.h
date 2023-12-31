! File %M% from Library %Q%
! Version %I% from %G% extracted: %H%
!------------------------------------------------------------------------------

SUBROUTINE flake_SfcFlx_roughness (fetch, U_a, u_star, h_ice,   & 
                             c_z0u_fetch, u_star_thresh, z0u, z0t, z0q)

!------------------------------------------------------------------------------
!
! Description:
!
!  Computes the water-surface or the ice-surface roughness lengths
!  with respect to wind velocity, potential temperature and specific humidity.
!
!  The water-surface roughness lengths with respect to wind velocity is computed
!  from the Charnock formula when the surface is aerodynamically rough.
!  A simple empirical formulation is used to account for the dependence 
!  of the Charnock parameter on the wind fetch. 
!  When the flow is aerodynamically smooth, the roughness length with respect to 
!  wind velocity is proportional to the depth of the viscous sub-layer.
!  The water-surface roughness lengths for scalars are computed using the power-law 
!  formulations in terms of the roughness Reynolds number (Zilitinkevich et al. 2001).
!  The ice-surface aerodynamic roughness is taken to be constant.
!  The ice-surface roughness lengths for scalars 
!  are computed through the power-law formulations 
!  in terms of the roughness Reynolds number (Andreas 2002).
!
!
! Current Code Owner: DWD, Dmitrii Mironov
!  Phone:  +49-69-8062 2705
!  Fax:    +49-69-8062 3721
!  E-mail: dmitrii.mironov@dwd.de
!
! History:
! Version    Date       Name
! ---------- ---------- ----
! 1.00       2005/11/17 Dmitrii Mironov 
!  Initial release
! !VERSION!  !DATE!     <Your name>
!  <Modification comments>
!
! Code Description:
! Language: Fortran 90.
! Software Standards: "European Standards for Writing and
! Documenting Exchangeable Fortran 90 Code".
!==============================================================================
!
! Declarations:
!
! Modules used:

!_dm Parameters are USEd in module "SfcFlx".
!_nu USE data_parameters , ONLY :   &
!_nu   ireals                     , & ! KIND-type parameter for real variables
!_nu   iintegers                      ! KIND-type parameter for "normal" integer variables

!==============================================================================

IMPLICIT NONE

!==============================================================================
!
! Declarations

!  Input (procedure arguments)
REAL (KIND = ireals), INTENT(IN) ::   &
  fetch                             , & ! Typical wind fetch [m]
  U_a                               , & ! Wind speed [m s^{-1}]
  u_star                            , & ! Friction velocity in the surface air layer [m s^{-1}]
  h_ice                                 ! Ice thickness [m]

!  Output (procedure arguments)
REAL (KIND = ireals), INTENT(OUT) ::   &
  c_z0u_fetch                        , & ! Fetch-dependent Charnock parameter
  u_star_thresh                      , & ! Threshold value of friction velocity [m s^{-1}]
  z0u                                , & ! Roughness length with respect to wind velocity [m]
  z0t                                , & ! Roughness length with respect to potential temperature [m]
  z0q                                    ! Roughness length with respect to specific humidity [m]

!  Local variables of type REAL
REAL (KIND = ireals) ::    &
  Re_s                   , & ! Surface Reynolds number 
  Re_s_thresh                ! Threshold value of Re_s

!==============================================================================
!  Start calculations
!------------------------------------------------------------------------------

Water_or_Ice: IF(h_ice.LT.h_Ice_min_flk) THEN  ! Water surface  

! The Charnock parameter as dependent on dimensionless fetch
  c_z0u_fetch = MAX(U_a, u_wind_min_sf)**2_iintegers/tpl_grav/fetch  ! Inverse dimensionless fetch
  c_z0u_fetch = c_z0u_rough + c_z0u_ftch_f*c_z0u_fetch**c_z0u_ftch_ex
  c_z0u_fetch = MIN(c_z0u_fetch, c_z0u_rough_L)                      ! Limit Charnock parameter

! Threshold value of friction velocity
  u_star_thresh = (c_z0u_smooth/c_z0u_fetch*tpl_grav*tpsf_nu_u_a)**num_1o3_sf

! Surface Reynolds number and its threshold value
  Re_s = u_star**3_iintegers/tpsf_nu_u_a/tpl_grav
  Re_s_thresh = c_z0u_smooth/c_z0u_fetch

! Aerodynamic roughness
  IF(Re_s.LE.Re_s_thresh) THEN                 
    z0u = c_z0u_smooth*tpsf_nu_u_a/u_star     ! Smooth flow
  ELSE
    z0u = c_z0u_fetch*u_star*u_star/tpl_grav  ! Rough flow
  END IF 
! Roughness for scalars  
  z0q = c_z0u_fetch*MAX(Re_s, Re_s_thresh)
  z0t = c_z0t_rough_1*z0q**c_z0t_rough_3 - c_z0t_rough_2
  z0q = c_z0q_rough_1*z0q**c_z0q_rough_3 - c_z0q_rough_2
  z0t = z0u*EXP(-c_Karman/Pr_neutral*z0t)
  z0q = z0u*EXP(-c_Karman/Sc_neutral*z0q) 

ELSE Water_or_Ice                              ! Ice surface

! The Charnock parameter is not used over ice, formally set "c_z0u_fetch" to its minimum value
  c_z0u_fetch = c_z0u_rough

! Threshold value of friction velocity
  u_star_thresh = c_z0u_smooth*tpsf_nu_u_a/z0u_ice_rough

! Aerodynamic roughness
  z0u = MAX(z0u_ice_rough, c_z0u_smooth*tpsf_nu_u_a/u_star)

! Roughness Reynolds number 
  Re_s = MAX(u_star*z0u/tpsf_nu_u_a, c_accur_sf)

! Roughness for scalars  
  IF(Re_s.LE.Re_z0s_ice_t) THEN 
    z0t = c_z0t_ice_b0t + c_z0t_ice_b1t*LOG(Re_s)
    z0t = MIN(z0t, c_z0t_ice_b0s)
    z0q = c_z0q_ice_b0t + c_z0q_ice_b1t*LOG(Re_s)
    z0q = MIN(z0q, c_z0q_ice_b0s)
  ELSE 
    z0t = c_z0t_ice_b0r + c_z0t_ice_b1r*LOG(Re_s) + c_z0t_ice_b2r*LOG(Re_s)**2_iintegers
    z0q = c_z0q_ice_b0r + c_z0q_ice_b1r*LOG(Re_s) + c_z0q_ice_b2r*LOG(Re_s)**2_iintegers
  END IF
  z0t = z0u*EXP(z0t)
  z0q = z0u*EXP(z0q)

END IF Water_or_Ice

! Limit roughness length between 1.5E-5 and 5.E-3 i
! as done in the GEM water routine (K. Winger, UQAM)
z0t = max( min( z0t, 5.E-3 ), 1.5E-5) 
z0q = max( min( z0q, 5.E-3 ), 1.5E-5)
z0u = max( min( z0u, 5.E-3 ), 1.5E-5)

!OPEN(UNIT=111, FILE='Roughness', POSITION='APPEND')
!WRITE(111,211) z0u, z0t, z0q

!211  FORMAT(3(G13.6, 1X))

!CLOSE(111)
!------------------------------------------------------------------------------
!  End calculations
!==============================================================================

END SUBROUTINE flake_SfcFlx_roughness

