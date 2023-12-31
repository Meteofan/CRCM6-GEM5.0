!     ######################
      SUBROUTINE SU_CONVPAR
!     ######################

!!****  *SU_CONVPAR * - routine to initialize the constants modules
!!
!!    PURPOSE
!!    -------
!       The purpose of this routine is to initialize  the constants
!     stored in  modules YOE_CONVPAR, YOMCST, YOE_CONVPAREXT.


!!**  METHOD
!!    ------
!!      The deep convection constants are set to their numerical values
!!
!!
!!    EXTERNAL
!!    --------
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!      Module YOE_CONVPAR   : contains deep convection constants
!!
!!    REFERENCE
!!    ---------
!!      Book2 of the documentation (module YOE_CONVPAR, routine SU_CONVPAR)
!!
!!
!!    AUTHOR
!!    ------
!!      P. BECHTOLD       * Laboratoire d'Aerologie *
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    26/03/96
!!   Last modified  15/04/98 adapted for ARPEGE
!-------------------------------------------------------------------------------


!*       0.    DECLARATIONS
!              ------------

use cnv_options
USE YOE_CONVPAR

IMPLICIT NONE
#include <arch_specific.hf>

!-------------------------------------------------------------------------------

!*       1.    Set the thermodynamical and numerical constants for
!              the deep convection parameterization
!              ---------------------------------------------------


XA25     = 625.E6    ! 25 km x 25 km reference grid area

XCRAD    = 1500.     ! cloud radius (m)
XCDEPTH  = 3.E3      ! minimum necessary cloud depth (m)
XENTR    = 0.03      ! entrainment constant (m/Pa) = 0.2 (m)

XZLCL    = 3.5E3     ! maximum allowed allowed height
                          ! difference between the surface and the DPL (m)
XZPBL    = 60.E2     ! minimum mixed layer depth to sustain convection
XWTRIG   = 6.00      ! constant in vertical velocity trigger
XDTHPBL  = .1        ! Temp. perturbation in PBL for trigger (K)
XDRVPBL  = 1.e-4     ! moisture  perturbation in PBL for trigger (kg/kg)


XNHGAM   = 1.3333    ! accounts for non-hydrost. pressure
                          ! in buoyancy term of w equation
                          ! = 2 / (1+gamma)
XTFRZ1   = 273.16    ! begin of freezing interval (K)
XTFRZ2   = 250.16    ! end of freezing interval (K)

XRHDBC   = 0.9       ! relative humidity below cloud in downdraft

XRCONV   = 0.015     ! constant in precipitation conversion
XRCONV   = 0.010     ! constant in precipitation conversion
XSTABT   = 0.75      ! factor to assure stability in  fractional time
                          ! integration, routine CONVECT_CLOSURE
XSTABC   = 0.95      ! factor to assure stability in CAPE adjustment,
                          !  routine CONVECT_CLOSURE
XUSRDPTH = 165.E2    ! pressure thickness used to compute updraft
                          ! moisture supply rate for downdraft
XMELDPTH = 200.E2    ! layer (Pa) through which precipitation melt is
                          ! allowed below downdraft
XUVDP    = 0.7       ! constant for pressure perturb in momentum transport

! Impose the following for compatibility with KFC

XDTHPBL  = 0.             ! Temp. perturbation in PBL for trigger (K)
XDRVPBL  = 0.             ! moisture  perturbation in PBL for trigger (kg/kg)
XTFRZ1   = 268.16    ! begin of freezing interval (K)
XTFRZ2   = 248.16    ! end of freezing interval (K)
XCDEPTH  = 4.E3      ! minimum necessary cloud depth (m)
XCDEPTH  = kfcdepth      ! minimum necessary cloud depth (m)
XUVDP    = 0.             ! constant for pressure perturb in momentum transport
XWTRIG   = 4.64      ! constant in vertical velocity trigger

END SUBROUTINE SU_CONVPAR

