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

!**s/r out_dyn_casc - model output for cascade

      subroutine out_dyn_casc()
      use vGrid_Descriptors, only: vgrid_descriptor,vgd_get,vgd_free,VGD_OK,VGD_ERROR
      use vgrid_wb, only: vgrid_wb_get
      use out_vref, only: out_vref_itf
      use gmm_vt1
      use gmm_pw
      use gmm_geof
      use grdc_options
      use gem_options
      use tdpack
      use glb_ld
      use tr3d
      use out_mod
      use out3
      use outp
      use gmm_itf_mod
      implicit none
#include <arch_specific.hf>


      character(len=512) varname
      integer k,istat,indo(G_nk+2)
      integer, dimension(:), pointer  :: ip1m
      real conv
      real, dimension(:    ), pointer :: hybm,hybt,hybt_w
      real, dimension(:,:  ), pointer :: tr1,tdiag,udiag,vdiag
      real, dimension(:,:,:), pointer :: tr2
      type(vgrid_descriptor) :: vcoord
      logical :: using_qt1
      real hybm_gnk2(1),hybt_gnk2(1),hyb0(1)
      integer ind0(1)
!
!------------------------------------------------------------------
!
      using_qt1 = .not.Schm_hydro_L

      nullify (pw_tt_plus,pw_uu_plus,pw_vv_plus,tdiag,udiag,vdiag)
      istat = gmm_get (gmmk_pw_tt_plus_s, pw_tt_plus)
      istat = gmm_get (gmmk_pw_uu_plus_s, pw_uu_plus)
      istat = gmm_get (gmmk_pw_vv_plus_s, pw_vv_plus)
      istat = gmm_get (gmmk_pw_p0_plus_s, pw_p0_plus)
      istat = gmm_get (gmmk_diag_tt_s   , tdiag     )
      istat = gmm_get (gmmk_diag_uu_s   , udiag     )
      istat = gmm_get (gmmk_diag_vv_s   , vdiag     )

      istat = gmm_get(gmmk_zdt1_s,zdt1)
      istat = gmm_get(gmmk_fis0_s,fis0)
      istat = gmm_get(gmmk_wt1_s ,wt1 )
      if ( using_qt1 ) istat = gmm_get(gmmk_qt1_s,qt1)

      do k=1,G_nk+2
         indo(k) = k
      end do
      nullify (ip1m,hybm,hybt,hybt_w)
      istat = vgrid_wb_get('ref-m',vcoord,ip1m)
      deallocate(ip1m); nullify(ip1m)
      istat = vgd_get (vcoord,'VCDM - vertical coordinate (m)',hybm)
      istat = vgd_get (vcoord,'VCDT - vertical coordinate (t)',hybt)
      istat = vgd_free(vcoord)
      allocate(tr1(l_minx:l_maxx,l_miny:l_maxy))
      hyb0(1)=0.0
      hybm_gnk2(1)=hybm(G_nk+2)
      hybt_gnk2(1)=hybt(G_nk+2)
      ind0(1)=1

      call itf_phy_diag ()

      Out_reduc_l= .true.

      call out_href3 ( 'Mass_point', Grdc_gid, Grdc_gif, 1,&
                                     Grdc_gjd, Grdc_gjf, 1 )
      call out_vref_itf  ( etiket=Out3_etik_S )

      conv= -tcdk_8
      call out_fstecr3 ( pw_tt_plus,l_minx,l_maxx,l_miny,l_maxy,hybt,'TT  ',1.,&
                         conv,5,-1,G_nk,indo,G_nk,Grdc_nbits,.false. )
      if (Out3_sfcdiag_L) then
         call out_fstecr3 ( tdiag,l_minx,l_maxx,l_miny,l_maxy,hybt_gnk2, &
                            'TT  ' ,1., conv,4,-1,1,ind0,1,Grdc_nbits,.false. )
      end if

      call out_fstecr3 (pw_p0_plus,l_minx,l_maxx,l_miny,l_maxy,hyb0,&
                        'P0  ',.01,0., 2,-1,1, ind0, 1, Grdc_nbits, .false.)

      call out_fstecr3 ( wt1 ,l_minx,l_maxx,l_miny,l_maxy,hybt,'WT1 ' ,1., &
                         0.,5,-1,G_nk,indo,G_nk,Grdc_nbits,.false. )
      call out_fstecr3 ( zdt1,l_minx,l_maxx,l_miny,l_maxy,hybt,'ZDT1',1., &
                         0.,5,-1,G_nk,indo,G_nk,Grdc_nbits,.false. )
      if ( using_qt1 ) then
         call out_fstecr3 ( qt1 ,l_minx,l_maxx,l_miny,l_maxy,hybm,'QT1 ' ,1., &
                            0.,5,-1,G_nk+1,indo,G_nk+1,Grdc_nbits,.false. )
      end if
      call out_fstecr3 ( fis0,l_minx,l_maxx,l_miny,l_maxy,hyb0  ,'FIS0',1., &
                         0.,5,-1,1,ind0,1,Grdc_nbits,.false. )

      do k=1,Grdc_ntr
         nullify (tr2)
         varname = 'TR/'//trim(Grdc_trnm_S(k))//':P'
         istat= gmm_get (varname,tr2)
         call out_fstecr3 ( tr2 ,l_minx,l_maxx,l_miny,l_maxy,hybt, &
                            Grdc_trnm_S(k),1.,0.,5,-1,G_nk,indo,G_nk,Grdc_nbits,.false.)
         if ( Out3_sfcdiag_L ) then
            tr1 = tr2(:,:,G_nk)
            call itf_phy_sfcdiag ( tr1(l_minx,l_miny),l_minx,l_maxx, &
                                   l_miny,l_maxy,varname,istat,.true. )
            call out_fstecr3 ( tr1 ,l_minx,l_maxx,l_miny,l_maxy, &
                               hybt_gnk2,Grdc_trnm_S(k),1.  , &
                               0.,4,-1,1,ind0,1,Grdc_nbits,.false. )
         endif
      end do

      conv= 1.0 / knams_8
      call out_fstecr3 ( pw_uu_plus, l_minx,l_maxx,l_miny,l_maxy,hybm,'UU  ' ,&
                         conv, 0., 5,-1,G_nk,indo,G_nk,Grdc_nbits,.false. )
      call out_fstecr3 ( pw_vv_plus, l_minx,l_maxx,l_miny,l_maxy,hybm,'VV  ' ,&
                         conv, 0., 5,-1,G_nk,indo,G_nk,Grdc_nbits,.false. )
      if (Out3_sfcdiag_L) then
         call out_fstecr3 ( udiag, l_minx,l_maxx,l_miny,l_maxy,hybm_gnk2,&
                            'UU  ' , conv, 0., 4,-1,1,ind0,1,Grdc_nbits,.false. )
         call out_fstecr3 ( vdiag, l_minx,l_maxx,l_miny,l_maxy,hybm_gnk2,&
                            'VV  ' , conv, 0., 4,-1,1,ind0,1,Grdc_nbits,.false. )
      endif

      deallocate (hybm,hybt,tr1)
!
!------------------------------------------------------------------
!
      return
      end

