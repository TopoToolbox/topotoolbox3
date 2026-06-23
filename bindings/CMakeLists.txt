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

set(TT_MEX_TARGETS
  tt_has_topotoolbox
  tt_fillsinks
  tt_identifyflats
  tt_gwdt_computecosts
  tt_gwdt
  tt_flow_routing_d8_carve
  tt_lowerenv
  tt_hillshade
  tt_hillshade_fused
  tt_graphflood
  tt_gradient8
  tt_excesstopography_fmm2d
  tt_excesstopography_fmm3d
  tt_excesstopography_fsm2d
  tt_streamquad_trapz_f32
  tt_streamquad_trapz_f64
  tt_traverse_down_f32_add_mul
  tt_traverse_down_f64_add_mul
)

foreach(TT_MEX_TARGET IN LISTS TT_MEX_TARGETS)
  matlab_add_mex(
    NAME ${TT_MEX_TARGET}
    MODULE
    SRC ${TT_MEX_TARGET}.c
    R2018a
    LINK_TO topotoolbox Matlab::mex Matlab::mx
    NO_IMPLICIT_LINK_TO_MATLAB_LIBRARIES
  )
  if(APPLE)
    target_link_options(${TT_MEX_TARGET} PRIVATE -ld_classic)
  endif()
endforeach()

install(
  TARGETS ${TT_MEX_TARGETS}
  DESTINATION "."
  COMPONENT Runtime
)
