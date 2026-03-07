# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles/LUMINA_autogen.dir/AutogenUsed.txt"
  "CMakeFiles/LUMINA_autogen.dir/ParseCache.txt"
  "LUMINA_autogen"
  )
endif()
