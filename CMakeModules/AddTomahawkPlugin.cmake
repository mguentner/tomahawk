MACRO(PARSE_ARGUMENTS prefix arg_names option_names)
  SET(DEFAULT_ARGS)
  FOREACH(arg_name ${arg_names})
    SET(${prefix}_${arg_name})
  ENDFOREACH(arg_name)
  FOREACH(option ${option_names})
    SET(${prefix}_${option} FALSE)
  ENDFOREACH(option)

  SET(current_arg_name DEFAULT_ARGS)
  SET(current_arg_list)
  FOREACH(arg ${ARGN})
    SET(larg_names ${arg_names})
    LIST(FIND larg_names "${arg}" is_arg_name)
    IF (is_arg_name GREATER -1)
      SET(${prefix}_${current_arg_name} ${current_arg_list})
      SET(current_arg_name ${arg})
      SET(current_arg_list)
    ELSE (is_arg_name GREATER -1)
      SET(loption_names ${option_names})
      LIST(FIND loption_names "${arg}" is_option)
      IF (is_option GREATER -1)
         SET(${prefix}_${arg} TRUE)
      ELSE (is_option GREATER -1)
         SET(current_arg_list ${current_arg_list} ${arg})
      ENDIF (is_option GREATER -1)
    ENDIF (is_arg_name GREATER -1)
  ENDFOREACH(arg)
  SET(${prefix}_${current_arg_name} ${current_arg_list})
ENDMACRO(PARSE_ARGUMENTS)

MACRO(CAR var)
  SET(${var} ${ARGV1})
ENDMACRO(CAR)

MACRO(CDR var junk)
  SET(${var} ${ARGN})
ENDMACRO(CDR)


macro(add_tomahawk_plugin)
    parse_arguments(PLUGIN
        "SOURCES;UI;LINK_LIBRARIES;TYPE;EXPORT_MACRO;COMPILE_DEFINITIONS"
        "NO_INSTALL"
        ${ARGN}
        )
    car(PLUGIN_NAME ${PLUGIN_DEFAULT_ARGS})

#     message("*** Arguments for ${PLUGIN_NAME}")
#     message("Sources: ${PLUGIN_SOURCES}")
#     message("Link libraries: ${PLUGIN_LINK_LIBRARIES}")
#     message("UI: ${PLUGIN_UI}")
#     message("TYPE: ${PLUGIN_TYPE}")
#     message("EXPORT_MACRO: ${PLUGIN_EXPORT_MACRO}")

    # create target name once for convenience
    set(target "tomahawk_${PLUGIN_TYPE}_${PLUGIN_NAME}")

    # qt stuff
    include_directories(${CMAKE_CURRENT_BINARY_DIR})
    if(PLUGIN_UI)
        qt4_wrap_ui(PLUGIN_UI_SOURCES ${PLUGIN_UI})
        list(APPEND PLUGIN_SOURCES ${PLUGIN_UI_SOURCES})
    endif()

    if(EXISTS "resources.qrc")
        qt4_add_resources(PLUGIN_RC_SOURCES "resources.qrc")
        list(APPEND PLUGIN_SOURCES ${PLUGIN_RC_SOURCES})
        unset(PLUGIN_RC_SOURCES)
    endif()

    # add target
    add_library(${target} MODULE ${PLUGIN_SOURCES})

    # definitions - can this be moved into set_target_properties below?
    add_definitions(${QT_DEFINITIONS})
    set_target_properties(${target} PROPERTIES AUTOMOC TRUE COMPILE_DEFINITIONS ${PLUGIN_EXPORT_MACRO})
    if(PLUGIN_COMPILE_DEFINITIONS)
        set_target_properties(${target} PROPERTIES COMPILE_DEFINITIONS ${PLUGIN_COMPILE_DEFINITIONS})
    endif()

    # add link targets
    target_link_libraries(${TOMAHAWK_LIBRARIES})
    if(PLUGIN_LINK_LIBRARIES)
        target_link_libraries(${target} ${PLUGIN_LINK_LIBRARIES})
    endif()

    # make installation optional, maybe useful for dummy plugins one day
    if(NOT PLUGIN_NO_INSTALL)
        include(GNUInstallDirs)
        install(TARGETS ${target} DESTINATION ${CMAKE_INSTALL_LIBDIR})
    endif()
endmacro()
