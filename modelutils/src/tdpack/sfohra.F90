!-------------------------------------- LICENCE BEGIN ------------------------------------
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
!-------------------------------------- LICENCE END --------------------------------------
!**fonction sfohra  -  calcule hum rel de hum sp, temp et pression.
!
      Function sfohra(qq,tt,pr)
      use tdpack, only: fohra
      implicit none
#include <arch_specific.hf>
      Real sfohra, qq, tt, pr
!
!Author
!          N. Brunet  (Jan91)
!
!Object
!          to return relative humidity(fraction) calculated from
!          specific humidity, temperature and pressure. Water phase
!          is considered only for all temperatures
!
!Arguments
!
!          - Input -
! qq       specific humidity in kg/kg
! tt       temperature in K
! PR       pressure in Pa
!*
!--------------------------------------------------------------------
!
!
      sfohra = fohra(qq,tt,pr)
!
      End Function sfohra
