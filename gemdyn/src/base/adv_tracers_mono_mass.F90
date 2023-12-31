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
      subroutine adv_tracers_mono_mass ( F_name_S, F_out, F_cub, &
                              F_mono, F_lin, F_min, F_max, F_in, &
                              F_for_flux_o,F_for_flux_i        , &
                              Minx,Maxx,Miny,Maxy,F_nk         , &
                              i0,in,j0,jn,k0,F_mono_kind,F_mass_kind )

      use lun
      use tracers
      implicit none
#include <arch_specific.hf>

      character(len=*), intent(in) ::F_name_S !I, Name of the interpolated field
      integer, intent(in) :: F_nk !I, Number of vertical levels
      integer, intent(in) :: i0,in,j0,jn,k0 !I, Scope of operator
      integer, intent(in) :: F_mono_kind !I, Kind of Shape preservation
      integer, intent(in) :: F_mass_kind !I, Kind of Mass conservation
      integer, intent(in) :: Minx,Maxx,Miny,Maxy
      real, dimension(Minx:Maxx,Miny:Maxy,F_nk), intent(out) :: F_out !Corrected (Shape preserved/conservative) solution
      real, dimension(Minx:Maxx,Miny:Maxy,F_nk), intent(in)  :: F_cub !Cubic  SL solution
      real, dimension(Minx:Maxx,Miny:Maxy,F_nk), intent(inout)  :: F_mono!Cubic  SL solution
      real, dimension(Minx:Maxx,Miny:Maxy,F_nk), intent(in)  :: F_lin !Linear SL solution
      real, dimension(Minx:Maxx,Miny:Maxy,F_nk), intent(in)  :: F_min !MIN over cell
      real, dimension(Minx:Maxx,Miny:Maxy,F_nk), intent(in)  :: F_max !MAX over cell
      real, dimension(Minx:Maxx,Miny:Maxy,F_nk), intent(in)  :: F_in  !Field at previous time step
      real, dimension(Minx:Maxx,Miny:Maxy,F_nk), intent(in)  :: F_for_flux_o !I: Advected mixing ratio with 0 in NEST
      real, dimension(Minx:Maxx,Miny:Maxy,F_nk), intent(in)  :: F_for_flux_i !I: Advected mixing ratio with 0 in CORE
      character(len=42) :: kind_S
!
!  author Monique Tanguay
!
   !@revisions
   ! v4_80 - Tanguay M.        - initial version
   ! v4_80 - Tanguay M.        - GEM4 Mass-Conservation
!*@/
   !@objective
   !Apply Shape Preservation/Mass Conservation schemes
   !--------------------------------------------------


      logical :: verbose_L
      logical :: CLIP_L, ILMC_L, Bermejo_Conde_L, Cubic_L, SLICE_L
      real high(Minx:Maxx,Miny:Maxy,F_nk)
!
!---------------------------------------------------------------------
!
      verbose_L       = Tr_verbose/=0

      CLIP_L          = F_mono_kind == 1
      ILMC_L          = F_mono_kind == 2
      Bermejo_Conde_L = F_mass_kind == 1
      SLICE_L         = F_mass_kind == 2
      Cubic_L         = F_mono_kind == 0.and.F_mass_kind == 9

   !Cubic or Mono(CLIPPING) interpolation
   !-------------------------------------
      if (.NOT.Bermejo_Conde_L.and..NOT.ILMC_L) then

         if (Cubic_L.or.SLICE_L) F_out(i0:in,j0:jn,k0:F_nk) = F_cub (i0:in,j0:jn,k0:F_nk)
         if (CLIP_L)             F_out(i0:in,j0:jn,k0:F_nk) = F_mono(i0:in,j0:jn,k0:F_nk)

         if(verbose_L) then
         if (Lun_out > 0.and..not.CLIP_L.and..not.SLICE_L) then
            write(Lun_out,*) 'TRACERS: ----------------------------------------------------------------------'
            write(Lun_out,*) 'TRACERS: Cubic SL Interpolation: ',F_name_S(4:7)
            write(Lun_out,*) 'TRACERS: ----------------------------------------------------------------------'
         elseif(Lun_out > 0.and.CLIP_L) then
            write(Lun_out,*) 'TRACERS: ----------------------------------------------------------------------'
            write(Lun_out,*) 'TRACERS: Cubic MONO(CLIPPING) SL Interpolation: ',F_name_S(4:7)
            write(Lun_out,*) 'TRACERS: ----------------------------------------------------------------------'
         elseif(Lun_out > 0.and.SLICE_L) then
            write(Lun_out,*)    'TRACERS: ----------------------------------------------------------------------'
            write(Lun_out,1000) 'TRACERS: Local SL Mass Conserving Interpolation (SLICE): ',F_name_S(4:7)
            if (Tr_SLICE_rebuild==1) kind_S = 'Laprise and Plante 1995 (PPM1)          '
            if (Tr_SLICE_rebuild==2) kind_S = 'Colella and Woodward 1984 (PPM2) CW     '
            if (Tr_SLICE_rebuild==3) kind_S = 'Colella and Woodward 1984 (PPM2) Z4     '
            if (Tr_SLICE_rebuild==4) kind_S = 'Colella and Woodward 1984 (PCM)         '
            write(Lun_out,*)    'TRACERS: SLICE_rebuild= ',Tr_SLICE_rebuild,' :',kind_S
            if (Tr_SLICE_mono==0) kind_S = 'NO MONO'
            if (Tr_SLICE_mono==3) kind_S = 'MONO Zerroukat et al. 2005/2006'
            if (Tr_SLICE_mono==4) kind_S = 'MONO: RHO_LEFT CLIPPED TO ZERO IF NEGATIVE'
            write(Lun_out,*)    'TRACERS: SLICE_mono   = ',Tr_SLICE_mono,   ' :', kind_S
            write(Lun_out,*)    'TRACERS: ----------------------------------------------------------------------'
         endif
         endif

         return

      endif

   !Reset Monotonicity without changing Mass: Sorensen et al,ILMC, 2013,GMD
   !-----------------------------------------------------------------------
      if (ILMC_L) call ILMC_LAM (F_name_S,F_mono,F_cub,F_min,F_max,Minx,Maxx,Miny,Maxy,F_nk,k0,Tr_ILMC_min_max_L,Tr_ILMC_sweep_max)

   !Restore Mass-Conservation: Bermejo and Conde,2002,MWR
   !-----------------------------------------------------
      if (Bermejo_Conde_L) then

         high = F_cub
         if (CLIP_L.or.ILMC_L) high = F_mono

         call Bermejo_Conde (F_name_S,F_out,high,F_lin,F_min,F_max,F_in,F_for_flux_o,F_for_flux_i, &
                             Minx,Maxx,Miny,Maxy,F_nk,k0,Tr_BC_min_max_L,CLIP_L,ILMC_L)

      else

         F_out(i0:in,j0:jn,k0:F_nk) = F_mono(i0:in,j0:jn,k0:F_nk)
         return

      endif
!
!---------------------------------------------------------------------
!
      return

 1000 format(1X,A57,1X,A3)

      end subroutine adv_tracers_mono_mass
