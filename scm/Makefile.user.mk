ifneq (,$(DEBUGMAKE))
$(info ## ====================================================================)
$(info ## File: $$scm/Makefile.user.mk)
$(info ## )
endif
#VERBOSE=1

#LIBGMM = 

export ATM_MODEL_ISOFFICIAL := true
export BUILDNAME = 
RBUILD_EXTRA_OBJ0 := 

COMPONENTS        := scm
COMPONENTS_UC     := $(foreach item,$(COMPONENTS),$(call rdeuc,$(item)))
COMPONENTS_VFILES := $(foreach item,$(COMPONENTS_UC),$($(item)_VFILES))

# SRCPATH_INCLUDE := $(CONST_SRCPATH_INCLUDE) $(CONST_SRCPATH)
# VPATH           := $(CONST_VPATH) #$(ROOT)/$(CONST_BUILDSRC)

#------------------------------------

MYSSMINCLUDEMK0 = $(foreach item,$(COMPONENTS),$($(item))/include/Makefile.ssm.mk)
MYSSMINCLUDEMK = $(wildcard $(RDE_INCLUDE0)/Makefile.ssm.mk $(MYSSMINCLUDEMK0))
ifneq (,$(MYSSMINCLUDEMK))
   ifneq (,$(DEBUGMAKE))
      $(info include $(MYSSMINCLUDEMK))
   endif
   include $(MYSSMINCLUDEMK)
endif

#------------------------------------
ifeq (-d,$(RDE_BUILDDIR_SFX))
COMP_RULES_FILE = $(MODELUTILS_COMP_RULES_DEBUG)
#ifeq (intel13sp1u2,$(CONST_RDE_COMP_ARCH))
#FFLAGS  = -C -ftrapuv #-warn all -warn nounused
#FFLAGS  = -g -traceback -ftrapuv -C #-warn all
#else
#FFLAGS  = -g -C -qflttrap=ov:zerodivide:enable:invalid -qinitauto=FF
#endif
endif
ifneq (,$(filter intel%,$(COMP_ARCH))$(filter PrgEnv-intel%,$(COMP_ARCH)))
   FFLAGS  = -C -g -traceback -ftrapuv #-warn all -warn nointerfaces
   CFLAGS  = -C -g -traceback -ftrapuv #-fp-model precise -Wall
else
   FFLAGS  = -C -g -traceback
   CFLAGS  = -C -g -traceback
endif

.PHONY: components_vfiles
components_vfiles: $(COMPONENTS_VFILES)


COMPONENTS_OBJECTS = $(foreach item,$(COMPONENTS),$(OBJECTS_$(item)))
.PHONY: components_objects
components_objects: $(COMPONENTS_VFILES) $(COMPONENTS_OBJECTS)


COMPONENTS_LIBS_FILES = $(foreach item,$(COMPONENTS_UC),$($(item)_LIBS_ALL_FILES_PLUS))
.PHONY: components_libs
components_libs: $(COMPONENTS_VFILES) $(COMPONENTS_OBJECTS) $(COMPONENTS_LIBS_FILES)
	ls -l $(COMPONENTS_LIBS_FILES)
	ls -lL $(COMPONENTS_LIBS_FILES)


COMPONENTS_ABS  := $(foreach item,$(COMPONENTS_UC),$($(item)_ABS))
COMPONENTS_ABS_FILES  := $(foreach item,$(COMPONENTS_UC),$($(item)_ABS_FILES))
.PHONY: components_abs components_abs_check
components_abs: $(COMPONENTS_ABS)
	ls -l $(COMPONENTS_ABS_FILES)


COMPONENTS_SSM_ALL  := $(foreach item,$(COMPONENTS_UC),$($(item)_SSMALL_FILES))
COMPONENTS_SSM_ARCH := $(foreach item,$(COMPONENTS_UC),$($(item)_SSMARCH_FILES))
COMPONENTS_SSM := $(COMPONENTS_SSM_ALL) $(COMPONENTS_SSM_ARCH)
.PHONY: components_ssm
components_ssm: $(COMPONENTS_SSM)
components_ssm_all: $(COMPONENTS_SSM_ALL)
components_ssm_arch: $(COMPONENTS_SSM_ARCH)


COMPONENTS_INSTALL_ALL := $(foreach item,$(COMPONENTS_UC),$($(item)_INSTALL))
COMPONENTS_UNINSTALL_ALL := $(foreach item,$(COMPONENTS_UC),$($(item)_UNINSTALL))
$(info COMPONENTS_INSTALL_ALL=$(COMPONENTS_INSTALL_ALL))
.PHONY: components_install components_uninstall
components_install: $(COMPONENTS_INSTALL_ALL)
components_uninstall: $(COMPONENTS_UNINSTALL_ALL)

ifneq (,$(DEBUGMAKE))
$(info ## ==== $$scm/Makefile.user.mk [END] ========================================)
endif
