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

module ver
   use type_mod
   implicit none
   public
   save

!
!**comdeck ver.cdk
!
!______________________________________________________________________
!                                                                      |
!  Vertical coordinate parameters                                      |
!______________________________________________________________________|
!                     |                                                |
! NAME                | DESCRIPTION                                    |
!----------------------------------------------------------------------|
! Ver_ip1%(t,m)       | ip1      for the hybrid vertical coordinate    |
!----------------------------------------------------------------------|
! Ver_a_8%(t,m)       | A        for the hybrid vertical coordinate    |
!----------------------------------------------------------------------|
! Ver_b_8%(t,m)       | B        for the hybrid vertical coordinate    |
!----------------------------------------------------------------------|
! Ver_c_8%(t,m)       | C        for the hybrid vertical coordinate    |
!----------------------------------------------------------------------|
! Ver_z_8%(t,m,x)     | Coordinate zeta: ln(pistar)                    |
!----------------------------------------------------------------------|
! Ver_dz_8%(t,m)      |            zeta spacing                        |
!----------------------------------------------------------------------|
! Ver_idz_8%(t,m)     |    inverse zeta spacing                        |
!----------------------------------------------------------------------|
! Ver_dbdz_8%(t,m)    | vertical derivative of B                       |
!----------------------------------------------------------------------|
! Ver_dcdz_8%(t,m)    | vertical derivative of C                       |
!----------------------------------------------------------------------|
! Ver_wp_8%(t,m)      | weights for averaging                          |
! Ver_wm_8%(t,m)      | weights for averaging                          |
! Ver_Tstar_8(t,m)    | variable T*                                    |
!----------------------------------------------------------------------|
! Ver_std_p_prof%(t,m)| STanDard Pressure PROFile for physics          |
!----------------------------------------------------------------------|
! Ver_table_8         | real*8 table containing vgrid descriptors      |
!----------------------------------------------------------------------|
! Ver_gama_8          | A parameter function of T*                     |
! Ver_epsi_8          | A parameter function of T*: RT*/(g tau)**2     |
! Ver_FIstr_8         | FI*: geopotential basic state function of T*   |
! Ver_bzz_8           | Vertical averaging on B from thermo to mom.    |
! Ver_czz_8           | Vertical averaging on C from thermo to mom.    |
! Ver_wpstar_8        | special weights for averaging                  |
! Ver_wmstar_8        | special weights for averaging                  |
!----------------------------------------------------------------------|
! Ver_onezero         | Vector with one everywhere but zero at k=1     |
!-----------------------------------------------------------------------
!
!
      type :: V8_tmx
         sequence
         real*8, dimension(:), pointer :: t,m,x
      end type V8_tmx

      type (V8_tmx) Ver_z_8

      type (vertical_i) Ver_ip1
      type (vertical_8) Ver_a_8
      type (vertical_8) Ver_b_8
      type (vertical_8) Ver_c_8
      type (vertical_8) Ver_dz_8
      type (vertical_8) Ver_idz_8
      type (vertical_8) Ver_dbdz_8
      type (vertical_8) Ver_dcdz_8
      type (vertical_8) Ver_wp_8
      type (vertical_8) Ver_wm_8
      type (vertical_8) Ver_Tstar_8

      type (vertical)   Ver_hyb
      type (vertical)   Ver_std_p_prof

      real :: Ver_hyb_top

      real*8 Ver_alfas_8,Ver_betas_8,Ver_css_8,Ver_cssp_8
      real*8 Ver_alfat_8,Ver_cst_8,Ver_cstp_8
      real*8 Ver_igt_8,Ver_igt2_8,Ver_ikt_8
      real*8 Ver_zmin_8,Ver_zmax_8

      integer Ver_code

      real*8, dimension(:,:,:), pointer :: ver_table_8
      real*8, dimension(:)    , pointer :: Ver_gama_8,Ver_epsi_8
      real*8, dimension(:)    , pointer :: Ver_FIstr_8,Ver_bzz_8
      real*8, dimension(:)    , pointer :: Ver_czz_8
      real*8, dimension(:)    , pointer :: Ver_wpstar_8,Ver_wmstar_8
      real*8, dimension(:)    , pointer :: Ver_wpA_8,Ver_wmA_8
      real*8, dimension(:)    , pointer :: Ver_wpM_8,Ver_wmM_8
      real*8, dimension(:)    , pointer :: Ver_wpC_8,Ver_wmC_8

      real, dimension(:), pointer :: Ver_onezero

end module ver
