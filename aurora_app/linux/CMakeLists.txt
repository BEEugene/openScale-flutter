cmake_minimum_required(VERSION 3.13)
project(aurora_app LANGUAGES CXX)

set(BINARY_NAME "aurora_app")

# Define application sources
set(APPLICATION_SOURCES
  "my_application.cc"
  "flutter/generated_plugin_registrant.cc"
)

# Executable
add_executable(${BINARY_NAME} ${APPLICATION_SOURCES})

# Apply basic build settings
apply_standard_settings(${BINARY_NAME})

# Add Flutter engine dependency
target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK)

# Include generated plugins
include(flutter/generated_plugins.cmake)

# Install target
install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}")

# Install desktop entry
install(
  FILES "aurora_app.desktop"
  DESTINATION "${CMAKE_INSTALL_PREFIX}/../share/applications"
)

# Bundle dependencies
foreach(plugin ${FLUTTER_PLUGIN_LIST})
  target_link_libraries(${BINARY_NAME} PRIVATE ${plugin}_plugin)
  list(APPEND PLUGIN_BUNDLED_LIBRARIES $<TARGET_FILE:${plugin}_plugin>)
  list(APPEND PLUGIN_BUNDLED_LIBRARIES ${${plugin}_bundled_libraries})
endforeach(plugin)

foreach(ffi_plugin ${FLUTTER_FFI_PLUGIN_LIST})
  list(APPEND PLUGIN_BUNDLED_LIBRARIES ${${ffi_plugin}_bundled_libraries})
endforeach(ffi_plugin)

# Copy bundled libraries on install
install(FILES ${PLUGIN_BUNDLED_LIBRARIES} DESTINATION "${CMAKE_INSTALL_PREFIX}")

# Fully static build for Aurora OS
target_link_libraries(${BINARY_NAME} PRIVATE "-static" "-static-libgcc" "-static-libstdc++")
