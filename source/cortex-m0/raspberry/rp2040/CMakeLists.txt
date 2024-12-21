cmake_minimum_required(VERSION 3.20)

include (../pico-sdk/pico_sdk_init.cmake)
project (picosdk C)

pico_sdk_init()
add_library(picosdk)
target_link_libraries(picosdk PUBLIC hardware_uart)
