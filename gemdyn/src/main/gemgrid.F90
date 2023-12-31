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

!**s/r gemgrid - grille program
      subroutine gemgrid
      use clib_itf_mod
      use step_options
      use nest_blending
      use glb_ld
      use grid_options
      use gem_options
      use hgc
      use lun
      use path
      implicit none
#include <arch_specific.hf>
!
!author V.Lee - Jun. 14, 2011
!
!object
!     to create a file containing all 3 pairs of tic tacs for the
!     GEM grid using functions from GEM
!
!     Computes positional parameters (>>=lat ^^=lon)
!
      integer, external :: fnom,fstouv,fstecr,fstfrm,fclos,wkoffit,&
                           grid_nml2,gem_nml,exdb,step_nml

      integer, external :: gemdm_config,domain_decomp3,grid_nml3
      character(len=120) :: outfile,etk,etk_ext
      character(len=2024) :: fn
      logical radians
      integer unf1,unf2,err,npack,i

      logical, parameter :: gauss_L = .false.
      logical uniform_L
      integer itile,jtile,i0,j0,i1,j1,ierx, iery
      integer Grd_ip1,Grd_ip2,Grd_ip3,ni,nj, in,jn
      integer nila,njla,belo,left,ip1,ip2
      real    dxmax, dymax
      real  , dimension(:), allocatable :: xpos, ypos
      real  , dimension(:,:), allocatable :: mask,wrk1,wrk2
      real*8, dimension(:), allocatable :: x_8, y_8
!
!----------------------------------------------------------------------
!
      call init_component

      etk = 'PARPOS'
      fn  = trim(Path_input_S)//'/model_settings.nml'
      Step_dt= 1.
      radians= .false.

      outfile= 'tape1'
      if (Grd_yinyang_L .and. Grd_yinyang_S == 'YAN') outfile= 'tape2'

 88   if (grid_nml3(fn) < 0) then
         print *,'STOP: problem with NAMELIST GRID'
         print *,"Use checknml to verify: \'checknml grid\'"
         stop
      endif
!!$      if (step_nml(fn) < 0) then
!!$         print *,'STOP: problem with NAMELIST STEP'
!!$         print *,"Use checknml to verify: \'checknml step\'"
!!$         stop
!!$      endif
      if (gem_nml(fn) < 0) then
         print *,'STOP: problem with NAMELIST GEM_CFGS'
         print *,"Use checknml to verify: \'checknml gem_cfgs\'"
         stop
      endif

      Step_runstrt_S='20160825.000000'
      err= grid_nml3 ('print')
!      err= step_nml  ('print'    )
      err= gem_nml   ('print'    )

      err= gemdm_config ()

      G_ni= Grd_ni ; G_nj= Grd_nj ; G_nk= 2

      allocate (x_8(Grd_ni+1), y_8(Grd_nj), xpos(Grd_ni+1), ypos(Grd_nj))

      dxmax = 360. ; dymax = 180. ; nila= G_ni ; njla= G_nj

      call set_gemHgrid3 ( x_8, y_8, G_ni, G_nj, Grd_dx, Grd_dy,   &
                           Grd_x0_8, Grd_xl_8, left,               &
                           Grd_y0_8, Grd_yl_8, belo,               &
                           nila, njla, dxmax, dymax,               &
                           Grd_yinyang_L,gauss_L,.true., uniform_L,&
                           ierx, iery, .true. )

      xpos(1:G_ni) = x_8(1:G_ni)
      ypos(1:G_nj) = y_8(1:G_nj)

      call set_igs2 ( ip1,ip2, xpos,ypos,G_ni,G_nj             ,&
                      Hgc_ig1ro,Hgc_ig2ro, Hgc_ig3ro, Hgc_ig4ro,&
                      1,G_ni,1,1,G_nj,1)

      Grd_ip3= 0

      err = clib_remove(outfile)

      unf1= 0
      if (fnom(unf1,outfile,'RND',0) >= 0) then
         err= fstouv (unf1, 'RND')
      else
         print *,'problem opening', trim(outfile)
         stop
      endif

      i0=1    ; j0=1
      i1=G_ni ; j1=G_nj
      itile=1 ; jtile=1

      write(6,*) 'LONGITUDE'
      write(6,778)(i,xpos(i),i=1,G_ni)
      write(6,*) 'LATITUDE'
      write(6,778)(i,ypos(i),i=1,G_nj)

 777  format(2i8,4e15.7,2i10,x,2I5)
 778  format(4(i5,e15.7))

      if (Grd_yinyang_L) then
         etk_ext=trim(etk)//'_'//trim(Grd_yinyang_S)
      else
         etk_ext=trim(etk)
      endif

      npack = -32

      err= fstecr ( xpos,xpos, npack, unf1, 0, 0, 0, G_ni, 1, 1 , &
                    ip1,ip2,Grd_ip3,'X','>>',etk_ext,Hgc_gxtyp_s, &
                    Hgc_ig1ro,Hgc_ig2ro,Hgc_ig3ro,Hgc_ig4ro, 5, .true. )
      err= fstecr ( ypos,ypos, npack, unf1, 0, 0, 0, 1, G_nj, 1 , &
                    ip1,ip2,Grd_ip3,'X','^^',etk_ext,Hgc_gxtyp_s, &
                    Hgc_ig1ro,Hgc_ig2ro,Hgc_ig3ro,Hgc_ig4ro, 5, .true. )

      err= fstfrm(unf1)
      err= fclos (unf1)

      err= domain_decomp3 (1, 1, .false.)
      call set_gmm
      call nest_set_gmmvar
      unf2=0
      if (fnom(unf2,trim(outfile)//'_core','RND',0) >= 0) then
         err= fstouv (unf2, 'RND')
      else
         print *,'problem opening', trim(outfile//'_core')
         stop
      endif

      i0= 1      + Grd_extension
      in= G_ni - Grd_extension
      j0= 1      + Grd_extension
      jn= G_nj - Grd_extension
      ni = in-i0+1
      nj = jn-j0+1

      xpos(1:ni) = x_8(i0:in)
      ypos(1:nj) = y_8(j0:jn)

      call set_igs2 ( Grd_ip1,Grd_ip2, xpos,ypos,ni,nj, &
                      Hgc_ig1ro,Hgc_ig2ro, Hgc_ig3ro, Hgc_ig4ro, &
                      1,ni,1,1,nj,1)
      err= fstecr ( xpos,xpos, npack, unf2, 0, 0, 0, ni, 1, 1, &
                    Grd_ip1,Grd_ip2,Grd_ip3,'X','>>',etk_ext,Hgc_gxtyp_s, &
                    Hgc_ig1ro,Hgc_ig2ro,Hgc_ig3ro,Hgc_ig4ro, 5, .true. )
      err= fstecr ( ypos,ypos, npack, unf2, 0, 0, 0, 1, nj, 1, &
                    Grd_ip1,Grd_ip2,Grd_ip3,'X','^^',etk_ext,Hgc_gxtyp_s, &
                    Hgc_ig1ro,Hgc_ig2ro,Hgc_ig3ro,Hgc_ig4ro, 5, .true. )

      unf1= 0
      err= fnom(unf1,outfile,'RND',0)
      err= fstouv (unf1, 'RND')

      allocate (mask(G_ni, G_nj))
      allocate (wrk1(l_minx:l_maxx,l_miny:l_maxy))
      allocate (wrk2(l_minx:l_maxx,l_miny:l_maxy))
      wrk2=1. ; wrk1=0.
      call nest_blend (wrk2,wrk1,l_minx,l_maxx,l_miny,l_maxy,'M',level=G_nk+1)
      mask(1:G_ni,1:G_nj) = wrk2(1:G_ni,1:G_nj)

      err= fstecr ( mask,mask, npack, unf1, 0, 0, 0, G_ni, G_nj, 1, &
                    0,0,0,'X','MSKC',etk_ext,'Z'    , &
                    ip1,ip2,Grd_ip3,0, 5, .true. )
      deallocate (mask,wrk1,wrk2)

      err= fstfrm(unf1)
      err= fclos (unf1)
      err= fstfrm(unf2)
      err= fclos (unf2)

      unf1=0
      if (fnom(unf1,trim(outfile)//'_free','RND',0) >= 0) then
         err= fstouv (unf1, 'RND')
      else
         print *,'problem opening', trim(outfile//'_core')
         stop
      endif

      i0= 1    + Grd_extension + Lam_blend_H
      in= G_ni - Grd_extension - Lam_blend_H
      j0= 1    + Grd_extension + Lam_blend_H
      jn= G_nj - Grd_extension - Lam_blend_H
      ni = in-i0+1
      nj = jn-j0+1

      xpos(1:ni) = x_8(i0:in)
      ypos(1:nj) = y_8(j0:jn)

      call set_igs2 ( Grd_ip1,Grd_ip2, &
                      xpos,ypos,ni,nj, &
                      Hgc_ig1ro,Hgc_ig2ro, Hgc_ig3ro, Hgc_ig4ro, &
                      1,ni,1,1,nj,1)
      err= fstecr ( xpos,xpos, npack, unf1, 0, 0, 0, ni, 1, 1, &
                    Grd_ip1,Grd_ip2,Grd_ip3,'X','>>',etk_ext,Hgc_gxtyp_s, &
                    Hgc_ig1ro,Hgc_ig2ro,Hgc_ig3ro,Hgc_ig4ro, 5, .true. )
      err= fstecr ( ypos,ypos, npack, unf1, 0, 0, 0, 1, nj, 1, &
                    Grd_ip1,Grd_ip2,Grd_ip3,'X','^^',etk_ext,Hgc_gxtyp_s, &
                    Hgc_ig1ro,Hgc_ig2ro,Hgc_ig3ro,Hgc_ig4ro, 5, .true. )

      err= fstfrm(unf1)
      err= fclos (unf1)

      deallocate (x_8, y_8, xpos, ypos)

      call gemtim4 ( Lun_out, 'AFTER set_opr', .false. )

      call memusage (6)

      call rpn_comm_FINALIZE(err)
!
!-------------------------------------------------------------------
!
      return
      end
