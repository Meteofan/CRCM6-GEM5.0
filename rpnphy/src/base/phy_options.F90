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

module phy_options
   implicit none
   public
   save

   integer, parameter, private :: IDOUBLE = 8

   integer, parameter :: LEVMAX            = 200 !# NOMBRE MAXIMUM DE NIVEAUX POUR LA PHYSIQUE

   integer, parameter :: OPT_OPTIX_OLD     = 1
   integer, parameter :: OPT_OPTIX_NEW     = 2
   integer, parameter :: RAD_NUVBRANDS     = 6 !#TODO: move to a radiation specific module/cdk
   integer(IDOUBLE), parameter :: MU_JDATE_HALFDAY = 43200 !#TODO: move to mu_jdate
   logical           :: chemistry    = .false.
   logical           :: climat       = .false.
   character(len=16) :: conv_mid     = 'NIL'
   character(len=16) :: conv_shal    = 'NIL'
   character(len=16) :: convec       = 'NIL'
   integer           :: cw_rad       = 0
   integer(IDOUBLE)  :: jdateo       = 0
   real              :: delt         = 0.
   character(len=4),  pointer :: dyninread_list_s(:) => NULL()
   logical           :: dynout       = .false.
   logical           :: impflx       = .false.
   logical           :: inincr       = .false.
   integer           :: ioptix       = OPT_OPTIX_OLD
   integer           :: kntrad       = 1
   logical           :: offline      = .false.
   character(len=1024) :: ozone_file_s = 'NIL'
   logical           :: reduc        = .false.
   character(len=16) :: schmsol      = 'ISBA'
   logical           :: tdiaglim     = .false.
   integer           :: tlift        = 0
   integer           :: nphyoutlist  = 0
   character(len=32), pointer :: phyoutlist_S(:) => NULL()

   !# Time length (hours) for special time accumulated physics variables
   integer           :: acchr        = 0
   namelist /physics_cfgs/ acchr
   namelist /physics_cfgs_p/ acchr

   !# Turbulent kinetic energy advect. is active if .true.
   logical           :: advectke     = .false.
   namelist /physics_cfgs/ advectke
   namelist /physics_cfgs_p/ advectke

   !# Surface heat flux from oceans is active if .true.
   logical           :: chauf        = .true.
   namelist /physics_cfgs/ chauf
   namelist /physics_cfgs_p/ chauf

   !# Clip tracers negative values
   logical           :: clip_tr_L      = .true.
   namelist /physics_cfgs/ clip_tr_L
   namelist /physics_cfgs_p/ clip_tr_L

   !# Conservation corrections for gridscale condensation
   !# * 'NIL ' : No conservation correction applied
   !# * 'TEND' : Temperature and moisture tendencies corrected
   character(len=16) :: cond_conserve = 'NIL'
   namelist /physics_cfgs/ cond_conserve
   namelist /physics_cfgs_p/ cond_conserve
   character(len=*), parameter :: COND_CONSERVE_OPT(2) = (/ &
        'NIL ', &
        'TEND'  &
        /)

   !# Evaporation parameter for Sunqvist gridscale condensation
   real           :: cond_evap       = 2.e-4
   namelist /physics_cfgs/ cond_evap
   namelist /physics_cfgs_p/ cond_evap

   !# Minimum cloud mixing ratio (kg/kg) for autoconversion in
   !# Sunqvist gridscale condensation
   real           :: cond_hmrst     = 3.e-4
   namelist /physics_cfgs/ cond_hmrst
   namelist /physics_cfgs_p/ cond_hmrst

   !# Min allowed values of modified hu00 (threshold relative humidity
   !# for stratiform condensation, Sunqvist gridscale condensation)
   real           :: cond_hu0min       = 0.85
   namelist /physics_cfgs/ cond_hu0min
   namelist /physics_cfgs_p/ cond_hu0min

   !# Max allowed values of modified hu00 (threshold relative humidity
   !# for stratiform condensation, Sunqvist gridscale condensation)
   real           :: cond_hu0max       = 0.975
   namelist /physics_cfgs/ cond_hu0max
   namelist /physics_cfgs_p/ cond_hu0max

   !# Standard deviation length scale (gridpoints) of Gaussian smoother
   !# applied to temperature and humidity inputs for Sunqvist gridscale
   !# condensation)
   real           :: cond_infilter    = -1.
   namelist /physics_cfgs/ cond_infilter
   namelist /physics_cfgs_p/ cond_infilter

   !# Obtain estimate of surface wind gusts if .true.
   logical           :: diag_twind   = .false.
   namelist /physics_cfgs/ diag_twind
   namelist /physics_cfgs_p/ diag_twind

   !# Activate Debug memory mode
   logical           :: debug_mem_L      = .false.
   namelist /physics_cfgs/ debug_mem_L
   namelist /physics_cfgs_p/ debug_mem_L

   !# Print a trace of the phy functions (MSG verbosity = debug)
   logical           :: debug_trace_L      = .false.
   namelist /physics_cfgs/ debug_trace_L
   namelist /physics_cfgs_p/ debug_trace_L

   !# Diffuse vertical motion if .true.
   logical           :: diffuw       = .false.
   namelist /physics_cfgs/ diffuw
   namelist /physics_cfgs_p/ diffuw

   !# Surface friction is active if .true.
   !# Uses Schuman-Newell lapse rate if .false.
   logical           :: drag         = .true.
   namelist /physics_cfgs/ drag
   namelist /physics_cfgs_p/ drag

   !# Minimal value for TKE in stable case (for 'CLEF')
   real              :: etrmin2      = 1.E-4
   namelist /physics_cfgs/ etrmin2
   namelist /physics_cfgs_p/ etrmin2

   !# Surface evaporation is active if .true.
   logical           :: evap         = .true.
   namelist /physics_cfgs/ evap
   namelist /physics_cfgs_p/ evap

   !# Boundary layer processes
   !# * 'NIL    ': no vertical diffusion
   !# * 'CLEF   ': non-cloudy boundary layer formulation
   !# * 'MOISTKE': cloudy boundary layer formulation
   !# * 'SURFACE': TODO
   !# * 'SIMPLE ': a very simple mixing scheme for neutral PBLs
   character(len=16) :: fluvert      = 'NIL'
   namelist /physics_cfgs/ fluvert
   namelist /physics_cfgs_p/ fluvert
   character(len=*), parameter :: FLUVERT_OPT(5) = (/ &
        'NIL    ', &
        'CLEF   ', &
        'MOISTKE', &
        'SURFACE', &
        'SIMPLE '  &
        /)

   !# (MOISTKE only) Apply factor fnn_reduc
   !# * .false.: everywhere
   !# * .true.: over water only
   logical           :: fnn_mask     = .false.
   namelist /physics_cfgs/ fnn_mask
   namelist /physics_cfgs_p/ fnn_mask

   !# (MOISTKE only) Reduction factor (between 0. and 1.) to be applied to the
   !# parameter FNN (turbulent flux enhancement due to boundary layer clouds)
   real              :: fnn_reduc    = 1.
   namelist /physics_cfgs/ fnn_reduc
   namelist /physics_cfgs_p/ fnn_reduc

   !# (CLEF+CONRES only) Non-dimensional parameter (must be >= 1.) that controls
   !# the value of the flux enhancement factor in CONRES
   real              :: fnnmod       = 2.
   namelist /physics_cfgs/ fnnmod
   namelist /physics_cfgs_p/ fnnmod

   !# Use Fomichev radiation code if .true.
   logical           :: fomic        = .false.
   namelist /physics_cfgs/ fomic
   namelist /physics_cfgs_p/ fomic

   !# Gravity wave drag formulation
   !# * 'NIL  ': no Gravity wave drag
   !# * 'GWD86': gravity wave drag + low-level blocking
   !# * 'SGO16': new formulation (2016) of GWD86
   character(len=16) :: gwdrag       = 'NIL'
   namelist /physics_cfgs/ gwdrag
   namelist /physics_cfgs_p/ gwdrag
   character(len=*), parameter :: GWDRAG_OPT(3) = (/ &
        'NIL  ', &
        'GWD86', &
        'SGO16'  &
        /)

   !# Number of times the 3-point filter will be applied to smooth the GW flux profiles
   integer           :: hines_flux_filter = 0
   namelist /physics_cfgs/ hines_flux_filter
   namelist /physics_cfgs_p/ hines_flux_filter

   !# Consider heating from non-orog. drag if = 1
   integer           :: iheatcal     = 0
   namelist /physics_cfgs/ iheatcal
   namelist /physics_cfgs_p/ iheatcal

   !# Comma-separated list of diagnostic level inputs to read.
   !# Default: indiag_list_s(1) = 'DEFAULT LIST',
   !# expanded to: UU, VV, TT, HU + all dynamic Tracers
   character(len=32) :: indiag_list_s(128) = ' '
   namelist /physics_cfgs/ indiag_list_s

   !# Initialize water content and cloud fraction seen by radiation for time 0 if .true.
   logical           :: inilwc       = .false.
   namelist /physics_cfgs/ inilwc
   namelist /physics_cfgs_p/ inilwc

   !# Type of input system used
   !# * 'OLD ' : GEM 4.8 input, MPI blocking based
   !# * 'DIST' : GEM 5.0 input system, RPN_COMM_IO/RPN_COMM_ezshuf_dist based
   !# * 'BLOC' : GEM 5.0 input system, RPN_COMM_bloc based
   character(len=16) :: input_type = 'OLD'
!!$   character(len=16) :: input_type = 'DIST'
   namelist /physics_cfgs/ input_type
   namelist /physics_cfgs_p/ input_type
   character(len=*), parameter :: INPUT_TYPE_OPT(3) = (/ &
        'OLD ', &
        'DIST', &
        'BLOC'  &
        /)

   !# Update ozone climatology during the run
   logical           :: intozot      = .false.
   namelist /physics_cfgs/ intozot
   namelist /physics_cfgs_p/ intozot

   !# Time between full radiation calculation (units D,H,M,S,P)
   character(len=16) :: kntrad_S     = ''
   namelist /physics_cfgs/ kntrad_S
   namelist /physics_cfgs_p/ kntrad_S

   !# Compute ice fraction in KTRSNT_MG if .true.
   logical           :: kticefrac    = .true.
   namelist /physics_cfgs/ kticefrac
   namelist /physics_cfgs_p/ kticefrac

   !# Compute lightning diagnostics if .true.
   !# (currently for Milbrandt-Yau microphysics only)
   logical           :: lightning_diag = .false.
   namelist /physics_cfgs/ lightning_diag
   namelist /physics_cfgs_p/ lightning_diag

   !# Add methane oxydation as source of humidity in the stratosphere if .true.
   logical           :: lmetox       = .false.
   namelist /physics_cfgs/ lmetox
   namelist /physics_cfgs_p/ lmetox

   !# Mixing length calc. scheme
   !# * 'BLAC62  ': mixing length calc. using Blackadar
   !# * 'BOUJO   ': mixing length calc. using Bougeault
   !# * 'TURBOUJO': mixing length calc. using Bougeault in turbulent regimes (otherwise Blackadar)
   !# * 'LH      ': mixing length calc. using Lenderink and Holtslag
   character(len=16) :: longmel      = 'BLAC62'
   namelist /physics_cfgs/ longmel
   namelist /physics_cfgs_p/ longmel
   character(len=*), parameter :: LONGMEL_OPT(4) = (/ &
        'BLAC62  ', &
        'BOUJO   ', &
        'TURBOUJO', &
        'LH      '  &
        /)

   !# Time length (hours) for special time averaged physics variables
   integer           :: moyhr = 0
   namelist /physics_cfgs/ moyhr
   namelist /physics_cfgs_p/ moyhr

   !# Number of ice-phase hydrometeor categories to use in the P3 microphysics
   !# scheme (currently limited to <5)
   integer           :: p3_ncat = 1
   namelist /physics_cfgs/ p3_ncat
   namelist /physics_cfgs_p/ p3_ncat

   !# Maximum time step (s) to be taken by the microphysics (P3) scheme, with time-splitting
   !# used to reduce step to below this value if necessary
   real           :: p3_dtmax = 60.
   namelist /physics_cfgs/ p3_dtmax
   namelist /physics_cfgs_p/ p3_dtmax

   !# calibration factor for ice deposition in microphysics (P3)
   real           :: p3_depfact = 1.0
   namelist /physics_cfgs/ p3_depfact
   namelist /physics_cfgs_p/ p3_depfact

   !# calibration factor for ice sublimation in microphysics (P3)
   real           :: p3_subfact = 1.0
   namelist /physics_cfgs/ p3_subfact
   namelist /physics_cfgs_p/ p3_subfact

   !# switch for real-time debugging in microphysics (P3)
   logical         :: p3_debug = .false.
   namelist /physics_cfgs/ p3_debug
   namelist /physics_cfgs_p/ p3_debug

   !# switch for subgrid cloud/precipitation fraction scheme (SCPF) in microphysics (P3)
   logical         :: p3_scpf_on = .false.
   namelist /physics_cfgs/ p3_scpf_on
   namelist /physics_cfgs_p/ p3_scpf_on

   !# precipitation fraction factor used by SCPF in microphysics (P3)
   real           :: p3_pfrac = 1.0
   namelist /physics_cfgs/ p3_pfrac
   namelist /physics_cfgs_p/ p3_pfrac

   !# model resolution factor used by SCPF in microphysics (P3)
   real           :: p3_resfact = 1.0
   namelist /physics_cfgs/ p3_resfact
   namelist /physics_cfgs_p/ p3_resfact

   !# Switch for aerosol activation scheme (1 = default, 2 = ARG + Aerosol climatology)
   integer           :: mp_aeroact = 1
   namelist /physics_cfgs/ mp_aeroact
   namelist /physics_cfgs_p/ mp_aeroact

   !# Switch for airmass type (1 = maritime, 2 = continental)
   integer           :: my_ccntype   = 1
   namelist /physics_cfgs/ my_ccntype
   namelist /physics_cfgs_p/ my_ccntype

   !# Double-moment for cloud (for 'mp_my' only)
   logical           :: my_dblmom_c  = .true.
   namelist /physics_cfgs/ my_dblmom_c
   namelist /physics_cfgs_p/ my_dblmom_c

   !# Double-moment for graupel (for 'mp_my' only)
   logical           :: my_dblmom_g  = .true.
   namelist /physics_cfgs/ my_dblmom_g
   namelist /physics_cfgs_p/ my_dblmom_g

   !# Double-moment for hail (for 'mp_my' only)
   logical           :: my_dblmom_h  = .true.
   namelist /physics_cfgs/ my_dblmom_h
   namelist /physics_cfgs_p/ my_dblmom_h

   !# Double-moment for ice (for 'mp_my' only)
   logical           :: my_dblmom_i  = .true.
   namelist /physics_cfgs/ my_dblmom_i
   namelist /physics_cfgs_p/ my_dblmom_i

   !# Double-moment for rain (for 'mp_my' only)
   logical           :: my_dblmom_r  = .true.
   namelist /physics_cfgs/ my_dblmom_r
   namelist /physics_cfgs_p/ my_dblmom_r

   !# Double-moment for snow (for 'mp_my' only)
   logical           :: my_dblmom_s  = .true.
   namelist /physics_cfgs/ my_dblmom_s
   namelist /physics_cfgs_p/ my_dblmom_s

   !# Compute MY Diagnostic fields if .true.
   logical           :: my_diagon    = .true.
   namelist /physics_cfgs/ my_diagon
   namelist /physics_cfgs_p/ my_diagon

   !# Ice-phase switched on if .true.
   logical           :: my_iceon     = .true.
   namelist /physics_cfgs/ my_iceon
   namelist /physics_cfgs_p/ my_iceon

   !# Initialize the number concentration for each category
   logical           :: my_initn     = .true.
   namelist /physics_cfgs/ my_initn
   namelist /physics_cfgs_p/ my_initn

   !# Autoconversion (cloud to rain) switched on
   logical           :: my_rainon    = .true.
   namelist /physics_cfgs/ my_rainon
   namelist /physics_cfgs_p/ my_rainon

   !# Sedimentation switched on
   logical           :: my_sedion    = .true.
   namelist /physics_cfgs/ my_sedion
   namelist /physics_cfgs_p/ my_sedion

   !# Snow initiation switched on
   logical           :: my_snowon    = .true.
   namelist /physics_cfgs/ my_snowon
   namelist /physics_cfgs_p/ my_snowon

   !# Parameters for three-component freezing term
   real              :: my_tc3comp(3)= (/-5.,-5.,-5./)
   namelist /physics_cfgs/ my_tc3comp
   namelist /physics_cfgs_p/ my_tc3comp

   !# Warm-phase switched on
   logical           :: my_warmon    = .true.
   namelist /physics_cfgs/ my_warmon
   namelist /physics_cfgs_p/ my_warmon

   !# Physic input blocking along X
   integer           :: ninblocx     = 1
   namelist /physics_cfgs/ ninblocx
   namelist /physics_cfgs_p/ ninblocx

   !# Physic input blocking along Y
   integer           :: ninblocy     = 1
   namelist /physics_cfgs/ ninblocy
   namelist /physics_cfgs_p/ ninblocy

   !# Hines non-orographic GWD scheme is active if .true.
   logical           :: non_oro      = .false.
   namelist /physics_cfgs/ non_oro
   namelist /physics_cfgs_p/ non_oro

   !# Pressure (in Pa) that defines the bottom emission level for gravity waves
   real              :: non_oro_pbot = 61000.0
   namelist /physics_cfgs/ non_oro_pbot
   namelist /physics_cfgs_p/ non_oro_pbot

   !# Number of timesteps for which surface fluxes "FC" and "FV" are
   !# gradually set from 0 to their full value in a "slow start fashion"
   !# at the beginning of a time integration
   integer           :: nsloflux     = 0
   namelist /physics_cfgs/ nsloflux
   namelist /physics_cfgs_p/ nsloflux

   !# Vectoc lenght physics memory space folding for openMP
   integer           :: p_runlgt     = -1
   namelist /physics_cfgs/ p_runlgt
   namelist /physics_cfgs_p/ p_runlgt

   !# Time-averaging of transfer coefficient for momentum to reduce 2-dt 
   !# oscillations in fluxes
   logical           :: pbl_cmu_timeavg = .false.
   namelist /physics_cfgs/ pbl_cmu_timeavg
   namelist /physics_cfgs_p/ pbl_cmu_timeavg
   
   !# Diffuse condensate fields
   logical           :: pbl_diff_condens = .false.
   namelist /physics_cfgs/ pbl_diff_condens
   namelist /physics_cfgs_p/ pbl_diff_condens

   !# Run with a modified closure for the dissipation length scale
   !# * 'NIL  ' : No modified closure for the dissipation length scale
   !# * 'LIM50' : A maximum value of 50m is imposed on dissipation length
   character(len=16) :: pbl_diss     = 'NIL'
   namelist /physics_cfgs/ pbl_diss
   namelist /physics_cfgs_p/ pbl_diss
   character(len=*), parameter :: PBL_DISS_OPT(2) = (/ &
        'LIM50', &
        'NIL  '  &
        /)

   !# Dissipative heating tendencies are computed for the PBL scheme such
   !# that total energy (kinetic + internal) is conserved
   !# * 'NIL       ' : No dissipative heating is computed
   !# * 'LOCAL_K   ' : Local total energy conservation based on diffusion coefficients
   !# * 'LOCAL_TEND' : Local total energy conservation based on wind tendencies
   character(len=16) :: pbl_dissheat = 'NIL'
   namelist /physics_cfgs/ pbl_dissheat
   namelist /physics_cfgs_p/ pbl_dissheat
   character(len=*), parameter :: PBL_DISSHEAT_OPT(3) = (/ &
        'LOCAL_TEND', &
        'LOCAL_K   ', &
        'NIL       '  &
        /)

   !# Conservation corrections for PBL scheme
   !# * 'NIL ' : No conservation correction applied
   !# * 'TEND' : Temperature and moisture tendencies corrected
   character(len=16) :: pbl_conserve = 'NIL'
   namelist /physics_cfgs/ pbl_conserve
   namelist /physics_cfgs_p/ pbl_conserve
   character(len=*), parameter :: PBL_CONSERVE_OPT(2) = (/ &
        'NIL ', &
        'TEND'  &
        /)

   !# Include the turbulent effects of trade wind cumulus clouds
   logical           :: pbl_cucloud  = .true.
   namelist /physics_cfgs/ pbl_cucloud
   namelist /physics_cfgs_p/ pbl_cucloud

   !# Call surface scheme immediately before the PBL
   logical           :: pbl_flux_consistency = .false.
   namelist /physics_cfgs/ pbl_flux_consistency
   namelist /physics_cfgs_p/ pbl_flux_consistency
 
   !# Class of stability functions (stable case) to use in the PBL
   !# * 'DELAGE97  ' : Use functions described by Delage (1997; BLM)
   !# * 'LOUIS79   ' : Use functions described by Louis (1979; BLM)
   !# * 'DERBY97   ' : Use functions described by Derbyshire (1997; Cardignton Tech Note)
   !# * 'BELJAARS99' : Use functions described by Beljaars and Viterbo (1999; Clear and Cloudy Boundary Layers)
   !# * 'BELJAARS91' : Use functions described by Beljaars and Holtslag (1991; JAM)
   !# * 'LOCK07    ' : Use functions described by Lock (2007; Tech Report) employed at UKMO
   character(len=16) :: pbl_func_stab = 'DELAGE97'
   namelist /physics_cfgs/ pbl_func_stab
   namelist /physics_cfgs_p/ pbl_func_stab
   character(len=*), parameter :: PBL_FUNC_STAB_OPT(6) = (/ &
        'DELAGE97  ', &
        'LOUIS79   ', &
        'DERBY97   ', &
        'BELJAARS99', &
        'BELJAARS91', &
        'LOCK07    '  &
        /)

   !# Class of stability functions (unstable case) to use in the PBL
   !# * 'DELAGE92' : Use functions described by Delage and Girard (1992; BLM)
   !# * 'DYER74  ' : Use functions described by Dyer (1974; BLM)
   character(len=16) :: pbl_func_unstab = 'DELAGE92'
   namelist /physics_cfgs/ pbl_func_unstab
   namelist /physics_cfgs_p/ pbl_func_unstab
   character(len=*), parameter :: PBL_FUNC_UNSTAB_OPT(2) = (/ &
        'DELAGE92', &
        'DYER74  '  &
        /)

   !# Choose form of asymptotic mixing length for Blacadar-type estimates
   !# * 'BLAC62' : Asymptotic 200 m proposed by Blackadar (1962; JGR) with clipping
   !# * 'LOCK07' : Diagnosed asymptotic scale of Lock (2007; Tech Report) used at UKMO
   character(len=16) :: pbl_mlblac_max = 'BLAC62'
   namelist /physics_cfgs/ pbl_mlblac_max
   namelist /physics_cfgs_p/ pbl_mlblac_max
   character(len=*), parameter :: PBL_MLBLAC_MAX_OPT(2) = (/ &
        'BLAC62', &
        'LOCK07'  &
        /)

   !# Apply "turboujo" turbulence conditions to dissipation length scale
   logical           :: pbl_mlturb_diss = .false.
   namelist /physics_cfgs/ pbl_mlturb_diss
   namelist /physics_cfgs_p/ pbl_mlturb_diss

   !# Run with legacy moistke clouds (no limits on cloud effects)
   logical           :: pbl_moistke_legacy_cloud = .false.
   namelist /physics_cfgs/ pbl_moistke_legacy_cloud
   namelist /physics_cfgs_p/ pbl_moistke_legacy_cloud

   !# Use the non-local PBL cloud formulation
   !# * 'NIL   ' : no non-local PBL cloud formulation
   !# * 'LOCK06' : Non-local cloud scheme of Lock and Mailhot (2006)
   character(len=16) :: pbl_nonloc   = 'NIL'
   namelist /physics_cfgs/ pbl_nonloc
   namelist /physics_cfgs_p/ pbl_nonloc
   character(len=*), parameter :: PBL_NONLOC_OPT(2) = (/ &
        'NIL   ',  &
        'LOCK06'  &
        /)

   !# Use the mixing length to average the Richardson number profile of (potentially)
   !# many layers to derive a "background" Ri estimate
   logical           :: pbl_ribkg    = .false.
   namelist /physics_cfgs/ pbl_ribkg
   namelist /physics_cfgs_p/ pbl_ribkg

   !# Richardson num. critical values for hysteresis
   real              :: pbl_ricrit(2)= 1.
   namelist /physics_cfgs/ pbl_ricrit
   namelist /physics_cfgs_p/ pbl_ricrit

   !# PBL representation of boundary layer clouds
   !# * 'NIL     ': No Shallow convection
   !# * 'CONRES  ': Bulk Richardson number-based turbulent enhancement
   !# * 'SHALOW  ': Deprecated (see 1998 RPN physics doc)
   !# * 'SHALODQC': Deprecated (see 1998 RPN physics doc)
   !# * 'GELEYN  ': Deprecated (see 1998 RPN physics doc)
   character(len=16) :: pbl_shal     = 'NIL'
   namelist /physics_cfgs/ pbl_shal
   namelist /physics_cfgs_p/ pbl_shal
   character(len=*), parameter :: PBL_SHAL_OPT(5) = (/ &
        'NIL     ', &
        'CONRES  ', &
        'SHALOW  ', &
        'SHALODQC', &
        'GELEYN  '  &
        /)

   !# Layer over which to adjust from SL to PBL stability functions [(bot,top) in m]
   real, dimension(2) :: pbl_slblend_layer = (/-1.,-1./)
   namelist /physics_cfgs/ pbl_slblend_layer
   namelist /physics_cfgs_p/ pbl_slblend_layer

   !# Adjustment to coefficient for TKE diffusion
   real              :: pbl_tkediff  = 1.
   namelist /physics_cfgs/ pbl_tkediff
   namelist /physics_cfgs_p/ pbl_tkediff

   !# Control of time scale for TKE diffusion
   logical           :: pbl_tkediff2dt  = .false.
   namelist /physics_cfgs/ pbl_tkediff2dt
   namelist /physics_cfgs_p/ pbl_tkediff2dt

   !# Depth (Pa) of the always-turbulent near-surface layer in the PBL
   real              :: pbl_turbsl_depth  = 3000.
   namelist /physics_cfgs/ pbl_turbsl_depth
   namelist /physics_cfgs_p/ pbl_turbsl_depth

   !# Relaxation timescale (s) for mixing length smoothing
   real              :: pbl_zntau    = 7200.
   namelist /physics_cfgs/ pbl_zntau
   namelist /physics_cfgs_p/ pbl_zntau

   !# Use true (motionless) surface boundary conditions for TKE diffusion
   logical           :: pbl_zerobc   = .false.
   namelist /physics_cfgs/ pbl_zerobc
   namelist /physics_cfgs_p/ pbl_zerobc

   !# Scheme to determine precipitation type
   !# * 'NIL     ': no call to bourge
   !# * 'BOURGE  ': use Bourgouin algorithm (bourge1) to determine precip. types.
   !# * 'BOURGE3D':
   character(len=16) :: pcptype      = 'NIL'
   namelist /physics_cfgs/ pcptype
   namelist /physics_cfgs_p/ pcptype
   character(len=*), parameter :: PCPTYPE_OPT(3) = (/ &
        'NIL     ', &
        'BOURGE  ', &
        'BOURGE3D'  &
        /)

   !# Print stats for phy_input read var
   logical           :: phystat_input_l = .false.
   namelist /physics_cfgs/ phystat_input_l
   namelist /physics_cfgs_p/ phystat_input_l

   !# Use double presision for physic statistics output
   logical           :: phystat_dble_l = .false.
   namelist /physics_cfgs/ phystat_dble_l
   namelist /physics_cfgs_p/ phystat_dble_l

   !# Physic statistics output for 3d varables:
   !# * .false. : mean, var, min and max for the whole 3d fiels
   !# * .true.  : mean, var, min and max are done for each levels independently
   logical           :: phystat_2d_l = .false.
   namelist /physics_cfgs/ phystat_2d_l
   namelist /physics_cfgs_p/ phystat_2d_l

   !# Physic statistics output Frequency
   character(len=16) :: phystat_freq_S = '0h'
   namelist /physics_cfgs/ phystat_freq_S
   namelist /physics_cfgs_p/ phystat_freq_S

   !# Physic statistics output: bus variable list that should be included in physics
   !# "block" stats. Possible values:
   !# * Long varnames
   !# * Short varnames
   !# * 'ALLVARS=EDPV': all variables from E, D, P, V buses (any combination of the 4 letters);
   character(len=32) :: phystat_list_s(1024) = ' '
   namelist /physics_cfgs/ phystat_list_s
!!$   namelist /physics_cfgs_p/ phystat_list_s

   !# CFC11 bckgrnd atmospheric concentration (PPMV)
   real              :: qcfc11       = -1.
   namelist /physics_cfgs/ qcfc11
   namelist /physics_cfgs_p/ qcfc11
   real, parameter :: QCFC11_DEFAULT = 0.280

   !# CFC12 bckgrnd atmospheric concentration (PPMV)
   real              :: qcfc12       = -1
   namelist /physics_cfgs/ qcfc12
   namelist /physics_cfgs_p/ qcfc12
   real, parameter :: QCFC12_DEFAULT = 0.530


   !# CH4 bckgrnd atmospheric concentration (PPMV)
   real              :: qch4         = -1.
   namelist /physics_cfgs/ qch4
   namelist /physics_cfgs_p/ qch4
   real, parameter :: QCH4_DEFAULT   = 1.783

   !# CO2 bckgrnd atmospheric concentration (PPMV)
   real              :: qco2         = -1.
   namelist /physics_cfgs/ qco2
   namelist /physics_cfgs_p/ qco2
   real, parameter :: QCO2_DEFAULT   = 380.

   !# N2O bckgrnd atmospheric concentration (PPMV)
   real              :: qn2o         = -1.
   namelist /physics_cfgs/ qn2o
   namelist /physics_cfgs_p/ qn2o
   real, parameter :: QN2O_DEFAULT   = 0.3186

   !# Atmospheric path length for solar radiation
   !# * 'RODGERS67' : Formulation used by Li and Barker (2005)
   !# * 'LI06' : Estimate of  Li and Shibata (2006)
   character(len=16) :: rad_atmpath = 'RODGERS67'
   namelist /physics_cfgs/ rad_atmpath
   namelist /physics_cfgs_p/ rad_atmpath
   character(len=*), parameter :: RAD_ATMPATH_OPT(2) = (/ &
        'RODGERS67', &
        'LI06     '  &
        /)

   !# Optical properties of ice cloud from condensation scheme for radiation
   !# * 'CCCMA'      : Radius estimate from CCCMA
   !# * 'SIGMA'      : Altitude-dependent ice radius
   character(len=16) :: rad_cond_rei = '15.'
   real              :: rei_const    = -1.
   namelist /physics_cfgs/ rad_cond_rei
   namelist /physics_cfgs_p/ rad_cond_rei
   character(len=*), parameter :: RAD_COND_REI_OPT(2) = (/ &
        'CCCMA', &
        'SIGMA'  &
        /)

   !# Optical properties of liquid cloud from condensation scheme for radiation
   !# * 'BARKER'     : Radii based on aircraft data (Slingo), range 4-17 microns
   !# * 'NEWRAD'     : The "new" optical properties used in the "newrad" scheme
   !# * 'ROTSTAYN03' : Radii based on Rotstayn and Liu (2003)
   character(len=16) :: rad_cond_rew = 'BARKER'
   real              :: rew_const    = -1.
   namelist /physics_cfgs/ rad_cond_rew
   namelist /physics_cfgs_p/ rad_cond_rew
   character(len=*), parameter :: RAD_COND_REW_OPT(3) = (/ &
        'BARKER    ', &
        'NEWRAD    ', &
        'ROTSTAYN03'  &
        /)

   !# Conservation corrections for radiation scheme
   !# * 'NIL ' : No conservation correction applied
   !# * 'TEND' : Temperature and moisture tendencies corrected
   character(len=16) :: rad_conserve = 'NIL'
   namelist /physics_cfgs/ rad_conserve
   namelist /physics_cfgs_p/ rad_conserve
   character(len=*), parameter :: RAD_CONSERVE_OPT(2) = (/ &
        'NIL ', &
        'TEND'  &
        /)

   !# Use emissivity computed by the surface schemes
   logical           :: rad_esfc     = .false.
   namelist /physics_cfgs/ rad_esfc
   namelist /physics_cfgs_p/ rad_esfc

   !# format of radiation files to be read
   !# * 'STD': RPN standard file
   !# * 'UNF': unformatted
   character(len=16) :: radfiles     = 'STD'
   namelist /physics_cfgs/ radfiles
   namelist /physics_cfgs_p/ radfiles
   character(len=*), parameter :: RADFILES_OPT(2) = (/ &
        'STD', &
        'UNF'  &
        /)

   !# Radiation fixes near the model top(for newrad only) if .true.
   logical           :: radfix       = .true.
   namelist /physics_cfgs/ radfix
   namelist /physics_cfgs_p/ radfix

   !# Vertical smoothing on radiative fluxes(for newrad only) if .true.
   logical           :: radfltr      = .true.
   namelist /physics_cfgs/ radfltr
   namelist /physics_cfgs_p/ radfltr

   !# Use climatological values of GHG in radiation (CCCMARAD2 only)
   logical           :: radghg_L     = .false.
   namelist /physics_cfgs/ radghg_L
   namelist /physics_cfgs_p/ radghg_L

   !# Radiation scheme
   !# * 'NIL      ': no radiation scheme
   !# * 'NEWRAD   ': complete radiation scheme
   !# * 'CCCMARAD ': most advanced radiation scheme
   !# * 'CCCMARAD2': most advanced radiation scheme v2
   character(len=16) :: radia        = 'NIL'
   namelist /physics_cfgs/ radia
   namelist /physics_cfgs_p/ radia
   character(len=*), parameter :: RADIA_OPT(4) = (/ &
        'NIL      ', &
        'NEWRAD   ', &
        'CCCMARAD ', &
        'CCCMARAD2'  &
        /)

   !# List of levels on which IR and VIS radiation calculations are
   !# performed (to save on CPU time) (for newrad only)
   integer           :: radnivl(LEVMAX+1) = 0
   namelist /physics_cfgs/ radnivl

   !# Key for activation of the radiation along slopes
   logical           :: radslope     = .false.
   namelist /physics_cfgs/ radslope
   namelist /physics_cfgs_p/ radslope

   !# Additional output for low level refraction
   logical           :: refract      = .false.
   namelist /physics_cfgs/ refract
   namelist /physics_cfgs_p/ refract

   !# Launching level value of GW RMS wind (m/s) from non-orographic origin
   real              :: rmscon       = 1.0
   namelist /physics_cfgs/ rmscon
   namelist /physics_cfgs_p/ rmscon

   !# water/ice phase for saturation calc. if .true.;
   !# water phase only for saturation calc. if .false.
   logical           :: satuco       = .true.
   namelist /physics_cfgs/ satuco
   namelist /physics_cfgs_p/ satuco

   !# Tuning factor for blocking height
   real              :: sgo_bhfac    = 1.5
   namelist /physics_cfgs/ sgo_bhfac
   namelist /physics_cfgs_p/ sgo_bhfac

   !# Sets the minimum value of the drag coefficient in the orographic
   !# blocking scheme.
   real              :: sgo_cdmin    = 1.0
   namelist /physics_cfgs/ sgo_cdmin
   namelist /physics_cfgs_p/ sgo_cdmin

   !# Turns on/off the non-linear amplification factor (depending on wind
   !# direction) of the drag coefficient in the orographic blocking scheme
   logical           :: sgo_nldirfac = .true.
   namelist /physics_cfgs/ sgo_nldirfac
   namelist /physics_cfgs_p/ sgo_nldirfac

   !# Critical phase for blocking height
   real              :: sgo_phic    = 0.2
   namelist /physics_cfgs/ sgo_phic
   namelist /physics_cfgs_p/ sgo_phic

   !# Turns on/off the amplification factor (due to stability) of the drag
   !# coefficient in the orographic blocking scheme
   logical           :: sgo_stabfac  = .true.
   namelist /physics_cfgs/ sgo_stabfac
   namelist /physics_cfgs_p/ sgo_stabfac

   !# Standard deviation length scale (gridpoints) of Gaussian smoother
   !# applied to wind GWD tendencies
   real           :: sgo_tdfilter    = 1.
   namelist /physics_cfgs/ sgo_tdfilter
   namelist /physics_cfgs_p/ sgo_tdfilter

   !# Description of threshold for mean wind speed for blocking
   real, dimension(2) :: sgo_windfac = (/2.,0.01/)
   namelist /physics_cfgs/ sgo_windfac
   namelist /physics_cfgs_p/ sgo_windfac

   !# (DEPRECATED) Run ISCCP cloud simulator (cccmarad only) if .true.
   !# WARNING: This option is no longuer suppored, will be removed
   logical           :: simisccp     = .false.
   namelist /physics_cfgs/ simisccp
   namelist /physics_cfgs_p/ simisccp

   !# Condensation scheme name
   !# * 'NIL       ' : No explicit condensation scheme used
   !# * 'CONSUN    ' : Sunqvist type condensation scheme
   !# * 'NEWSUND   ' : Sunqvist type condensation scheme
   !# * 'MP_MY2_OLD' : Milbrandtl and Yau microphysics scheme (old formulation)
   !# * 'MP_MY2    ' : Milbrandtl and Yau microphysics scheme
   !# * 'MP_P3     ' : P3 microphysics scheme
   character(len=16) :: stcond       = 'NIL'
   namelist /physics_cfgs/ stcond
   namelist /physics_cfgs_p/ stcond
   character(len=*), parameter :: STCOND_OPT(6) = (/ &
        'NIL       ', &
        'CONSUN    ', &
        'NEWSUND   ', &
        'MP_MY2_OLD', &
        'MP_MY2    ', &
        'MP_P3     '  &
        /)

   !# Special treatment of stratosphere;
   !# if .true. ignore convection/condensation tendencies where pressure is lower
   !# than topc or specific humidity is lower than minq as specified in nocld.cdk
   logical           :: stratos      = .false.
   namelist /physics_cfgs/ stratos
   namelist /physics_cfgs_p/ stratos

   !# Factor used in the gwd formulation = 1/(LENGTH SCALE)
   real              :: taufac       = 8.E-6
   namelist /physics_cfgs/ taufac
   namelist /physics_cfgs_p/ taufac

   !# Run the physics in test harness mode
   logical           :: test_phy     = .false.
   namelist /physics_cfgs/ test_phy
   namelist /physics_cfgs_p/ test_phy

   !# Print runtime timings
   logical           :: timings_L    = .false.
   namelist /physics_cfgs/ timings_L
   namelist /physics_cfgs_p/ timings_L

   !# Select a turbulent orographic form drag scheme
   !# * 'NIL'        : No turbulent orographic form drag scheme
   !# * 'BELJAARS04' : Form drag scheme described by Beljaars et al. (2006; QJRMS)
   !# WARNING: This option is broken thus disabled- will be fixed in dev branch
   character(len=16) :: tofd         = 'NIL'
   namelist /physics_cfgs/ tofd
   namelist /physics_cfgs_p/ tofd
   character(len=*), parameter :: TOFD_OPT(2) = (/ &
        'NIL       ', &
        'BELJAARS04'  &
        /)

   !# (newrad only) Use TT(12000) instead of skin temp in downward IR
   !# flux calculation if .true.
   logical           :: ts_flxir     = .false.
   namelist /physics_cfgs/ ts_flxir
   namelist /physics_cfgs_p/ ts_flxir

contains

   function phy_options_init() result(F_istat)
      implicit none
      integer :: F_istat
#include <rmnlib_basics.hf>
      logical, save :: init_L = .false.
      F_istat = RMN_OK
      if (init_L) return
      init_L = .true.
      indiag_list_s(1) = 'DEFAULT LIST'
      return
   end function phy_options_init

end module phy_options
