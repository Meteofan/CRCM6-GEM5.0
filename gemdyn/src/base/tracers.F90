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

!**s/r tracers - Establishes final list of tracers for GEMDM

      subroutine tracers ()
      use phy_itf, only: PHY_MAXNAMELENGTH,phymeta,phy_getmeta
      use gem_options
      use glb_ld
      use lun
      use tr3d
      use clib_itf_mod
      implicit none
#include <arch_specific.hf>

!author
!     Michel Desgagne  -  Sept 2001
!
!revision
! v2_31 - Desgagne M.       - initial version
! v3_21 - Lee V.            - remove Tr2d
! v3_30 - Desgagne M.       - memory calculation for tracers
!
!arguments
!        Tr3d_name_S acquires the list of tracers from itf_phy_inikey
!        In this subroutine, it will acquire what is introduced from
!        Tr3d_username_S (constructed from the entry routine)
!        ie: QC can be filled with either QC or QCT1 or QCT0 from the
!            given analysis (accessed by E_tr3dname_S of gement nml)
!            but this is converted via BMF/BCS/3DF as QC
!        Tracers requested under auto cascade requires only the first
!        2 letters


      character(len=512) :: varname,attributes
      character(len=PHY_MAXNAMELENGTH) :: varname_S,prefix_S, &
                                          basename_S,time_S,ext_S
      integer i,j,ind,wload,hzd,monot,massc,dejala,istat,nmeta
      real vmin
      type(phymeta), dimension(:), pointer :: pmeta
!
!     __________________________________________________________________
!
      nmeta= 0 ; nullify(pmeta)
      if ( Schm_phyms_L ) then
         nmeta = phy_getmeta(pmeta,' ',F_npath='V',F_bpath='D',F_quiet=.true.)
      end if

      do i=1,nmeta
         varname_S = pmeta(i)%vname
         istat = clib_toupper(varname_S)
         if (varname_S(1:3) /= 'TR/') cycle
         call gmmx_name_parts(varname_S,prefix_S,basename_S,time_S,ext_S)
         if (time_S/=':P') cycle
         dejala=0
         do j=1,Tr3d_ntr
            if (trim(Tr3d_name_S(j))==basename_S) dejala=j
         enddo
         if (dejala==0) then
            Tr3d_ntr = Tr3d_ntr + 1
            dejala   = Tr3d_ntr
            Tr3d_name_S(dejala)= basename_S
         endif
         Tr3d_hzd (dejala)= pmeta(i)%hzd   ; Tr3d_wload(dejala)= pmeta(i)%wload
         Tr3d_mono(dejala)= pmeta(i)%monot ; Tr3d_mass (dejala)= pmeta(i)%massc
         Tr3d_vmin(dejala)= pmeta(i)%vmin
      enddo

      do i=1,MAXTR3D
         if (Tr3d_list_s(i)=='') exit
         ind= index(Tr3d_list_s(i),",")
         if (ind == 0) then
            call low2up(Tr3d_list_s(i), varname)
            attributes = ''
         else
            call low2up(Tr3d_list_s(i)(1:ind-1),varname   )
            call low2up(Tr3d_list_s(i)(ind+1: ),attributes)
         endif
         call tracers_attributes2(attributes, wload,hzd,monot,massc,vmin)
         dejala=0
         do j=1,Tr3d_ntr
            if (trim(Tr3d_name_S(j))==trim(varname)) dejala=j
         enddo
         if (dejala==0) then
            Tr3d_ntr = Tr3d_ntr + 1
            dejala   = Tr3d_ntr
            Tr3d_name_S(dejala)= trim(varname)
         endif
         Tr3d_hzd (dejala)= (hzd>0) ; Tr3d_wload(dejala)= (wload>0)
         Tr3d_mono(dejala)= monot   ; Tr3d_mass (dejala)= massc
         Tr3d_vmin(dejala)= vmin
      end do

      dejala=0
      do j=1,Tr3d_ntr
         if (trim(Tr3d_name_S(j))=='HU') dejala=j
      enddo
      if (dejala==0) then
         Tr3d_ntr = Tr3d_ntr + 1
         Tr3d_name_S(tr3d_ntr)(1:4) = 'HU  '
         Tr3d_hzd   (Tr3d_ntr)= .false. ; Tr3d_wload(Tr3d_ntr)= .false.
         Tr3d_mono  (Tr3d_ntr)= 0       ; Tr3d_mass (Tr3d_ntr)= 0
         Tr3d_vmin  (Tr3d_ntr)= 0.
      else
         Tr3d_wload(dejala)= .false.
      endif

      if (Lun_out > 0) then
         write (Lun_out,1001)
         do i=1,Tr3d_ntr
            write(Lun_out,1002) Tr3d_name_S(i),Tr3d_wload(i),Tr3d_hzd(i),Tr3d_mono(i),Tr3d_mass(i),Tr3d_vmin(i)
         end do
      endif

      call ac_posi (G_xg_8(1),G_yg_8(1),G_ni,G_nj,Lun_out > 0)

 1001 format (/' Final list of tracers:'/3x,' Name   Wload  Hzd   Mono  Mass    Min')
 1002 format (4x,a4,2l6,2i6,3x,e10.3)
!
!     __________________________________________________________________
!
      return
      end
