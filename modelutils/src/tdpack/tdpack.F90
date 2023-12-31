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
!-------------------------------------- LICENCE END ---------------------------

module tdpack
   use tdpack_const
   implicit none
   public

   !# fpp tdpack.F90 provides the pre-processing result

#define _TDARG1 tdpk1
#define _TDARG2 tdpk1, tdpk2
#define _TDARG3 tdpk1, tdpk2, tdpk3
#define _TDARG6 tdpk1, tdpk2, tdpk3, tdpk4, tdpk5, tdpk6

#define _TDFNC1(N, F) N = F(tdpk1) 
#define _TDFNC2(N, F) N = F(tdpk1, tdpk2) 
#define _TDFNC3(N, F) N = F(tdpk1, tdpk2, tdpk3) 
#define _TDFNC6(N, F) N = F(tdpk1, tdpk2, tdpk3, tdpk4, tdpk5, tdpk6) 

#define __FORTRAN__
#include "tdpack_func.h"

   real, external :: schal, sesahr3, sesahu3, sfodla, sfodle, sfodqa
   real, external :: sfodqs, sfoefq, sfoew, sfoewa, sfohr, sfohra, sfols
   real, external :: sfolv, sfopop, sfopot, sfoqfe, sfoqsa, sfoqst, sfottv
   real, external :: sfotvt, sgamash, sgamasp, sgamatd, shraes3, shrahu3
   real, external :: shuaes3, shuahr3, stetae, sthtaw3, sthtaw4, sttlcl

contains

   real*8 function maskt(_TDARG1)
      real, intent(in) :: _TDARG1
      _TDFNC1(maskt, MASKT)
   end function
!#Note: undef are done to prevent line too long generated by macro in other functions, following function will use the fortran function instead of the marco
#undef MASKT

   real*8 function fomults(tdpk1d, tdpk2)
      real*8, intent(in) :: tdpk1d
      real,   intent(in) :: tdpk2
      fomults = FOMULTS(tdpk1d,tdpk2)
   end function
#undef FOMULTS

   real*8 function foewf(_TDARG1)
      real, intent(in) :: _TDARG1
      _TDFNC1(foewf, FOEWF)
   end function
#undef FOEWF

   real*8 function foew(_TDARG1)
      real, intent(in) :: _TDARG1
      _TDFNC1(foew, FOEW)
   end function
#undef FOEW

   real*8 function foewaf(_TDARG1)
      real, intent(in) :: _TDARG1
      _TDFNC1(foewaf, FOEWAF)
   end function
#undef FOEWAF

   real*8 function foewa(_TDARG1)
      real, intent(in) :: _TDARG1
      _TDFNC1(foewa, FOEWA)
   end function
#undef FOEWA

   real*8 function fodle(_TDARG1)
      real, intent(in) :: _TDARG1
      _TDFNC1(fodle, FODLE)
   end function
#undef FODLE

   real*8 function fodla(_TDARG1)
      real, intent(in) :: _TDARG1
      _TDFNC1(fodla, FODLA)
   end function
#undef FODLA

   real*8 function fesif(_TDARG1)
      real, intent(in) :: _TDARG1
      _TDFNC1(fesif, FESIF)
   end function
#undef FESIF

   real*8 function fesi(_TDARG1)
      real, intent(in) :: _TDARG1
      _TDFNC1(fesi, FESI)
   end function
#undef FESI

   real*8 function fdlesi(_TDARG1)
      real, intent(in) :: _TDARG1
      _TDFNC1(fdlesi, FDLESI)
   end function
#undef FDLESI

   real*8 function foefq(_TDARG2)
      real, intent(in) :: _TDARG2
      _TDFNC2(foefq, FOEFQ)
   end function
#undef FOEFQ

   real*8 function fesmx(_TDARG2)
      real, intent(in) :: _TDARG2
      _TDFNC2(fesmx, FESMX)
   end function
#undef FESMX

   real*8 function fols(_TDARG1)
      real, intent(in) :: _TDARG1
      _TDFNC1(fols, FOLS)
   end function

   real*8 function folv(_TDARG1)
      real, intent(in) :: _TDARG1
      _TDFNC1(folv, FOLV)
   end function

   real*8 function fdqsmx(_TDARG2)
      real, intent(in) :: _TDARG2
      _TDFNC2(fdqsmx, FDQSMX)
   end function

   real*8 function fodqa(_TDARG2)
      real, intent(in) :: _TDARG2
      _TDFNC2(fodqa, FODQA)
   end function

   real*8 function fodqs(_TDARG2)
      real, intent(in) :: _TDARG2
      _TDFNC2(fodqs, FODQS)
   end function

   real*8 function foqfe(_TDARG2)
      real, intent(in) :: _TDARG2
      _TDFNC2(foqfe, FOQFE)
   end function

   real*8 function foqsa(_TDARG2)
      real, intent(in) :: _TDARG2
      _TDFNC2(foqsa, FOQSA)
   end function

   real*8 function foqst(_TDARG2)
      real, intent(in) :: _TDARG2
      _TDFNC2(foqst, FOQST)
   end function

   real*8 function foqstx(tdpk1,tdpk2d)
      real, intent(in) :: tdpk1
      real*8, intent(in) :: tdpk2d
      foqstx = FOQSTX(tdpk1,tdpk2d)
   end function

   real*8 function fottv(_TDARG2)
      real, intent(in) :: _TDARG2
      _TDFNC2(fottv, FOTTV)
   end function

   real*8 function fotvt(_TDARG2)
      real, intent(in) :: _TDARG2
      _TDFNC2(fotvt, FOTVT)
   end function

   real*8 function fqsmxx(tdpk1d,tdpk2)
      real*8, intent(in) :: tdpk1d
      real, intent(in) :: tdpk2
      fqsmxx = FQSMXX(tdpk1d,tdpk2)
   end function

   real*8 function fdlesmx(_TDARG3)
      real, intent(in) :: _TDARG3
      _TDFNC3(fdlesmx, FDLESMX)
   end function

   real*8 function fesmxx(tdpk1,tdpk2d,tdpk3d)
      real, intent(in) :: tdpk1
      real*8, intent(in) :: tdpk2d,tdpk3d
      fesmxx = FESMXX(tdpk1,tdpk2d,tdpk3d)
   end function

   real*8 function fohr(_TDARG3)
      real, intent(in) :: _TDARG3
      _TDFNC3(fohr, FOHR)
   end function

   real*8 function fohra(_TDARG3)
      real, intent(in) :: _TDARG3
      _TDFNC3(fohra, FOHRA)
   end function

   real*8 function fohrx(tdpk1,tdpk2,tdpk3d)
      real, intent(in) :: tdpk1,tdpk2
      real*8, intent(in) :: tdpk3d
      fohrx = FOHRX(tdpk1,tdpk2,tdpk3d)
   end function

   real*8 function fopoip(_TDARG3)
      real, intent(in) :: _TDARG3
      _TDFNC3(fopoip, FOPOIP)
   end function

   real*8 function fopoit(_TDARG3)
      real, intent(in) :: _TDARG3
      _TDFNC3(fopoit, FOPOIT)
   end function

   real*8 function fottvh(_TDARG3)
      real, intent(in) :: _TDARG3
      _TDFNC3(fottvh, FOTTVH)
   end function

   real*8 function fotvht(_TDARG3)
      real, intent(in) :: _TDARG3
      _TDFNC3(fotvht, FOTVHT)
   end function

   real*8 function fqsmx(_TDARG3)
      real, intent(in) :: _TDARG3
      _TDFNC3(fqsmx, FQSMX)
   end function

   real*8 function fdlesmxx(tdpk1,tdpk2,tdpk3,tdpk4d,tdpk5d,tdpk6d)
      real, intent(in) :: tdpk1,tdpk2,tdpk3
      real*8, intent(in) :: tdpk4d,tdpk5d,tdpk6d
      fdlesmxx = FDLESMXX(tdpk1,tdpk2,tdpk3,tdpk4d,tdpk5d,tdpk6d)
   end function


end module tdpack

