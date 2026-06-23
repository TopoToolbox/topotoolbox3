cmake_minimum_required(VERSION 3.22)

project(
  mxtopotoolbox
  VERSION 0.0.1
  LANGUAGES C
)

find_package(Matlab)

include(FetchContent)
FetchContent_Declare(
  topotoolbox
  GIT_REPOSITORY https://github.com/TopoToolbox/libtopotoolbox.git
  GIT_TAG 73d67c4deb8b547f6f26f84fe233d5b16a65ac13
)
FetchContent_MakeAvailable(topotoolbox)

matlab_add_mex(
  NAME tt_has_topotoolbox
  MODULE
  SRC tt_has_topotoolbox.c
  R2018a
  LINK_TO topotoolbox Matlab::mex Matlab::mx
  NO_IMPLICIT_LINK_TO_MATLAB_LIBRARIES
)

matlab_add_mex(
  NAME tt_fillsinks
  MODULE
  SRC tt_fillsinks.c
  R2018a
  LINK_TO topotoolbox Matlab::mex Matlab::mx
  NO_IMPLICIT_LINK_TO_MATLAB_LIBRARIES
)

matlab_add_mex(
  NAME tt_identifyflats
  MODULE
  SRC tt_identifyflats.c
  R2018a
  LINK_TO topotoolbox Matlab::mex Matlab::mx
  NO_IMPLICIT_LINK_TO_MATLAB_LIBRARIES
)

matlab_add_mex(
  NAME tt_gwdt_computecosts
  MODULE
  SRC tt_gwdt_computecosts.c
  R2018a
  LINK_TO topotoolbox Matlab::mex Matlab::mx
  NO_IMPLICIT_LINK_TO_MATLAB_LIBRARIES
)

matlab_add_mex(
  NAME tt_gwdt
  MODULE
  SRC tt_gwdt.c
  R2018a
  LINK_TO topotoolbox Matlab::mex Matlab::mx
  NO_IMPLICIT_LINK_TO_MATLAB_LIBRARIES
)

matlab_add_mex(
  NAME tt_flow_routing_d8_carve
  MODULE
  SRC tt_flow_routing_d8_carve.c
  R2018a
  LINK_TO topotoolbox Matlab::mex Matlab::mx
  NO_IMPLICIT_LINK_TO_MATLAB_LIBRARIES
)

matlab_add_mex(
  NAME tt_lowerenv
  MODULE
  SRC tt_lowerenv.c
  R2018a
  LINK_TO topotoolbox Matlab::mex Matlab::mx
  NO_IMPLICIT_LINK_TO_MATLAB_LIBRARIES
)

matlab_add_mex(
  NAME tt_hillshade
  MODULE
  SRC tt_hillshade.c
  R2018a
  LINK_TO topotoolbox Matlab::mex Matlab::mx
  NO_IMPLICIT_LINK_TO_MATLAB_LIBRARIES
)

matlab_add_mex(
  NAME tt_hillshade_fused
  MODULE
  SRC tt_hillshade_fused.c
  R2018a
  LINK_TO topotoolbox Matlab::mex Matlab::mx
  NO_IMPLICIT_LINK_TO_MATLAB_LIBRARIES  
)

matlab_add_mex(
  NAME tt_graphflood
  MODULE
  SRC tt_graphflood.c
  R2018a
  LINK_TO topotoolbox Matlab::mex Matlab::mx
  NO_IMPLICIT_LINK_TO_MATLAB_LIBRARIES  
)

matlab_add_mex(
  NAME tt_gradient8
  MODULE
  SRC tt_gradient8.c
  R2018a
  LINK_TO topotoolbox Matlab::mex Matlab::mx
  NO_IMPLICIT_LINK_TO_MATLAB_LIBRARIES  
)

matlab_add_mex(
  NAME tt_excesstopography_fmm2d
  MODULE
  SRC tt_excesstopography_fmm2d.c
  R2018a
  LINK_TO topotoolbox Matlab::mex Matlab::mx
  NO_IMPLICIT_LINK_TO_MATLAB_LIBRARIES  
)

matlab_add_mex(
  NAME tt_excesstopography_fmm3d
  MODULE
  SRC tt_excesstopography_fmm3d.c
  R2018a
  LINK_TO topotoolbox Matlab::mex Matlab::mx
  NO_IMPLICIT_LINK_TO_MATLAB_LIBRARIES  
)

matlab_add_mex(
  NAME tt_excesstopography_fsm2d
  MODULE
  SRC tt_excesstopography_fsm2d.c
  R2018a
  LINK_TO topotoolbox Matlab::mex Matlab::mx
  NO_IMPLICIT_LINK_TO_MATLAB_LIBRARIES  
)

matlab_add_mex(
  NAME tt_streamquad_trapz_f32
  MODULE
  SRC tt_streamquad_trapz_f32.c
  R2018a
  LINK_TO topotoolbox Matlab::mex Matlab::mx
  NO_IMPLICIT_LINK_TO_MATLAB_LIBRARIES
)

matlab_add_mex(
  NAME tt_streamquad_trapz_f64
  MODULE
  SRC tt_streamquad_trapz_f64.c
  R2018a
  LINK_TO topotoolbox Matlab::mex Matlab::mx
  NO_IMPLICIT_LINK_TO_MATLAB_LIBRARIES
)

matlab_add_mex(
  NAME tt_traverse_down_f32_add_mul
  MODULE
  SRC tt_traverse_down_f32_add_mul.c
  R2018a
  LINK_TO topotoolbox Matlab::mex Matlab::mx
  NO_IMPLICIT_LINK_TO_MATLAB_LIBRARIES
)

matlab_add_mex(
  NAME tt_traverse_down_f64_add_mul
  MODULE
  SRC tt_traverse_down_f64_add_mul.c
  R2018a
  LINK_TO topotoolbox Matlab::mex Matlab::mx
  NO_IMPLICIT_LINK_TO_MATLAB_LIBRARIES
)

install(
  TARGETS tt_has_topotoolbox tt_fillsinks tt_identifyflats
          tt_gwdt_computecosts tt_gwdt tt_flow_routing_d8_carve
          tt_lowerenv tt_hillshade tt_hillshade_fused tt_graphflood
          tt_gradient8
          tt_excesstopography_fsm2d
          tt_excesstopography_fmm3d
          tt_excesstopography_fmm2d
          tt_streamquad_trapz_f32
          tt_streamquad_trapz_f64
	  tt_traverse_down_f32_add_mul
	  tt_traverse_down_f64_add_mul
  DESTINATION "."
  COMPONENT Runtime
)
