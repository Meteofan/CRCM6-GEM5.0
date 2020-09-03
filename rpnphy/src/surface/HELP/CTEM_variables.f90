program abx
      PHYVAR2D1(ailc,         'VN=ailc         ;ON=AILC;VD=lumped LAI for 4 CLASS PFTs                    ;VS=A*'//ncv//'    ;VB=p0')
      PHYVAR2D1(ailcb,        'VN=ailcb        ;ON=AILB;VD=brown LAI                                      ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(ailcg,        'VN=ailcg        ;ON=AILG;VD=green LAI                                      ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(alirctm,      'VN=alirctm      ;ON=ALIC;VD=canopy albedo (near i.r.) from CTEM            ;VS=A*'//ncv//'    ;VB=p0')
      PHYVAR2D1(allwacc,      'VN=allwacc      ;ON=LAAC;VD=longwave albedo acc. for cur. day                                 ;VB=p0')
      PHYVAR2D1(alswacc,      'VN=alswacc      ;ON=SAAC;VD=shortwave albedo acc. for cur. day                                ;VB=p0')
      PHYVAR2D1(alvsctm,      'VN=alvsctm      ;ON=ALIS;VD=canopy albedo (visible) from CTEM              ;VS=A*'//ncv//'    ;VB=p0')
      PHYVAR2D1(ancgvgac,     'VN=ancgvgac     ;ON=PHGA;VD=daily accum. of ancgveg                        ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(ancsvgac,     'VN=ancsvgac     ;ON=PHSA;VD=daily accum. of ancsveg                        ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(anndefct,     'VN=anndefct     ;ON=AWD ;VD=an. water deficit (mm)                                            ;VB=p0')
      PHYVAR2D1(annpcp,       'VN=annpcp       ;ON=APR ;VD=an. prec. (mm)                                                    ;VB=p0')
      PHYVAR2D1(annsrpls,     'VN=annsrpls     ;ON=AWS ;VD=an. water surplus (mm)                                            ;VB=p0')
      PHYVAR2D1(anpcpcur,     'VN=anpcpcur     ;ON=APRY;VD=annual prec. for cur. year (mm)                                   ;VB=p0')
      PHYVAR2D1(anpecur,      'VN=anpecur      ;ON=AEVY;VD=an. pot. evap. for cur. year (mm)                                 ;VB=p0')
      PHYVAR2D1(anpotevp,     'VN=anpotevp     ;ON=AEV ;VD=an. pot. evap. (mm)                                               ;VB=p0')
      PHYVAR2D1(aridity,      'VN=aridity      ;ON=ARI ;VD=aridity index                                                     ;VB=p0')
      PHYVAR2D1(bleafmas,     'VN=bleafmas     ;ON=CBLF;VD=brown leaf mass                                ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(bmasveg,      'VN=bmasveg      ;ON=BMV ;VD=total (gleaf + stem + root) biomass            ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(burnvegf,     'VN=burnvegf     ;ON=BVF ;VD=burned area fraction                           ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(cfluxcg,      'VN=cfluxcg      ;ON=CFCG;VD=aerodynamic conductance over ground                               ;VB=p0')
      PHYVAR2D1(cfluxcs,      'VN=cfluxcs      ;ON=CFCS;VD=aerodynamic conductance over snow                                 ;VB=p0')
      PHYVAR2D1(cmasvegc,     'VN=cmasvegc     ;ON=CMVC;VD=total canopy mass from CTEM                    ;VS=A*'//ncv//'    ;VB=p0')
      PHYVAR2D1(co2conc,      'VN=co2conc      ;ON=CO2C;VD=atmos. CO2 conc.                                                  ;VB=p0')
      PHYVAR2D1(co2i1cg,      'VN=co2i1cg      ;ON=C1G ;VD=intercellular CO2 conc. (ground, sunlit)       ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(co2i1cs,      'VN=co2i1cs      ;ON=C1S ;VD=intercellular CO2 conc. (snow, sunlit)         ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(co2i2cg,      'VN=co2i2cg      ;ON=C2G ;VD=intercellular CO2 conc. (ground, shaded)       ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(co2i2cs,      'VN=co2i2cs      ;ON=C2S ;VD=intercellular CO2 conc. (snow, shaded)         ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(colddayr,     'VN=colddayr     ;ON=CLDD;VD=cold days counter                              ;VS=A*2            ;VB=p0')
      PHYVAR2D1(defctcur,     'VN=defctcur     ;ON=WDM ;VD=water deficit for cur. month                                      ;VB=p0')
      PHYVAR2D1(defctmon,     'VN=defctmon     ;ON=MWD ;VD=nb months with water deficit                                      ;VB=p0')
      PHYVAR2D1(defmnr,       'VN=defmnr       ;ON=MWDY;VD=nb months with water deficit for cur. yr                          ;VB=p0')
      PHYVAR2D1(dftcuryr,     'VN=dftcuryr     ;ON=AWDY;VD=water deficit for cur. year                                       ;VB=p0')
      PHYVAR2D1(dryslen,      'VN=dryslen      ;ON=DSL ;VD=dry season length (months)                                        ;VB=p0')
      PHYVAR2D1(dvdfcan,      'VN=dvdfcan      ;ON=DVDF;VD=CTEM PFT fractions within CLASS PFTs           ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(extnprob,     'VN=extnprob     ;ON=XTP ;VD=fire extinguishing probability                                    ;VB=p0')
      PHYVAR2D1(fcancmx,      'VN=fcancmx      ;ON=FCAN; '//'VD=max. fract. coverage of each CTEM PFT     ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(flhrloss,     'VN=flhrloss     ;ON=FHL ;VD=fall or harvest loss                           ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(flinacc,      'VN=flinacc      ;ON=FIAC;VD=IR downward energy flux acc. for cur. day                         ;VB=p0')
      PHYVAR2D1(flutacc,      'VN=flutacc      ;ON=FTAC;VD=IR upward energy flux acc. for cur. day                           ;VB=p0')
      PHYVAR2D1(fsinacc,      'VN=fsinacc      ;ON=FBAC;VD=VIS downward flux acc. for the day                                ;VB=p0')
      PHYVAR2D1(fsnowacc,     'VN=fsnowacc     ;ON=FSNA;VD=daily accum. snow fraction                                        ;VB=p0')
      PHYVAR2D1(gavglai,      'VN=gavglai      ;ON=GLAI;VD=grid averaged green LAI                                           ;VB=p0')
      PHYVAR2D1(gavgltms,     'VN=gavgltms     ;ON=GLF ;VD=grid averaged litter mass                                         ;VB=p0')
      PHYVAR2D1(gavgscms,     'VN=gavgscms     ;ON=GSTM;VD=grid averaged soil carbon mass                                    ;VB=p0')
      PHYVAR2D1(gdd5,         'VN=gdd5         ;ON=GD5 ;VD=growing degree days over 5c                                       ;VB=p0')
      PHYVAR2D1(gdd5cur,      'VN=gdd5cur      ;ON=GD5Y;VD=growing degree days over 5c for cur. yr                           ;VB=p0')
      PHYVAR2D1(geremort,     'VN=geremort     ;ON=GMRT;VD=growth related mortality (1/day)               ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(gleafmas,     'VN=gleafmas     ;ON=CGLF;VD=green leaf mass                                ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(grwtheff,     'VN=grwtheff     ;ON=GREF;VD=growth efficiency                              ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(intrmort,     'VN=intrmort     ;ON=IMRT;VD=intrinsic (age related) mortality (1/day)      ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(lambda,       'VN=lambda       ;ON=LMBD;VD=npp fraction used for spatial expansion        ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(lfstatur,     'VN=lfstatur     ;ON=HLST;VD=leaf phenology status                          ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(litrmass,     'VN=litrmass     ;ON=CLTR;VD=litter mass                                    ;VS=A*'//niccp//'  ;VB=p0')
      PHYVAR2D1(lyrotmas,     'VN=lyrotmas     ;ON=LYRM;VD=root mass at the end of last year              ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(lystmmas,     'VN=lystmmas     ;ON=LYSM;VD=stem mass at the end of last year              ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(mlightng,     'VN=mlightng     ;ON=MLNT;VD=mean monthly lightning frequency               ;VS=A*12           ;VB=p0')
      PHYVAR2D1(nfcancmx,     'VN=nfcancmx     ;ON=NY2C;VD=fcancmx for next year                          ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(nppveg,       'VN=nppveg       ;ON=NPPV;VD=net primary productivity                       ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(paic,         'VN=paic         ;ON=PAIC;VD=PAI for CLASS PFTs                             ;VS=A*'//ncv//'    ;VB=p0')
      PHYVAR2D1(pandayr,      'VN=pandayr      ;ON=HPAD;VD=days with positive net photosynthesis          ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(pfcancmx,     'VN=pfcancmx     ;ON=PY2C;VD=fcancmx from previous year                     ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(pftexistr,    'VN=pftexistr    ;ON=PFTE;VD=array indic. pfts exist (1) or not (-1)        ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(pgleafmass,   'VN=pgleafmass   ;ON=PGLM;VD=root mass (?) from prev. step                  ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(prbfrhuc,     'VN=prbfrhuc     ;ON=PFHC;VD=prob. of fire due to human causes                                 ;VB=p0')
      PHYVAR2D1(preacc,       'VN=preacc       ;ON=PRAC;VD=accum. of precip. for the day                                     ;VB=p0')
      PHYVAR2D1(pstemmass,    'VN=pstemmass    ;ON=PSTM;VD=stem mass from prev. step                      ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(rmatc,        'VN=rmatc        ;ON=RMA ;VD=layer root fraction (CLASS PFTs)               ;VS=A*'//ncvxcg//' ;VB=p0')
      PHYVAR2D1(rmatctem,     'VN=rmatctem     ;ON=RMAC;VD=layer root fraction (CTEM PFTs)                ;VS=A*'//niccxcg//';VB=p0')
      PHYVAR2D1(rmlcgvga,     'VN=rmlcgvga     ;ON=LRGA;VD=daily accum. of rmlcgveg                       ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(rmlcsvga,     'VN=rmlcsvga     ;ON=LRSA;VD=daily accum. of rmlcsveg                       ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(rootdpth,     'VN=rootdpth     ;ON=RTDP;VD=rooting depth                                  ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(rootmass,     'VN=rootmass     ;ON=CROT;VD=root mass                                      ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(rothrlos,     'VN=rothrlos     ;ON=RHL ;VD=root loss due to harvest                       ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(slai,         'VN=slai         ;ON=SLAI;VD=imaginary LAI for phenology purposes           ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(slaic,        'VN=slaic        ;ON=SLC ;VD=storage LAI for use within CLASS               ;VS=A*'//ncv//'    ;VB=p0')
      PHYVAR2D1(soilcmas,     'VN=soilcmas     ;ON=CSOC;VD=soil carbon mass                               ;VS=A*'//niccp//'  ;VB=p0')
      PHYVAR2D1(srpcuryr,     'VN=srpcuryr     ;ON=AWSY;VD=water surplus for cur. yr                                         ;VB=p0')
      PHYVAR2D1(srplscur,     'VN=srplscur     ;ON=WSM ;VD=water surplus for cur. month                                      ;VB=p0')
      PHYVAR2D1(srplsmon,     'VN=srplsmon     ;ON=MWS ;VD=nb months with water surplus                                      ;VB=p0')
      PHYVAR2D1(stemmass,     'VN=stemmass     ;ON=CSTM;VD=stem mass                                      ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(stmhrlos,     'VN=stmhrlos     ;ON=SHL ;VD=stem loss due to harvest                       ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(surmnr,       'VN=surmnr       ;ON=MWSY;VD=nb months with water surplus for cur. yr                          ;VB=p0')
      PHYVAR2D1(taaccgat,     'VN=taaccgat     ;ON=TAAC;VD=daily accum. of air temperature                                   ;VB=p0')
      PHYVAR2D1(tbaraccgat,   'VN=tbaraccgat   ;ON=TBAC;VD=daily accum. of soil temperature               ;VS=A*'//ncg//'    ;VB=p0')
      PHYVAR2D1(tbarcacc,     'VN=tbarcacc     ;ON=TCA ;VD=soil temp. acc. (canopy over ground)           ;VS=A*'//ncg//'    ;VB=p0')
      PHYVAR2D1(tbarcsacc,    'VN=tbarcsacc    ;ON=TCSA;VD=soil temp. acc. (canopy over snow)             ;VS=A*'//ncg//'    ;VB=p0')
      PHYVAR2D1(tbargacc,     'VN=tbargacc     ;ON=TGA ;VD=soil temp. acc. (bare ground)                  ;VS=A*'//ncg//'    ;VB=p0')
      PHYVAR2D1(tbargsacc,    'VN=tbargsacc    ;ON=TGSA;VD=soil temp. acc. (snow over ground)             ;VS=A*'//ncg//'    ;VB=p0')
      PHYVAR2D1(tcanoaccgat,  'VN=tcanoaccgat  ;ON=TCOA;VD=canopy temp. acc. over ground                                     ;VB=p0')
      PHYVAR2D1(tcansacc,     'VN=tcansacc     ;ON=TSA ;VD=canopy temp. acc. over snow                                       ;VB=p0')
      PHYVAR2D1(tcoldm,       'VN=tcoldm       ;ON=CMT ;VD=temperature of coldest month (c)                                  ;VB=p0')
      PHYVAR2D1(tcurm,        'VN=tcurm        ;ON=TCM ;VD=temperature of current month (c)                                  ;VB=p0')
      PHYVAR2D1(thicecacc,    'VN=thicecacc    ;ON=THIA;VD=daily acc. canopy frozen water                 ;VS=A*'//ncg//'    ;VB=p0')
      PHYVAR2D1(thliqcacc,    'VN=thliqcacc    ;ON=TLCA;VD=daily acc. canopy liquid water                 ;VS=A*'//ncg//'    ;VB=p0')
      PHYVAR2D1(thliqgacc,    'VN=thliqgacc    ;ON=TLGA;VD=daily acc. liquid water on ground              ;VS=A*'//ncg//'    ;VB=p0')
      PHYVAR2D1(tmonthb,      'VN=tmonthb      ;ON=T12 ;VD=monthly temperatures (c)                       ;VS=A*12           ;VB=p0')
      PHYVAR2D1(tmonthb,      'VN=tmonthb      ;ON=T12 ;VD=monthly temperatures (c)                       ;VS=A*12           ;VB=p0')
      PHYVAR2D1(todfrac,      'VN=todfrac      ;ON=TODF;VD=max coverage of CTEM PFTs at end of day        ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(twarmm,       'VN=twarmm       ;ON=WMT ;VD=temperature of warmest month (c)                                  ;VB=p0')
      PHYVAR2D1(tymaxlai,     'VN=tymaxlai     ;ON=TYML;VD=max LAI for this year)                         ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(uvaccgat,     'VN=uvaccgat     ;ON=UVAC;VD=daily acc. U wind speed                                           ;VB=p0')
      PHYVAR2D1(veghght,      'VN=veghght      ;ON=VGHG;VD=vegetation height                              ;VS=A*'//nicc//'   ;VB=p0')
      PHYVAR2D1(vgbiomas,     'VN=vgbiomas     ;ON=VGBM;VD=grid averaged vegetation biomass                                  ;VB=p0')
      PHYVAR2D1(vvaccgat,     'VN=vvaccgat     ;ON=VVAC;VD=daily acc. V wind speed                                           ;VB=p0')
      PHYVAR2D1(wdmindex,     'VN=wdmindex     ;ON=WDI ;VD=array indic. wet (1) or dry (-1) month         ;VS=A*12           ;VB=p0')
      PHYVAR2D1(zolnc,        'VN=zolnc        ;ON=Z0C ;VD=roughness length for CLASS PFTs                ;VS=A*'//ncv//'    ;VB=p0')
      PHYVAR2D1(afrleaf,      'VN=afrleaf      ;ON=AFRL;VD=leaf allocation fraction                       ;VS=A*'//nicc//'   ;VB=v0')
      PHYVAR2D1(afrroot,      'VN=afrroot      ;ON=AFRR;VD=root allocation fraction                       ;VS=A*'//nicc//'   ;VB=v0')
      PHYVAR2D1(afrstem,      'VN=afrstem      ;ON=AFRS;VD=stem allocation fraction                       ;VS=A*'//nicc//'   ;VB=v0')
      PHYVAR2D1(autores,      'VN=autores      ;ON=AUTR;VD=grid avg. autotrophic resp.                                       ;VB=v0')
      PHYVAR2D1(autresveg,    'VN=autresveg    ;ON=ATRV;VD=autotrophic respiration                        ;VS=A*'//nicc//'   ;VB=v0')
      PHYVAR2D1(burnarea,     'VN=burnarea     ;ON=BURN;VD=burned area                                                       ;VB=v0')
      PHYVAR2D1(colrate,      'VN=colrate      ;ON=COL ;VD=colonisation rate (1/day)                      ;VS=A*'//nicc//'   ;VB=v0')
      PHYVAR2D1(dstcemls,     'VN=dstcemls     ;ON=DST ;VD=co2 emission losses from veg. disturbance                         ;VB=v0')
      PHYVAR2D1(dstcemls3,    'VN=dstcemls3    ;ON=DST3;VD=co2 emission losses from litter pool dist.                        ;VB=v0')
      PHYVAR2D1(gpp,          'VN=gpp          ;ON=GPP ;VD=grid avg. gross primary productivity                              ;VB=v0')
      PHYVAR2D1(gppveg,       'VN=gppveg       ;ON=GPPV;VD=gross primary productivity                     ;VS=A*'//nicc//'   ;VB=v0')
      PHYVAR2D1(grclarea,     'VN=grclarea     ;ON=GRCL;VD=grid cell area                                                    ;VB=v0')
      PHYVAR2D1(hetresveg,    'VN=hetresveg    ;ON=HTRV;VD=heterotrophic respiration                      ;VS=A*'//niccp//'  ;VB=v0')
      PHYVAR2D1(hetrores,     'VN=hetrores     ;ON=HTRR;VD=grid avg. heterotrophic resp.                                     ;VB=v0')
      PHYVAR2D1(humiftrs,     'VN=humiftrs     ;ON=HUMF;VD=humidified litter transfer to soil C pool                         ;VB=v0')
      PHYVAR2D1(leaflitr,     'VN=leaflitr     ;ON=LLIT;VD=leaf litter fall not caused by fire or mort.   ;VS=A*'//nicc//'   ;VB=v0')
      PHYVAR2D1(litrfall,     'VN=litrfall     ;ON=LITF;VD=total litter fall                                                 ;VB=v0')
      PHYVAR2D1(litres,       'VN=litres       ;ON=LITR;VD=grid avg. litter respiration                                      ;VB=v0')
      PHYVAR2D1(litresveg,    'VN=litresveg    ;ON=LTRV;VD=litter respiration                             ;VS=A*'//niccp//'  ;VB=v0')
      PHYVAR2D1(lucemcom,     'VN=lucemcom     ;ON=LUCE;VD=land use change combustion emission losses                        ;VB=v0')
      PHYVAR2D1(lucltrin,     'VN=lucltrin     ;ON=LUCL;VD=land use change litter pool inputs                                ;VB=v0')
      PHYVAR2D1(lucsocin,     'VN=lucsocin     ;ON=LUCS;VD=land use change soil C pool inputs                                ;VB=v0')
      PHYVAR2D1(ltstatus,     'VN=ltstatus     ;ON=LTST;VD=light status                                   ;VS=A*'//nicc//'   ;VB=v0')
      PHYVAR2D1(mortrate,     'VN=mortrate     ;ON=MORT;VD=mortality rate (1/day)                         ;VS=A*'//nicc//'   ;VB=v0')
      PHYVAR2D1(nbp,          'VN=nbp          ;ON=NBP ;VD=grid averaged net biome productivity                              ;VB=v0')
      PHYVAR2D1(nbpveg,       'VN=nbpveg       ;ON=NBPV;VD=net biome productivity                         ;VS=A*'//niccp//'  ;VB=v0')
      PHYVAR2D1(nep,          'VN=nep          ;ON=NEP ;VD=grid averaged net ecosystem productivity                          ;VB=v0')
      PHYVAR2D1(nepveg,       'VN=nepveg       ;ON=NEPV;VD=net ecosystem productivity                     ;VS=A*'//niccp//'  ;VB=v0')
      PHYVAR2D1(npp,          'VN=npp          ;ON=NPP ;VD=grid averaved net primary productivity                            ;VB=v0')
      PHYVAR2D1(probfire,     'VN=probfire     ;ON=PRBF;VD=probability of fire                                               ;VB=v0')
      PHYVAR2D1(rg,           'VN=rg           ;ON=RGC ;VD=grid averaged growth respiration                                  ;VB=v0')
      PHYVAR2D1(rgveg,        'VN=rgveg        ;ON=RGCV;VD=growth respiration                             ;VS=A*'//nicc//'   ;VB=v0')
      PHYVAR2D1(rm,           'VN=rm           ;ON=RMC ;VD=maintenance respiration                                           ;VB=v0')
      PHYVAR2D1(rml,          'VN=rml          ;ON=RML ;VD=grid avg. leaf maintenance resp.                                  ;VB=v0')
      PHYVAR2D1(rmlvegacc,    'VN=rmlvegacc    ;ON=RMLA;VD=leaf maintenance respiration                   ;VS=A*'//nicc//'   ;VB=v0')
      PHYVAR2D1(rmr,          'VN=rmr          ;ON=RMR ;VD=grid avg. root maintenance resp.                                  ;VB=v0')
      PHYVAR2D1(rmrveg,       'VN=rmrveg       ;ON=RMRV;VD=root maintenance resp.                         ;VS=A*'//nicc//'   ;VB=v0')
      PHYVAR2D1(rms,          'VN=rms          ;ON=RMS ;VD=grid avg. stem maintenance resp.                                  ;VB=v0')
      PHYVAR2D1(rmsveg,       'VN=rmsveg       ;ON=RMSV;VD=stem maintenance resp.                         ;VS=A*'//nicc//'   ;VB=v0')
      PHYVAR2D1(roottemp,     'VN=roottemp     ;ON=RTC ;VD=root temperature                               ;VS=A*'//nicc//'   ;VB=v0')
      PHYVAR2D1(socres,       'VN=socres       ;ON=SOCR;VD=grid avg. soil carbon resp.                                       ;VB=v0')
      PHYVAR2D1(socresveg,    'VN=socresveg    ;ON=SCRV;VD=soil carbon respiration                        ;VS=A*'//niccp//'  ;VB=v0')
      PHYVAR2D1(soilresp,     'VN=soilresp     ;ON=SOLR;VD=soil respiration                                                  ;VB=v0')
      PHYVAR2D1(tltrleaf,     'VN=tltrleaf     ;ON=TLTL;VD=leaf litter fall                               ;VS=A*'//nicc//'   ;VB=v0')
      PHYVAR2D1(tltrroot,     'VN=tltrroot     ;ON=TLTR;VD=root litter fall                               ;VS=A*'//nicc//'   ;VB=v0')
      PHYVAR2D1(tltrstem,     'VN=tltrstem     ;ON=TLTS;VD=stem litter fall                               ;VS=A*'//nicc//'   ;VB=v0')
      PHYVAR2D1(vgbiomas_veg, 'VN=vgbiomas_veg ;ON=VGBG;VD=vegetation biomass                             ;VS=A*'//nicc//'   ;VB=v0')
      PHYVAR2D1(wtstatus,     'VN=wtstatus     ;ON=WTST;VD=soil water status                              ;VS=A*'//nicc//'   ;VB=v0')